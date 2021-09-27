// Az in vara? :D
let weapons = [
    'advancedrifle.png',      'appistol.png',
    'assaultrifle.png',       'assaultrifle_mk2.png',
    'assaultshotgun.png',     'assaultsmg.png',
    'autoshotgun.png',        'bullpuprifle.png',
    'bullpuprifle_mk2.png',   'bullpupshotgun.png',
    'carbinerifle.png',       'carbinerifle_mk2.png',
    'combatmg.png',           'combatmg_mk2.png',
    'combatpdw.png',          'combatpistol.png',
    'compactrifle.png',       'dbshotgun.png',
    'doubleaction.png',       'gusenberg.png',
    'heavypistol.png',        'heavyshotgun.png',
    'heavysniper.png',        'heavysniper_mk2.png',
    'machinepistol.png',      'marksmanpistol.png',
    'marksmanrifle.png',      'marksmanrifle_mk2.png',
    'mg.png',                 'microsmg.png',
    'minigun.png',            'minismg.png',
    'musket.png',             'pistol.png',
    'pistol50.png',           'pistol_mk2.png',
    'pumpshotgun.png',        'pumpshotgun_mk2.png',
    'revolver.png',           'revolver_mk2.png',
    'sawnoffshotgun.png',     'smg.png',
    'smg_mk2.png',            'snspistol.png',
    'snspistol_mk2.png',      'specialcarbine.png',
    'specialcarbine_mk2.png', 'vintagepistol.png'
];

let weaponsprice = {
    "pumpshotgun.png":13000,       "snspistol.png":5000,
    "pistol_mk2.png":5000,         "revolver_mk2.png":12000,
    "bullpuprifle.png":15000,      "mg.png":20000,
    "combatmg_mk2.png":22000,      "appistol.png":7000,
    "minigun.png":25000,           "revolver.png":10000,
    "carbinerifle.png":10000,      "bullpupshotgun.png":15000,
    "assaultrifle_mk2.png":12000,  "gusenberg.png":16000,
    "advancedrifle.png":10000,     "assaultrifle.png":10000,
    "combatmg.png":20000,          "heavypistol.png":5000,
    "snspistol_mk2.png":6000,      "heavysniper_mk2.png":25000,
    "combatpistol.png":5000,       "specialcarbine_mk2.png":16000,
    "assaultsmg.png":11000,        "carbinerifle_mk2.png":13000,
    "marksmanpistol.png":12000,    "vintagepistol.png":5000,
    "specialcarbine.png":15000,    "bullpuprifle_mk2.png":18000,
    "smg_mk2.png":12000,           "marksmanrifle.png":16000,
    "compactrifle.png":11000,      "sawnoffshotgun.png":13000,
    "mpshotgun_mk2.png":18000,     "pistol50.png":8000,
    "pistol.png":5000,             "smg.png":10000,
    "minismg.png":15000,           "microsmg.png":13000,
    "marksmanrifle_mk2.png":18000, "musket.png":25000,
    "machinepistol.png":10000,     "heavysniper.png":23000,
    "doubleaction.png":10000,      "autoshotgun.png":18000,
    "assaultshotgun.png":13000,    "heavyshotgun.png":25000,
    "dbshotgun.png":16000,         "combatpdw.png":13000,
    "pumpshotgun_mk2.png":15000
};

let maps = {"bank":"bank.jpg","bimeh":"bimeh.jpg","cargo":"cargo.jpg","skyscraper":"skyscraper.jpg","shop1":"shop1.jpg","shop2":"shop2.jpg","javaheri":"javaheri.jpg","1v1":"1v1.jpg","island":"island.jpg","jail":"jail.jpg"}
var lobbyID, TeamID, mapping, SWeapon, lobbyname, friendlyFire, roundNum, TotalPlayers;
var page = 0;

