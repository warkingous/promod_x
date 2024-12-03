/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;

main()
{
	if ( isDefined( level.scorebot ) && level.scorebot )
	{

		if( game["promod_in_timeout"] )
			sb_text = "timeout";
		else
		{
			if( game["promod_first_readyup_done"] )
				sb_text = "2nd_half";
			else
				sb_text = "1st_half";
		}

		game["promod_scorebot_ticker_buffer"] += "" + sb_text+"_ready_up";
	}

	level.timeLimitOverride = true;
	level.rdyup = true;
	level.rup_txt_fx = true;

	setDvar( "g_deadChat", 1 );
	setClientNameMode( "auto_change" );
	setGameEndTime( 0 );

	thread periodAnnounce();

	level.ready_up_over = false;
	level.ready_up_complete = false;
	previous_not_ready_count = 0;

	thread updatePlayerHUDInterval();
	thread lastPlayerReady();

	userIds = [];

	while ( !level.ready_up_over && game["MATCHMAKING_MODE"] == 1 )
	{
		all_players_ready = true;
		level.not_ready_count = 0;

		if ( level.players.size < 1 )
		{
			all_players_ready = false;

			wait 0.2;
			continue;
		}

		// We need min 2 players to start a match
		// if( level.players.size < 2 )
		// {
		// 	all_players_ready = false;

		// 	wait 0.2;
		// 	continue;
		// }

		if( getDvarInt("fps_match_canceled") == 1 )
		{
			all_players_ready = false;

			wait 0.2;
		 	continue;
		}

		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( !isDefined( player.looped ) )
			{
				player setclientdvar("self_ready", 0);

				player.looped = true;
				player.ready = false;
				player.update = false;
				player.statusicon = "compassping_enemy";
				player thread selfLoop();

				// Added nadetraining in ready-up period even if its not strat mode
				player thread promod\stratmode::nadeTraining();
				
				if ( isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" )
					player thread createExtraHUD();
			}


			player.oldready = player.update;

			if ( player.ready )
			{
				player.update = true;
			}

			if ( !player.ready || isDefined( player.inrecmenu ) && player.inrecmenu && !player promod\client::get_config( "PROMOD_RECORD" ) )
			{
				level.not_ready_count++;
				all_players_ready = false;
				player.update = false;
			}

			player.newready = player.update;

			if ( player.oldready != player.newready && ( !isDefined( player.inrecmenu ) || !player.inrecmenu ) )
			{
				player setclientdvar("self_ready", int(player.ready));
				player.oldready = player.newready;

				if ( player.ready )
					player.statusicon = "compassping_friendlyfiring_mp";
				else
					player.statusicon = "compassping_enemy";
			}
		}

		if(previous_not_ready_count != level.not_ready_count)
		{
			for(i=0;i<level.players.size;i++)
			{
				level.players[i] setclientdvar("waiting_on", level.not_ready_count);
				level.players[i] ShowScoreBoard();
				previous_not_ready_count = level.not_ready_count;
			}
		}

		// Players check
		// if(previous_not_ready_count != level.not_ready_count && level.players.size < 2)
		// {
		// 	for(i=0;i<level.players.size;i++)
		// 	{
		// 		level.players[i] setclientdvar("waiting_on", 1);
		// 		level.players[i] ShowScoreBoard();
		// 		previous_not_ready_count = level.not_ready_count;
		// 	}
		// }


		// Start auto demo record when all players ready-up before 5min timer
		if ( all_players_ready )
		{

			for ( i = 0; i < level.players.size; i++ )
			{
				if( !isDefined( level.players[i].pers["isBot"] ) && isDefined( level.players[i].pers["class"] ) && isDefined( level.players[i].pers["team"] ) && isDefined( level.players[i].pers["userId"] ) )
				{
					userIds[userIds.size] = level.players[i].pers["userId"];
				}
			}

			// Match started with correct amount of players
			if ( userIds.size != 0 && getDvarInt("fps_comp_size") != 0 && userIds.size == getDvarInt("fps_comp_size") )
			{
			
				level.ready_up_over = true;
				level.ready_up_complete = true;

				for ( i = 0; i < level.players.size; i++ )
				{
					if ( !level.players[i] promod\client::get_config( "PROMOD_RECORD" ) && !isDefined( level.players[i].pers["isBot"] ) && isDefined( level.players[i].pers["class"] ) && isDefined( level.players[i].pers["team"] ) && level.players[i].pers["team"] != "spectator" && !level.players[i].pers["recording_executed"] )
					{
						level.players[i] thread startDemoRecord();					
					}
					level.players[i] thread promod\stats::startServerRecord(level.players[i]);
				}	
			}else {

				level.ready_up_over = true;
			}
		}			

		wait 0.05;
	}

	while ( !level.ready_up_over && game["MATCHMAKING_MODE"] == 0 )
	{
		all_players_ready = true;
		level.not_ready_count = 0;

		if ( level.players.size < 1 )
		{
			all_players_ready = false;

			wait 0.2;
			continue;
		}

		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( !isDefined( player.looped ) )
			{
				player setclientdvar("self_ready", 0);

				player.looped = true;
				player.ready = false;
				player.update = false;
				player.statusicon = "compassping_enemy";
				player thread selfLoop();

				// Added nadetraining in ready-up period even if its not strat mode
				player thread promod\stratmode::nadeTraining();
				
				if ( isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" )
					player thread createExtraHUD();
			}


			player.oldready = player.update;

			if ( player.ready )
			{
				player.update = true;
			}

			if ( !player.ready || isDefined( player.inrecmenu ) && player.inrecmenu && !player promod\client::get_config( "PROMOD_RECORD" ) )
			{
				level.not_ready_count++;
				all_players_ready = false;
				player.update = false;
			}

			player.newready = player.update;

			if ( player.oldready != player.newready && ( !isDefined( player.inrecmenu ) || !player.inrecmenu ) )
			{
				player setclientdvar("self_ready", int(player.ready));
				player.oldready = player.newready;

				if ( player.ready )
					player.statusicon = "compassping_friendlyfiring_mp";
				else
					player.statusicon = "compassping_enemy";
			}
		}

		if(previous_not_ready_count != level.not_ready_count)
		{
			for(i=0;i<level.players.size;i++)
			{
				level.players[i] setclientdvar("waiting_on", level.not_ready_count);
				level.players[i] ShowScoreBoard();
				previous_not_ready_count = level.not_ready_count;
			}
		}


		// Start auto demo record when all players ready-up before 5min timer
		if ( all_players_ready )
		{
			level.ready_up_over = true;
			level.ready_up_complete = true;

			for ( i = 0; i < level.players.size; i++ )
			{
				if ( !level.players[i] promod\client::get_config( "PROMOD_RECORD" ) && !isDefined( level.players[i].pers["isBot"] ) && isDefined( level.players[i].pers["class"] ) && isDefined( level.players[i].pers["team"] ) && level.players[i].pers["team"] != "spectator" && !level.players[i].pers["recording_executed"] )
				{
					level.players[i] thread startDemoRecord();					
				}
				level.players[i] thread promod\stats::startServerRecord(level.players[i]);
			}
		}
			

		wait 0.05;
	}

	level notify("kill_ru_period");
	level notify("header_destroy");

	if( level.ready_up_complete )
	{

		// Send match started info TODO
		if( level.fps_is_public == 0 && !game["promod_first_readyup_done"] ){ //level.players.size > 1 && game["PROMOD_KNIFEROUND"] == 0
			thread promod\stats::mapStarted();
			wait 0.1;
			thread promod\stats::initPlayers();
		}

		// Public stats
		if ( level.fps_is_public == 1 )
			thread promod\stats::publicMapStarted();

		for( i = 0;i < level.players.size; i++)
		{
			level.players[i] setclientdvars("self_ready","", "ui_hud_hardcore", 1 );
			level.players[i].statusicon = "";

			// Start automatic demo record when we reach 5min limit in matchmaking mode
			if ( !level.players[i] promod\client::get_config( "PROMOD_RECORD" ) && !isDefined( level.players[i].pers["isBot"] ) && isDefined( level.players[i].pers["class"] ) && isDefined( level.players[i].pers["team"] ) && level.players[i].pers["team"] != "spectator" && !level.players[i].pers["recording_executed"] && game["MATCHMAKING_MODE"] )
				level.players[i] thread startDemoRecord();

			level.players[i] thread promod\stats::startServerRecord(level.players[i]);
		}

		for( i = 0;i < level.players.size; i++)
			level.players[i] ShowScoreBoard();

		game["state"] = "postgame";

		visionSetNaked( "mpIntro", 1 );

		matchStartText = createServerFontString( "default", 1.5 );
		matchStartText setPoint( "CENTER", "CENTER", 0, -75 );
		matchStartText.sort = 1001;
		matchStartText setText( "All Players are Ready!" );
		matchStartText.foreground = false;
		matchStartText.hidewheninmenu = false;
		matchStartText.glowColor = (0.6, 0.64, 0.69);
		matchStartText.glowAlpha = 1;
		matchStartText setPulseFX( 100, 4000, 1000 );

		matchStartText2 = createServerFontString( "default", 1.5 );
		matchStartText2 setPoint( "CENTER", "CENTER", 0, -60 );
		matchStartText2.sort = 1001;
		matchStartText2 setText( game["strings"]["match_starting_in"] );
		matchStartText2.foreground = false;
		matchStartText2.hidewheninmenu = false;

		matchStartTimer = createServerTimer( "default", 1.4 );
		matchStartTimer setPoint( "CENTER", "CENTER", 0, -45 );
		matchStartTimer setTimer( 5 );
		matchStartTimer.sort = 1001;
		matchStartTimer.foreground = false;
		matchStartTimer.hideWhenInMenu = false;

		wait 5;

		visionSetNaked( getDvar( "mapname" ), 1 );

		matchStartText destroyElem();
		matchStartText2 destroyElem();
		matchStartTimer destroyElem();

		game["promod_do_readyup"] = false;
		game["promod_first_readyup_done"] = 1;
		game["state"] = "playing";

		
	} else {

		game["state"] = "postgame";

		visionSetNaked( "mpIntro", 1 );

		matchStartText = createServerFontString( "default", 2 );
		matchStartText setPoint( "CENTER", "CENTER", 0, -75 );
		matchStartText.sort = 1001;
		matchStartText setText( "Match has been cancelled!" );
		matchStartText.foreground = false;
		matchStartText.hidewheninmenu = false;
		matchStartText.glowColor = (1, 0.1, 0.1);
		matchStartText.glowAlpha = 1;
		matchStartText setPulseFX( 100, 10000, 1000 );

		matchStartText2 = createServerFontString( "default", 1.5 );
		matchStartText2 setPoint( "CENTER", "CENTER", 0, -50 );
		matchStartText2.sort = 1001;
		matchStartText2 setText( "Some players did not join in time" );
		matchStartText2.foreground = false;
		matchStartText2.hidewheninmenu = false;
		matchStartText2 setPulseFX( 100, 10000, 1000 );

		matchStartText3 = createServerFontString( "default", 1.5 );
		matchStartText3 setPoint( "CENTER", "CENTER", 0, 50 );
		matchStartText3.sort = 1001;
		matchStartText3 setText( "Leaving game in:" );
		matchStartText3.foreground = false;
		matchStartText3.hidewheninmenu = false;
		matchStartText3 setPulseFX( 100, 10000, 1000 );

		matchStartTimer = createServerTimer( "default", 1.4 );
		matchStartTimer setPoint( "CENTER", "CENTER", 0, 70 );
		matchStartTimer setTimer( 6 );
		matchStartTimer.color = (1, 0.3, 0.3);
		//matchStartTimer setText( "xx" );
		matchStartTimer.sort = 1001;
		matchStartTimer.foreground = false;
		matchStartTimer.hideWhenInMenu = false;

		

		for( i = 0;i < level.players.size; i++)
		{
			level.players[i] setClientDvar( "ui_hud_hardcore", 1 );
			level.players[i] setClientDvar( "match_cancelled", 1 );
			//level.players[i] setclientdvar("self_ready", 1);
			//level.players[i] thread removeWeapons();
			level.players[i] freezeControls( true );
			level.players[i] allowsprint(false);
			level.players[i] allowjump(false);
			level.players[i] setMoveSpeedScale( 0 );
		}

		failSound[0] = "US_1mc_mission_fail";
		failSound[1] = "UK_1mc_mission_fail";
		failSound[2] = "AB_1mc_mission_fail";
		failSound[3] = "RU_1mc_mission_fail";

		finalFailSound = failSound[randomInt(4)];
		playSoundOnPlayers(finalFailSound);

		if( getDvarInt("fps_match_canceled") != 1)
			thread promod\stats::cancelMatch( userIds );
		
		setDvar("fps_match_canceled", 1);

		//iprintln("Game will quit in 5 seconds...");

		wait 7;

		for( i = 0;i < level.players.size; i++)
		{
			level.players[i] setClientDvar("record_string", "quit");
			level.players[i] closeMenu();
			level.players[i] closeInGameMenu();
			level.players[i] openMenu( game["menu_demo"] );
			level.players[i] closeMenu();
		}		

		

		matchStartText destroyElem();
		matchStartText2 destroyElem();
		//matchStartTimer destroyElem();

		game["promod_do_readyup"] = true;
		game["promod_first_readyup_done"] = 0;
		game["state"] = "postgame";

		visionSetNaked( getDvar( "mapname" ), 1 );
		
		wait 15;

	}

	map_restart( true );
}

