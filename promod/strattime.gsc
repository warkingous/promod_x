/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\gametypes\_hud_util;

main()
{
	// Check if promod timeout has been called
	if ( game["promod_timeout_called"] )
	{
		// Start promod timeout thread and return
		thread promod\timeout::main();
		return;
	}

	// Start strat time thread
	thread stratTime();

	// Wait until strat time is over
	level waittill( "strat_over" );

	// Get all players
	players = getentarray("player", "classname");

	// Loop through players
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		classType = player.pers["class"];

		// Check if player is on allies or axis team, in playing state, and has a class defined
		if ( ( player.pers["team"] == "allies" || player.pers["team"] == "axis" ) && player.sessionstate == "playing" && isDefined( player.pers["class"] ) )
		{
			// Check if it's not a knife round or knife rounds are not defined
			if ( isDefined( game["PROMOD_KNIFEROUND"] ) && !game["PROMOD_KNIFEROUND"] || !isDefined( game["PROMOD_KNIFEROUND"] ) )
			{
				// Give frag grenade based on hardcore mode and weapon allowances
				if ( level.hardcoreMode && getDvarInt("weap_allow_frag_grenade") )
					player giveWeapon( "frag_grenade_short_mp" );
				else if ( getDvarInt( "weap_allow_frag_grenade" ) )
					player giveWeapon( "frag_grenade_mp" );

				// Check loadout grenade and give corresponding grenade based on weapon allowance
				if ( player.pers[classType]["loadout_grenade"] == "flash_grenade" && getDvarInt("weap_allow_flash_grenade") )
				{
					player setOffhandSecondaryClass("flash");
					player giveWeapon( "flash_grenade_mp" );
				}
				else if ( player.pers[classType]["loadout_grenade"] == "smoke_grenade" && getDvarInt("weap_allow_smoke_grenade") )
				{
					player setOffhandSecondaryClass("smoke");
					player giveWeapon( "smoke_grenade_mp" );
				}

				// Set sidearm and primary weapons based on class
				player maps\mp\gametypes\_class::sidearmWeapon();
				player maps\mp\gametypes\_class::primaryWeapon();
			}
			// Remove weapons for knife rounds
			else
				player thread maps\mp\gametypes\_globallogic::removeWeapons();

			player allowsprint(true);
			player setMoveSpeedScale( 1.0 - 0.05 * int( isDefined( player.curClass ) && player.curClass == "assault" ) * int( isDefined( game["PROMOD_KNIFEROUND"] ) && !game["PROMOD_KNIFEROUND"] || !isDefined( game["PROMOD_KNIFEROUND"] ) ) );
			player allowjump(true);
		}
	}

	UpdateClientNames();

	// Check if promod timeout has been called
	if ( game["promod_timeout_called"] )
	{
		// Start promod timeout thread and return
		thread promod\timeout::main();
		return;
	}
}

stratTime()
{
	thread stratTimer();

	level.strat_over = false;
	strat_time_left = game["PROMOD_STRATTIME"] + level.prematchPeriod * int( getDvarInt( "promod_allow_strattime" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] && level.gametype == "sd" );

	while ( !level.strat_over )
	{
		players = getentarray("player", "classname");
		for ( i = 0; i < players.size; i++ )
		{
			player = players[i];

			if ( ( player.pers["team"] == "allies" || player.pers["team"] == "axis" ) && !isDefined( player.pers["class"] ) )
				player.statusicon = "hud_status_dead";
		}

		wait 0.25;

		strat_time_left -= 0.25;

		if ( strat_time_left <= 0 || game["promod_timeout_called"] )
			level.strat_over = true;
	}

	level notify( "strat_over" );
}

stratTimer()
{
	matchStartText = createServerFontString( "default", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -60 );
	matchStartText.sort = 1001;

	if( isDefined(game["PROMOD_KNIFEROUND"]) && game["PROMOD_KNIFEROUND"] )
		matchStartText setText( "Knife Round" );
	else
		matchStartText setText( "Strat Time" );

	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = false;

	matchStartTimer = createServerTimer( "default", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, -45 );
	matchStartTimer setTimer( game["PROMOD_STRATTIME"] + level.prematchPeriod * int( getDvarInt( "promod_allow_strattime" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] && level.gametype == "sd" ) );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = false;

	level waittill( "strat_over" );

	if ( isDefined( matchStartText ) )
		matchStartText destroy();

	if ( isDefined( matchStartTimer ) )
		matchStartTimer destroy();
}