// Create Lobby Functions
function onCreateLobby(){
    $('.question').css('display', 'none');
    $('div[name="createlobby"]').css('display', 'block');
};
function onChangeMap(){
    var newSelect = $('#map').val();
    $('.map-img').attr('src', './assets/imgs/'+maps[newSelect])
};
function LeftWeaponButton() {
    var nowSelect = $('.weapon-select img').attr('src').split('/');
    if(weapons.indexOf(nowSelect[3]) > 0){
        $('.weapon-select img').attr('src', './assets/weapons/'+weapons[weapons.indexOf(nowSelect[3])-1]);
        $('.weapon-name').attr('id', weapons[weapons.indexOf(nowSelect[3])-1].split('.')[0]);
        $('.weapon-name').html(weapons[weapons.indexOf(nowSelect[3])-1].split('.')[0].replace('_', ' '));
        $('.weapon-price').html('$'+weaponsprice[weapons[weapons.indexOf(nowSelect[3])-1]]);
    }else{
        $('.weapon-select img').attr('src', './assets/weapons/'+weapons[weapons.length-1]);
        $('.weapon-name').attr('id', weapons[weapons.length-1].split('.')[0]);
        $('.weapon-name').html(weapons[weapons.length-1].split('.')[0].replace('_', ' '));
        $('.weapon-price').html('$'+weaponsprice[weapons[weapons.length-1]]);
    };
};
function RightWeaponButton() {
    var nowSelect = $('.weapon-select img').attr('src').split('/');
    if(weapons.indexOf(nowSelect[3]) == weapons.length-1){
        $('.weapon-select img').attr('src', './assets/weapons/'+weapons[0]);
        $('.weapon-name').attr('id', weapons[0].split('.')[0]);
        $('.weapon-name').html(weapons[0].split('.')[0].replace('_', ' '));
        $('.weapon-price').html('$'+weaponsprice[weapons[0]]);
    }else{
        $('.weapon-select img').attr('src', './assets/weapons/'+weapons[weapons.indexOf(nowSelect[3])+1]);
        $('.weapon-name').attr('id', weapons[weapons.indexOf(nowSelect[3])+1].split('.')[0]);
        $('.weapon-name').html(weapons[weapons.indexOf(nowSelect[3])+1].split('.')[0].replace('_', ' '));
        $('.weapon-price').html('$'+weaponsprice[weapons[weapons.indexOf(nowSelect[3])+1]]);
    };
};
function onSubmit(){
    lobbyname = $('#lname');
    lobbypass = $('#lbpass');
    friendlyFire = $('#fire').val();
    roundNum = $('#round');
    if(lobbyname.length != 0 && lobbyname.val().length > lobbyname.attr('minlength')){
        var max = roundNum.attr('max');
        if(roundNum.val() > 0 && parseInt(roundNum.val()) <= parseInt(max)){
            fetch(`https://${GetParentResourceName()}/CreateLobby`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    mapName: mapping,
                    weaponModel: SWeapon,
                    lobbyName: lobbyname.val(),
                    friendlyFire: friendlyFire,
                    roundNum: roundNum.val(),
                    Password: lobbypass.val()
                })
            }).then(resp => resp.json()).then(lobid => {
                lobbyID = lobid
            });
            page = 100;
            TeamID = 0;
            $('div[name="createlobby"]').css('display', 'none');
            $('#startButton').css('display', 'block');
            $('div[name="main"]').css('display', 'block');
        }else{
            roundNum.val(max);
            $('#round').css('border-color', 'red');
        };
    }else{
        $('#lname').css('border-color', 'red');
    };
};

