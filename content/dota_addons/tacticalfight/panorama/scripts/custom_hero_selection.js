"use strict";

var selectedUnitsRadiant = ["","","","","",];
var selectedUnitsDire = ["","","","",""];
var numberUnitsRadiant = 0;
var numberUnitsDire = 0;


(function()
{
	GameEvents.Subscribe( "start_picking_phase", picking_phase_screen );
	GameEvents.Subscribe( "start_game_phase", game_phase );
	GameEvents.Subscribe( "enemy_picked", enemy_picked );

	var next_turn_panel = $.FindChildInContext('#next_turn');
	next_turn_panel.visible = false;
	next_turn_panel.enabled = false;
})();


function picking_phase_screen()
{
	
}

function game_phase()
{
	var AllElements = $.FindChildInContext('#PickList');
	AllElements.enabled = false;
	AllElements.visible = false;

	var AllElements2 = $.FindChildInContext('#PickTextPanel');
	AllElements2.visible = false;
	AllElements2.enabled = false;

	var next_turn_panel = $.FindChildInContext('#next_turn')
	next_turn_panel.visible = true;
	next_turn_panel.enabled = true;

	var selection_panel = $.FindChildInContext('#HeroesPicked')
	selection_panel.visible = false;
	selection_panel.enabled = false;
	
}

 function enemy_picked(data)
 {
 	var team = data.enemy_team;
 	var heroname = data.heroName;
 	var number = data.number;
 	var local_hero = Players.GetLocalPlayer();
	var local_team = Players.GetTeam( local_hero );
	if (team != local_team){
		if (team == 2){
				var hero_panel = $.FindChildInContext('#hero_'+number+'_dire');
				hero_panel.visible = true;
				hero_panel.RemoveClass("disabled");
				hero_panel.AddClass("hero_selection_"+(number + 4));
				hero_panel.heroname = heroname;
		}
		else{
				var hero_panel = $.FindChildInContext('#hero_'+number+'_radiant');
				hero_panel.visible = true;
				hero_panel.RemoveClass("disabled");
				hero_panel.AddClass("hero_selection_"+(number - 1));
				hero_panel.heroname = heroname; 
			}
		}
 }


/* Select a hero, called when a player clicks a hero panel in the layout */
function SelectHero( heroName,actualHeroName ) {

	var local_hero_id = Game.GetLocalPlayerID();

	if (local_hero_id == 0){
		if (numberUnitsRadiant < 5){
			selectedUnitsRadiant[numberUnitsRadiant] = heroName;
			numberUnitsRadiant = numberUnitsRadiant + 1;
			var hero_panel = $.FindChildInContext('#hero_'+numberUnitsRadiant+'_radiant');
			hero_panel.visible = true;
			hero_panel.RemoveClass("disabled");
			hero_panel.AddClass("hero_selection_"+numberUnitsRadiant);
			hero_panel.heroname = actualHeroName;
			//Send the pick to the server
			GameEvents.SendCustomGameEventToServer( "hero_selected", { HeroName: heroName, PlayerID: local_hero_id, TrueHeroName : actualHeroName, AmountHeroes: numberUnitsRadiant} );

		}
	} else{
		if (numberUnitsDire < 5){
			selectedUnitsDire[numberUnitsDire] = heroName;
			numberUnitsDire = numberUnitsDire + 1;
			var hero_panel = $.FindChildInContext('#hero_'+numberUnitsDire+'_dire');
			hero_panel.RemoveClass("disabled");
			hero_panel.AddClass("hero_selection_"+numberUnitsDire);
			hero_panel.heroname = actualHeroName;
			//Send the pick to the server
			GameEvents.SendCustomGameEventToServer( "hero_selected", { HeroName: heroName, PlayerID: local_hero_id, TrueHeroName : actualHeroName, AmountHeroes: numberUnitsDire} );
		}
	}
}

/* Skips a turn */
function SkipTurn() {
	var local_hero = Players.GetLocalPlayer();
	var team = Players.GetTeam( local_hero );
	GameEvents.SendCustomGameEventToServer( "skip_turn", {teamID: team} );
}