createExtraHUD()
{
	// Hold hint
	// self.hint1 = newClientHudElem(self);
	// self.hint1.x = -7;
	// self.hint1.y = 266;
	// self.hint1.horzAlign = "right";
	// self.hint1.vertAlign = "top";
	// self.hint1.alignX = "center";
	// self.hint1.alignY = "middle";
	// self.hint1.fontScale = 1.4;
	// self.hint1.font = "default";
	// self.hint1.color = (0.8, 1, 1);
	// self.hint1.hidewheninmenu = true;
	// self.hint1 setText( "" );

	// Immunity hint
	self.hint2 = createFontString( "default", 1.4 );
	self.hint2 setPoint( "CENTER", "CENTER", 0, 183 );
	self.hint2.sort = 1001;
	self.hint2.foreground = false;
	self.hint2.hidewheninmenu = true;
	self.hint2 setText( "" );

}

startDemoRecord()
{
	map_name = toLower( getDvar( "mapname" ) );

	if( level.fps_match_id != 0 )
	{
		demo_name = "FPS_" + level.fps_match_id + "_" + map_name + "_" + generateRandomString(4);
	}		
	else if ( game["LAN_MODE"] )
	{
		demo_name = "LAN_" + map_name + "_" + generateRandomString(8);
	}		
	else 
	{
		demo_name = "Match_" + map_name + "_" + generateRandomString(8);
	}		
	
	self setClientDvar("record_string", "stoprecord;record " + demo_name);
	//self closeMenu();
	//self closeInGameMenu();

	if( level.gametype == "sd" ){
		self openMenu( game["menu_demo"] );
		self closeMenu();
		self.pers["recording_executed"] = true;
	}
}