// Join In Lobby Functions
function onJoinLobby(){
    $('.question').css('display', 'none');
    $('.list').css('display', 'block');
    fetch(`https://${GetParentResourceName()}/LobbyList`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(data => {
        var jdata = JSON.parse(data);
        if(jdata.length != 0){
            for(var i=0;i<jdata.length;i++){
                if(jdata[i].pass == null || jdata[i].pass == ""){
                    $('.boxlobbeys').append('<h1 class="lobbeys" id="Lobby-'+jdata[i].LobbyId+'" onclick="onSelectLobby(this.id)">'+jdata[i].name+' | '+jdata[i].map+' | '+jdata[i].weapon+'</h1>');
                }else{
                    $('.boxlobbeys').append('<h1 class="lobbeys" id="Lobby-'+jdata[i].LobbyId+'-locked" onclick="onSelectLobby(this.id)">'+jdata[i].name+' | '+jdata[i].map+' | Locked</h1>');
                };
            };
        }else{
            $('.boxlobbeys').append('<h1 class="lobbeys">No Lobby!</h1>');
        };
    });
};
function onSelectLobby(id){
    var lid = id.split('-');
    lobbyID = lid[1];
    if(lid[2] == 'locked'){
        $('.lobby-password').css('display', 'block');
        $('.lobbeys').css('display', 'none');
        page = 85;
    }else{
        page = 0;
        TeamID = 0;
        $('.list').css('display', 'none');
        $('#startButton').css('display', 'none');
        $('div[name="main"]').css('display', 'block');
        fetch(`https://${GetParentResourceName()}/JoinLobby`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                LobbyId: lobbyID
            })
        }).then(resp => resp.json()).then(data => {
            var jdata = JSON.parse(data);
            for(var i=0;i<3;i++){
                var team = jdata[i];
                for(var i2=0;i2<team.length;i2++){
                    if(i == 0){
                        $('.joiners').append(team[i2].value);
                    }else if(i == 1){
                        $('.teamone').append(team[i2].value);
                    }else{
                        $('.teamtwo').append(team[i2].value);
                    };
                };
            };
        });
    };
};
function onJoin(id){
    var tid = id.split('-')[1];
    fetch(`https://${GetParentResourceName()}/SwitchTeam`, 
	{
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            LobbyId: lobbyID,
            LastTeam: TeamID,
            JoinTeam: tid
        })
    }).then(resp => resp.json()).then(data => 
	{
        if(data)
		{
            if(TeamID != 0){
                $('#TM-'+TeamID).css('display', 'block');
            };
            $('#'+id).css('display', 'none');
            page = 100;
            TeamID = tid;
        };
    })
};

// In Lobby Functions
function onStart(){
    page = 0;
    fetch(`https://${GetParentResourceName()}/StartMatch`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            LobbyId: lobbyID
        })
    }).then(resp => resp.json());
};
function onReady(){
    $('#ReadyButton').css('display', 'none');
    $('#UnReadyButton').css('display', 'block');
    fetch(`https://${GetParentResourceName()}/ToggleReadyPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            LobbyId: lobbyID,
            Team: TeamID,
            ready: true
        })
    }).then(resp => resp.json());
};
function onUnready(){
    $('#UnReadyButton').css('display', 'none');
    $('#ReadyButton').css('display', 'block');
    fetch(`https://${GetParentResourceName()}/ToggleReadyPlayer`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            LobbyId: lobbyID,
            Team: TeamID,
            ready: false
        })
    }).then(resp => resp.json());
};
function onLeave(){
    page = 0;
    $('.lobby').css('display', 'none');
    fetch(`https://${GetParentResourceName()}/QuitLobby`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            LobbyId: lobbyID,
            Team: TeamID
        })
    }).then(resp => resp.json());
    TeamID = 0;
    lobbyID = 0;
    location.reload();
};

