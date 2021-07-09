--[[--

	Author: ! In The Name Of God !#4934
	Our Discord Servers: https://discord.gg/8u2GV2CBmh - https://discord.gg/zyCBQP5uS6	
	
--]]--

local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local LobbyList = {}
local PlayerLoadouts = {}
local LobbyCounter = 0
local PBPlayers = {}

function CreateLobby(xPlayer, data)
	local RoundNum = tonumber(data.roundNum)
	if not RoundNum or RoundNum < 1 then RoundNum = 1
	elseif RoundNum > 5 then RoundNum = 5
	end
	
	local LobbyName = tostring(data.lobbyName)
	if #LobbyName < 3 or #LobbyName > 15 then LobbyName = "Just a name" end
	
	local LobbyPass = tostring(data.Password)
	if #LobbyPass > 10 then LobbyPass = "" end
	
	local MapName = tostring(data.mapName)
	if not MapData[MapName] then MapName = AuthorizedMaps[math.random(1, #AuthorizedMaps)] end
	
	table.insert(LobbyList, 
	{
		lobbyOwner = xPlayer,
		-- Useful
		LobbyId = #LobbyList + 1,
		name = LobbyName,
		map = MapName,
		weapon = data.weaponModel,			
		pass = LobbyPass,
		-- Useless
		friendlyFire = data.friendlyFire,
		roundNum = RoundNum,
		teams = { {}, {}, {} },
		started = false,
		roundCounter = 0,
		LobbyCounter = LobbyCounter,
		Kills = {}
	})
	LobbyCounter = LobbyCounter + 1
	
	return #LobbyList
end

function FindLobby(LobbyId)
	for k, v in pairs(LobbyList) do
		if v.LobbyId == LobbyId then
			return k, v
		end
	end
	return nil, nil
end

function DoesOwnerHasLobby(identifier)
	for k, v in pairs(LobbyList) do
		if v.lobbyOwner.identifier == identifier then 
			return true 
		end
	end
	return false
end

function GetTeamHTMLValue(teamID, playerId, readyState)
	local tempStr = '<h2 class="player'
	if readyState then tempStr = tempStr .. ' ready' end
	tempStr = tempStr .. ' team-' .. tostring(teamID) .. '" id="' .. tostring(playerId) .. '">' .. GetPlayerName(playerId) .. '</h2>'
	return tempStr
end

function FindPlayerInLobby(LobbyId, PlayerId)
	local _, Lobby = FindLobby(LobbyId)
	if Lobby then
		for teamID, teamData in pairs(Lobby.teams) do
			for playerIndex, playerData in pairs(teamData) do
				if playerData.source == PlayerId then
					return teamID, playerIndex, playerData
				end
			end
		end
	end
	return nil, nil, nil
end

function GetTeamsWithHTMLValue(Teams)
	for teamKey, teamValue in pairs(Teams) do
		for playerKey, playerValue in pairs(teamValue) do
			playerValue.value = GetTeamHTMLValue(teamKey - 1, playerValue.source, playerValue.ready)
		end
	end
	return Teams
end

function JoinLobby(LobbyId, PlayerId)
	local _, Lobby = FindLobby(LobbyId)
	if Lobby then
		local LastTeamID, PlayerIndex, Player = FindPlayerInLobby(LobbyId, PlayerId)
		if LastTeamID then table.remove(LobbyList[_].teams[LastTeamID], PlayerIndex) end
		table.insert(LobbyList[_].teams[1], { source = PlayerId, ready = false })
		for teamID, teamData in pairs(LobbyList[_].teams) do
			for playerIndex, playerData in pairs(teamData) do
				if playerData.source ~= PlayerId then
					TriggerClientEvent('esx_paintball:JoinLobby', playerData.source, 0, GetTeamHTMLValue(0, PlayerId, false))
				end
			end
		end
		return GetTeamsWithHTMLValue(LobbyList[_].teams)
	end	
	return {}
end

function QuitLobby(LobbyId, TeamID, PlayerId)
	local _, Lobby = FindLobby(LobbyId)
	if Lobby then
		local LastTeamID, PlayerIndex, Player = FindPlayerInLobby(LobbyId, PlayerId)
		if LastTeamID then 
			table.remove(LobbyList[_].teams[TeamID + 1], PlayerIndex) 
			if LobbyList[_].teams[LastTeamID][PlayerIndex] then
				table.remove(LobbyList[_].teams[LastTeamID], PlayerIndex) 
			end
		end
		for teamID, teamData in pairs(LobbyList[_].teams) do
			for playerIndex, playerData in pairs(teamData) do
				PBPlayers[playerData.source] = false
				TriggerClientEvent('esx_paintball:QuitLobby', playerData.source, PlayerId)
			end
		end
		if Lobby.lobbyOwner.source == PlayerId then
			TriggerClientEvent('esx_paintball:ForceExit', -1, LobbyId)
			LobbyList[_] = nil
		end
	end
end

function RefreshLobbyPlayers(LobbyId)
	for teamKey, teamValue in pairs(LobbyList[LobbyId].teams) do
		for playerKey, playerValue in pairs(teamValue) do
			TriggerClientEvent('esx_paintball:RefreshPlayer', -1, LobbyList[LobbyId].LobbyId, playerValue.source, teamKey - 1, GetTeamHTMLValue(teamKey - 1, playerValue.source, playerValue.ready))
		end
	end
end

function ToggleReadyPlayer(LobbyId, TeamID, ReadyState, PlayerId)
	local _, Lobby = FindLobby(LobbyId)
	if Lobby then
		local LastTeamID, PlayerIndex, Player = FindPlayerInLobby(LobbyId, PlayerId)
		if LastTeamID == (TeamID + 1) then 
			LobbyList[_].teams[TeamID + 1][PlayerIndex].ready = ReadyState
			RefreshLobbyPlayers(_)			
		end
	end	
end

function SwitchTeam(LobbyId, LastTeamID, TeamID, PlayerId)
	local _, Lobby = FindLobby(LobbyId)
	if Lobby then
		local CurrentTeamID, PlayerIndex, Player = FindPlayerInLobby(LobbyId, PlayerId)
		if CurrentTeamID == (LastTeamID + 1) then
			table.insert(LobbyList[_].teams[TeamID + 1], { source = PlayerId, ready = Player.ready })
			table.remove(LobbyList[_].teams[CurrentTeamID], PlayerIndex)
			RefreshLobbyPlayers(_)
			return {}
		end
	end	
	return nil
end

function StartMatch(LobbyId, PlayerId)
	local _, Lobby = FindLobby(LobbyId)
	if Lobby then
		if Lobby.lobbyOwner.source == PlayerId and not Lobby.started then
			local tempTeams = {0, 0}
			for i = 1, 3 do
				for k, v in pairs(LobbyList[_].teams[i]) do
					if i == 1 then
						TriggerClientEvent('esx_paintball:ForceExit', v.source, LobbyId)					
						QuitLobby(LobbyId, 0, v.source)
					else
						if v.ready == true then
							tempTeams[i - 1] = tempTeams[i - 1] + 1
						end
					end
				end
			end
			if (tempTeams[1] + tempTeams[2]) == (#LobbyList[_].teams[2] + #LobbyList[_].teams[3]) and (tempTeams[1] > 0 and tempTeams[2] > 0) then
				LobbyList[_].started = true
				for i = 2, 3 do
					LobbyList[_].winRounds, LobbyList[_].loseRounds = {0, 0}, {0, 0}
					for k, v in pairs(LobbyList[_].teams[i]) do
						v.alive, v.kills, v.deaths = true, 0, 0	
						PBPlayers[v.source] = true
						TriggerClientEvent('esx_paintball:StartMatch', v.source, LobbyId, LobbyList[_].map, LobbyList[_].weapon, i - 1, LobbyList[_].teams[i], LobbyList[_].roundNum, (#LobbyList[_].teams[2] + #LobbyList[_].teams[3]))
					end
				end
				StartRound(-1, LobbyId)
			end
		end
	end
end

ESX.RegisterServerCallback('esx_paintball:CreateLobby', function(source, cb, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end
	if DoesOwnerHasLobby(xPlayer.identifier) then cb({}) return end
	local createdLobbyID = CreateLobby({source = xPlayer.source, identifier = xPlayer.identifier, name = string.gsub(xPlayer.name, "_", " ")}, data)
	cb(createdLobbyID)
	table.insert(LobbyList[createdLobbyID].teams[1], { source = source, ready = true })
	TriggerClientEvent('esx_paintball:JoinLobby', source, 0, GetTeamHTMLValue(0, source, true))
	TriggerClientEvent('esx_paintball:RefreshLobbies', -1, createdLobbyID)
end)

ESX.RegisterServerCallback('esx_paintball:GetLobbyList', function(source, cb, data)
	local newLobbyListTable = {}
	for k, v in pairs(LobbyList) do
		if not v.started then
			table.insert(newLobbyListTable, { LobbyId = v.LobbyId, name = v.name, map = v.map, weapon = v.weapon, pass = v.pass })
		end
	end
	cb(json.encode(newLobbyListTable))
end)

ESX.RegisterServerCallback('esx_paintball:JoinLobby', function(source, cb, data)
	cb(json.encode(JoinLobby(tonumber(data.LobbyId), source)))
end)

ESX.RegisterServerCallback('esx_paintball:QuitLobby', function(source, cb, data)
	QuitLobby(tonumber(data.LobbyId), tonumber(data.Team), source)
	cb({})
end)

ESX.RegisterServerCallback('esx_paintball:ToggleReadyPlayer', function(source, cb, data)
	ToggleReadyPlayer(tonumber(data.LobbyId), tonumber(data.Team), data.ready, source)
	cb({})
end)

ESX.RegisterServerCallback('esx_paintball:SwitchTeam', function(source, cb, data)
	cb(SwitchTeam(tonumber(data.LobbyId), tonumber(data.LastTeam), tonumber(data.JoinTeam), source))
end)

ESX.RegisterServerCallback('esx_paintball:StartMatch', function(source, cb, data)
	StartMatch(tonumber(data.LobbyId), source)
	cb({})
end)

ESX.RegisterServerCallback('esx_paintball:GetLobbyPassword', function(source, cb, data)
	if type(data) ~= 'table' then cb(false) return end
	if not data.LobbyId or not data.Password then cb(false) return end
	local _, tLobby = FindLobby(tonumber(data.LobbyId))
	if tLobby then
		if tLobby.pass == data.Password then
			cb(true)
			return
		end
	end
	cb(false)
end)

function IsPlayerInPB(source)
	if PBPlayers[source] then return true end
	return false
end

exports("IsPlayerInPB", function(source)
	return IsPlayerInPB(source)
end)

--[[ PB Main ]]--
RegisterServerEvent('esx_paintball:SetPlayerReqs')
AddEventHandler('esx_paintball:SetPlayerReqs', function(LobbyId)
	local _, Lobby = FindLobby(LobbyId)
	if Lobby and Lobby.started then
		local CurrentTeamID, PlayerIndex, Player = FindPlayerInLobby(LobbyId, source)
		if CurrentTeamID then
			PlayerLoadouts[source] = true
			SetPlayerRoutingBucket(source, 6700 + LobbyId)
		end
	end
end)

RegisterServerEvent('esx_paintball:StartRound')
AddEventHandler('esx_paintball:StartRound', function(LobbyId)
	local _, Lobby = FindLobby(LobbyId)
	if Lobby and Lobby.started then
		local CurrentTeamID, PlayerIndex, Player = FindPlayerInLobby(LobbyId, source)
		if CurrentTeamID then
			local weaponName = string.upper("weapon_" .. LobbyList[_].weapon)
			TriggerClientEvent('esx:addPBWeapon', source, weaponName, 500)
			TriggerClientEvent('esx:addWeapon', source, "WEAPON_KNIFE", 500)
		end
	end
end)

RegisterServerEvent('esx_paintball:QuitPaintBall')
AddEventHandler('esx_paintball:QuitPaintBall', function(LobbyId, winnerTeam)
	local xPlayer = ESX.GetPlayerFromId(source)
	if source == '' or (xPlayer and xPlayer.permission_level > 0) then
		local _, Lobby = FindLobby(LobbyId)
		if Lobby and Lobby.started then
			for i = 2, 3 do
				for playerKey, playerValue in pairs(LobbyList[_].teams[i]) do
					local xPlayer = ESX.GetPlayerFromId(playerValue.source)
					SetPlayerRoutingBucket(playerValue.source, 0)
					TriggerClientEvent('esx_paintball:QuitPaintBall', playerValue.source, LobbyId, winnerTeam)
				end
			end
			Wait(1000)
			LobbyList[_] = nil
		end
	end
end)

RegisterServerEvent('esx_paintball:RestoreLoadout')
AddEventHandler('esx_paintball:RestoreLoadout', function()
	if PlayerLoadouts[source] then
		local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent('esx_paintball:RLO', source, xPlayer.loadout)
		PlayerLoadouts[source] = nil
	end
end)

RegisterServerEvent('esx_paintball:onPBDeath')
AddEventHandler('esx_paintball:onPBDeath', function(LobbyId, data)
	local _source = source
	local victimPlayer = _source
	local killerPlayer = nil
	if data.killerServerId then killerPlayer = data.killerServerId end
	
	local _, Lobby = FindLobby(LobbyId)
	if Lobby and Lobby.started then
		local CurrentTeamID, PlayerIndex, Player = FindPlayerInLobby(LobbyId, _source)
		if CurrentTeamID then		
			LobbyList[_].teams[CurrentTeamID][PlayerIndex].alive = false
			LobbyList[_].teams[CurrentTeamID][PlayerIndex].deaths = LobbyList[_].teams[CurrentTeamID][PlayerIndex].deaths + 1
			if killerPlayer then
				local KillerTeamID, KillerIndex, Killer = FindPlayerInLobby(LobbyId, killerPlayer)
				if KillerTeamID then
					if not LobbyList[_].Kills[killerPlayer] then LobbyList[_].Kills[killerPlayer] = {source = killerPlayer, name = GetPlayerName(killerPlayer), kills = 0, team = KillerTeamID - 1} end
					LobbyList[_].Kills[killerPlayer].kills = LobbyList[_].Kills[killerPlayer].kills + 1
					GetTopKillers(_)				
					
					LobbyList[_].teams[KillerTeamID][KillerIndex].kills = LobbyList[_].teams[KillerTeamID][KillerIndex].kills + 1
				end
			end			
			
			local aliveCount = {0, 0}
			for i = 2, 3 do
				for playerKey, playerValue in pairs(LobbyList[_].teams[i]) do
					if playerValue.alive then
						aliveCount[i - 1] = aliveCount[i - 1] + 1
					end
				end
			end
			
			TriggerClientEvent('esx_paintball:onPBDeath', -1, LobbyId, CurrentTeamID - 1, data, _source, aliveCount)			
			
			local RoundWinner = nil
			if aliveCount[1] > aliveCount[2] and aliveCount[2] == 0 then
				LobbyList[_].winRounds[1] = LobbyList[_].winRounds[1] + 1
				LobbyList[_].loseRounds[2] = LobbyList[_].winRounds[2] + 1
				LobbyList[_].roundCounter = LobbyList[_].roundCounter + 1
				RoundWinner = 1
			elseif aliveCount[2] > aliveCount[1] and aliveCount[1] == 0 then
				LobbyList[_].winRounds[2] = LobbyList[_].winRounds[2] + 1
				LobbyList[_].loseRounds[1] = LobbyList[_].winRounds[1] + 1
				LobbyList[_].roundCounter = LobbyList[_].roundCounter + 1
				RoundWinner = 2
			end

			local PBWinner = nil
			if LobbyList[_].winRounds[1] == LobbyList[_].roundNum then PBWinner = 1
			elseif LobbyList[_].winRounds[2] == LobbyList[_].roundNum then PBWinner = 2
			end
			
			if PBWinner then
				TriggerEvent('esx_paintball:QuitPaintBall', LobbyId, PBWinner)
			else
				if RoundWinner then
					for i = 2, 3 do
						for playerKey, playerValue in pairs(LobbyList[_].teams[i]) do
							playerValue.alive = true
						end
					end
					StartRound(-1, LobbyId, RoundWinner, _)
				end
			end
		end
	end
end)

function GetTopKillers(LobbyKey)
	local max = {[1] = {source = 0, name = "No-One", kills = 0, team = 0}, [2] = {source = 0, name = "No-One", kills = 0, team = 0}, [3] = {source = 0, name = "No-One", kills = 0, team = 0}, [4] = {source = 0, name = "No-One", kills = 0, team = 0}, [5] = {source = 0, name = "No-One", kills = 0, team = 0}}
	for k, v in pairs(LobbyList[LobbyKey].Kills) do
		if v.kills > max[1].kills then
			max[1].kills, max[1].name, max[1].source, max[1].team = v.kills, v.name, v.source, v.team
		end
	end
	for k, v in pairs(LobbyList[LobbyKey].Kills) do
		if v.kills > max[2].kills and v.source ~= max[1].source then
			max[2].kills, max[2].name, max[2].source, max[2].team = v.kills, v.name, v.source, v.team
		end
	end	
	for k, v in pairs(LobbyList[LobbyKey].Kills) do
		if v.kills > max[3].kills and v.source ~= max[1].source and v.source ~= max[2].source then
			max[3].kills, max[3].name, max[3].source, max[3].team = v.kills, v.name, v.source, v.team
		end
	end	
	for k, v in pairs(LobbyList[LobbyKey].Kills) do
		if v.kills > max[4].kills and v.source ~= max[1].source and v.source ~= max[2].source and v.source ~= max[3].source then
			max[4].kills, max[4].name, max[4].source, max[4].team = v.kills, v.name, v.source, v.team
		end
	end	
	for k, v in pairs(LobbyList[LobbyKey].Kills) do
		if v.kills > max[5].kills and v.source ~= max[1].source and v.source ~= max[2].source and v.source ~= max[3].source and v.source ~= max[4].source then
			max[5].kills, max[5].name, max[5].source, max[5].team = v.kills, v.name, v.source, v.team
		end
	end		
	
	TriggerClientEvent('esx_paintball:setTopKillers', -1, LobbyList[LobbyKey].LobbyId, max)
end

function StartRound(PlayerId, LobbyId, RoundWinner, _)
	local LobbyKey, LobbyValue = FindLobby(LobbyId)
	if not _ then _ = LobbyKey end
	
	local TempRound = LobbyList[_].roundCounter
	local TempLobbyCounter = LobbyList[_].LobbyCounter
	
	SetTimeout(((7 * 60) + 1) * 1000, function()
		local LobbyKey2, LobbyValue2 = FindLobby(LobbyId)
		if LobbyValue2 and LobbyValue2.started then
			if LobbyValue.lobbyOwner.source == LobbyValue2.lobbyOwner.source and LobbyValue.LobbyId == LobbyValue2.LobbyId then
				if TempRound == LobbyValue2.roundCounter and TempLobbyCounter == LobbyValue2.LobbyCounter then
					local TeamAlives = {0, 0}
					for i = 2, 3 do
						for playerKey, playerValue in pairs(LobbyList[_].teams[i]) do
							if playerValue.alive then
								TeamAlives[i - 1] = TeamAlives[i - 1] + 1
							end
						end
					end
					if TeamAlives[1] > 0 and TeamAlives[2] > 0 then
						TriggerClientEvent('esx_paintball:BringTogether', -1, LobbyId, TempRound)
					end
				end
			end
		end
	end)
	
	if RoundWinner then
		TriggerClientEvent('esx_paintball:StartRound', PlayerId, LobbyId, RoundWinner)
		if _ ~= nil then
			TriggerClientEvent('esx_paintball:UpdateTeams', PlayerId, LobbyId, LobbyList[_].winRounds, LobbyList[_].roundCounter)			
		end
	else
		TriggerClientEvent('esx_paintball:StartRound', PlayerId, LobbyId)
	end
end

AddEventHandler('playerDropped', function()
	local _source = source
	for lobbyKey, lobbyValue in pairs(LobbyList) do
		for i = 2, 3 do
			for playerKey, playerValue in pairs(lobbyValue.teams[i]) do
				if playerValue.source == _source then
					local _ = lobbyKey
					local CurrentTeamID = i
					local PlayerIndex = playerKey
					local LobbyId = lobbyValue.LobbyId
					
					if playerValue.alive then
						local aliveCount = {0, 0}
						for i = 2, 3 do
							for playerKey2, playerValue2 in pairs(LobbyList[_].teams[i]) do
								if playerValue2.alive then
									aliveCount[i - 1] = aliveCount[i - 1] + 1
								end
							end
						end
						
						local RoundWinner = nil
						if aliveCount[1] > aliveCount[2] and aliveCount[2] == 0 then
							LobbyList[_].winRounds[1] = LobbyList[_].winRounds[1] + 1
							LobbyList[_].loseRounds[2] = LobbyList[_].winRounds[2] + 1
							LobbyList[_].roundCounter = LobbyList[_].roundCounter + 1
							RoundWinner = 1
						elseif aliveCount[2] > aliveCount[1] and aliveCount[1] == 0 then
							LobbyList[_].winRounds[2] = LobbyList[_].winRounds[2] + 1
							LobbyList[_].loseRounds[1] = LobbyList[_].winRounds[1] + 1
							LobbyList[_].roundCounter = LobbyList[_].roundCounter + 1
							RoundWinner = 2
						end

						local PBWinner = nil
						if LobbyList[_].winRounds[1] == LobbyList[_].roundNum then PBWinner = 1
						elseif LobbyList[_].winRounds[2] == LobbyList[_].roundNum then PBWinner = 2
						end
						
						if PBWinner then
							TriggerEvent('esx_paintball:QuitPaintBall', LobbyId, PBWinner)
						else
							if RoundWinner then
								for j = 2, 3 do
									for playerKey2, playerValue2 in pairs(LobbyList[_].teams[j]) do
										playerValue2.alive = true
									end
								end				
								StartRound(-1, LobbyId, RoundWinner, _)
							end
						end					
					end
					
					LobbyList[_].teams[CurrentTeamID][PlayerIndex] = nil
					TriggerClientEvent('esx_paintball:PlayerDisconnected', -1, LobbyId, _source)
					
					if #LobbyList[_].teams[2] == 0 or #LobbyList[_].teams[3] == 0 then
						local PBWinner = nil
						if LobbyList[_].teams[2] == 0 then PBWinner = 2
						else PBWinner = 1
						end					
						TriggerEvent('esx_paintball:QuitPaintBall', LobbyId, PBWinner)
					end
				end
			end
		end
	end
end)

AddEventHandler("weaponDamageEvent", function(sender, data)
	if IsPlayerInPB(sender) then
		if IsPlayerInPB(data.hitGlobalId) then
			return
		end
		CancelEvent()
	end
end)