stopDemoRecord()
{
	self setClientDvar("record_string", "stoprecord");
	self closeMenu();
	self closeInGameMenu();
	self openMenu( game["menu_demo"] );
	self closeMenu();
}

generateRandomString(length)
{    
    list = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    string = "";

    for (i = 0; i < length; i++)
    {
        random_int = randomintrange(0, list.size);
        string += list[random_int];
    }

    return string;
}

lastPlayerReady()
{
	wait 0.5;

	while ( !level.ready_up_over )
	{
		maxwait = 0;
		while ( !level.ready_up_over && level.not_ready_count == 1 && level.players.size > 1 && maxwait <= 5 )
		{
			wait 0.05;
			maxwait += 0.05;
		}

		if( level.not_ready_count == 1 && level.players.size > 1 )
		{
			for(i=0;i<level.players.size;i++)
			{
				player = level.players[i];

				if( player.ready )
				{
					player.soundplayed = undefined;
					player.timesplayed = undefined;
				}
				else
				{
					if ( ( !isDefined( player.soundplayed ) || gettime() - 20000 > player.soundplayed ) && ( !isDefined( player.timesplayed ) || player.timesplayed < 4 ) && ( !isDefined( player.inrecmenu ) || !player.inrecmenu ) )
					{
						player PlayLocalSound( player maps\mp\gametypes\_quickmessages::getSoundPrefixForTeam()+"1mc_lastalive" );
						player.soundplayed = gettime();

						if ( isDefined( player.timesplayed ) )
							player.timesplayed++;
						else
							player.timesplayed = 1;
					}
				}
			}
		}

		wait 0.05;
	}
}

