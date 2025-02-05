/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	level endon( "restarting" );

	thread errorMessage();
	thread backlotCheck();
	//thread serverCheck();

	for(;;)
	{
		if ( getDvarInt( "sv_cheats" ) || isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" )
			break;

		forceDvar( "authServerName", "cod4master.activision.com" );
		forceDvar( "sv_disableClientConsole", "0" );
		forceDvar( "sv_fps", "20" );
		forceDvar( "sv_pure", "1" );
		// CoD4X supports 100 000, stock client doesnt
		//forceDvar( "sv_maxrate", "100000" );
		forceDvar( "g_gravity", "800" );
		forceDvar( "g_speed", "190" );
		forceDvar( "g_knockback", "1000" );
		forceDvar( "g_playercollisionejectspeed", "25" );
		forceDvar( "g_dropforwardspeed", "10" );
		forceDvar( "g_drophorzspeedrand", "100" );
		forceDvar( "g_dropupspeedbase", "10" );
		forceDvar( "g_dropupspeedrand", "5" );
		forceDvar( "g_useholdtime", "0" );

		if( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" )
		{
			forceDvar( "g_maxdroppedweapons", "16" );

			if ( !game["LAN_MODE"] )
				forceDvar( "g_smoothclients", "1" );
		}

		wait 0.1;
	}
}

serverCheck()
{
    level endon( "restarting" );  // End if the server restarts

    for(;;)
    {
        // Stop checking if cheats are enabled or the match mode is "strat"
        if ( getDvarInt( "sv_cheats" ) || (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "strat") )
            break;

        // Initialize variables to track if all checks are successful
        allPluginsLoaded = true;
        allSettingsCorrect = true;

        // Check individual plugins
        ipPluginLoaded = getDvarInt("ipPluginLoaded");
        if (!ipPluginLoaded) {
            iprintlnbold("^1Plugin Check Failed^7: IP Plugin is not loaded.");
            allPluginsLoaded = false;
        }

        ddPluginLoaded = getDvarInt("ddPluginLoaded");
        if (!ddPluginLoaded) {
            iprintlnbold("^1Plugin Check Failed^7: DD Plugin is not loaded.");
            allPluginsLoaded = false;
        }

        // chatPluginLoaded = getDvarInt("chatPluginLoaded");
        // if (!chatPluginLoaded) {
        //     iprintlnbold("^1Plugin Check Failed^7: Chat Plugin is not loaded.");
        //     allPluginsLoaded = false;
        // }

        demoPluginLoaded = getDvarInt("demoPluginLoaded");
        if (!demoPluginLoaded) {
            iprintlnbold("^1Plugin Check Failed^7: Demo Plugin is not loaded.");
            allPluginsLoaded = false;
        }

        authPluginLoaded = getDvarInt("authPluginLoaded");
        if (!authPluginLoaded) {
            iprintlnbold("^1Plugin Check Failed^7: Auth Plugin is not loaded.");
            allPluginsLoaded = false;
        }

        // Server settings checks
        steamForce = getDvar("sv_steamforce");
        if (steamForce != "Require Steam but use PlayerIDs") {
            iprintlnbold("^1Server Violation^7: sv_steamforce is not set to 2.");
            allSettingsCorrect = false;
        }

        noSteamNames = getDvarInt("sv_nosteamnames");
        if (!noSteamNames) {
            iprintlnbold("^1Server Violation^7: sv_nosteamnames is not enabled.");
            allSettingsCorrect = false;
        }

        friendlyBlock = getDvarInt("g_friendlyPlayerCanBlock");
        if (!friendlyBlock) {
            iprintlnbold("^1Server Violation^7: g_friendlyPlayerCanBlock is not enabled.");
            allSettingsCorrect = false;
        }

        // antilag = getDvarInt("g_antilag");
        // if (!antilag) {
        //     iprintlnbold("^1Server Violation^7: g_antilag is not enabled.");
        //     allSettingsCorrect = false;
        // }

        svFps = getDvarInt("sv_fps");
        if (svFps != 20) {
            iprintlnbold("^1Server Violation^7: sv_fps is not set to 20.");
            allSettingsCorrect = false;
        }

        // If all plugins and settings are correct, set serverReady to true
        if (allPluginsLoaded && allSettingsCorrect) {
            serverReady = true;
            //iprintlnbold("^2Server setup complete! All plugins and settings are correctly configured.");
        } else {
            serverReady = false;
        }

        // Wait 2 seconds before repeating the checks
        wait 2;
    }
}

backlotCheck()
{
	counter = 3;

	for(i = 0; i < counter; i++)
	{
		if ( getDvarInt( "sv_cheats" ) || (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "strat") )
            break;

		if( level.script == "mp_backlot" || level.script == "mp_backlot_fix")
			iprintlnbold("^1Warning^7: You should play ^3mp_backlot_x ^7instead of " + level.script);

		wait 10;
	}	
}

forceDvar(dvar, value)
{
	val = getDvar( dvar );
	if( val != value )
	{
		setDvar( dvar, value );
		iprintln("^3"+dvar+" has been changed back to '"+value+"' (was '"+val+"')");
	}
}

errorMessage()
{
	level endon( "restarting" );

	for(;;)
	{
		if ( getDvarInt( "sv_cheats" ) || isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" )
			break;

		// Punkbuster is removed from CoD4X servers
		//if ( !getDvarInt( "sv_punkbuster" ) && !game["LAN_MODE"] && !game["PROMOD_PB_OFF"] )
		//	iprintlnbold("^1Server Violation^7: Punkbuster Disabled");

		if ( getDvarInt( "scr_player_maxhealth" ) != 100 && game["HARDCORE_MODE"] != 1 && game["CUSTOM_MODE"] != 1 || getDvarInt( "scr_player_maxhealth" ) != 30 && game["HARDCORE_MODE"] == 1 && game["CUSTOM_MODE"] != 1 )
			iprintlnbold("^1Server Violation^7: Modified Player Health");

		antilag = getDvarInt( "g_antilag" );
		dedicated = getDvar( "dedicated" );
		if ( (antilag && dedicated == "dedicated LAN server") || (!antilag && dedicated == "dedicated internet server" && !game["PROMOD_PB_OFF"]))
		 	iprintlnbold("^1Server Violation^7: Modified Connection");

		if( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" || toLower( getDvar( "fs_game" ) ) == "mods/fps_promod_276" )
		{
			if( toLower(getDvar("fs_game")) != "mods/fps_promod_276" )
				iprintlnbold("^1Server Violation^7: Invalid fs_game value");

			iwdnames = strToK( getDvar( "sv_iwdnames" ), " " );
			iwdsums = strToK( getDvar( "sv_iwds" ), " " );
			iwd_loaded = false;
			for(i=0;i<iwdnames.size;i++)
			{
				switch(iwdnames[i])
				{
					case "iw_00":
					case "iw_01":
					case "iw_02":
					case "iw_03":
					case "iw_04":
					case "iw_05":
					case "iw_06":
					case "iw_07":
					case "iw_08":
					case "iw_09":
					case "iw_10":
					case "iw_11":
					case "iw_12":
					case "iw_13":
						break;

					case "z_c_r":
						if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" && iwdsums[i] != "-2064692340" )
							iprintlnbold("^1Server Violation^7: Modified Custom IWD File While In Match Mode");
						break;
						
					case "fps_promod_276":
						if( iwdsums[i] != "523046345" )
							iprintlnbold("^1Server Violation^7: Modified Promod IWD Detected");
						iwd_loaded = true;
						break;
						
					// Extra CoD4X files check
					case "jcod4x_00":
						if( iwdsums[i] != "94291723" )
							iprintlnbold("^1Server Violation^7: Modified CoD4X IWD Detected");
						break;

					default:
						if( !isCustomMap() || !isSubStr(iwdnames[i], level.script ) )
							iprintlnbold("^1Server Violation^7: Extra IWD Files Detected");
						break;
				}
			}
			if(!iwd_loaded)
				iprintlnbold("^1Server Violation^7: Promod IWD Not Loaded");
		}

		wait 2;
	}
}

isCustomMap()
{
	switch(level.script)
	{
		case "mp_backlot":
		case "mp_bloc":
		case "mp_bog":
		case "mp_broadcast":
		case "mp_carentan":
		case "mp_cargoship":
		case "mp_citystreets":
		case "mp_convoy":
		case "mp_countdown":
		case "mp_crash":
		case "mp_crash_snow":
		case "mp_creek":
		case "mp_crossfire":
		case "mp_farm":
		case "mp_killhouse":
		case "mp_overgrown":
		case "mp_pipeline":
		case "mp_shipment":
		case "mp_showdown":
		case "mp_strike":
		case "mp_vacant":
			return false;
	}
	return true;
}
