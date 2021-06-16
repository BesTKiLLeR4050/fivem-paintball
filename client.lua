--[[--

	Author: ! In The Name Of God !#4934
	Our Discord Servers: https://discord.gg/8u2GV2CBmh - https://discord.gg/zyCBQP5uS6	
	
--]]--

local Keys = 
{
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX, Config = nil, {}
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(8)
    end
	Config.Weapons = ESX.GetWeaponList()
end)

local isNearPB, isNearMarker = false, false
local isLBOpen = false
local isDead = false

local PBData = 
{
	LobbyId = -1,
	InPB = false,
	TeamID = 0,
	Teammates = {},
	MouseScroll = 0,
	CurrentRound = -1,
	MaxRounds = 0
}

RegisterNUICallback('CreateLobby', function(data, cb)
	if not isNearPB then return end
	ESX.TriggerServerCallback('esx_paintball:CreateLobby', function(LobbyID)
		PBData.LobbyId = tonumber(LobbyID)
		cb(LobbyID)
	end, data)
end)

RegisterNUICallback('QuitFromMenu', function(data, cb)
	OpenLobbyMenu(false)
end)

RegisterNUICallback('LobbyList', function(data, cb)
	if not isNearPB then return end
	ESX.TriggerServerCallback('esx_paintball:GetLobbyList', function(Lobbies)
		cb(Lobbies)
	end, data)
end)

RegisterNUICallback('JoinLobby', function(data, cb)
	if not isNearPB then return end
	PBData.LobbyId = tonumber(data.LobbyId)
	ESX.TriggerServerCallback('esx_paintball:JoinLobby', function(Teams)
		cb(Teams)
	end, data)
end)

RegisterNUICallback('QuitLobby', function(data, cb)
	if not isNearPB then return end
	OpenLobbyMenu(false)
	ESX.TriggerServerCallback('esx_paintball:QuitLobby', function(newData)
		cb(newData)
	end, data)
end)

RegisterNUICallback('GetLobbyPassword', function(data, cb)
	if not isNearPB then return end
	ESX.TriggerServerCallback('esx_paintball:GetLobbyPassword', function(isCorrect)
		cb(isCorrect)
	end, data)	
end)

RegisterNUICallback('SwitchTeam', function(data, cb)
	if not isNearPB then return end
	ESX.TriggerServerCallback('esx_paintball:SwitchTeam', function(newData)
		cb(newData)
	end, data)	
end)

RegisterNUICallback('StartMatch', function(data, cb)
	if not isNearPB then return end
	ESX.TriggerServerCallback('esx_paintball:StartMatch', function(newData)
		cb(newData)
	end, data)	
end)

RegisterNUICallback('ToggleReadyPlayer', function(data, cb)
	if not isNearPB then return end
	ESX.TriggerServerCallback('esx_paintball:ToggleReadyPlayer', function(newData)
		cb(newData)
	end, data)	
end)

Citizen.CreateThread(function()
	TriggerEvent('chat:removeSuggestion', '/pbmenu')
	TriggerEvent('chat:removeSuggestion', '/pbmsu')
	TriggerEvent('chat:removeSuggestion', '/pbmsd')
	TriggerEvent('chat:removeSuggestion', '/quitpb')
	while true do
		Citizen.Wait(1000)
		local playerPed = PlayerPedId()
		local myCoords = GetEntityCoords(playerPed)
		isNearPB = (GetDistanceBetweenCoords(myCoords, PBMarker.Pos) <= PBMarker.DrawDistance)
		local tempMarkerVal = isNearMarker
		isNearMarker = IsNearPB()
		if tempMarkerVal ~= isNearMarker then
			TriggerEvent('esx_paintball:isNearMarker', isNearMarker)
		end
	end
end)