updatePlayerHUDInterval()
{
	level endon("kill_ru_period");

	while ( !level.ready_up_over )
	{
		wait 5;

		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			if ( isDefined( player ) )
			{
				if ( isDefined( player.ready ) && !isDefined( player.inrecmenu ) )
					player setclientdvar("self_ready", int(player.ready));

				if ( isDefined( level.not_ready_count ) )
					player setclientdvar("waiting_on", level.not_ready_count);
			}
		}
	}
}

selfLoop()
{
	self endon("disconnect");

	self thread onSpawn();
	self thread clientHUD();

	self setClientDvar( "self_kills", "" );

	while ( !level.ready_up_over )
	{
		while ( !isDefined( self.pers["team"] ) || self.pers["team"] == "none" )
			wait 0.05;
		
		// Spectator & bots always ready
		while ( self.pers["team"] == "spectator" || isDefined( self.pers["isBot"] ) )
		{
			self.ready = true;
			wait 0.05;
		}
			

		wait 0.05;

		// Return back to position fix - so we dont ready up by accident
		if(isDefined( self.flying ) && self.flying )
		{
			//do nothing
		}
		else 
		{
			if ( self useButtonPressed() )
			self.ready = !self.ready;
		}

		while ( self useButtonPressed() )
			wait 0.1;
		
		// Change hint for disabling killing
		if ( !isDefined( self.ruptally ) || self.ruptally == -1 )
		{
			//self.hint1 setText( "" );
			if( isDefined( self.hint2 ))
				self.hint2 setText( "" );
		}
		else {
			//self.hint1 setText( "Hold ^3[{+melee}]" );
			if( isDefined( self.hint2 ))
				self.hint2 setText( "Hold ^3[{+melee}]^7 for Immunity" );
		}
			

		// Add functionality to turn off the ability to be killed or flashed
		if ( self meleeButtonPressed() )
		{
			wait 0.1;

			holdButtonTime = 0;
			while ( holdButtonTime < 0.5 && self meleeButtonPressed() )
			{
				holdButtonTime += 0.05;
				wait 0.05;
			}

			if ( holdButtonTime > 0.35 )
			{
				if ( isDefined( self.ruptally ) )
				{
					self.ruptally = undefined;
					self setclientdvar("self_kills", "");					
				}
			}

			while ( self meleeButtonPressed() )
				wait 0.05;
		}
	}
}