// Other Functions
function onNext(){
    if(page == 0){
        $('#cancelButton').css('display', 'none');
        $('#backButton').css('display', 'block');
        $('.selectmap').css('display', 'none');
        $('.weapon-select').css('display', 'block');
        mapping = $('#map').val();
        page = page+1;
    }else{
        $('#nextButton').css('display', 'none');
        $('#submitButton').css('display', 'block');
        $('.weapon-select').css('display', 'none');
        $('.setting').css('display', 'block');
        SWeapon = $('.weapon-name').attr('id');
        page = page+1;
    };
};
function onBack(){
    if(page == 2){
        $('#nextButton').css('display', 'block');
        $('#submitButton').css('display', 'none');
        $('.weapon-select').css('display', 'block');
        $('.setting').css('display', 'none');
        page = page-1;
    }else{
        $('#cancelButton').css('display', 'block');
        $('#backButton').css('display', 'none');
        $('.selectmap').css('display', 'block');
        $('.weapon-select').css('display', 'none');
        page = page-1;
    };
};
function onCancel(){
    page = 0;
    $('.lobby').css('display', 'none');
    fetch(`https://${GetParentResourceName()}/QuitFromMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).then(resp => resp.json());
    location.reload()
};
function onBackQuestion(){
    if(page != 85){
        $('.question').css('display', 'block');
        $('.list').css('display', 'none');
        $('.boxlobbeys').find('h1').remove();
    }else{
        page = 0
        $('.lobby-password').css('display', 'none');
        $('.lobbeys').css('display', 'block');
    };
};

// Keyup Event
document.onkeyup = function(data) {
    if(data.which == 27){ // ESC Press
        if(page == 0){
            fetch(`https://${GetParentResourceName()}/QuitFromMenu`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            }).then(resp => resp.json());
            location.reload();
        };
    }else if(data.which == 13){
        if(page == 85){
            var pass = $('#lpass').val();
            if(pass != null || pass != ""){
                fetch(`https://${GetParentResourceName()}/GetLobbyPassword`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: JSON.stringify({
                        LobbyId: lobbyID,
						Password: pass
                    })
                }).then(resp => resp.json()).then(data => {
                    if(data == true){
                        page = 0;
                        TeamID = 0;
                        $('.list').css('display', 'none');
                        $('#startButton').css('display', 'none');
                        $('div[name="main"]').css('display', 'block');
                        fetch(`https://${GetParentResourceName()}/JoinLobby`, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: JSON.stringify({
                                LobbyId: lobbyID
                            })
                        }).then(resp => resp.json()).then(data => {
                            var jdata = JSON.parse(data);
                            for(var i=0;i<3;i++){
                                var team = jdata[i];
                                for(var i2=0;i2<team.length;i2++){
                                    if(i == 0){
                                        $('.joiners').append(team[i2].value);
                                    }else if(i == 1){
                                        $('.teamone').append(team[i2].value);
                                    }else{
                                        $('.teamtwo').append(team[i2].value);
                                    };
                                };
                            };
                        });
                    }else{
                        $('#lpass').css('border-color', 'red');
                    };
                });
            };
        };
    };
};

var SecondCounter = -1
setInterval(() =>
{
	if(SecondCounter != -1)
	{
		var date = new Date(0);
		date.setSeconds(SecondCounter);
		var timeString = date.toISOString().substr(14, 8);
		$('.btn-grad4').html(timeString.replace(".00", ""));
		SecondCounter--;
	}
}, 1000)

function addKill(killer, weapon, killed, headshot) 
{
    let killerName = sanitizeString(killer.name);
    let killedName = sanitizeString(killed.name);

    let killfeedElement = `
        <div class="kill-wrapper">
            <div class="kill">
                <p class="${killer.team}">${killerName}</p>
                ${(weapon == "VEHICLE") ? `<i style="padding-left: 5px; padding-right: 5px;" class="fas fa-car-side"></i>` : `<img src="https://cdn.gtakoth.com/weapons/${weapon}.png">`}
                ${(headshot) ? '<i class="fas fa-crosshairs"></i> ' : ""}
                <p class="${killed.team}">${killedName}</p>
            </div>
        </div>
    `;

    let elem = $(killfeedElement);
    $('.killfeed').append(elem);
    elem.hide().show(500);

    setTimeout(() => { elem.hide(500); setTimeout(() => { elem.html(""); }, 500); }, 5000);
}

function sanitizeString(str)
{
    str = str.replace(/[^a-z0-9áéíóúñü \.,_-]/gim,"");
    return str.trim();
}