RegisterKeyMapping('pbmenu', 'PaintBall Lobby Menu', 'keyboard', 'e')
RegisterCommand("pbmenu", function()
	if isNearMarker then
		if IsEntityDead(PlayerPedId()) then
			ESX.ShowNotification('~r~Shoma zende nistid!')
			return
		end
		OpenLobbyMenu(true)
	end	
end)

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(PBMarker.Pos.x, PBMarker.Pos.y, PBMarker.Pos.z)
	SetBlipSprite(blip, 437)
	SetBlipColour(blip, 36)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("PaintBall")
	EndTextCommandSetBlipName(blip)
	
	while true do
		Citizen.Wait(5)
		if isNearPB then
			if isNearMarker and not isLBOpen then
				SetTextComponentFormat('STRING')
				AddTextComponentString('Press ~INPUT_CONTEXT~ To Open Lobby Menu')
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)		
			end
			DrawMarker(PBMarker.Type, PBMarker.Pos.x, PBMarker.Pos.y, PBMarker.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, PBMarker.Size.x, PBMarker.Size.y, PBMarker.Size.z, PBMarker.Color.r, PBMarker.Color.g, PBMarker.Color.b, 100, false, true, 2, false, false, false, false)			
		elseif PBData.InPB then
			if MapData[PBData.MapName]["area"] then
				local AreaData = MapData[PBData.MapName]["area"]
				DrawMarker(PBMarker.Type, AreaData.Pos.x, AreaData.Pos.y, AreaData.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, AreaData.Size.x, AreaData.Size.y, AreaData.Size.z, 0, 150, 0, 50, false, true, 2, false, false, false, false)			
			end
		else
			if isLBOpen then
				OpenLobbyMenu(false)
				isLBOpen = false
			end
			Citizen.Wait(1000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if PBData.InPB and PBData.LobbyId ~= -1 then
			if not isNearPB then
				local playerPed = PlayerPedId()
				if MapData[PBData.MapName]["area"] then
					local AreaData = MapData[PBData.MapName]["area"]
					if GetDistanceBetweenCoords(GetEntityCoords(playerPed), AreaData.Pos.x, AreaData.Pos.y, AreaData.Pos.z) > ((AreaData.Size.x / 2) + 3) then
						TriggerEvent('esx_paintball:ShowMessage', "~r~Out Of Zone", 120)
						Citizen.Wait(500)
						SetEntityHealth(playerPed, GetEntityHealth(playerPed) - 10)
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(8)
		
		if PBData.InPB then
			DisableControlAction(2, Keys['F1'])		
			DisableControlAction(2, Keys['F2'])
			DisableControlAction(2, Keys['F3'])			
			DisableControlAction(2, Keys['F5'])
			DisableControlAction(2, Keys['F6'])
			DisableControlAction(2, Keys['F7'])			
			DisableControlAction(2, Keys['F9'])
			DisableControlAction(2, Keys['K'])
			DisableControlAction(2, Keys['H'])
			DisableControlAction(2, Keys['~'])
		end
		
		--[[if PBData.MouseScroll ~= 0 then
			SetTextFont(4)
			SetTextScale(0.5, 0.5)
			local myTeamColor = TeamColors["team" .. PBData.TeamID]
			SetTextColour(myTeamColor.r, myTeamColor.g, myTeamColor.b, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()

			BeginTextCommandDisplayText("STRING")
			AddTextComponentSubstringPlayerName(PBData.Teammates[PBData.MouseScroll].name)
			EndTextCommandDisplayText(0.180, 0.92)
		end]]
	end
end)

function OpenLobbyMenu(state)
	SendNUIMessage({type = "show", show = state})
	SetNuiFocus(state, state)
	isLBOpen = state
	if state ~= nil then
		PBData.LobbyId = -1
	end
end

RegisterNetEvent('esx_paintball:JoinLobby')
AddEventHandler('esx_paintball:JoinLobby', function(TeamID, HTMLVal)
	SendNUIMessage({action = 'JoinTeam', team = TeamID, value = HTMLVal})
end)

RegisterNetEvent('esx_paintball:QuitLobby')
AddEventHandler('esx_paintball:QuitLobby', function(PlayerId)
	SendNUIMessage({action = 'LeftTeam', player = PlayerId})
end)

RegisterNetEvent('esx_paintball:RefreshPlayer')
AddEventHandler('esx_paintball:RefreshPlayer', function(LobbyId, PlayerId, TeamID, HTMLVal)
	if LobbyId == PBData.LobbyId then
		TriggerEvent('esx_paintball:QuitLobby', PlayerId)
		TriggerEvent('esx_paintball:JoinLobby', TeamID, HTMLVal)
	end
end)

RegisterNetEvent('esx_paintball:ForceExit')
AddEventHandler('esx_paintball:ForceExit', function(LobbyId)
	if PBData.LobbyId == LobbyId then
		OpenLobbyMenu(false)
	end
end)

RegisterNetEvent('esx_paintball:RefreshLobbies')
AddEventHandler('esx_paintball:RefreshLobbies', function(LobbyId)
	if isLBOpen then
		if PBData.LobbyId ~= LobbyId then
			SendNUIMessage({action = 'RefreshLobbies'})
		end
	end
end)

function IsNearPB()
	local playerPed = PlayerPedId()
	local myCoords = GetEntityCoords(playerPed)
	if GetDistanceBetweenCoords(myCoords, PBMarker.Pos) < (PBMarker.Size.x / 2) then return true end
	return false
end

--[[ PB Main ]]--
--[[function SetPosition(TeamID, )
function PreparePB(LobbyId, )]]
RegisterKeyMapping('pbmsu', 'PaintBall MS Up', 'mouse_wheel', 'iom_wheel_up')
RegisterKeyMapping('pbmsd', 'PaintBall MS Down', 'mouse_wheel', 'iom_wheel_down')

RegisterCommand("pbmsu", function()
	if PBData.InPB and isDead then
		if PBData.MouseScroll + 1 > #PBData.Teammates then 
			PBData.MouseScroll = 1
		else
			PBData.MouseScroll = PBData.MouseScroll + 1
		end
		ToggleSpec(true, PBData.MouseScroll)
	end
end)

RegisterCommand("pbmsd", function()
	if PBData.InPB and isDead then
		if PBData.MouseScroll - 1 < 1 then 
			PBData.MouseScroll = #PBData.Teammates
		else
			PBData.MouseScroll = PBData.MouseScroll - 1
		end
		ToggleSpec(true, PBData.MouseScroll)
	end
end)

RegisterNetEvent('esx_paintball:StartMatch')
AddEventHandler('esx_paintball:StartMatch', function(LobbyId, mapName, weaponName, teamID, teammates, MaxRounds)
	if PBData.LobbyId == LobbyId then
		PBData.InPB = true
		PBData.TeamID = teamID
		PBData.MapName = mapName
		PBData.WeaponName = weaponName
		PBData.TeamPos = MapData[mapName]["team" .. teamID]				
		PBData.CurrentRound = 0
		PBData.MaxRounds = MaxRounds
		
		local myServerID = GetPlayerServerId(PlayerId())
		for k, v in pairs(teammates) do
			if v.source ~= myServerID then
				table.insert(PBData.Teammates, { source = v.source, player = GetPlayerFromServerId(v.source), name = GetPlayerName(GetPlayerFromServerId(v.source)), alive = true })
			end
		end
		OpenLobbyMenu(nil)
		TriggerEvent('esx_paintball:inPaintBall', true)				
		TriggerServerEvent('esx_paintball:SetPlayerReqs', PBData.LobbyId--[[, GetPlayerLoadout()]])
		TriggerEvent('skinchanger:getSkin', function(skin)
			if tonumber(skin.sex) == 0 then
				TriggerEvent('skinchanger:loadClothes', skin, json.decode(ClothesData["team" .. teamID]["male"]))
			elseif tonumber(skin.sex) == 1 then
				TriggerEvent('skinchanger:loadClothes', skin, json.decode(ClothesData["team" .. teamID]["female"]))
			end
		end)
		Citizen.Wait(300)
		SendNUIMessage({action = "ShowGameHUD", value = true})			
		SendNUIMessage({action = "ResetRoundTimer", value = 420, r = 0, g = 200, b = 0})						
		SendNUIMessage({action = "UpdateTeams", team1 = "0", team2 = "0"})		
		SendNUIMessage({action = "UpdateTotalRounds", value = "0", maxRounds = PBData.MaxRounds})
	end
end)

RegisterNetEvent('esx_paintball:UpdateTeams')
AddEventHandler('esx_paintball:UpdateTeams', function(LobbyId, teams, totalRounds)
	if PBData.LobbyId == LobbyId then
		SendNUIMessage({action = "UpdateTeams", team1 = tostring(teams[1]), team2 = tostring(teams[2])})
		SendNUIMessage({action = "UpdateTotalRounds", value = tostring(totalRounds), maxRounds = PBData.MaxRounds})
	end
end)

RegisterNetEvent('esx_paintball:StartRound')
AddEventHandler('esx_paintball:StartRound', function(LobbyId, RoundWinner)
	if PBData.LobbyId == LobbyId then
		SendNUIMessage({action = "ShowGameHUD", value = true})	
		SendNUIMessage({action = "ResetRoundTimer", value = 420, r = 0, g = 200, b = 0})		
		TriggerEvent('holsterweapon:ResetAll')
		DisplayRadar(false)
		isDead = false
		TriggerEvent('es_admin:freezePlayer', true)		
		Citizen.Wait(250)
		TriggerEvent('es_admin:freezePlayer', false)	
		ToggleSpec(false)
		for k, v in pairs(PBData.Teammates) do
			v.alive = true
		end
		if RoundWinner then
			local tempMsg = "~g~You win this round"		
			if RoundWinner ~= PBData.TeamID then tempMsg = "~r~Team " .. RoundWinner .. " won round" end		
			TriggerEvent('esx_paintball:ShowMessage', tempMsg)
			PBData.CurrentRound = PBData.CurrentRound + 1
		else
			PBData.CurrentRound = 0
		end
		local playerPed = PlayerPedId()
		RemoveAllPedWeapons(playerPed, true)
				
		RequestCollisionAtCoord(PBData.TeamPos.x, PBData.TeamPos.y, PBData.TeamPos.z + 0.05)		
		while not HasCollisionLoadedAroundEntity(playerPed) do
			RequestCollisionAtCoord(PBData.TeamPos.x, PBData.TeamPos.y, PBData.TeamPos.z + 0.05)
			Citizen.Wait(1)
		end
		TriggerEvent('esx_ambulancejob:revive')
		Citizen.Wait(1000)
		SetEntityCoords(playerPed, PBData.TeamPos.x, PBData.TeamPos.y, PBData.TeamPos.z)
		RespawnPed(playerPed, PBData.TeamPos.x, PBData.TeamPos.y, PBData.TeamPos.z, PBData.TeamPos.h)
		Citizen.Wait(300)
		StopScreenEffect('DeathFailOut')
		TriggerServerEvent('esx_paintball:StartRound', PBData.LobbyId)
		TriggerEvent('es_admin:freezePlayer', true)		
		Citizen.Wait(500)
		TriggerEvent('es_admin:freezePlayer', false)
	end
end)

RegisterNetEvent('esx_paintball:QuitPaintBall')
AddEventHandler('esx_paintball:QuitPaintBall', function(LobbyId, PBWinner)
	if PBData.LobbyId == LobbyId then
		SendNUIMessage({action = "ResetRoundTimer", value = false})
		SendNUIMessage({action = "ShowGameHUD", value = false})
		SendNUIMessage({action = "UpdateTeams"})
		SendNUIMessage({action = "UpdateTotalRounds"})
		DisplayRadar(true)
		isDead = false
		Citizen.Wait(500)
		for k, v in pairs(GetActivePlayers()) do
			NetworkSetInSpectatorMode(false, GetPlayerPed(v))
		end
		TriggerEvent('esx_paintball:inSafeZone')
		TriggerEvent('esx_skin:reloadMe')
		Citizen.Wait(2500)
		TriggerEvent('esx_ambulancejob:revive')		
		Citizen.Wait(2000)
		local playerPed = PlayerPedId()
		
		SetEntityCoords(playerPed, PBMarker.Pos.x, PBMarker.Pos.y, PBMarker.Pos.z)		
		RemoveAllPedWeapons(playerPed, true)
		Citizen.Wait(300)
		TriggerServerEvent('esx_paintball:RestoreLoadout')
		local tempText = "~g~You won this match"
		if PBWinner ~= PBData.TeamID then
			tempText = "~r~Team " .. PBWinner .. " won match"
		end
		TriggerEvent('esx_paintball:ShowMessage', tempText)
		TriggerEvent('esx_paintball:inPaintBall', false)
		PBData.InPB = false
		PBData.TeamID = 0
		PBData.Teammates = {}
		PBData.MouseScroll = 0
		PBData.CurrentRound = -1
		PBData.MaxRounds = 0
		OpenLobbyMenu(false)
	end
end)

local BreakThatShit = false
RegisterNetEvent('esx_paintball:BringTogether')
AddEventHandler('esx_paintball:BringTogether', function(LobbyId, BringRound)
	if PBData.InPB and PBData.LobbyId == LobbyId then
		local playerPed = PlayerPedId()
		local BringPos = MapData[PBData.MapName]["eteam" .. PBData.TeamID]
		SetEntityCoords(playerPed, BringPos.x, BringPos.y, BringPos.z)
		SetEntityHeading(playerPed, BringPos.h)
		TriggerEvent('esx_paintball:ShowMessage', "~r~Out Of Time!")
		TriggerEvent('es_admin:freezePlayer', true)		
		Citizen.Wait(3333)
		TriggerEvent('es_admin:freezePlayer', false)
		local OFTWait = 10
		SendNUIMessage({action = "ResetRoundTimer", value = OFTWait, r = 200, g = 0, b = 0})
		Citizen.Wait(OFTWait * 1000)
		while true do
			if BreakThatShit then BreakThatShit = false return end			
			if not PBData.InPB or PBData.LobbyId ~= LobbyId or PBData.CurrentRound ~= BringRound then return end
			Citizen.Wait(math.random(500, 3000))
			SetEntityHealth(playerPed, GetEntityHealth(playerPed) - math.random(1, 7))
		end
	end
end)

function GetWeaponComponents(wName)
	local playerPed = PlayerPedId()
	local weaponComponents = {}

	for i=1, #Config.Weapons, 1 do
		local weaponName = Config.Weapons[i].name
		if weaponName == wName then
			local weaponHash = GetHashKey(weaponName)

			if HasPedGotWeapon(playerPed, weaponHash, false) and weaponName ~= 'WEAPON_UNARMED' then
				local components = Config.Weapons[i].components
	
				if #components > 0 then
					for j=1, #components, 1 do
						if HasPedGotWeaponComponent(playerPed, weaponHash, components[j].hash) then
							table.insert(weaponComponents, components[j].hash)
						end
					end				
				end
				
				break
			end			
			
			break
		end
	end
	
	return weaponComponents
end

function GetPlayerLoadout()
	local playerPed      = PlayerPedId()
	local loadout        = {}

	for i = 1, #Config.Weapons, 1 do
		local weaponName = Config.Weapons[i].name
		local weaponHash = GetHashKey(weaponName)
		local weaponComponents = {}
		local weaponTint = 0

		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponName ~= 'WEAPON_UNARMED' then
			local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
			
			weaponComponents = GetWeaponComponents(weaponName)				
			weaponTint = GetPedWeaponTintIndex(playerPed, weaponHash)

			table.insert(loadout, 
			{
				name = weaponName,
				ammo = ammo,
				label = Config.Weapons[i].label,
				data = { components = weaponComponents, tint = weaponTint }
			})
		end
	end
	
	return loadout
end

RegisterNetEvent('esx_paintball:ShowMessage')
AddEventHandler('esx_paintball:ShowMessage', function(MsgText, setCounter)
	local scaleform = RequestScaleformMovie("mp_big_message_freemode")
	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end

	BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
	BeginTextComponent("STRING")
	AddTextComponentString(MsgText)
	EndTextComponent()
	PopScaleformMovieFunctionVoid()	

	local counter = 0
	local maxCounter = (setCounter or 200)
	while counter < maxCounter do
		counter = counter + 1
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_paintball:RLO')
AddEventHandler('esx_paintball:RLO', function(LO)
	TriggerEvent('esx:restoreLoadout', LO)
end)

AddEventHandler('esx_paintball:GetPBData', function(cb)
	cb(PBData)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	BreakThatShit = true
	isDead = true
	if PBData.InPB and PBData.LobbyId ~= -1 then
		PBData.MouseScroll = 0
		ToggleSpec(true, PBData.MouseScroll)
		TriggerServerEvent('esx_paintball:onPBDeath', PBData.LobbyId, data)
	end
end)

function GetWeaponLabel(weaponName)
	local weapons = ESX.GetWeaponList()
	for i=1, #weapons, 1 do
		if GetHashKey(weapons[i].name) == weaponName then
			return weapons[i].label
		end
	end
end

function GetTeammate(PlayerId)
	for k, v in pairs(PBData.Teammates) do
		if v.source == PlayerId then
			return k, v
		end
	end
	return nil, nil
end

RegisterNetEvent('esx_paintball:onPBDeath')
AddEventHandler('esx_paintball:onPBDeath', function(LobbyId, TeamID, data, victim, teamsCount)
	if PBData.InPB then
		if PBData.LobbyId == LobbyId then
			if PBData.TeamID == TeamID then
				local tempMsgColor = "~b~"
				if PBData.TeamID == 2 then tempMsgColor = "~y~" end
				local tempMsg = "~w~Az Teame Shoma " .. tempMsgColor .. teamsCount[PBData.TeamID] .. " ~w~Nafar Zende Ast"
				ESX.ShowNotification(tempMsg)
				if victim ~= GetPlayerServerId(PlayerId()) then
					local _, myTeammate = GetTeammate(victim)
					if myTeammate then
						PBData.Teammates[_].alive = false	
						if PBData.MouseScroll == _ then
							ToggleSpec(true)
						end						
					end
					for k, v in pairs(PBData.Teammates) do
						if v.source == victim and isDead and PBData.MouseScroll ~= victim and v.alive then
							ToggleSpec(false)
							Wait(50)
							ToggleSpec(true)
							break
						end
					end
				end
			else
				local tempMsgColor = "~b~"
				if TeamID == 2 then tempMsgColor = "~y~" end
				local tempMsg = "~w~Az Teame " .. tempMsgColor .. "(" .. TeamID .. ") ~g~" .. teamsCount[TeamID] .. " ~w~Nafar Zende Ast"
				ESX.ShowNotification(tempMsg)			
			end
		end
	end
end)

RegisterNetEvent('esx_paintball:PlayerDisconnected')
AddEventHandler('esx_paintball:PlayerDisconnected', function(LobbyId, PlayerId)
	if PBData.InPB then
		if PBData.LobbyId == LobbyId then
			local _, Teammate = GetTeammate(PlayerId)
			if Teammate then
				PBData.Teammates[_] = nil
				if PBData.MouseScroll == _ then
					ToggleSpec(true)
				end
			end
		end
	end
end)

RegisterNetEvent('esx:addPBWeapon')
AddEventHandler('esx:addPBWeapon', function(weaponName, ammo)
	if PBData.InPB then
		local playerPed  = PlayerPedId()
		local weaponHash = GetHashKey(weaponName)
		local weaponTint = math.random(1, 7)
		if string.find(weaponName, "MK2") ~= nil then weaponTint = math.random(1, 31) end
		GiveWeaponToPed(playerPed, weaponHash, ammo, false, true, weaponTint)
	end
end)

--[[RegisterCommand("quitpb", function(source, args)
	TriggerServerEvent('esx_paintball:QuitPaintBall', tonumber(args[1]))
end, false)]]

function ToggleSpec(state, playerId)
	if state then
		local _, nextSpecPlayer = GetNextAliveTeammate(playerId or PBData.MouseScroll)
		if nextSpecPlayer then
			PBData.MouseScroll = _
			NetworkSetInSpectatorMode(true, GetPlayerPed(nextSpecPlayer))
			SendNUIMessage({action = "SpectatePlayer", value = PBData.Teammates[_].name})			
		else
			ToggleSpec(false)
		end
	else
		for k, v in pairs(PBData.Teammates) do
			NetworkSetInSpectatorMode(false, GetPlayerPed(v.player))
		end
		SendNUIMessage({action = "SpectatePlayer"})
		PBData.MouseScroll = 0
	end
end

function GetNextAliveTeammate(teammateID)
	for k, v in pairs(PBData.Teammates) do
		if v.alive then
			if k >= teammateID then
				return k, v.player
			end
		end
	end
	for k, v in pairs(PBData.Teammates) do
		if v.alive then
			return k, v.player
		end
	end
	return nil, nil
end

function RespawnPed(ped, x, y, z, heading)
	SetEntityHealth(ped, 200.0)
	SetEntityCoordsNoOffset(ped, x, y, z, false, false, false, true)
	NetworkResurrectLocalPlayer(x, y, z, heading, true, false)
	SetPlayerInvincible(ped, false)
	TriggerEvent('playerSpawned', x, y, z)
	ClearPedBloodDamage(ped)
	ESX.UI.Menu.CloseAll()
end

--[[AddEventHandler('gameEventTriggered', function(eventName, data)
	if eventName == 'CEventNetworkEntityDamage' then
		-- Fe'lan hichi
	end
end)]]

RegisterCommand("quitpb", function(source, args)
	TriggerServerEvent('esx_paintball:QuitPaintBall', tonumber(args[1]))
end, false)

RegisterNetEvent('esx_paintball:setTopKillers')
AddEventHandler('esx_paintball:setTopKillers', function(LobbyId, topKillers)
	if PBData.LobbyId == LobbyId then
		SendNUIMessage({topKillers = topKillers})
	end
end)

-- Exports
exports("IsPlayerInPB", function()
	return PBData.InPB
end)