clientHUD()
{
	self endon("disconnect");

	if ( !game["promod_first_readyup_done"] )
		self waittill("spawned_player");

	//text = "";
	//if ( !game["promod_first_readyup_done"] )
	//	text = "Pre-Match";
	//else if ( game["promod_in_timeout"] )
	//	text = "Timeout";
	//else
	//	text = "Half-Time";

	//self.periodtext = createFontString( "default", 1.6 );
	//self.periodtext setPoint( "CENTER", "CENTER", 0, -75 );
	//self.periodtext.sort = 1001;
	//self.periodtext setText( text + " Ready-Up Period" );
	//self.periodtext.foreground = false;
	//self.periodtext.hidewheninmenu = true;

	self.halftimetext = createFontString( "default", 1.5 );
	self.halftimetext.alpha = 0;
	self.halftimetext setPoint( "CENTER", "CENTER", 0, 200 );
	self.halftimetext.sort = 1001;

	self.halftimetext.foreground = false;
	self.halftimetext.hidewheninmenu = true;

	if ( game["promod_first_readyup_done"] && game["promod_in_timeout"] && (!isDefined( game["LAN_MODE"] ) || !game["LAN_MODE"]) || game["MATCHMAKING_MODE"] && !game["promod_first_readyup_done"] && !game["promod_in_timeout"])
		text = "Remaining";
	else
		text = "Elapsed";

	self.halftimetext setText( "Time " + text );

	self thread moveOver();

	level waittill("kill_ru_period");

	//if ( isDefined( self.periodtext ) )
	//	self.periodtext destroy();

	if ( isDefined( self.halftimetext ) )
		self.halftimetext destroy();

}

onSpawn()
{
	self endon("disconnect");

	while ( !level.ready_up_over )
	{
		self waittill("spawned_player");
		self iprintlnbold("Press ^3[{+activate}] ^7to Ready-Up");
	}
}

periodAnnounce()
{
	level.halftimetimer = createServerTimer( "default", 1.4 );
	level.halftimetimer.alpha = 0;
	level.halftimetimer setPoint( "CENTER", "CENTER", 0, 215 );

	if ( !game["promod_in_timeout"] || isDefined( game["LAN_MODE"] ) && game["LAN_MODE"] )
		level.halftimetimer setTimerUp( 0 );
	else
	{
		if( ( game["MATCHMAKING_MODE"] ) )
			level.halftimetimer setTimer( 120 );
		else
			level.halftimetimer setTimer( 300 );
	}

	if( ( game["MATCHMAKING_MODE"] ) && !game["promod_in_timeout"])
	{
		level.timeout_over = false;
		level.halftimetimer setTimer( 180 );
		level.timeout_time_left = 180;
		thread promod\timeout::timeoutLoop();
	}
	

	level.halftimetimer.sort = 1001;
	level.halftimetimer.foreground = false;
	level.halftimetimer.hideWhenInMenu = true;

	level waittill("kill_ru_period");

	if ( isDefined( level.halftimetimer ) )
		level.halftimetimer destroy();
}

moveOver()
{
	level endon("kill_ru_period");
	self endon("disconnect");

	//if( level.rup_txt_fx )
	//{
	//	wait 3;
	//	self.periodtext MoveOverTime( 2.5 );
	//}


	if( level.rup_txt_fx )
	{
		wait 2.6;
		if( isDefined( level.halftimetimer ) )
			level.halftimetimer.alpha = 1;
		level.rup_txt_fx = false;
	}

	if( isDefined( self.halftimetext ) )
		self.halftimetext.alpha = 1;
}