// NUI Sended Event
window.addEventListener("message", function(event)
{
	if(event.data.type == 'show')
	{
		if(event.data.show){
			$('.lobby').css('display', 'block');
		}else{
			$('.lobby').css('display', 'none');
			this.location.reload();
		};
	};
	if(event.data.action == 'JoinTeam')
	{
		if(event.data.team == 0){
			$('.joiners').append(event.data.value);
		}else if(event.data.team == 1){
			$('.teamone').append(event.data.value);
		}else{
			$('.teamtwo').append(event.data.value);
		};
	}
	else if(event.data.action == 'LeftTeam')
	{
		$('#'+event.data.player).remove();
	}
	else if(event.data.action == 'ToggleReadyPlayer')
	{
		$('#'+event.data.player).html(event.data.value);
	}
	else if(event.data.action == "RefreshLobbies")
	{
        $('.boxlobbeys').find('h1').remove();
		onJoinLobby()
	}
	else if(event.data.action == "ShowGameHUD")
	{
		if(event.data.value) $('.gamehud').css('display', 'block');
		else $('.gamehud').css('display', 'none');
	}
	else if(event.data.action == "SpectatePlayer")
	{
		if(event.data.value)
		{
			$('.btn-grad').html(event.data.value);
			$('.btn-grad').css('display', 'block');
		}
		else $('.btn-grad').css('display', 'none');
	}
	else if(event.data.action == "UpdateTeams")
	{
		if(event.data.team1 && event.data.team2)
		{
			$('.btn-grad2').html(event.data.team1 + " Wins");
			$('.btn-grad3').html(event.data.team2 + " Wins");
			$('.btn-grad2').css('display', 'block');			
			$('.btn-grad3').css('display', 'block');						
		}
		else
		{
			$('.btn-grad2').css('display', 'none');			
			$('.btn-grad3').css('display', 'none');									
		}
	}
	else if(event.data.action == "UpdateTotalRounds")
	{
		if(event.data.value)
		{
			$('.btn-grad5').html("Round " + (parseInt(event.data.value) + 1) + " / " + event.data.maxRounds);
			$('.btn-grad5').css('display', 'block');
		}
		else $('.btn-grad5').css('display', 'none');	
	}
	else if(event.data.action == "ResetRoundTimer")
	{
		if(event.data.value) 
		{
			$('.btn-grad4').css('background-color', 'rgba(' + event.data.r + ', ' + event.data.g + ', ' + event.data.b + ', 0.8)');			
			$('.btn-grad4').css('display', 'block');	
			SecondCounter = event.data.value;
		}
		else 
		{
			$('.btn-grad4').css('display', 'none');	
			SecondCounter = -1
		}
	}
	else if(event.data.topKillers)
	{
		for(var i = 0; i < 5; i++)
		{
			// var teamName = "", teamColor = "";			
			if(event.data.topKillers[i].team == 0)
			{
				 $('#topcat' + (i + 1)).fadeOut(850);
			}
			else
			{
				$('#topcat' + (i + 1)).fadeIn(850);
				if(event.data.topKillers[i].team == 1) 
				{
					// teamName = " (Blue)";
					$('#top' + (i + 1) + 'btn').css('background-image', 'linear-gradient(to right,#00c6ff 0%,#0072ff 51%,#00c6ff 100%)');
					$('#top' + (i + 1) + 'a').css('background-image', 'linear-gradient(to right,#00c6ff 0%,#0072ff 51%,#00c6ff 100%)');
				}
				else if(event.data.topKillers[i].team == 2) 
				{
					// teamName = " (Orange)";
					$('#top' + (i + 1) + 'btn').css('background-image', 'linear-gradient(to right,#FD9800 0%,#ffbf00 51%,#FD9800 100%)');
					$('#top' + (i + 1) + 'a').css('background-image', 'linear-gradient(to right,#FD9800 0%,#ffbf00 51%,#FD9800 100%)');
				}
			}
			$('#hud #top' + (i + 1)).text(event.data.topKillers[i].name/* + teamName*/);
			$('#hud #top' + (i + 1) + 'a #top' + (i + 1) + 'b').text(event.data.topKillers[i].kills);
		}
	}
});
