/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	if ( !isDefined( level.tweakablesInitialized ) )
		maps\mp\gametypes\_tweakables::init();

	level.splitscreen = 0;
	level.xenon = 0;
	level.ps3 = 0;
	level.console = 0;
	level.oldschool = 0;

	level.onlineGame = false;
	level.rankedMatch = false;

	level.script = toLower( getDvar( "mapname" ) );
	level.gametype = toLower( getDvar( "g_gametype" ) );

	checkRestartMap();

	level.otherTeam["allies"] = "axis";
	level.otherTeam["axis"] = "allies";

	level.teamBased = false;

	level.overrideTeamScore = false;
	level.overridePlayerScore = false;
	level.displayHalftimeText = false;
	level.displayRoundEndText = true;

	level.endGameOnScoreLimit = true;
	level.endGameOnTimeLimit = true;

	precacheString( &"MP_HALFTIME" );
	precacheString( &"MP_OVERTIME" );
	precacheString( &"MP_ROUNDEND" );
	precacheString( &"MP_INTERMISSION" );
	precacheString( &"MP_SWITCHING_SIDES" );
	precacheString( &"MP_CONNECTED" );

	level.halftimeType = "halftime";
	level.halftimeSubCaption = &"MP_SWITCHING_SIDES";

	level.lastStatusTime = 0;
	level.wasWinning = "none";

	level.lastSlowProcessFrame = 0;

	level.placement["allies"] = [];
	level.placement["axis"] = [];
	level.placement["all"] = [];

	level.postRoundTime = 5;

	level.inOvertime = false;

	level.players = [];

	level.shoutbars = [];

	registerDvars();
	registerMatchDvars();
	registerPingWatchDvars();

	precacheModel( "tag_origin" );

	precacheShader( "faction_128_usmc" );
	precacheShader( "faction_128_arab" );
	precacheShader( "faction_128_ussr" );
	precacheShader( "faction_128_sas" );
	precacheShader("line_horizontal");

	if ( !isDefined( game["tiebreaker"] ) )
		game["tiebreaker"] = false;

	if ( !isDefined( game["gamestarted"] ) )
		promod\modes::main();

	level.hardcoreMode = getDvarInt( "scr_hardcore" );
	level.roundswitch = getDvarInt( "scr_" + level.gametype + "_roundswitch" );
	level.roundLimit = getDvarInt( "scr_" + level.gametype + "_roundlimit" );
	level.timelimit = getDvarFloat( "scr_" + level.gametype + "_timelimit" );
	level.scoreLimit = getDvarInt( "scr_" + level.gametype + "_scorelimit" );
	level.numLives = getDvarInt( "scr_" + level.gametype + "_numlives" );

	// Overtime variable
	level.overtimeRoundSwitch = getDvarInt("scr_" + level.gametype + "_ot_roundlimit");

	setDvar( "ui_scorelimit", level.scoreLimit );
	setDvar( "ui_timelimit", level.timelimit );

	if ( level.hardcoreMode )
		setDvar( "scr_player_maxhealth", 30 );
	else
		setDvar( "scr_player_maxhealth", 100 );

	// Stats variables
	if ( !isDefined( game["alliesTeamId"] ) ){
		game["alliesTeamId"] = -1;
		game["alliesTeamName"] = "Not defined";
		game["alliesTeamTag"] = "Not defined";
	}

	if ( !isDefined( game["axisTeamId"] ) ){
		game["axisTeamId"] = -1;
		game["axisTeamName"] = "Not defined";
		game["axisTeamTag"] = "Not defined";
	}
		
	
	// So we can track overtimes
	//game["totalroundsplayed"] = 0;
	
	// AC + Extra functionality
	if( level.match_id != 0 )
	{	
		promod\ac::main();
	}

}

registerDvars()
{
	setDvar( "ui_bomb_timer", 0 );
	makeDvarServerInfo( "ui_bomb_timer" );
}

registerMatchDvars()
{
	// Set custom branding
	if ( getDvar( "branding" ) == "" )
	{
		setDvar( "branding", 0 );
		level.branding = 0;
	}    	
	else {
		level.branding = 1;
		level.branding_name = getDvar( "branding_name" );
		level.branding_shortcut = getDvar( "branding_shortcut" );
		level.branding_url = getDvar( "branding_url" );
	}

	// Set server match_id
	if ( getDvar( "match_id" ) == "" )
	{
		setDvar( "match_id", 0 );
		level.match_id = 0;
	}    	
	else
		level.match_id =  getDvarInt( "match_id" );

	//Set server track_pub_stats
	if ( getDvar( "track_pub_stats" ) == "" )
	{
		setDvar( "track_pub_stats", 0 );
		level.track_pub_stats = 0;
	}    	
	else
		level.track_pub_stats = getDvarInt( "track_pub_stats" );

	// Set server type
	if ( getDvar( "is_public" ) == "" )
	{
		setDvar( "is_public", 0 );
		level.is_public = 0;
	}    	
	else
		level.is_public = getDvarInt( "is_public" );
}

registerPingWatchDvars()
{
	level.ping_force = getDvarInt( "ping_force" );

	// Set server max_ping
	if ( getDvar( "max_ping" ) == "" )
		setDvar( "max_ping", 100 ); 	
	else
		level.max_ping =  getDvarInt( "max_ping" );

	if ( getDvar( "ping_allowed_players" ) == "" )
		setDvar (  "ping_allowed_players", 0 );
	else {
		level.steamIds = strtok(getDvar("ping_allowed_players"), ",");
	}
		
}

SetupCallbacks()
{
	level.spawnPlayer = ::spawnPlayer;
	level.spawnClient = ::spawnClient;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;
	level.onPlayerScore = ::default_onPlayerScore;
	level.onTeamScore = ::default_onTeamScore;

	level.onXPEvent = ::onXPEvent;
	level.waveSpawnTimer = ::waveSpawnTimer;

	level.onSpawnPlayer = ::blank;
	level.onSpawnSpectator = ::default_onSpawnSpectator;
	level.onSpawnIntermission = ::default_onSpawnIntermission;
	level.onRespawnDelay = ::blank;

	level.onTimeLimit = ::default_onTimeLimit;
	level.onScoreLimit = ::default_onScoreLimit;
	level.onDeadEvent = ::default_onDeadEvent;
	level.onOneLeftEvent = ::default_onOneLeftEvent;
	level.giveTeamScore = ::giveTeamScore;
	level.givePlayerScore = ::givePlayerScore;

	level._setTeamScore = ::_setTeamScore;
	level._setPlayerScore = ::_setPlayerScore;

	level._getTeamScore = ::_getTeamScore;
	level._getPlayerScore = ::_getPlayerScore;

	level.onPrecacheGametype = ::blank;
	level.onStartGameType = ::blank;
	level.onPlayerConnect = ::blank;
	level.onPlayerDisconnect = ::blank;
	level.onPlayerDamage = ::blank;
	level.onPlayerKilled = ::blank;

	level.onEndGame = ::blank;

	level.autoassign = ::menuAutoAssign;
	level.spectator = ::menuSpectator;
	level.killspec = ::menuKillspec;
	level.allies = ::menuAllies;
	level.axis = ::menuAxis;
}

WaitTillSlowProcessAllowed()
{
	while ( level.lastSlowProcessFrame == gettime() )
		wait 0.05;

	level.lastSlowProcessFrame = gettime();
}

blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{
}

default_onDeadEvent( team )
{
	if ( team == "allies" )
	{
		iPrintLn( game["strings"]["allies_eliminated"] );
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["allies_eliminated"] );
		setDvar( "ui_text_endreason", game["strings"]["allies_eliminated"] );

		thread endGame( "axis", game["strings"]["allies_eliminated"], "allies_eliminated" );
		logPrint("endGame from 1 \n");
		iprintln("Allies eliminated from gl");
	}
	else if ( team == "axis" )
	{
		iPrintLn( game["strings"]["axis_eliminated"] );
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["axis_eliminated"] );
		setDvar( "ui_text_endreason", game["strings"]["axis_eliminated"]);

		thread endGame( "allies", game["strings"]["axis_eliminated"], "axis_eliminated" );
		logPrint("endGame from 2 \n");
		iprintln("Axis eliminated from gl");
	}
	else
	{
		makeDvarServerInfo( "ui_text_endreason", game["strings"]["tie"] );
		setDvar( "ui_text_endreason", game["strings"]["tie"] );

		if ( level.teamBased )
		{
			thread endGame( "tie", game["strings"]["tie"], "draw" );
			logPrint("endGame from 3 \n");
		}
		else
		{
			thread endGame( undefined, game["strings"]["tie"], "draw" );
			logPrint("endGame from 4 \n");
		}
	}
}

default_onOneLeftEvent( team )
{
	if ( !level.teamBased )
	{
		winner = getHighestScoringPlayer();
		thread endGame( winner, &"MP_ENEMIES_ELIMINATED", "enemies_eliminated" );
		logPrint("endGame from 5 \n");
	}
}

default_onTimeLimit()
{
	winner = undefined;

	// Check if the game is team-based
	if ( level.teamBased )
	{
		// Check if the scores of both teams are equal
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";

		// Check which team has the higher score
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
	}
	else
		// If it's not team-based, determine the highest-scoring player as the winner
		winner = getHighestScoringPlayer();

	// Set the end reason text for the UI
	makeDvarServerInfo( "ui_text_endreason", game["strings"]["time_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["time_limit_reached"] );

	// Start a thread to end the game
	thread endGame( winner, game["strings"]["time_limit_reached"], "time_limit_reached" );
	logPrint("endGame from 6 \n");
}

default_onScoreLimit()
{
	// Check if the end game on score limit is disabled
	if ( !level.endGameOnScoreLimit )
		return;

	winner = undefined;

	// Check if the game is team-based
	if ( level.teamBased )
	{
		// Check if the scores of both teams are equal
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		// Check which team has the higher score
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
	}
	else
		// If it's not team-based, determine the highest-scoring player as the winner
		winner = getHighestScoringPlayer();

	// Set the end reason text for the UI
	makeDvarServerInfo( "ui_text_endreason", game["strings"]["score_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["score_limit_reached"] );

	level.forcedEnd = true;

	// Start a thread to end the game
	thread endGame( winner, game["strings"]["score_limit_reached"], "score_limit_reached" );
	logPrint("endGame from 7 \n");
}

updateGameEvents()
{
	// Check if there are no remaining lives and not in overtime, or in the grace period
	if ( ( !level.numLives && !level.inOverTime ) || level.inGracePeriod )
		return;

	if ( level.teamBased )
	{
		// Check if both teams ever existed and have no remaining lives and no remaining players
		if ( level.everExisted["allies"] && !level.aliveCount["allies"] && level.everExisted["axis"] && !level.aliveCount["axis"] && !level.playerLives["allies"] && !level.playerLives["axis"] )
		{
			[[level.onDeadEvent]]( "all" );
			return;
		}

		// Check if the "allies" team ever existed, has no remaining players and no remaining lives
		if ( level.everExisted["allies"] && !level.aliveCount["allies"] && !level.playerLives["allies"] )
		{
			[[level.onDeadEvent]]( "allies" );
			return;
		}

		// Check if the "axis" team ever existed, has no remaining players and no remaining lives
		if ( level.everExisted["axis"] && !level.aliveCount["axis"] && !level.playerLives["axis"] )
		{
			[[level.onDeadEvent]]( "axis" );
			return;
		}

		// Check if the "allies" team had more than one player alive, and now only one player and one life remaining
		if ( level.lastAliveCount["allies"] > 1 && level.aliveCount["allies"] == 1 && level.playerLives["allies"] == 1 )
		{
			[[level.onOneLeftEvent]]( "allies" );
			return;
		}

		// Check if the "axis" team had more than one player alive, and now only one player and one life remaining
		if ( level.lastAliveCount["axis"] > 1 && level.aliveCount["axis"] == 1 && level.playerLives["axis"] == 1 )
		{
			[[level.onOneLeftEvent]]( "axis" );
			return;
		}
	}
	else
	{
		// Check if neither the "allies" nor the "axis" team has any remaining players or lives, and there are more than one player in the game
		if ( (!level.aliveCount["allies"] && !level.aliveCount["axis"]) && (!level.playerLives["allies"] && !level.playerLives["axis"]) && level.maxPlayerCount > 1 )
		{
			[[level.onDeadEvent]]( "all" );
			return;
		}

		// Check if there is only one player remaining in the game and one life remaining, and there are more than one player in the game
		if ( (level.aliveCount["allies"] + level.aliveCount["axis"] == 1) && (level.playerLives["allies"] + level.playerLives["axis"] == 1) && level.maxPlayerCount > 1 )
		{
			[[level.onOneLeftEvent]]( "all" );
			return;
		}
	}
}

matchStartTimer()
{
	visionSetNaked( "mpIntro", 0 );

	// Create and position the match start text element
	matchStartText = createServerFontString( "default", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -60 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["match_starting_in"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;

	// Create and position the match start timer element
	matchStartTimer = createServerTimer( "default", 1.4 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, -45 );
	matchStartTimer setTimer( level.prematchPeriod );
	matchStartTimer.sort = 1001;
	matchStartTimer.foreground = false;
	matchStartTimer.hideWhenInMenu = true;

	// Wait for the pre-match period
	wait level.prematchPeriod;

	// Set the vision to the map name and show it
	visionSetNaked( getDvar( "mapname" ), 1 );

	// Destroy the match start text and timer elements
	matchStartText destroyElem();
	matchStartTimer destroyElem();
}

matchStartTimerSkip()
{
	visionSetNaked( getDvar( "mapname" ), 0 );
}

spawnPlayer()
{
	prof_begin( "spawnPlayer_preUTS" );

	// Set up event handlers for various player events
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("joined_team");
	self notify("spawned");
	self notify("end_respawn");

	self setSpawnVariables();

	if ( isDefined( self.proxBar ) )
		self.proxBar destroyElem();
	if ( isDefined( self.proxBarText ) )
		self.proxBarText destroyElem();
	if ( isDefined( self.xpBar ) )
		self.xpBar destroyElem();

	if ( level.teamBased )
		self.sessionteam = self.team;
	else
		self.sessionteam = "none";

	hadSpawned = self.hasSpawned;

	// Set player session state and related variables
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;

	// Set player's maximum health and current health to default values
	self.maxhealth = maps\mp\gametypes\_tweakables::getTweakableValue( "player", "maxhealth" );
	self.health = self.maxhealth;

	// Update player's spawn status and spawn time
	self.hasSpawned = true;
	self.spawnTime = getTime();

	// Decrement player's lives if applicable
	if ( self.pers["lives"] )
		self.pers["lives"]--;

	// Check if the player was alive at the start of the match
	if ( !self.wasAliveAtMatchStart )
	{
		acceptablePassedTime = 20;
		if ( level.timeLimit > 0 && acceptablePassedTime < level.timeLimit * 15 )
			acceptablePassedTime = level.timeLimit * 15;

		if ( level.inGracePeriod || getTimePassed() < acceptablePassedTime * 1000 )
			self.wasAliveAtMatchStart = true;
	}

	[[level.onSpawnPlayer]]();

	prof_end( "spawnPlayer_preUTS" );

	level thread updateTeamStatus();

	prof_begin( "spawnPlayer_postUTS" );

	// Give loadout or remove weapons based on game mode and settings
	if ( isDefined( game["PROMOD_KNIFEROUND"] ) && game["PROMOD_KNIFEROUND"] && isDefined( level.strat_over ) && level.strat_over )
		self thread removeWeapons();
	else
		self maps\mp\gametypes\_class::giveLoadout( self.team, self.class );

	// Handle player controls and HUD messages based on game state
	if ( level.inPrematchPeriod && game["promod_do_readyup"] )
		self freezeControls( true );
	else if ( level.inPrematchPeriod )
	{
		self freezeControls( true );

		team = self.pers["team"];
		thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team] );
	}
	else
	{
		self freezeControls( false );
		self enableWeapons();
		if ( !hadSpawned && isDefined( game["state"] ) && game["state"] == "playing" )
		{
			team = self.team;
			thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"][team + "_name"], undefined, game["icons"][team], game["colors"][team] );
		}
	}

	// Disable certain player actions if the strat is not over
	if ( isDefined( level.strat_over ) && !level.strat_over )
	{
		self allowsprint(false);
		self allowjump(false);
		self setMoveSpeedScale( 0 );
	}

	prof_end( "spawnPlayer_postUTS" );

	wait 0.1;

	// Notify that the player has spawned
	self notify( "spawned_player" );

	// Fixed demo recording over-writing bug, also mouse cursor bug on map end
	if (!isDefined(self.pers["recording_executed"]))
		self.pers["recording_executed"] = false;

	if ( !isDefined( self.pers["isBot"] ) && isDefined( self.pers["team"] ) && self.pers["team"] != "spectator" && game["roundsplayed"] > 0 && level.is_public == 0 ) //level.gametype == "sd"
    {
		if( !self promod\client::get_config( "PROMOD_RECORD" ) && !self.pers["recording_executed"] )
        	self thread promod\readyup::startDemoRecord();

		self thread promod\stats::startServerRecord( self );
	}
	
	

	// Freeze the player for the round end if it is the post-game state
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		self freezePlayerForRoundEnd();

	waittillframeend;

	// Clear the status icon if the "rdyup" variable is not defined or is false
	if ( !isDefined( level.rdyup ) || !level.rdyup )
		self.statusicon = "";

	// Update player information for Promod shoutcasting
	self promod\shoutcast::updatePlayer();
}

// Remove weapons for knife round
removeWeapons()
{
	// Set up event handler for player disconnection
	self endon("disconnect");

	// Give the player their loadout based on their team and class
	self maps\mp\gametypes\_class::giveLoadout( self.team, self.class );

	wait 0.05;

	attachment = "";
	// Determine the attachment for the sidearm weapon based on the player's class
	if(self.pers[self.pers["class"]]["loadout_secondary_attachment"] == "silencer")
		attachment = "_silencer";

	// Determine the sidearm weapon based on the player's class and attachment
	sidearmWeapon = self.pers[self.pers["class"]]["loadout_secondary"]+attachment+"_mp";

	// Take away all weapons from the player
	self takeAllWeapons();

	// Give the player the specific sidearm weapon
	self giveWeapon(sidearmWeapon, 0);
	self setweaponammoclip(sidearmWeapon, 0);
	self setweaponammostock(sidearmWeapon, 0);
	// Switch the player to the sidearm weapon
	self switchtoWeapon(sidearmWeapon);
	// Set a client-side dvar to show enemies on the compass
	self setclientdvar("g_compassShowEnemies", 1);
}

spawnSpectator( origin, angles )
{
	// Notify that the player has spawned and end the respawn notification
    self notify("spawned");
    self notify("end_respawn");

	in_spawnSpectator( origin, angles );
}

respawn_asSpectator( origin, angles )
{
	in_spawnSpectator( origin, angles );
}

in_spawnSpectator( origin, angles )
{
	self setSpawnVariables();

	// Clear lower message if the player's team is "spectator"
	if ( self.pers["team"] == "spectator" )
		self clearLowerMessage();

	// Set session state and related variables for spectator
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;

	if(self.pers["team"] == "spectator")
	{
		// Clear status icon if "rdyup" variable is not defined or false
		if ( !isDefined( level.rdyup ) || !level.rdyup )
			self.statusicon = "";

		// Start monitoring free look if it's not already defined
		if ( !isDefined( self.freelook ) )
			self thread monitorFreeLook();
	}

	// Set spectate permissions
	maps\mp\gametypes\_spectating::setSpectatePermissions();

	[[level.onSpawnSpectator]]( origin, angles );

	// Update team status in the level thread
	level thread updateTeamStatus();
}

getPlayerFromClientNum( clientNum )
{
	if ( clientNum < 0 )
		return undefined;

	// Iterate through the level players
	for ( i = 0; i < level.players.size; i++ )
	{
		// Check if the entity number of the player matches the client number
		if ( level.players[i] getEntityNumber() == clientNum )
			return level.players[i];
	}
	// If no player entity is found, return undefined
	return undefined;
}

waveSpawnTimer()
{
	// End the function if the game has ended
	level endon( "game_ended" );

	// Continuously execute the following code while the game state is "playing"
	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		time = getTime();

		// Check if enough time has passed for the Allies wave to respawn
		if ( time - level.lastWave["allies"] > (level.waveDelay["allies"] * 1000) )
		{
			// Trigger the "wave_respawn_allies" notification
			level notify ( "wave_respawn_allies" );
			// Update the last wave time and reset the player spawn index for Allies
			level.lastWave["allies"] = time;
			level.wavePlayerSpawnIndex["allies"] = 0;
		}
		// Check if enough time has passed for the Axis wave to respawn
		if ( time - level.lastWave["axis"] > (level.waveDelay["axis"] * 1000) )
		{
			// Trigger the "wave_respawn_axis" notification
			level notify ( "wave_respawn_axis" );
			// Update the last wave time and reset the player spawn index for Axis
			level.lastWave["axis"] = time;
			level.wavePlayerSpawnIndex["axis"] = 0;
		}
		// Wait for a short duration before checking again
		wait 0.05;
	}
}

freeLook( condition )
{
	// Check if the game spectator type is set to 1 (free look)
	if ( getDvarInt( "scr_game_spectatetype" ) == 1 )
	{
		if ( condition )
			wait 0.1;
			
		// Iterate through the level players
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( player.pers["team"] == "spectator" )
			{
				// If the player's free look mode is not defined or false, allow or disallow spectating in free look mode based on the condition
				if ( !isDefined( player.freelook ) || !player.freelook )
					player allowSpectateTeam( "freelook", condition );
			}
		}
	}
}

monitorFreeLook()
{
	self.freelook = true;

	self thread checkADS();
	self thread checkAttack();
	self thread checkMelee();
	self thread checkFrag();
}

checkFrag()
{
	self endon("disconnect");
	self endon("joined_team");

	waittillframeend;

	for(;;)
	{
		// Check if the frag button is pressed
		if ( self fragButtonPressed() )
		
		{
			//iprintln("Frag pressed");
			if ( !isDefined( self.thirdPersonActive ) ){
				self.thirdPersonActive = true;
				self setClientDvar( "cg_thirdperson", 1 );
			}else {
				self.thirdPersonActive = undefined;
				self setClientDvar( "cg_thirdperson", 0 );
			}			
		}

		while ( self fragButtonPressed() )
		{
			wait 0.05;
			continue;
		}

		wait 0.05;
	}
}

checkMelee()
{
	self endon("disconnect");
	self endon("joined_team");

	waittillframeend;

	for(;;)
	{
		if ( self meleeButtonPressed() )
		
		{
			self notify ( "stop_follow" );
			self.freelook = true;
			self.spectatorlast = undefined;
		}

		while ( self meleeButtonPressed() )
		{
			wait 0.05;
			continue;
		}

		wait 0.05;
	}
}

checkAttack()
{
	self endon("disconnect");
	self endon("joined_team");

	waittillframeend;

	for(;;)
	{
		if ( self attackButtonPressed() )
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				players = level.players[i];

				if ( isAlive( players ) && ( ( players.pers["team"] == "allies" || players.pers["team"] == "axis" ) ) )
				{
					self notify ( "stop_follow" );
					self.freelook = false;
					break;
				}
			}
		}

		while ( self attackButtonPressed() )
		{
			wait 0.05;
			continue;
		}

		wait 0.05;
	}
}

checkADS()
{
	self endon("disconnect");
	self endon("joined_team");

	waittillframeend;

	for(;;)
	{
		while( !self adsButtonPressed() )
			wait 0.05;

		for ( i = 0; i < level.players.size; i++ )
		{
			players = level.players[i];

			if ( isAlive( players ) && ( ( players.pers["team"] == "allies" || players.pers["team"] == "axis" ) ) )
			{
				self notify ( "stop_follow" );
				self.freelook = false;
				break;
			}
		}

		while( self adsButtonPressed() )
			wait 0.05;
	}
}

default_onSpawnSpectator( origin, angles)
{
	thread freeLook( false );

	if( isDefined( origin ) && isDefined( angles ) )
	{
		self spawn(origin, angles);
		thread freeLook( true );
		return;
	}

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	self spawn(spawnpoint.origin, spawnpoint.angles);

	thread freeLook( true );
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");

	self setSpawnVariables();

	self clearLowerMessage();

	self freezeControls( false );

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;

	[[level.onSpawnIntermission]]();
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}

default_onSpawnIntermission()
{
	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = spawnPoints[0];

	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
}

timeUntilRoundEnd()
{
	// Check if the game has already ended
	if ( level.gameEnded )
	{
		// Calculate the time passed since the game ended
		timePassed = (getTime() - level.gameEndTime) / 1000;
		// Calculate the remaining time based on the post-round time
		timeRemaining = level.postRoundTime - timePassed;

		// If the remaining time is negative, return 0
		if ( timeRemaining < 0 )
			return 0;
		// Return the remaining time
		return timeRemaining;
	}

	// Check if in overtime, no time limit set, or start time not defined
	if ( level.inOvertime || level.timeLimit <= 0 || !isDefined( level.startTime ) )
		return undefined;

	// Calculate the time passed since the round started
	timePassed = (getTime() - level.startTime)/1000;
	// Calculate the remaining time based on the time limit and post-round time
	timeRemaining = (level.timeLimit * 60) - timePassed;

	// Return the remaining time plus the post-round time
	return timeRemaining + level.postRoundTime;
}

freezePlayerForRoundEnd()
{
	self clearLowerMessage();
}

freeGameplayHudElems()
{
	if ( isDefined( self.lowerMessage ) )
		self.lowerMessage destroyElem();
	if ( isDefined( self.lowerTimer ) )
		self.lowerTimer destroyElem();

	if ( isDefined( self.proxBar ) )
		self.proxBar destroyElem();
	if ( isDefined( self.proxBarText ) )
		self.proxBarText destroyElem();
}

endGame( winner, endReasonText, reason )
{
	// Check if the game state is already "postgame"
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		return;

	// Call the onEndGame function if defined
	if ( isDefined( level.onEndGame ) )
		[[level.onEndGame]]( winner );

	// Set the g_deadChat dvar to 1 if the game is in "match" mode
	if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" )
		setDvar( "g_deadChat", 1 );

	// Update game state and end time variables
	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;

	winnerTeamId = 0;
	attack_score = 0;
	defence_score = 0;

	level notify ( "game_ended" );

	setGameEndTime( 0 );

	// Update player placement and perform round end actions
	updatePlacement();

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];

		player freezePlayerForRoundEnd();
		player thread roundEndDoF( 4 );
		player freeGameplayHudElems();
	}

	// Update scorebot information if enabled
	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		winners = "";
		if ( winner == "allies" )
		{
			if ( game["attackers"] == "allies" && game["defenders"] == "axis" )
				winners = "attack";
			else
				winners = "defence";
		}
		else if ( winner == "axis" )
		{
			if ( game["attackers"] == "allies" && game["defenders"] == "axis" )
				winners = "defence";
			else
				winners = "attack";
		}
		else
			winners = "tie";

		attack_score = game["teamScores"]["allies"];
		defence_score = game["teamScores"]["axis"];

		game["promod_scorebot_ticker_buffer"] += "round_winner" + winners + "" + attack_score + "" + defence_score; 
	}

	// Stats
	if( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" && level.match_id != 0 ) //&& level.gametype == "sd" 
	{
		thread promod\stats::roundReport( game["totalroundsplayed"]+1, game["teamScores"]["allies"], game["teamScores"]["axis"], reason, winner, game["PROMOD_KNIFEROUND"], game["promod_overtime_active"], game["promod_overtime_count"] );
	}

	if ( (level.roundLimit > 1 || (!level.roundLimit && level.scoreLimit != 1)) && !level.forcedEnd )
	{
		// Check if the round end text should be displayed
		if ( level.displayRoundEndText )
		{	
			// Iterate through all players
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];

				// Display team-specific outcome notification for team-based games
				if ( level.teamBased )
					player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, true, endReasonText, 0.75 );
				else
					player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText, 0.75 );

				// Set client dvars for players who are not spectators
				if ( isDefined( player.pers["team"] ) && player.pers["team"] == "spectator" )
					continue;

				player setClientDvars("ui_hud_hardcore", 1,	"cg_drawSpectatorMessages", 0, "g_compassShowEnemies", 0 );
				
				// Start recording on each round end
				// if ( isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" )
				// {
				// 	player thread promod\readyup::startDemoRecord();
				// }
			}

			// Trigger the header thread
			level thread header();

			// If we did not hit OverTime but did hit round limit or score limit
			if ( hitRoundLimit() || hitScoreLimit() && !hitOvertime() )
				roundEndWait( level.roundEndDelay / 2 );
			else
				roundEndWait( level.roundEndDelay );
		}

		 // Increment the number of rounds played
		game["roundsplayed"]++;
		game["totalroundsplayed"]++;

		logPrint("ROUNDS" + game["roundsplayed"]);

		roundSwitching = false;

		// Check if we hit OVERTIME
		startOvertime = checkOvertimeSwitch();
	

		// Check for half-time
		if ( !hitRoundLimit() && !hitScoreLimit() )
			roundSwitching = checkRoundSwitch();

		// Start Overtime
		if (startOvertime && level.teamBased)
		{
			// Loop players
			for (i = 0; i < level.players.size; i++)
			{
				player = level.players[i];
				
				
				if ( player.pers["team"] == "spectator" ){
					player setClientDvars(
					"shout_scores_attack", game["teamScores"][game["defenders"]],
					"shout_scores_defence", game["teamScores"][game["defenders"]]
					);
				}

				// Check if player's team is undefined or if the player is a spectator
				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" ){
					// Spawn player in the intermission state and close menus
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();					
					continue;
				} 

				// Set switchType to "overtime"
				switchType = "overtime";
				wait 2;

				// Select a random overtime sound and play it for all players
				overtimeSound[0] = "RU_1mc_overtime";
				overtimeSound[1] = "AB_1mc_overtime";
				overtimeSound[2] = "UK_1mc_overtime";
				overtimeSound[3] = "US_1mc_overtime";

				finalOvertimeSound = overtimeSound[randomInt(4)];
				playSoundOnPlayers(finalOvertimeSound);
				
				
				// Display the overtime outcome message for each player
				for ( i = 0; i < level.players.size; i++ )
				{
					player = level.players[i];
					player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, level.halftimeSubCaption );
					player setClientDvar( "ui_hud_hardcore", 1 );
				}

				// Wait for the duration of level.postRoundTime
				roundEndWait( level.postRoundTime );

				// Set the level.intermission flag to true
				level.intermission = true;

				// Perform actions for each player
				for ( i = 0; i < level.players.size; i++ )
				{
					player = level.players[i];

					// Close menus, reset outcome notification, and spawn player in the intermission state
					player closeMenu();
					player closeInGameMenu();
					player notify ( "reset_outcome" );
					player thread spawnIntermission();
					player setClientDvar( "ui_hud_hardcore", 0 );
				}

				wait 4;	


				// Switch sides for each player 
				for(i = 0; i < level.players.size; i++) 
				{
					player = level.players[i];

					if ( player.pers["team"] == "axis" )
					{
						// Set the switching flag to true and open the Allies menu
						player.switching = true;
						player menuAllies();
					}
					else if( player.pers["team"] == "allies" )
					{
						// Set the switching flag to true and open the Axis menu
						player.switching = true;
						player menuAxis();
					}
				}
			}

			// Swap the scores between Allies and Axis teams
			old_score = game["teamScores"]["allies"];
			game["teamScores"]["allies"] = game["teamScores"]["axis"];
			game["teamScores"]["axis"] = old_score;

			// Swap teamIds for stats
			if( level.match_id != 0 && level.is_public == 0 )
			{
				//old_teamId = game["alliesTeamId"];
				//game["alliesTeamId"] = game["axisTeamId"];
				//game["axisTeamId"] = old_teamId;
				//iprintln("switch ot");		

				thread promod\stats::halftime();	
			}

			// Reset the timeout flags for both teams
			game["allies_timeout_called"] = 0;
			game["axis_timeout_called"] = 0;

			// Reset the number of rounds played
			game["roundsplayed"] = 0;

			// Update the class availability for Allies and Axis teams
			thread maps\mp\gametypes\_promod::updateClassAvailability( "allies" );
			thread maps\mp\gametypes\_promod::updateClassAvailability( "axis" );

			// Wait for the specified halftime round end delay
			roundEndWait( level.halftimeRoundEndDelay );

		}
		
		// If we hit half-time
		else if ( roundSwitching && level.teamBased )
		{
			// Iterate through all players
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];

				// Set scores for shoutcaster display if the player is a spectator
				if( player.pers["team"] == "spectator" )
					player setClientDvars(
											"shout_scores_attack", game["teamScores"][game["defenders"]],
											"shout_scores_defence", game["teamScores"][game["attackers"]] );

				// Handle actions for players who are not spectators	
				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
				{
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}

				switchType = level.halftimeType;

				// Determine the type of halftime (halftime or intermission) based on round or score limit
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else
						switchType = "intermission";
				}

				// Display halftime outcome notification for players
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, level.halftimeSubCaption );
				player setClientDvar( "ui_hud_hardcore", 1 );

				if ( player.pers["team"] == "axis" )
				{
					player.switching = true;
					player menuAllies();
				}
				else if( player.pers["team"] == "allies" )
				{
					player.switching = true;
					player menuAxis();
				}
			}
			
			// Swap team scores and reset timeout called variables
			old_score = game["teamScores"]["allies"];
			game["teamScores"]["allies"] = game["teamScores"]["axis"];
			game["teamScores"]["axis"] = old_score;

			game["allies_timeout_called"] = 0;
			game["axis_timeout_called"] = 0;

			// Update class availability for both teams
			thread maps\mp\gametypes\_promod::updateClassAvailability( "allies" );
			thread maps\mp\gametypes\_promod::updateClassAvailability( "axis" );

			// Swap teamIds for stats
			if( level.match_id != 0 && level.is_public == 0 )
			{
				old_teamId = game["alliesTeamId"] ;
				game["alliesTeamId"] = game["axisTeamId"];
				game["axisTeamId"] = old_teamId;
				//iprintln("switch");		

				thread promod\stats::halftime();	
			}

			// Wait for the specified round end delay for halftime
			roundEndWait( level.halftimeRoundEndDelay );
		}

		// If we did not hit half-time or round limit or score limit
		else if ( !hitRoundLimit() && !hitScoreLimit() && !level.displayRoundEndText && level.teamBased )
		{
			// Iterate through all players
			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];

				// Handle actions for players who are not spectators
				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
				{
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}

				switchType = level.halftimeType;

				// Determine the type of halftime (halftime or round end) based on round or score limit
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "roundend";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchTime = "roundend";
					}
				}

				// Display round outcome notification for players
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, endReasonText );
				player setClientDvar( "ui_hud_hardcore", 1 );
			}

			roundEndWait( level.halftimeRoundEndDelay );
		}
		// First round? If in a knife round?
		if ( isDefined(game["PROMOD_KNIFEROUND"]) && game["PROMOD_KNIFEROUND"] )
		{
			// If in a match-mode
			if(isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match")
			{
				// First ready-up period
				game["promod_do_readyup"] = 1;
				game["promod_first_readyup_done"] = 0;

				for( i = 0; i < level.players.size; i++ )
				{
					level.players[i].pers["kills"] = 0;
					level.players[i].pers["deaths"] = 0;
					level.players[i].pers["assists"] = 0;
					level.players[i].pers["score"] = 0;
					waittillframeend;
				}

				game["roundsplayed"]--;
				game["totalroundsplayed"]--;
				[[level._setTeamScore]]( "allies", 0 );
				[[level._setTeamScore]]( "axis", 0 );

				for( i = 0; i < level.players.size; i++ )
					if(level.players[i].pers["team"] == "spectator")
						level.players[i] setClientDvars(
												"shout_scores_attack", game["teamScores"][game["attackers"]],
												"shout_scores_defence", game["teamScores"][game["defenders"]] );
			}
			game["PROMOD_KNIFEROUND"] = 0;
			for(i=0;i<level.players.size;i++)
			{
				if(level.players[i].pers["team"] == "axis" || level.players[i].pers["team"] == "allies")
					level.players[i] setclientdvar("g_compassShowEnemies", 0);
				waittillframeend;
			}
		}

		// If we didnt hit round limit nor score limit, we are still playing
		if ( !hitRoundLimit() && !hitScoreLimit() )
		{
			game["state"] = "playing";
			map_restart( true );
			return;
		}

		// If we did hit round limit
		if ( hitRoundLimit() )
			endReasonText = game["strings"]["round_limit_reached"];
		// If we did hit score limit
		else if ( hitScoreLimit() )
			endReasonText = game["strings"]["score_limit_reached"];
		// If we did hit time limit
		else
			endReasonText = game["strings"]["time_limit_reached"];
	}

	// We did finish a map
	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			attack_score = game["teamScores"]["allies"];
			defence_score = game["teamScores"]["axis"];
		}
		else
		{
			attack_score = game["teamScores"]["axis"];
			defence_score = game["teamScores"]["allies"];
		}

		game["promod_scorebot_ticker_buffer"] += "map_completeattack" + attack_score + "defence" + defence_score;
	}

	winnerTeamId = -1;

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];

		if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
		{
			player [[level.spawnIntermission]]();
			player closeMenu();
			player closeInGameMenu();
			continue;
		}

		if ( level.teamBased )
		{
			winner = getWinningTeam();

			// Show winning team
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		}
		else
			// Show winner
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );

		player setClientDvars( "ui_hud_hardcore", 1, "cg_drawSpectatorMessages", 0, "g_compassShowEnemies", 0 );

		// Players stats
		if( level.match_id != 0 && level.is_public == 0 )
		{
			// Send players stats to api on map end
			if ( isDefined( player.pers["teamId"] ) && player.pers["teamId"] != 0 )
			{
				if ( player.pers["team"] == winner )
					winnerTeamId = player.pers["teamId"];
				else if ( winner == "tie" )
				 	winnerTeamId = -1;

				player thread promod\stats::sendStatsData();
			}
		}

		// Public stats
		if ( level.is_public ==1 && !isDefined( self.pers["isBot"] ))
			player thread promod\stats::sendPublicStatsData();
		
		// Stop recording demo on map end
		if ( isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" )
		{
			player thread promod\readyup::stopDemoRecord();
			player thread promod\stats::stopServerRecord();
		}
	}

	wait 1;

	// Send data to api on map end
	if ( level.match_id != 0 )
		thread promod\stats::mapFinished(winnerTeamId);

	// Sounds
	// for ( i = 0; i < level.players.size; i++ )
	// {
	// 	player = level.players[i];

	// 	if ( isDefined( player.pers["team"] ) && player.pers["team"] == getWinningTeam() )
	// 	{
	// 		player playSound(getWinnerSound());
	// 	}
		
	// 	if( isDefined( player.pers["team"] ) && player.pers["team"] != getWinningTeam() && player.pers["team"] != "spectator" )
	// 	{
	// 		player playSound(getLoserSound());
	// 	}
	// }	

	roundEndWait( level.postRoundTime );

	level.intermission = true;

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];

		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
		player thread spawnIntermission();
		player setClientDvar( "ui_hud_hardcore", 0 );

		// Print promod stats
		player maps\mp\gametypes\_weapons::printStats(true);
	}


	wait 4;

	// If in a match mode, just fast restart map
	if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" )
	{
		map_restart( false );
		return;
	}

	exitLevel( false );
}

getWinningTeam()
{
	if ( getGameScore( "allies" ) == getGameScore( "axis" ) )
		winner = "tie";
	else if ( getGameScore( "allies" ) > getGameScore( "axis" ) )
		winner = "allies";
	else
		winner = "axis";

	return winner;
}

roundEndWait( defaultDelay )
{
	notifiesDone = false;
	while ( !notifiesDone )
	{
		notifiesDone = true;
		for ( i = 0; i < level.players.size; i++ )
		{
			players = level.players[i];
			if ( !isDefined( players.doingNotify ) || !players.doingNotify )
				continue;

			notifiesDone = false;
		}
		wait 0.5;
	}

	wait defaultDelay;
}

roundEndDOF( time )
{
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}

getHighestScoringPlayer()
{
	winner = undefined;
	tie = false;

	for( i = 0; i < level.players.size; i++ )
	{
		players = level.players[i];
		if ( !isDefined( players.score ) || players.score < 1 )
			continue;

		if ( !isDefined( winner ) || players.score > winner.score )
		{
			winner = players;
			tie = false;
		}
		else if ( players.score == winner.score )
			tie = true;
	}

	if ( tie || !isDefined( winner ) )
		return undefined;
	else
		return winner;
}

checkTimeLimit()
{
	if ( isDefined( level.timeLimitOverride ) && level.timeLimitOverride )
		return;

	if ( !isDefined( game["state"] ) || game["state"] != "playing" )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( level.timeLimit <= 0 )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( level.inPrematchPeriod )
	{
		setGameEndTime( 0 );
		return;
	}

	if ( !isdefined( level.startTime ) )
		return;

	timeLeft = getTimeRemaining();

	setGameEndTime( getTime() + int(timeLeft) );

	if ( timeLeft > 0 )
		return;

	[[level.onTimeLimit]]();
}

getTimeRemaining()
{
	return level.timeLimit * 60000 - getTimePassed();
}

checkScoreLimit()
{
	// Check if the game state is not playing or score limit is not set
	if ((!isDefined(game["state"]) || game["state"] != "playing") || level.scoreLimit <= 0)
		return;

	// Check if overtime is active
	if (game["promod_overtime_active"])
	{
		overtimeRoundSwitch = level.overtimeRoundSwitch * int(game["promod_overtime_count"]);

		// Checks for team based gametypes
		if (level.teamBased)
		{
			// Check if either team's score is below the adjusted score limit for overtime
			if (game["teamScores"]["allies"] < level.scoreLimit + overtimeRoundSwitch || game["teamScores"]["axis"] < level.scoreLimit + overtimeRoundSwitch)
				return;
		}
		// Checks for solo based gametypes
		else
		{
			// Check if the individual player's score is below the score limit
			if (!isPlayer(self) || self.score < level.scoreLimit)
				return;
		}
	}
	// If overtime is not active
	else
	{
		// Checks for team based gametypes
		if (level.teamBased)
		{
			// Check if either team's score is below the score limit
			if (game["teamScores"]["allies"] < level.scoreLimit || game["teamScores"]["axis"] < level.scoreLimit)
				return;
		}
		// Checks for solo based gametypes
		else
		{
			// Check if the individual player's score is below the score limit
			if (!isPlayer(self) || self.score < level.scoreLimit)
				return;
		}
	}

	// Trigger the score limit event
	[[level.onScoreLimit]]();
}

hitRoundLimit()
{
	// Check if round limit is not set
	if( level.roundLimit <= 0 )
		return false;
	
	// Check if we are in a overtime
	if( game["promod_overtime_active"] )
	{
		// Check if the total rounds played (including overtime rounds) has reached the round limit
		return ( game["roundsplayed"] >= level.roundLimit + ( level.overtimeRoundSwitch * int(game["promod_overtime_count"]) ));
	}
	// We are not in overtime
	// Check if the total rounds played has reached the round limit
	else
		return ( game["roundsplayed"] >= level.roundLimit );
}
 
hitScoreLimit()
{
	if (level.scoreLimit <= 0)
		return false;

	if (level.teamBased)
	{
		if (game["promod_overtime_active"])
		{
			effectiveScoreLimit = level.scoreLimit + (level.overtimeRoundSwitch * int(game["promod_overtime_count"]));
			if (game["teamScores"]["allies"] >= effectiveScoreLimit || game["teamScores"]["axis"] >= effectiveScoreLimit)
				return true;
		}
		else
		{
			if (game["teamScores"]["allies"] >= level.scoreLimit || game["teamScores"]["axis"] >= level.scoreLimit)
				return true;
		}
	}
	else
	{
		for (i = 0; i < level.players.size; i++)
		{
			player = level.players[i];
			if (isDefined(player.score))
			{
				if (player.score >= level.scoreLimit)
					return true;
			}
		}
	}

	return false;
}

updateGameTypeDvars()
{
	level endon ( "game_ended" );

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		thread checkTimeLimit();
		thread checkScoreLimit();

		if ( isdefined( level.startTime ) && getTimeRemaining() < 3000 )
		{
			wait 0.1;
			continue;
		}
		wait 1;
	}
}

menuAutoAssign()
{
	teams[0] = "allies";
	teams[1] = "axis";
	assignment = teams[randomInt(2)];

	self closeMenus();

	if ( level.teamBased )
	{
		playerCounts = self maps\mp\gametypes\_teams::CountPlayers();

		if ( playerCounts["allies"] == playerCounts["axis"] )
		{
			if( getTeamScore( "allies" ) == getTeamScore( "axis" ) )
				assignment = teams[randomInt(2)];
			else if ( getTeamScore( "allies" ) < getTeamScore( "axis" ) )
				assignment = "allies";
			else
				assignment = "axis";
		}
		else if( playerCounts["allies"] < playerCounts["axis"] )
			assignment = "allies";
		else
			assignment = "axis";

		if ( assignment == self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead") )
		{
			self beginClassChoice();
			return;
		}
	}

	if ( assignment != self.pers["team"] && self.sessionstate == "playing" )
	{
		self.switching_teams = true;
		self.joining_team = assignment;
		self.leaving_team = self.pers["team"];
		self suicide();
	}

	oldTeam = self.pers["team"];

	self.pers["class"] = undefined;
	self.class = undefined;
	self.pers["team"] = assignment;
	self.team = assignment;
	self setClientDvar( "loadout_curclass", "" );

	if(isDefined(self.pers["shoutnum"]))
		self promod\shoutcast::removePlayer();

	self updateObjectiveText();

	if ( level.teamBased )
		self.sessionteam = assignment;
	else
		self.sessionteam = "none";

	if ( !isDefined( level.rdyup ) || !level.rdyup )
	{
		if ( !isAlive( self ) )
			self.statusicon = "hud_status_dead";
		else
			self.statusicon = "";
	}

	self notify("joined_team");
	self notify("end_respawn");

	self.freelook = undefined;

	if( self.pers["team"] == "allies" && oldTeam != self.pers["team"] )
	{
		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
			iPrintLN(self.name + " Joined Attack");
		else
			iPrintLN(self.name + " Joined Defence");
	}
	else if( self.pers["team"] == "axis" && oldTeam != self.pers["team"] )
	{
		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
			iPrintLN(self.name + " Joined Defence");
		else
			iPrintLN(self.name + " Joined Attack");
	}

	if ( oldTeam != self.pers["team"] && ( oldTeam == "allies" || oldTeam == "axis" ) )
			thread maps\mp\gametypes\_promod::updateClassAvailability( oldTeam );

	self setClientDvars("g_compassShowEnemies", 0, "cg_scoreboardheight", 435 );

	self beginClassChoice();

	self setclientdvar( "g_scriptMainMenu", game[ "menu_class_" + self.pers["team"] ] );
}

updateObjectiveText()
{
	if ( self.pers["team"] == "spectator" )
	{
		self setClientDvar( "cg_objectiveText", "" );
		return;
	}

	if( level.scorelimit > 0 )
		self setclientdvar( "cg_objectiveText", getObjectiveScoreText( self.pers["team"] ), level.scorelimit );
	else
		self setclientdvar( "cg_objectiveText", getObjectiveText( self.pers["team"] ) );
}

closeMenus()
{
	self closeMenu();
	self closeInGameMenu();
}

beginClassChoice()
{
	if ( self.pers["team"] == "axis" || self.pers["team"] == "allies" )
		self openMenu( game[ "menu_changeclass_" + self.pers["team"] ] );
}

menuAllies()
{
	if ( self.pers["team"] == "allies" )
		return;

	self closeMenus();

	if ( !isDefined( self.switching ) )
		self.switching = false;

	if ( self.pers["team"] != "allies" )
	{
		if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] != "match" && level.teamBased && !self.switching && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
		{
			self openMenu(game["menu_team"]);
			return;
		}

		if ( level.inGracePeriod && (!isdefined(self.hasDoneCombat) || !self.hasDoneCombat) )
			self.hasSpawned = false;

		if( self.sessionstate == "playing" && !self.switching )
		{
			self.switching_teams = true;
			self.joining_team = "allies";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		oldTeam = self.pers["team"];

		if ( self.switching )
		{
			self.pers["team"] = "allies";
			self.team = "allies";
		}
		else
		{
			self.pers["class"] = undefined;
			self.class = undefined;
			self.pers["team"] = "allies";
			self.team = "allies";
			self setClientDvar( "loadout_curclass", "" );
		}

		if(isDefined(self.pers["shoutnum"]))
			self promod\shoutcast::removePlayer();

		self updateObjectiveText();

		if ( level.teamBased )
			self.sessionteam = "allies";
		else
			self.sessionteam = "none";

		if ( !isDefined( level.rdyup ) || !level.rdyup )
		{
			if ( !isAlive( self ) )
				self.statusicon = "hud_status_dead";
			else
				self.statusicon = "";
		}

		self setclientdvar("g_scriptMainMenu", game["menu_class_allies"]);

		self notify("joined_team");
		self notify("end_respawn");

		self.freelook = undefined;

		if( game["attackers"] == "allies" && game["defenders"] == "axis" && !self.switching )
			iprintln(self.name + " Joined Attack");
		else if ( !self.switching )
			iprintln(self.name + " Joined Defence");

		if ( oldTeam == "axis" )
			thread maps\mp\gametypes\_promod::updateClassAvailability( oldTeam );

		self setClientDvars("g_compassShowEnemies", 0, "cg_scoreboardheight", 435 );
	}

	if ( !self.switching )
		self beginClassChoice();

	self.switching = false;
}

menuAxis()
{
	if ( self.pers["team"] == "axis" )
		return;

	self closeMenus();

	if ( !isDefined( self.switching ) )
		self.switching = false;

	if ( self.pers["team"] != "axis" )
	{
		if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] != "match" && level.teamBased && !self.switching && !maps\mp\gametypes\_teams::getJoinTeamPermissions( "allies" ) )
		{
			self openMenu(game["menu_team"]);
			return;
		}

		if ( level.inGracePeriod && (!isdefined(self.hasDoneCombat) || !self.hasDoneCombat) )
			self.hasSpawned = false;

		if( self.sessionstate == "playing" && !self.switching )
		{
			self.switching_teams = true;
			self.joining_team = "axis";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		oldTeam = self.pers["team"];

		if ( self.switching )
		{
			self.pers["team"] = "axis";
			self.team = "axis";
		}
		else
		{
			self.pers["class"] = undefined;
			self.class = undefined;
			self.pers["team"] = "axis";
			self.team = "axis";
			self setClientDvar( "loadout_curclass", "" );
		}

		if(isDefined(self.pers["shoutnum"]))
			self promod\shoutcast::removePlayer();

		self updateObjectiveText();

		if ( level.teamBased )
			self.sessionteam = "axis";
		else
			self.sessionteam = "none";

		if ( !isDefined( level.rdyup ) || !level.rdyup )
		{
			if ( !isAlive( self ) )
				self.statusicon = "hud_status_dead";
			else
				self.statusicon = "";
		}

		self setclientdvar("g_scriptMainMenu", game["menu_class_axis"]);

		self notify("joined_team");
		self notify("end_respawn");

		self.freelook = undefined;

		if( game["attackers"] == "allies" && game["defenders"] == "axis" && !self.switching )
			iprintln(self.name + " Joined Defence");
		else if ( !self.switching )
			iprintln(self.name + " Joined Attack");

		if ( oldTeam == "allies" )
			thread maps\mp\gametypes\_promod::updateClassAvailability( oldTeam );

		self setClientDvars("g_compassShowEnemies", 0, "cg_scoreboardheight", 435 );
	}

	if ( !self.switching )
		self beginClassChoice();

	self.switching = false;
}

menuKillspec()
{
	if ( self.pers["team"] != "axis" && self.pers["team"] != "allies" )
		return;

	self closeMenus();

	if( self.sessionstate == "playing" )
		self suicide();

	self.pers["class"] = undefined;
	self.class = undefined;
	self iprintln("Choose a class to respawn");
	self setClientDvar("loadout_curclass", "");
	self thread [[level.spawnSpectator]]( self.origin, self.angles );

	thread maps\mp\gametypes\_promod::updateClassAvailability( self.pers["team"] );

	if(isDefined(self.pers["shoutnum"]))
		self promod\shoutcast::removePlayer();
}

menuSpectator()
{
	if ( self.pers["team"] == "spectator" )
		return;

	self closeMenus();
	self openMenu(game["menu_shoutcast"]);

	if(self.pers["team"] != "spectator")
	{
		if(self.sessionstate == "playing")
		{
			self.switching_teams = true;
			self.joining_team = "spectator";
			self.leaving_team = self.pers["team"];
			self suicide();
		}

		oldTeam = self.pers["team"];

		self.pers["class"] = undefined;
		self.class = undefined;
		self.pers["team"] = "spectator";
		self.team = "spectator";
		self setClientDvar( "loadout_curclass", "" );

		if(isDefined(self.pers["shoutnum"]))
			self promod\shoutcast::removePlayer();

		self updateObjectiveText();

		self.sessionteam = "spectator";
		self thread [[level.spawnSpectator]]( self.origin, self.angles );

		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
			self setClientDvars(
							"shout_attack_name", "Attack",
							"shout_defence_name", "Defence" );
		else
			self setClientDvars(
							"shout_attack_name", "Defence",
							"shout_defence_name", "Attack" );

		self setClientDvars(
						"shout_scores_attack", game["teamScores"][game["attackers"]],
						"shout_scores_defence", game["teamScores"][game["defenders"]] );

		self setclientdvar( "g_scriptMainMenu", game["menu_shoutcast"] );

		self notify("joined_spectators");
		iprintln(self.name + " Joined Shoutcaster");

		self promod\shoutcast::loadOne();

		if ( oldTeam == "allies" || oldTeam == "axis" )
			thread maps\mp\gametypes\_promod::updateClassAvailability( oldTeam );

		self setClientDvars("g_compassShowEnemies", 1, "cg_scoreboardheight", 500 );
	}
}

removeDisconnectedPlayerFromPlacement()
{
	offset = 0;
	numPlayers = level.placement["all"].size;
	found = false;
	for ( i = 0; i < numPlayers; i++ )
	{
		if ( level.placement["all"][i] == self )
			found = true;

		if ( found )
			level.placement["all"][i] = level.placement["all"][ i + 1 ];
	}
	if ( !found )
		return;

	level.placement["all"][ numPlayers - 1 ] = undefined;

	updateTeamPlacement();

	if ( level.teamBased )
		return;

	numPlayers = level.placement["all"].size;
	for ( i = 0; i < numPlayers; i++ )
	{
		player = level.placement["all"][i];
		player notify( "update_outcome" );
	}
}

updatePlacement()
{
	prof_begin("updatePlacement");

	if ( !level.players.size )
		return;

	level.placement["all"] = [];
	for ( i = 0; i < level.players.size; i++ )
	{
		if ( level.players[i].team == "allies" || level.players[i].team == "axis" )
			level.placement["all"][level.placement["all"].size] = level.players[i];
	}

	placementAll = level.placement["all"];

	for ( i = 1; i < placementAll.size; i++ )
	{
		player = placementAll[i];
		playerScore = player.score;
		for ( j = i - 1; j >= 0 && (playerScore > placementAll[j].score || (playerScore == placementAll[j].score && player.deaths < placementAll[j].deaths)); j-- )
			placementAll[j + 1] = placementAll[j];
		placementAll[j + 1] = player;
	}

	level.placement["all"] = placementAll;

	updateTeamPlacement();

	prof_end("updatePlacement");
}

updateTeamPlacement()
{
	placement["allies"]	= [];
	placement["axis"] = [];
	placement["spectator"] = [];

	if ( !level.teamBased )
		return;

	placementAll = level.placement["all"];
	placementAllSize = placementAll.size;

	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];

		placement[team][ placement[team].size ] = player;
	}

	level.placement["allies"] = placement["allies"];
	level.placement["axis"] = placement["axis"];
}

onXPEvent( event )
{
	self maps\mp\gametypes\_rank::giveRankXP( event );
}

givePlayerScore( event, player, victim )
{
	if ( level.overridePlayerScore )
		return;

	score = player.pers["score"];
	[[level.onPlayerScore]]( event, player, victim );

	if ( score == player.pers["score"] )
		return;

	player.score = player.pers["score"];

	if ( !level.teambased )
		thread sendUpdatedDMScores();

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}

default_onPlayerScore( event, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );
	player.pers["score"] += score;
}

_setPlayerScore( player, score )
{
	if ( score == player.pers["score"] )
		return;

	player.pers["score"] = score;
	player.score = player.pers["score"];

	player notify ( "update_playerscore_hud" );
	player thread checkScoreLimit();
}

_getPlayerScore( player )
{
	return player.pers["score"];
}

giveTeamScore( event, team, player, victim )
{
	if ( level.overrideTeamScore )
		return;

	teamScore = game["teamScores"][team];
	[[level.onTeamScore]]( event, team, player, victim );

	if ( teamScore == game["teamScores"][team] )
		return;

	updateTeamScores( team );

	thread checkScoreLimit();
}

_setTeamScore( team, teamScore )
{
	if ( teamScore == game["teamScores"][team] )
		return;

	game["teamScores"][team] = teamScore;

	updateTeamScores( team );

	thread checkScoreLimit();
}

updateTeamScores( team1, team2 )
{
	setTeamScore( team1, getGameScore( team1 ) );
	if ( isdefined( team2 ) )
		setTeamScore( team2, getGameScore( team2 ) );

	if ( level.teambased )
		thread sendUpdatedTeamScores();
}

_getTeamScore( team )
{
	return game["teamScores"][team];
}

default_onTeamScore( event, team, player, victim )
{
	score = maps\mp\gametypes\_rank::getScoreInfoValue( event );

	otherTeam = level.otherTeam[team];

	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		level.wasWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		level.wasWinning = otherTeam;

	game["teamScores"][team] += score;

	isWinning = "none";
	if ( game["teamScores"][team] > game["teamScores"][otherTeam] )
		isWinning = team;
	else if ( game["teamScores"][otherTeam] > game["teamScores"][team] )
		isWinning = otherTeam;

	if ( isWinning != "none" && isWinning != level.wasWinning && getTime() - level.lastStatusTime > 5000 )
		level.lastStatusTime = getTime();

	if ( isWinning != "none" )
		level.wasWinning = isWinning;
}

sendUpdatedTeamScores()
{
	level notify("updating_scores");
	level endon("updating_scores");
	wait 0.05;

	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
		level.players[i] updateScores();

	for( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if( player.pers["team"] == "spectator" )
		{
			if( game["attackers"] == "allies" && game["defenders"] == "axis" )
				player setClientDvars(
										"shout_scores_attack", game["teamScores"]["allies"],
										"shout_scores_defence", game["teamScores"]["axis"] );
			else
				player setClientDvars(
										"shout_scores_attack", game["teamScores"]["axis"],
										"shout_scores_defence", game["teamScores"]["allies"] );
		}
	}

	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		if ( !isDefined( level.allies_team ) )
			level.allies_team = "none";
		if ( !isDefined( level.axis_team ) )
			level.axis_team = "none";

		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			game["promod_scorebot_attack_ticker_buffer"] = game["teamScores"]["allies"] + level.allies_team;
			game["promod_scorebot_defence_ticker_buffer"] = game["teamScores"]["axis"] + level.axis_team;
		}
		else
		{
			game["promod_scorebot_attack_ticker_buffer"] = game["teamScores"]["axis"] + level.axis_team;
			game["promod_scorebot_defence_ticker_buffer"] = game["teamScores"]["allies"] + level.allies_team;
		}
	}
}

sendUpdatedDMScores()
{
	level notify("updating_dm_scores");
	level endon("updating_dm_scores");
	wait 0.05;

	WaitTillSlowProcessAllowed();

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] updateDMScores();
		level.players[i].updatedDMScores = true;
	}
}

initPersStat( dataName )
{
	if( !isDefined( self.pers[dataName] ) )
		self.pers[dataName] = 0;
}

getPersStat( dataName )
{
	return self.pers[dataName];
}

incPersStat( dataName, increment )
{
	self.pers[dataName] += increment;
}

updateTeamStatus()
{
	level notify("updating_team_status");
	level endon("updating_team_status");
	level endon ( "game_ended" );

	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		return;

	resetTimeout();

	prof_begin( "updateTeamStatus" );

	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;

	level.lastAliveCount["allies"] = level.aliveCount["allies"];
	level.lastAliveCount["axis"] = level.aliveCount["axis"];
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];

		team = player.team;
		class = player.class;

		if ( team != "spectator" && (isDefined( class ) && class != "") )
		{
			level.playerCount[team]++;

			if ( player.sessionstate == "playing" )
			{
				level.aliveCount[team]++;
				level.playerLives[team]++;

				if ( isAlive( player ) )
				{
					level.alivePlayers[team][level.alivePlayers.size] = player;
					level.activeplayers[ level.activeplayers.size ] = player;
				}
			}
			else if ( player maySpawn() )
				level.playerLives[team]++;
		}
	}

	if ( level.aliveCount["allies"] + level.aliveCount["axis"] > level.maxPlayerCount )
		level.maxPlayerCount = level.aliveCount["allies"] + level.aliveCount["axis"];

	if ( level.aliveCount["allies"] )
		level.everExisted["allies"] = true;
	if ( level.aliveCount["axis"] )
		level.everExisted["axis"] = true;

	for( i = 0; i < level.players.size; i++ )
		if( level.players[i].pers["team"] == "allies" || level.players[i].pers["team"] == "axis" )
			level.players[i] setClientDvars("self_alive", level.aliveCount[level.players[i].pers["team"]],
											"opposing_alive", level.aliveCount[maps\mp\gametypes\_gameobjects::getEnemyTeam(level.players[i].pers["team"])] );

	if ( isDefined( level.scorebot ) && level.scorebot )
	{
		level.allies_team = "";
		level.axis_team = "";

		players = getentarray("player","classname");
		for( i = 0; i < players.size; i++ )
		{
			player = players[i];
			playerstring = "" + player.name + "" + int( isAlive( player ) ) + "" + player.kills + "" + player.assists + "" + player.deaths + "0";

			if ( player.pers["team"] == "allies" )
				level.allies_team += playerstring;
			else if ( player.pers["team"] == "axis" )
				level.axis_team += playerstring;
		}

		if ( level.allies_team == "" )
			level.allies_team = "none";
		if ( level.axis_team == "" )
			level.axis_team = "none";

		level.allies_string = game["teamScores"]["allies"] + level.allies_team;
		level.axis_string = game["teamScores"]["axis"] + level.axis_team;

		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			game["promod_scorebot_attack_ticker_buffer"] = level.allies_string;
			game["promod_scorebot_defence_ticker_buffer"] = level.axis_string;
		}
		else
		{
			game["promod_scorebot_attack_ticker_buffer"] = level.axis_string;
			game["promod_scorebot_defence_ticker_buffer"] = level.allies_string;
		}
	}

	prof_end( "updateTeamStatus" );

	level updateGameEvents();
}

isValidClass( class )
{
	return isdefined( class ) && class != "";
}

playTickingSound()
{
	self endon("death");
	self endon("stop_ticking");

	level endon("game_ended");

	for(;;)
	{
		self playSound( "ui_mp_suitcasebomb_timer" );
		wait 1;
	}
}

stopTickingSound()
{
	self notify("stop_ticking");
}

timeLimitClock()
{
	level endon ( "game_ended" );

	wait 0.05;

	clockObject = spawn( "script_origin", (0,0,0) );

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		if ( !level.timerStopped && level.timeLimit )
		{
			timeLeft = getTimeRemaining() / 1000;
			timeLeftInt = int(timeLeft + 0.5);

			if ( timeLeftInt <= 10 || (timeLeftInt <= 30 && timeLeftInt % 2 == 0) )
			{
				if ( !timeLeftInt )
					break;

				clockObject playSound( "ui_mp_timer_countdown" );
			}

			if ( timeLeft - floor(timeLeft) >= 0.05 )
				wait timeLeft - floor(timeLeft);
		}

		wait 1;
	}
}

gameTimer()
{
	level endon ( "game_ended" );

	level waittill("prematch_over");

	level.startTime = getTime();
	level.discardTime = 0;

	if ( isDefined( game["roundMillisecondsAlreadyPassed"] ) )
	{
		level.startTime -= game["roundMillisecondsAlreadyPassed"];
		game["roundMillisecondsAlreadyPassed"] = undefined;
	}

	prevtime = gettime();

	while ( isDefined( game["state"] ) && game["state"] == "playing" )
	{
		if ( !level.timerStopped )
			game["timepassed"] += gettime() - prevtime;

		prevtime = gettime();
		wait 1;
	}
}

getTimePassed()
{
	if ( !isDefined( level.startTime ) )
		return 0;

	if ( level.timerStopped )
		return (level.timerPauseTime - level.startTime) - level.discardTime;
	else
		return (gettime() - level.startTime) - level.discardTime;
}

pauseTimer()
{
	if ( level.timerStopped )
		return;

	level.timerStopped = true;
	level.timerPauseTime = gettime();
}

resumeTimer()
{
	if ( !level.timerStopped )
		return;

	level.timerStopped = false;
	level.discardTime += gettime() - level.timerPauseTime;
}

openMainMenu()
{
	maxwait = 0;
	while ( !level.players.size && maxwait <= 1 )
	{
		wait 0.05;
		maxwait += 0.05;
	}

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "none" )
		{
			player setclientdvar( "g_scriptMainMenu", game["menu_team"] );
			player openMenu( game["menu_team"] );
		}
	}
}

checkRestartMap()
{
	if ( getDvar( "o_gametype" ) == "" )
		setDvar( "o_gametype", level.gametype );
	else if ( getDvar( "o_gametype" ) != level.gametype )
	{
		level.restarting = true;

		setDvar( "o_gametype", level.gametype );

		maprot = getDvar( "sv_maprotationcurrent" );
		new_maprot = "map " + level.script + " " + maprot;
		setDvar( "sv_maprotationcurrent", new_maprot );
		exitLevel( false );
	}
}

startGame()
{
	level thread header();

	thread gameTimer();
	level.timerStopped = true;
	thread maps\mp\gametypes\_spawnlogic::spawnPerFrameUpdate();

	prematchPeriod();

	thread openMainMenu();

	if ( isDefined( game["promod_timeout_called"] ) && game["promod_timeout_called"] )
	{
		thread promod\timeout::main();
		return;
	}

	if ( isDefined( game["promod_do_readyup"] ) && game["promod_do_readyup"] )
	{
		thread disableBombsites();
		thread promod\readyup::main();
		return;
	}

	if ( ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" || getDvarInt( "promod_allow_strattime" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] ) && level.gametype == "sd" )
		promod\strattime::main();

	if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" )
	{
		thread disableBombsites();
		thread promod\stratmode::main();
		setDvar( "g_deadChat", 1 );
		SetClientNameMode( "auto_change" );
		setGameEndTime( 0 );
		return;
	}
	else if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" )
		setDvar( "g_deadChat", 0 );

	if ( isDefined( level.timeout_over ) && !level.timeout_over )
		return;

	if ( isDefined(game["PROMOD_KNIFEROUND"]) && game["PROMOD_KNIFEROUND"] )
	{
		thread disableBombsites();

		if(game["PROMOD_MATCH_MODE"] != "pub")
		{
			level.timeLimitOverride = true;
			setGameEndTime( 0 );
		}
	}

	level notify("prematch_over");
	level notify("header_destroy");
	level.timerStopped = false;

	game["promod_in_timeout"] = 0;

	if ( !isDefined( game["PROMOD_KNIFEROUND"] ) || !game["PROMOD_KNIFEROUND"] || game["PROMOD_MATCH_MODE"] == "pub" )
		thread timeLimitClock();

	thread gracePeriod();
}

header()
{
	if ( isDefined( game["state"] ) && game["state"] == "postgame" )
		wait 0.75;

	promod_ver = newHudElem();
	promod_ver.x = -7;
	promod_ver.y = 35;
	promod_ver.horzAlign = "right";
	promod_ver.vertAlign = "top";
	promod_ver.alignX = "right";
	promod_ver.alignY = "middle";
	promod_ver.fontScale = 1.4;
	promod_ver.hidewheninmenu = true;
	promod_ver.color = (0.8, 1, 1);
	promod_ver setText( game["PROMOD_VERSION"] );

	promod_mode = newHudElem();
	promod_mode.x = -7;
	promod_mode.y = 50;
	promod_mode.horzAlign = "right";
	promod_mode.vertAlign = "top";
	promod_mode.alignX = "right";
	promod_mode.alignY = "middle";
	promod_mode.fontScale = 1.4;
	promod_mode.hidewheninmenu = true;
	promod_mode.color = (1,1,0);
	promod_mode setText( game["PROMOD_MODE_HUD"] );

	level waittill( "header_destroy" );

	if ( isDefined( promod_ver ) )
		promod_ver destroy();

	if ( isDefined( promod_mode ) )
		promod_mode destroy();
}

disableBombsites()
{
	if ( level.gametype == "sd" && isDefined( level.bombZones ) )
		for ( j = 0; j < level.bombZones.size; j++ )
			level.bombZones[j] maps\mp\gametypes\_gameobjects::disableObject();
}

prematchPeriod()
{
	level endon( "game_ended" );

	if ( level.prematchPeriod > 0 && isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] != "match" && game["PROMOD_MATCH_MODE"] != "strat" )
	{
		if ( getDvarInt( "promod_allow_strattime" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] && level.gametype == "sd" )
			matchStartTimerSkip();
		else
			matchStartTimer();
	}
	else
		matchStartTimerSkip();

	level.inPrematchPeriod = false;

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] freezeControls( false );
		level.players[i] enableWeapons();
	}
}

gracePeriod()
{
	level endon("game_ended");

	wait level.gracePeriod;

	level notify ( "grace_period_ending" );
	wait 0.05;

	level.inGracePeriod = false;

	if ( !isDefined( game["state"] ) || game["state"] != "playing" )
		return;

	if ( level.numLives )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			if ( !player.hasSpawned && player.sessionteam != "spectator" && !isAlive( player ) )
				player.statusicon = "hud_status_dead";
		}
	}

	level thread updateTeamStatus();
}

TimeUntilWaveSpawn( minimumWait )
{
	earliestSpawnTime = gettime() + minimumWait * 1000;

	lastWaveTime = level.lastWave[self.pers["team"]];
	waveDelay = level.waveDelay[self.pers["team"]] * 1000;

	numWavesPassedEarliestSpawnTime = (earliestSpawnTime - lastWaveTime) / waveDelay;

	numWaves = ceil( numWavesPassedEarliestSpawnTime );

	timeOfSpawn = lastWaveTime + numWaves * waveDelay;

	if ( isdefined( self.waveSpawnIndex ) )
		timeOfSpawn += 50 * self.waveSpawnIndex;

	return (timeOfSpawn - gettime()) / 1000;
}

TimeUntilSpawn()
{
	if ( ( level.inGracePeriod && !self.hasSpawned ) || ( isDefined( level.rdyup ) && level.rdyup ) || ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" ) )
		return 0;

	respawnDelay = 0;
	if ( self.hasSpawned )
	{
		result = self [[level.onRespawnDelay]]();
		if ( isDefined( result ) )
			respawnDelay = result;
		else
			respawnDelay = getDvarInt( "scr_" + level.gameType + "_playerrespawndelay" );
	}

	waveBased = (getDvarInt( "scr_" + level.gameType + "_waverespawndelay" ) > 0);

	if ( waveBased )
		return self TimeUntilWaveSpawn( respawnDelay );

	return respawnDelay;
}

maySpawn()
{
	if ( ( isDefined( level.rdyup ) && level.rdyup ) || ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" ) )
		return true;

	if ( level.inOvertime )
		return false;

	if ( level.numLives )
	{
		if ( level.teamBased )
			gameHasStarted = ( level.everExisted[ "axis" ] && level.everExisted[ "allies" ] );
		else
			gameHasStarted = (level.maxPlayerCount > 1);

		if ( gameHasStarted && ( !self.pers["lives"] || ( !level.inGracePeriod && !self.hasSpawned ) ) )
			return false;
	}
	return true;
}

spawnClient( timeAlreadyPassed )
{
	if ( !self maySpawn() )
	{
		shouldShowRespawnMessage = true;
		if ( ( level.roundLimit > 1 && game["roundsplayed"] >= (level.roundLimit - 1) ) || ( level.scoreLimit > 1 && level.teambased && game["teamScores"]["allies"] >= level.scoreLimit - 1 && game["teamScores"]["axis"] >= level.scoreLimit - 1 ) )
			shouldShowRespawnMessage = false;

		if ( shouldShowRespawnMessage )
		{
			setLowerMessage( game["strings"]["spawn_next_round"] );
			self thread removeSpawnMessageShortly();
		}
		self thread [[level.spawnSpectator]]( self.origin, self.angles );
		return;
	}

	if ( self.waitingToSpawn )
		return;

	self.waitingToSpawn = true;

	self waitAndSpawnClient( timeAlreadyPassed );

	if ( isdefined( self ) )
		self.waitingToSpawn = false;
}

waitAndSpawnClient( timeAlreadyPassed )
{
	self endon ( "disconnect" );
	self endon ( "end_respawn" );
	self endon ( "game_ended" );

	if ( !isdefined( timeAlreadyPassed ) )
		timeAlreadyPassed = 0;

	spawnedAsSpectator = false;

	if ( !isdefined( self.waveSpawnIndex ) && isdefined( level.wavePlayerSpawnIndex[self.team] ) )
	{
		self.waveSpawnIndex = level.wavePlayerSpawnIndex[self.team];
		level.wavePlayerSpawnIndex[self.team]++;
	}

	timeUntilSpawn = TimeUntilSpawn();
	if ( timeUntilSpawn > timeAlreadyPassed )
	{
		timeUntilSpawn -= timeAlreadyPassed;
		timeAlreadyPassed = 0;
	}
	else
	{
		timeAlreadyPassed -= timeUntilSpawn;
		timeUntilSpawn = 0;
	}

	if ( timeUntilSpawn > 0 )
	{
		setLowerMessage( game["strings"]["waiting_to_spawn"], timeUntilSpawn );

		if ( !spawnedAsSpectator )
			self thread respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;

		self waitForTimeOrNotify( timeUntilSpawn, "force_spawn" );
	}

	waveBased = (getDvarInt( "scr_" + level.gameType + "_waverespawndelay" ) > 0);
	if ( !maps\mp\gametypes\_tweakables::getTweakableValue( "player", "forcerespawn" ) && self.hasSpawned && !waveBased )
	{
		setLowerMessage( game["strings"]["press_to_spawn"] );

		if ( !spawnedAsSpectator )
			self thread respawn_asSpectator( self.origin + (0, 0, 60), self.angles );
		spawnedAsSpectator = true;

		self waitRespawnButton();
	}

	self.waitingToSpawn = false;

	self clearLowerMessage();

	self.waveSpawnIndex = undefined;

	self thread [[level.spawnPlayer]]();
}

waitForTimeOrNotify( time, notifyname )
{
	self endon("disconnect");
	self endon( notifyname );
	wait time;
}

removeSpawnMessageShortly()
{
	self endon("disconnect");

	waittillframeend;

	self endon("end_respawn");

	wait 2;

	self clearLowerMessage( 2 );
}

Callback_StartGameType()
{
	level.prematchPeriod = 0;

	level.intermission = false;
	game["state"] = "playing";

	if ( !isDefined( game["gamestarted"] ) )
	{
		if ( !isDefined( game["allies"] ) )
			game["allies"] = "marines";
		if ( !isDefined( game["axis"] ) )
			game["axis"] = "opfor";
		if ( !isDefined( game["attackers"] ) )
			game["attackers"] = "allies";
		if ( !isDefined( game["defenders"] ) )
			game["defenders"] = "axis";

		if ( !isDefined( game["state"] ) )
			game["state"] = "playing";

		precacheStatusIcon("hud_status_dead");
		precacheStatusIcon("hud_status_connecting");
		precacheStatusIcon("compassping_friendlyfiring_mp");
		precacheStatusIcon("compassping_enemy");

		precacheRumble( "damage_heavy" );

		precacheShader( "white" );
		precacheShader( "black" );

		makeDvarServerInfo( "scr_allies", "usmc" );
		makeDvarServerInfo( "scr_axis", "arab" );

		game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPAWN";
		if ( level.teamBased )
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_TEAMS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}
		else
		{
			game["strings"]["waiting_for_teams"] = &"MP_WAITING_FOR_PLAYERS";
			game["strings"]["opponent_forfeiting_in"] = &"MP_OPPONENT_FORFEITING_IN";
		}

		game["strings"]["match_starting_in"] = &"MP_MATCH_STARTING_IN";
		game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
		game["strings"]["waiting_to_spawn"] = &"MP_WAITING_TO_SPAWN";
		game["strings"]["match_starting"] = &"MP_MATCH_STARTING";
		game["strings"]["change_class"] = &"MP_CHANGE_CLASS_NEXT_SPAWN";

		game["strings"]["tie"] = &"MP_MATCH_TIE";
		game["strings"]["round_draw"] = &"MP_ROUND_DRAW";

		game["strings"]["enemies_eliminated"] = &"MP_ENEMIES_ELIMINATED";
		game["strings"]["score_limit_reached"] = &"MP_SCORE_LIMIT_REACHED";
		game["strings"]["round_limit_reached"] = &"MP_ROUND_LIMIT_REACHED";
		game["strings"]["time_limit_reached"] = &"MP_TIME_LIMIT_REACHED";
		game["strings"]["players_forfeited"] = &"MP_PLAYERS_FORFEITED";

		if( game["attackers"] == "allies" && game["defenders"] == "axis" )
		{
			game["strings"]["allies_name"] = "Attack";
			game["strings"]["axis_name"] = "Defence";
			game["strings"]["allies_eliminated"] = "Attack eliminated";
			game["strings"]["axis_eliminated"] = "Defence eliminated";
			game["strings"]["allies_forfeited"] = "Attack forfeited";
			game["strings"]["axis_forfeited"] = "Defence forfeited";
		}
		else
		{
			game["strings"]["allies_name"] = "Defence";
			game["strings"]["axis_name"] = "Attack";
			game["strings"]["allies_eliminated"] = "Defence eliminated";
			game["strings"]["axis_eliminated"] = "Attack eliminated";
			game["strings"]["allies_forfeited"] = "Defence forfeited";
			game["strings"]["axis_forfeited"] = "Attack forfeited";
		}

		switch ( game["allies"] )
		{
			case "sas":
				game["strings"]["allies_win"] = &"MP_SAS_WIN_MATCH";
				game["strings"]["allies_win_round"] = &"MP_SAS_WIN_ROUND";
				game["strings"]["allies_mission_accomplished"] = &"MP_SAS_MISSION_ACCOMPLISHED";

				game["icons"]["allies"] = "faction_128_sas";
				game["colors"]["allies"] = (0.6,0.64,0.69);
				game["voice"]["allies"] = "UK_1mc_";
				setDvar( "scr_allies", "sas" );
				break;

			default:
				game["strings"]["allies_win"] = &"MP_MARINES_WIN_MATCH";
				game["strings"]["allies_win_round"] = &"MP_MARINES_WIN_ROUND";
				game["strings"]["allies_mission_accomplished"] = &"MP_MARINES_MISSION_ACCOMPLISHED";

				game["icons"]["allies"] = "faction_128_usmc";
				game["colors"]["allies"] = (0.6,0.64,0.69);
				game["voice"]["allies"] = "US_1mc_";
				setDvar( "scr_allies", "usmc" );
				break;
		}
		switch ( game["axis"] )
		{
			case "russian":
				game["strings"]["axis_win"] = &"MP_SPETSNAZ_WIN_MATCH";
				game["strings"]["axis_win_round"] = &"MP_SPETSNAZ_WIN_ROUND";
				game["strings"]["axis_mission_accomplished"] = &"MP_SPETSNAZ_MISSION_ACCOMPLISHED";

				game["icons"]["axis"] = "faction_128_ussr";
				game["colors"]["axis"] = (0.52,0.28,0.28);
				game["voice"]["axis"] = "RU_1mc_";
				setDvar( "scr_axis", "ussr" );
				break;

			default:
				game["strings"]["axis_win"] = &"MP_OPFOR_WIN_MATCH";
				game["strings"]["axis_win_round"] = &"MP_OPFOR_WIN_ROUND";
				game["strings"]["axis_mission_accomplished"] = &"MP_OPFOR_MISSION_ACCOMPLISHED";

				game["icons"]["axis"] = "faction_128_arab";
				game["colors"]["axis"] = (0.65,0.57,0.41);
				game["voice"]["axis"] = "AB_1mc_";
				setDvar( "scr_axis", "arab" );
				break;
		}

		[[level.onPrecacheGameType]]();

		game["gamestarted"] = true;

		game["teamScores"]["allies"] = game["SCORES_ATTACK"];
		game["teamScores"]["axis"] = game["SCORES_DEFENCE"];

		level.prematchPeriod = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "matchstarttime" );

		thread promod\setvariables::main();

		if ( !isDefined( game["promod_scorebot_ticker_buffer"] ) )
		{
			setDvar( "promod_scorebot_ticker_num", 0 );
			game["promod_scorebot_ticker_buffer"] = 0;
		}

		game["promod_scorebot_ticker_buffer"] += "map" + getDvar("mapname") + "" + level.gametype;
	}

	if ( !isdefined( game["timepassed"] ) )
		game["timepassed"] = 0;

	if ( !isdefined( game["roundsplayed"] ) )
		game["roundsplayed"] = game["SCORES_ATTACK"] + game["SCORES_DEFENCE"];

	if ( !isDefined( game["totalroundsplayed"] ) )
		game["totalroundsplayed"] = game["SCORES_ATTACK"] + game["SCORES_DEFENCE"];

	if ( !isDefined( game["promod_do_readyup"] ) )
		game["promod_do_readyup"] = false;

	if ( (isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" || getDvarInt( "promod_allow_readyup" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"]) && ( !game["roundsplayed"] && !game["promod_first_readyup_done"] || ( game["SCORES_ATTACK"] > 0 || game["SCORES_DEFENCE"] > 0 ) ) )
		game["promod_do_readyup"] = true;

	game["SCORES_ATTACK"] = 0;
	game["SCORES_DEFENCE"] = 0;

	level.gameEnded = false;
	level.teamSpawnPoints["axis"] = [];
	level.teamSpawnPoints["allies"] = [];

	level.objIDStart = 0;
	level.forcedEnd = false;

	level.useStartSpawns = true;

	thread maps\mp\gametypes\_promod::init();
	thread maps\mp\gametypes\_rank::init();
	thread maps\mp\gametypes\_menus::init();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_teams::init();
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_scoreboard::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_quickmessages::init();

	thread promod\scorebot::main();

	stringNames = getArrayKeys( game["strings"] );
	for ( i = 0; i < stringNames.size; i++ )
		if(!isstring(game["strings"][stringNames[i]]))
			precacheString( game["strings"][stringNames[i]] );

	level.maxPlayerCount = 0;
	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.lastAliveCount["allies"] = 0;
	level.lastAliveCount["axis"] = 0;
	level.everExisted["allies"] = false;
	level.everExisted["axis"] = false;
	level.waveDelay["allies"] = 0;
	level.waveDelay["axis"] = 0;
	level.lastWave["allies"] = 0;
	level.lastWave["axis"] = 0;
	level.wavePlayerSpawnIndex["allies"] = 0;
	level.wavePlayerSpawnIndex["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	makeDvarServerInfo( "ui_scorelimit" );
	makeDvarServerInfo( "ui_timelimit" );

	waveDelay = getDvarInt( "scr_" + level.gameType + "_waverespawndelay" );
	if ( waveDelay )
	{
		level.waveDelay["allies"] = waveDelay;
		level.waveDelay["axis"] = waveDelay;
		level.lastWave["allies"] = 0;
		level.lastWave["axis"] = 0;

		level thread [[level.waveSpawnTimer]]();
	}

	level.inPrematchPeriod = true;

	level.gracePeriod = 4;

	level.inGracePeriod = true;

	level.roundEndDelay = 4;
	level.halftimeRoundEndDelay = 3;

	updateTeamScores( "axis", "allies" );

	if ( !level.teamBased )
		thread initialDMScoreUpdate();

	[[level.onStartGameType]]();

	thread promod\messagecenter::main();

	deletePlacedEntity("misc_turret");

	thread deletePickups();

	thread startGame();

	level thread updateGameTypeDvars();
}

deletePickups()
{
	pickups = getentarray( "oldschool_pickup", "targetname" );

	for ( i = 0; i < pickups.size; i++ )
	{
		if ( isdefined( pickups[i].target ) )
			getent( pickups[i].target, "targetname" ) delete();
		pickups[i] delete();
	}
}

initialDMScoreUpdate()
{
	wait 0.2;
	numSent = 0;
	for(;;)
	{
		didAny = false;

		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			if ( !isdefined( player ) )
				continue;

			if ( isdefined( player.updatedDMScores ) )
				continue;

			player.updatedDMScores = true;
			player updateDMScores();

			didAny = true;
			wait 0.5;
		}

		if ( !didAny )
			wait 3;
	}
}

// Check for half-time
checkRoundSwitch()
{
	// No overtime if roundSwitch is disabled or if gametype is DM
	if ( !level.roundSwitch || level.gametype == "dm" )
		return false;

	// If we are in over-time
	if( game["promod_overtime_active"] )
	{
		// If the number of rounds played is divisible by roundswitch (scr_sd_roundSwitch) basically if its halftime
		if ( game["roundsplayed"] % level.overtimeRoundSwitch == 0 )
		{
			// If in a match mode, and if ready-up is allowed and if first ready-up is done, that means we reached proper half-time, that means another ready-up period
			if ( ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" || getDvarInt( "promod_allow_readyup" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] ) && game["promod_first_readyup_done"] )
			{
				// If we are in a match-making mode, dont start ready-up period
				if( game["MATCHMAKING_MODE"] )
					game["promod_do_readyup"] = false;
				else 
					game["promod_do_readyup"] = true;

				if ( !checkOvertimeSwitch() )
					playHalfTimeSound();
			}			

			game["promod_timeout_called"] = false;

			[[level.onRoundSwitch]]();
			return true;
		}

	}
	else
	{		
		if ( game["roundsplayed"] % level.roundswitch == 0 )
		{
			if ( ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" || getDvarInt( "promod_allow_readyup" ) && isDefined( game["CUSTOM_MODE"] ) && game["CUSTOM_MODE"] ) && game["promod_first_readyup_done"] )
			{
				if( game["MATCHMAKING_MODE"] )
				{
					game["promod_do_readyup"] = false;
				}
				else
				{ 
					game["promod_do_readyup"] = true;
				}

				playHalfTimeSound();
			}
			game["promod_timeout_called"] = false;

			[[level.onRoundSwitch]]();
			return true;
		}
	}	

	return false;
}

playHalfTimeSound()
{
	halftimeSound[0] = "RU_1mc_halftime";
	halftimeSound[1] = "AB_1mc_halftime";
	halftimeSound[2] = "UK_1mc_halftime";
	halftimeSound[3] = "US_1mc_halftime";

	finalhalftimeSound = halftimeSound[randomInt(4)];
	playSoundOnPlayers(finalhalftimeSound);
}

getLoserSound()
{
	loserSound[0] = "RU_1mc_mission_fail";
	loserSound[1] = "AB_1mc_mission_fail";
	loserSound[2] = "UK_1mc_mission_fail";
	loserSound[3] = "US_1mc_mission_fail";

	finalLoserSound = loserSound[randomInt(4)];
	return finalLoserSound;
}

getWinnerSound()
{
	winnerSound[0] = "RU_1mc_mission_success";
	winnerSound[1] = "AB_1mc_mission_success";
	winnerSound[2] = "UK_1mc_mission_success";
	winnerSound[3] = "US_1mc_mission_success";

	finalWinnerSound = winnerSound[randomInt(4)];
	return finalWinnerSound;
}

getGameScore( team )
{
	return game["teamScores"][team];
}

Callback_PlayerConnect()
{
	thread notifyConnecting();

	self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	waittillframeend;

	if ( !isDefined( self ) )
		return;

	level notify( "connected", self );

	if ( !isDefined( level.rdyup ) || !level.rdyup )
		self.statusicon = "";

	if( !isdefined( self.pers["score"] ) )
		iPrintLn( &"MP_CONNECTED", self.name );

	logPrint("J;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n");

	if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" )
		self setClientDvar( "promod_hud_website", "" );
	else
		self setClientDvar( "promod_hud_website", getDvar( "promod_hud_website" ) );

	self setClientDvars("cg_hudGrenadeIconMaxRangeFrag", int(!level.hardcoreMode)*250,
						"cg_drawcrosshair", int(!level.hardcoreMode),
						"cg_drawSpectatorMessages", 1,
						"ui_hud_hardcore", level.hardcoreMode,
						"fx_drawClouds", 0,
						"ui_showmenuonly", "",
						"self_ready", "",
						"match_cancelled", 0);

	self initPersStat( "score" );
	self.score = self.pers["score"];

	self initPersStat( "deaths" );
	self.deaths = self getPersStat( "deaths" );

	self initPersStat( "suicides" );
	self.suicides = self getPersStat( "suicides" );

	self initPersStat( "kills" );
	self.kills = self getPersStat( "kills" );

	self initPersStat( "headshots" );
	self.headshots = self getPersStat( "headshots" );

	self initPersStat( "assists" );
	self.assists = self getPersStat( "assists" );

	self initPersStat( "teamkills" );

	self initPersStat( "damage_done" );
	self initPersStat( "damage_taken" );
	self initPersStat( "friendly_damage_done" );
	self initPersStat( "friendly_damage_taken" );
	self initPersStat( "shots" );
	self initPersStat( "hits" );
	self initPersStat( "plants" );
	self initPersStat( "defuses" );

	self.isDefusing = false;
	self.isPlanting = false;
	self.clutchKills = 0;
	self.clutchSituation = false;

	self.lastGrenadeSuicideTime = -1;

	self.teamkillsThisRound = 0;

	self.pers["lives"] = level.numLives;

	self.hasSpawned = false;
	self.waitingToSpawn = false;
	self.deathCount = 0;

	self.wasAliveAtMatchStart = false;

	self thread maps\mp\_flashgrenades::monitorFlash();
	self thread promod\ping::mainLoop();
	self thread promod\velocity::mainLoop();

	level.players[level.players.size] = self;

	if(isDefined(self.pers["shoutnum"]))
		level.shoutbars[self.pers["shoutnum"]] = self;

	if ( level.teambased )
		self updateScores();

	level endon( "game_ended" );

	if ( isDefined( self.pers["team"] ) )
		self.team = self.pers["team"];

	if ( isDefined( self.pers["class"] ) )
		self.class = self.pers["class"];

	if ( !isDefined( self.pers["team"] ) )
	{
		self.pers["team"] = "none";
		self.team = "none";
		self.sessionstate = "dead";

		self setClientDvar("loadout_curclass", "");

		self updateObjectiveText();

		[[level.spawnSpectator]]();

		self thread promod\client::use_config();
		self thread maps\mp\gametypes\_promod::initClassLoadouts();

		thread maps\mp\gametypes\_promod::updateClassAvailability( "allies" );
		thread maps\mp\gametypes\_promod::updateClassAvailability( "axis" );

		self setclientdvar( "g_scriptMainMenu", game["menu_team"] );
		self openMenu( game["menu_team"] );

		if ( level.teamBased )
		{
			self.sessionteam = self.pers["team"];

			if ( ( !isDefined( level.rdyup ) || !level.rdyup ) && !isAlive( self ) )
				self.statusicon = "hud_status_dead";

			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
		}
	}
	else if ( self.pers["team"] == "spectator" )
	{
		self setclientdvar( "g_scriptMainMenu", game["menu_shoutcast"] );
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		[[level.spawnSpectator]]();
	}
	else
	{
		self.sessionteam = self.pers["team"];
		self.sessionstate = "dead";

		self updateObjectiveText();

		[[level.spawnSpectator]]();

		if ( isValidClass( self.pers["class"] ) )
			self thread [[level.spawnClient]]();

		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	}
}

Callback_PlayerDisconnect()
{
	// Players stats
	if ( level.match_id != 0 && isDefined( self.pers["teamId"] ))
		self promod\stats::sendStatsData();

	// Public stats
	if ( level.track_pub_stats == 1 && level.is_public == 1 )
		self promod\stats::sendPublicStatsData();

	self removePlayerOnDisconnect();

	[[level.onPlayerDisconnect]]();

	logPrint("Q;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.name + "\n");

	for ( i = 0; i < level.players.size; i++ )
	{
		if ( level.players[i] == self )
		{
			while ( i < level.players.size-1 )
			{
				level.players[i] = level.players[i+1];
				i++;
			}
			level.players[i] = undefined;
			break;
		}
	}

	if ( level.gameEnded )
		self removeDisconnectedPlayerFromPlacement();

	self promod\shoutcast::removePlayer();
	self maps\mp\gametypes\_weapons::printStats(true);

	if ( isDefined( self.pers["team"] ) && ( self.pers["team"] == "allies" || self.pers["team"] == "axis" ) )
		thread maps\mp\gametypes\_promod::updateClassAvailability( self.pers["team"] );

	level thread updateTeamStatus();
}

removePlayerOnDisconnect()
{
	for ( i = 0; i < level.players.size; i++ )
	{
		if ( level.players[i] == self )
		{
			while ( i < level.players.size-1 )
			{
				level.players[i] = level.players[i+1];
				i++;
			}
			level.players[i] = undefined;
			break;
		}
	}
}

isWallBang( attacker, victim )
{
	start = attacker getEye();
	end = victim getEye();
	if( bulletTracePassed( start, end, false, attacker ) )
		return 0;
	return 1;
}

isHeadShot( sWeapon, sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet") && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_IMPACT";
}

angleDiff(player, eAttacker)
	{
		myAngle = player.angles[1]; // -180 <-> +180
		myAngle += 180; // flip direction, now in range 0 <-> 360
		if (myAngle > 180) myAngle -= 360; // back to range -180 <-> +180

		enemyAngle = eAttacker.angles[1];

		anglediff = myAngle - enemyAngle;
		if (anglediff > 180)		anglediff -= 360;
		else if (anglediff < -180)	anglediff += 360;

		return anglediff;
	}

Callback_PlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( !isDefined( level.rdyup ) )
		level.rdyup = false;

	if ( getDvarInt("g_knockback") != 1000 || isDefined( game["state"] ) && game["state"] == "postgame" || self.sessionteam == "spectator" || isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" && isDefined( self.flying ) && self.flying || isDefined( level.bombDefused ) && level.bombDefused || isDefined( level.bombExploded ) && level.bombExploded && self.pers["team"] == game["attackers"] || isDefined( game["PROMOD_KNIFEROUND"] ) && game["PROMOD_KNIFEROUND"] && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_FALLING" && !level.rdyup )
		return;

	if( isDefined(eAttacker) && isPlayer(eAttacker) && isPlayer(self) && eAttacker.sessionstate == "playing" && isDefined(iDamage) && isDefined( sMeansOfDeath ) && sMeansOfDeath != "" && (sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_PISTOL_BULLET"))
		iDamage = int(iDamage*1.4);

	self.iDFlags = iDFlags;
	self.iDFlagsTime = getTime();

	// If we are in a ready-up period
	if ( level.rdyup && isDefined( eAttacker ) && isPlayer( eAttacker ) && eAttacker != self )
	{
		// If attackers ruptally (indication whether he had intention to kill someone) is defined or < 0
		if ( !isDefined( eAttacker.ruptally ) || eAttacker.ruptally < 0 )
		{
			// Set his ruptally flag non-zero so he can be killed or flashed
			eAttacker.ruptally = 0;
			eAttacker setclientdvar("self_kills", 0);
		}

		// If our ruptally is not defined
		if ( !isDefined( self.ruptally ) )
			self.ruptally = -1;
		// If our ruptally is less than 0 (no intension of tryin to kill someone), ignore damage
		if ( self.ruptally < 0 )
			return;
	}

	// Scope hitbox arms fix
	if ( isDefined(sWeapon) && isDefined(sHitLoc) && isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self ) 
	{
		if ( (sHitLoc == "left_arm_lower" || sHitLoc == "right_arm_lower") &&  (sWeapon == "remington700_mp" || sWeapon == "m40a3_mp") && iDFlags != 8 )		    
		{
			// If players are looking to each other, make shot to arm a kill
			distance = distance(self.origin, eAttacker.origin);
			angleDiff = angleDiff(self, eAttacker);
			if (distance > 100 && anglediff > -20 && anglediff < 20)
			{
				//iprintln("^1Hitbox fix left - " + sHitLoc + "- Distance: " + distance + " - Angle: " + int(anglediff));
				iDamage = 100;
			}
		}
		// Right upper arm fix - cod2 both arms always insta kill, cod4 right arm upper is 98
		if(sHitLoc == "right_arm_upper" && (sWeapon == "remington700_mp" || sWeapon == "m40a3_mp") && iDFlags != 8 ){
			//distance = distance(self.origin, eAttacker.origin);
			//angleDiff = angleDiff(self, eAttacker);
			iDamage = 100;
			//iprintln("^1Hitbox fix right - " + sHitLoc + "- Distance: " + distance + " - Angle: " + int(anglediff));
		}
	}


	// bit arrays are interesting, huh?
	if( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	// Not sure exactly what happens here, but ok...
	if ( level.teamBased && self.health == self.maxhealth || !isDefined( self.attackers ) )
	{
		self.attackers = [];
		self.attackerData = [];
	}

	if ( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if ( sWeapon == "none" && isDefined( eInflictor ) )
	{
		if ( isDefined( eInflictor.targetname ) && eInflictor.targetname == "explodable_barrel" )
			sWeapon = "explodable_barrel";
		else if ( isDefined( eInflictor.destructible_type ) && isSubStr( eInflictor.destructible_type, "vehicle_" ) )
			sWeapon = "destructible_car";
	}

	friendly = false;

	// if level.iDFLAGS_NO_PROTECTION element in iDflags is not 0, this will happen. NO_PROTECTION == 0 could be god-mode
	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
		if ( (isSubStr( sMeansOfDeath, "MOD_GRENADE" ) || isSubStr( sMeansOfDeath, "MOD_EXPLOSIVE" ) || isSubStr( sMeansOfDeath, "MOD_PROJECTILE" )) && isDefined( eInflictor ) && game["PROMOD_MATCH_MODE"] != "match" && eInflictor.classname == "grenade" && ( (self.lastSpawnTime + 3500) > getTime() && distance( eInflictor.origin, self.lastSpawnPoint.origin ) < 250 || !isDefined ( eAttacker.pers["class"] ) ) )
			return;

		if ( level.teamBased && isPlayer( eAttacker ) && self != eAttacker && self.pers["team"] == eAttacker.pers["team"] )
		{
			if ( !level.friendlyfire )
				return;
			if ( level.friendlyfire == 1 || (level.friendlyfire == 2 || level.friendlyfire == 3) && isAlive( eAttacker ) )
			{
				if( (level.friendlyfire & 2) > 0 ) // 2 or 3
					iDamage = int(iDamage * 0.5);

				if ( iDamage < 1 )
					iDamage = 1;

				if( (level.friendlyfire & 1) > 0 ) // 1 or 3
				{
					if(!level.rdyup)
					{
						if(!isDefined(self.pers["friendly_damage_taken"]))
							self.pers["friendly_damage_taken"] = 0;
						if(!isDefined(eAttacker.pers["friendly_damage_done"]))
							eAttacker.pers["friendly_damage_done"] = 0;

						self.pers["friendly_damage_taken"] += min(iDamage, self.health);
						eAttacker.pers["friendly_damage_done"] += min(iDamage, self.health);
					}

					self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
				}
				if( (level.friendlyfire & 2) > 0 ) // 2 or 3
					eAttacker finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			}
			friendly = true;
		}
		else
		{
			if(iDamage < 1)
				iDamage = 1;

			if ( level.teamBased && isDefined( eAttacker ) && isPlayer( eAttacker ) )
			{
				if ( !isdefined( self.attackerData[eAttacker.clientid] ) )
				{
					self.attackers[ self.attackers.size ] = eAttacker;
					self.attackerData[eAttacker.clientid] = false;
				}
				if ( isDefined(sWeapon) && isSubStr("m1014_mp winchester1200_mp mp5_mp uzi_mp ak74u_mp ak47_mp m14_mp mp44_mp g3_mp g36c_mp m16_mp m4_mp m40a3_mp remington700_mp", sWeapon) )
					self.attackerData[eAttacker.clientid] = true;
			}

			if( !level.rdyup && isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self )
			{
				if(!isDefined(eAttacker.pers["hits"]))
					eAttacker.pers["hits"] = 0;

				eAttacker.pers["hits"]++;

				if(!isDefined(self.pers["damage_taken"]))
					self.pers["damage_taken"] = 0;
				if(!isDefined(eAttacker.pers["damage_done"]))
					eAttacker.pers["damage_done"] = 0;

				self.pers["damage_taken"] += min(iDamage, self.health);
				eAttacker.pers["damage_done"] += min(iDamage, self.health);
			}

			self finishPlayerDamageWrapper(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
		}

		if ( isDefined(eAttacker) && eAttacker != self )
		{
			if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
				thread dinkNoise(eAttacker, self);

			if ( iDamage > 0 && ( getDvarInt( "scr_enable_hiticon" ) == 1 || getDvarInt( "scr_enable_hiticon" ) == 2 && !(iDFlags & level.iDFLAGS_PENETRATION) ) )
			{
				if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
					eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( false );
				else 
					eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( false );
			}
		}

		self.hasDoneCombat = true;
	}

	if ( isdefined( eAttacker ) && eAttacker != self && !friendly )
		level.useStartSpawns = false;

	if( level.rdyup || isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" )
	{
		if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sHitLoc ) )
		{
			if ( eAttacker != self )
			{
				if ( sHitLoc == "none" )
				{
					eAttacker iprintln("You inflicted ^2" + iDamage + "^7 damage to " + self.name);
					self iprintln(eAttacker.name + " inflicted ^1" + iDamage + "^7 damage to you");
				}
				else
				{
					damagestring = "";
					if( isSubStr( sHitLoc, "torso_upper" ) )
						damagestring = "upper torso";
					else if( isSubStr( sHitLoc, "torso_lower" ) )
						damagestring = "lower torso";
					else if( isSubStr( sHitLoc, "leg_upper" ) )
						damagestring = "upper leg";
					else if( isSubStr( sHitLoc, "leg_lower" ) )
						damagestring = "lower leg";
					else if( isSubStr( sHitLoc, "arm_upper" ) )
						damagestring = "upper arm";
					else if( isSubStr( sHitLoc, "arm_lower" ) )
						damagestring = "lower arm";
					else if( isSubStr( sHitLoc, "head" ) || isSubStr( sHitLoc, "helmet" ) )
						damagestring = "head";
					else if( isSubStr( sHitLoc, "neck" ) )
						damagestring = "neck";
					else if( isSubStr( sHitLoc, "foot" ) )
						damagestring = "foot";
					else if( isSubStr( sHitLoc, "hand" ) )
						damagestring = "hand";

					metrestring = int(distance(self.origin, eAttacker.origin) * 2.54) / 100;

					eAttacker iprintln("You inflicted ^2" + iDamage + "^7 damage at a distance of ^2" + metrestring + "^7 metres in the ^2" + damagestring + "^7 to " + self.name);
					self iprintln(eAttacker.name + " inflicted ^1" + iDamage + "^7 damage at a distance of ^1" + metrestring + "^7 metres in the ^1" + damagestring + "^7 to you");
				}
			}
			else if ( sHitLoc == "none" )
				self iprintln("You inflicted ^1" + iDamage + "^7 damage to yourself");
		}
		else if ( sMeansOfDeath == "MOD_FALLING" )
			self iprintln("You inflicted ^1" + iDamage + "^7 damage to yourself");
	}

	// Logging into file
	if( self.sessionstate != "dead" )
	{
		lpattackerteam = "";

		if( isPlayer( eAttacker ) )
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		logPrint("D;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.pers["team"] + ";" + self.name + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	}

	// Shoutcaster healthbar update
	self promod\shoutcast::updatePlayer();
}

dinkNoise( player1, player2 )
{
	player1 playLocalSound("bullet_impact_headshot_2");
	player2 playLocalSound("bullet_impact_headshot_2");
}

finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	self damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage );
}

damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage )
{
	self thread maps\mp\gametypes\_weapons::onWeaponDamage( eInflictor, sWeapon, sMeansOfDeath, iDamage );
	self PlayRumbleOnEntity( "damage_heavy" );
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if ( !isDefined( level.rdyup ) )
		level.rdyup = false;

	self endon( "spawned" );
	self notify( "killed_player" );

	if ( self.sessionteam == "spectator" || ( isDefined( game["state"] ) && game["state"] == "postgame" ) )
		return;

	prof_begin( "PlayerKilled pre constants" );

	if( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
		attacker = attacker.owner;

	if( level.teamBased && isDefined( attacker.pers ) && self.team == attacker.team && sMeansOfDeath == "MOD_GRENADE" && !level.friendlyfire )
		obituary(self, self, sWeapon, sMeansOfDeath);
	else
		obituary(self, attacker, sWeapon, sMeansOfDeath);

	// Fixed old promod bug when suicide()
	//if ( !isDefined( game["promod_do_readyup"] ) || !game["promod_do_readyup"] && attacker != self )
	self maps\mp\gametypes\_weapons::dropWeaponForDeath( attacker );

	self.sessionstate = "dead";

	if ( !isDefined( level.rdyup ) || !level.rdyup )
		self.statusicon = "hud_status_dead";

	if (level.rdyup && isDefined( attacker.pers ) && ( attacker != self ) )
	{
		attacker.ruptally++;
		attacker setclientdvar("self_kills", attacker.ruptally);
	}

	if (!level.rdyup)
	{
		self.deathCount++;

		if( isDefined( attacker.pers ) && !isDefined( self.switching_teams ) )
		{
			self incPersStat( "deaths", 1 );
			self.deaths = self getPersStat( "deaths" );
		}
	}

	lpattackGuid = "0";
	lpattackname = "0";
	lpattackerteam = "0";
	attackerStance = "0";
	lpattacknum = 0;
	attackerADS = 0;
	attackerIsOnGround = 0;
	isAttackerDefusing = 0;
	isAttackerPlanting = 0;
	isAttackerFlashed = 0;
	isTeamkill = 0;	
	metrestring = 0;
	isWallbang = isWallbang( attacker, self );
	camo = "camo_none";
	isClutchKill = 0;

	death_by_falling = false;
	death_by_barell = false;
	death_by_bombsite = false;

	if(isDefined(eInflictor))
	{
		if(isDefined(eInflictor.classname) && eInflictor.classname == "worldspawn")
		{
			death_by_falling = true;
		}

		if(isDefined(eInflictor.targetname) && eInflictor.targetname == "explodable_barell")
		{
			death_by_barell = true;
		}

		if(isDefined(eInflictor.model) && eInflictor.model == "com_bomb_objective")
		{
			death_by_bombsite = true;
		}
	}


	// iprintln("classname " + attacker.classname);// trigger_hurt
	// iprintln("flags " + attacker.flags);
	// iprintln("label " + attacker.label);
	// iprintln("inf classname " + eInflictor.classname); // trigger_hurt°, script_model
	// iprintln("inf flags " +eInflictor.flags);
	// iprintln("inf sflags " +eInflictor.spawnflags);
	// iprintln("inf tname " + eInflictor.targetname); //yy explodable_barell, pf5_auto1, pf221_auto1
	// iprintln("inf t " + eInflictor.target);
	// iprintln("inf model " + eInflictor.model); // com_bomb_objective, com_barell_benzin
	// iprintln("inf d " + eInflictor.damage);
	// iprintln("inf names " + eInflictor.attachModelNames);
	// iprintln("inf label" +eInflictor.label);

	prof_end( "PlayerKilled pre constants" );

	if( isPlayer( attacker ) )
	{
		lpattackGuid = attacker getGuid();
		lpattackname = attacker.name;
		lpattackerteam = attacker.pers["team"];
		attackerStance = attacker getStance();
		attackerADS = attacker playerADS();
		attackerIsOnGround = attacker isOnGround();
		
		if( isDefined( attacker.isDefusing ) )
			isAttackerDefusing = attacker.isDefusing; 
		if( isDefined( attacker.isPlanting ) )
			isAttackerPlanting = attacker.isPlanting;

		isAttackerFlashed = attacker maps\mp\_flashgrenades::isFlashbanged();
		metrestring = int(distance(self.origin, attacker.origin) * 2.54) / 100;

		// camo
		if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( sWeapon ) )
			camo = attacker.pers[attacker.pers["class"]]["loadout_camo"];
		
		if ( maps\mp\gametypes\_weapons::isSideArm( sWeapon ) )
			camo = attacker.pers[attacker.pers["class"]]["loadout_secondary_camo"];


		if ( attacker == self )
		{
			doKillcam = false;

			if ( isDefined( self.switching_teams ) )
			{
				if ( !level.teamBased && ((self.leaving_team == "allies" && self.joining_team == "axis") || (self.leaving_team == "axis" && self.joining_team == "allies")) )
				{
					playerCounts = self maps\mp\gametypes\_teams::CountPlayers();
					playerCounts[self.leaving_team]--;
					playerCounts[self.joining_team]++;

					if( !level.rdyup && (playerCounts[self.joining_team] - playerCounts[self.leaving_team]) > 1 )
					{
						self thread [[level.onXPEvent]]( "suicide" );
						self incPersStat( "suicides", 1 );
						self.suicides = self getPersStat( "suicides" );
					}
				}
			}
			else
			{
				if (!level.rdyup)
				{
					self thread [[level.onXPEvent]]( "suicide" );
					self incPersStat( "suicides", 1 );
					self.suicides = self getPersStat( "suicides" );

					scoreSub = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "suicidepointloss" );
					_setPlayerScore( self, _getPlayerScore( self ) - scoreSub );
				}
				if ( sMeansOfDeath == "MOD_SUICIDE" && sHitLoc == "none" && self.throwingGrenade )
					self.lastGrenadeSuicideTime = gettime();
			}
		}
		else
		{
			prof_begin( "PlayerKilled attacker" );

			lpattacknum = attacker getEntityNumber();

			doKillcam = true;

			if ( level.teamBased && self.pers["team"] == attacker.pers["team"] )
			{
				if ( sMeansOfDeath != "MOD_GRENADE" && level.friendlyfire && !level.rdyup )
				{
					attacker thread [[level.onXPEvent]]( "teamkill" );

					attacker.pers["teamkills"] += 1;
					isTeamkill = true;

					if ( maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillpointloss" ) )
					{
						scoreSub = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
						_setPlayerScore( attacker, _getPlayerScore( attacker ) - scoreSub );
					}
				}
			}
			else
			{
				prof_begin( "pks1" );

				// Check for clutch situation
				checkClutchSituation(attacker);

				// Track clutch kills
				if (attacker.clutchSituation != "0")
				{
					attacker.clutchKills++;
					isClutchKill = 1;
				}

				if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
				{
					attacker incPersStat( "headshots", 1 );
					attacker.headshots = attacker getPersStat( "headshots" );
					value = maps\mp\gametypes\_rank::getScoreInfoValue( "headshot" );
					attacker thread maps\mp\gametypes\_rank::giveRankXP( "headshot", value );
					attacker playLocalSound( "bullet_impact_headshot_2" );
				}
				else
				{
					value = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
					attacker thread maps\mp\gametypes\_rank::giveRankXP( "kill", value );
				}

				if (!level.rdyup)
				{
					attacker incPersStat( "kills", 1 );
					attacker.kills = attacker getPersStat( "kills" );

					givePlayerScore( "kill", attacker, self );

					giveTeamScore( "kill", attacker.pers["team"], attacker, self );

					scoreSub = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "deathpointloss" );
					_setPlayerScore( self, _getPlayerScore( self ) - scoreSub );
				}

				prof_end( "pks1" );

				if ( !level.rdyup && level.teamBased )
				{
					prof_begin( "PlayerKilled assists" );

					if ( isdefined( self.attackers ) )
					{
						for ( j = 0; j < self.attackers.size; j++ )
						{
							player = self.attackers[j];

							if ( !isDefined( player ) || player == attacker )
								continue;

							player thread processAssist( self );
						}
						self.attackers = [];
					}

					prof_end( "PlayerKilled assists" );
				}
			}

			prof_end( "PlayerKilled attacker" );
		}
	}
	else
	{
		doKillcam = false;
		killedByEnemy = false;

		lpattacknum = -1;
		lpattackguid = "";
		lpattackname = "";
		lpattackerteam = "world";

		if ( isDefined( attacker ) && isDefined( attacker.team ) && (attacker.team == "axis" || attacker.team == "allies") && attacker.team != self.pers["team"] )
		{
			killedByEnemy = true;
			if ( level.teamBased )
				giveTeamScore( "kill", attacker.team, attacker, self );
		}
	}

	self promod\shoutcast::updatePlayer();

	self.switching_teams = undefined;
	self.joining_team = undefined;
	self.leaving_team = undefined;

	prof_begin( "PlayerKilled post constants" );

	if ( sMeansOfDeath == "MOD_MELEE" )
		scWeapon = "knife_mp";
	else
		scWeapon = sWeapon;

	sHeadshot = int(sMeansOfDeath == "MOD_HEAD_SHOT");

	if ( isDefined( level.scorebot ) && level.scorebot && !level.rdyup )
		game["promod_scorebot_ticker_buffer"] += "kill" + lpattackname + "" + scWeapon + "" + self.name + "" + sHeadshot;

	logPrint( "K;" + self getGuid() + ";" + self getEntityNumber() + ";" + self.pers["team"] + ";" + self.name + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n" );

	// Stats
	if( isDefined( eInflictor ) )
		inflictorOrigin = eInflictor.origin;
	else 	
		inflictorOrigin = "";

	if ( isDefined( timeUntilRoundEnd() ) )
		time = ( timeUntilRoundEnd() - level.postRoundTime );
	else 
		time = 0;

	if(!isDefined(isClutchKill))
		isClutchKill = 0;

	attacker_data = lpattackerteam + ";" + attackerStance+ ";" +attackerAds+ ";" +attackerIsOnGround+ ";" +isAttackerDefusing+ ";" +isAttackerPlanting+ ";" +isAttackerFlashed+ ";" +attacker.origin + ";" +isClutchKill;
	victim_data = self.pers["team"]+ ";" +self getStance()+ ";" +self playerADS()+ ";" +self isOnGround()+ ";" +self.isDefusing+ ";" +self.isPlanting+ ";" +self maps\mp\_flashgrenades::isFlashbanged()+ ";" +self.origin;
	kill_data = isTeamkill+ ";" +isWallbang+ ";" +sWeapon+ ";" +camo+ ";" +iDamage+ ";" +metrestring+ ";" +sMeansOfDeath+ ";" +sHitLoc+ ";" +inflictorOrigin+ ";" + death_by_barell +";" + death_by_bombsite +";"+ death_by_falling +";" +time+ ";" + (game["totalroundsplayed"]+1)+ ";" +level.script+ ";" +level.match_id;

	if( !level.rdyup && isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" && level.match_id != 0 && level.is_public == 0 ) //&& level.gametype == "sd" && game["PROMOD_KNIFEROUND"] == 0
	{
		thread promod\stats::processKillData(attacker, self, attacker_data,	victim_data, kill_data);
	}

	level thread updateTeamStatus();

	self clonePlayer( deathAnimDuration );

	self thread [[level.onPlayerKilled]](eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);

	if ( sWeapon == "none" )
		doKillcam = false;

	killcamentity = -1;

	self.deathTime = getTime();

	wait 0.25;

	self.cancelKillcam = false;
	self thread cancelKillCamOnUse();

	if ( isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "match" && level.gametype == "sd" )
		postDeathDelay = waitForTimeOrNotifies( 0.75 );
	else
		postDeathDelay = waitForTimeOrNotifies( 1.75 );

	self notify ( "death_delay_finished" );

	if ( !isDefined( game["state"] ) || game["state"] != "playing" )
		return;

	respawnTimerStartTime = gettime();

	if ( !self.cancelKillcam && doKillcam && level.killcam )
	{
		livesLeft = !(level.numLives && !self.pers["lives"]);
		timeUntilSpawn = TimeUntilSpawn();
		willRespawnImmediately = livesLeft && (timeUntilSpawn <= 0);

		self maps\mp\gametypes\_killcam::killcam( lpattacknum, killcamentity, sWeapon, postDeathDelay, psOffsetTime, willRespawnImmediately, timeUntilRoundEnd(), [], attacker );
	}

	prof_end( "PlayerKilled post constants" );

	if ( !isDefined( game["state"] ) || game["state"] != "playing" )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		return;
	}

	if ( isValidClass( self.class ) )
	{
		timePassed = (gettime() - respawnTimerStartTime) / 1000;
		self thread [[level.spawnClient]]( timePassed );
	}
}

checkClutchSituation( attacker )
{
    // Get the number of players alive on each team
    aliveCounts = getPlayersAlive();
    
    // Check if the player is the last man standing
    if (aliveCounts[attacker.sessionteam] == 1)
    {
        // Determine the number of enemies alive
        numEnemiesAlive = 0;
        if (attacker.sessionteam == "axis")
            numEnemiesAlive = aliveCounts["allies"];
        else
            numEnemiesAlive = aliveCounts["axis"];
        
        // Determine the type of clutch situation
        if (numEnemiesAlive >= 1 && numEnemiesAlive <= 5)
        {
            // Update the player's clutch situation and reset their clutch kills
            attacker.clutchSituation = "1v" + numEnemiesAlive;
            attacker.clutchKills = 0;
            
            // Notify the player that they are in a clutch situation
            //self notify("clutch_situation");
        }
    }else {
		attacker.clutchSituation = "0";
        attacker.clutchKills = 0;
	}
}

getPlayersAlive()
{
    aliveCounts = [];
    
    // Loop through all players to count the number of alive players on each team
    for (i = 0; i < level.players.size; i++)
    {
        player = level.players[i];
        
        // Skip spectators
        if (player.sessionteam == "spectator")
            continue;
        
        // Increment the count for the player's team
        if (!isDefined(aliveCounts[player.sessionteam]))
            aliveCounts[player.sessionteam] = 1;
        else
            aliveCounts[player.sessionteam]++;
    }
    
    return aliveCounts;
}

cancelKillCamOnUse()
{
	self endon ( "death_delay_finished" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	for(;;)
	{
		if ( !self UseButtonPressed() )
		{
			wait 0.05;
			continue;
		}

		buttonTime = 0;
		while( self UseButtonPressed() )
		{
			buttonTime += 0.05 ;
			wait 0.05;
		}

		if ( buttonTime >= 0.5 )
			continue;

		buttonTime = 0;

		while ( !self UseButtonPressed() && buttonTime < 0.5 )
		{
			buttonTime += 0.05 ;
			wait 0.05;
		}

		if ( buttonTime >= 0.5 )
			continue;

		self.cancelKillcam = true;
		return;
	}
}

waitForTimeOrNotifies( desiredDelay )
{
	startedWaiting = getTime();

	waitedTime = (getTime() - startedWaiting)/1000;

	if ( waitedTime < desiredDelay )
	{
		wait desiredDelay - waitedTime;
		return desiredDelay;
	}
	else
		return waitedTime;
}

processAssist( killedplayer )
{
	self endon("disconnect");
	killedplayer endon("disconnect");

	wait 0.05;
	WaitTillSlowProcessAllowed();

	if ( ( self.pers["team"] != "axis" && self.pers["team"] != "allies" ) || ( self.pers["team"] == killedplayer.pers["team"] ) )
		return;

	self thread [[level.onXPEvent]]( "assist" );
	self incPersStat( "assists", 1 );
	self.assists = self getPersStat( "assists" );

	givePlayerScore( "assist", self, killedplayer );

	if ( !isDefined( level.rdyup ) )
		level.rdyup = false;

	if ( isDefined( level.scorebot ) && level.scorebot && !level.rdyup )
		game["promod_scorebot_ticker_buffer"] += "assist_by" + self.name;
}

Callback_PlayerLastStand()
{
}

setSpawnVariables()
{
	resetTimeout();

	self StopShellshock();
	self StopRumble( "damage_heavy" );
	self setClientDvar( "cg_thirdPerson", 0 );
}

notifyConnecting()
{
	if( level.match_id != 0 )
		self promod\ac::setPlayerRank();
	else
		self setRank( 0, 1 );

	waittillframeend;

	if( isDefined( self ) )
		level notify( "connecting", self );
}

setObjectiveText( team, text )
{
	game["strings"]["objective_"+team] = text;
	precacheString( text );
}

setObjectiveScoreText( team, text )
{
	game["strings"]["objective_score_"+team] = text;
	precacheString( text );
}

setObjectiveHintText( team, text )
{
	game["strings"]["objective_hint_"+team] = text;
	precacheString( text );
}

getObjectiveText( team )
{
	if ( !isDefined( game["strings"]["objective_"+team] ) )
		return "";

	return game["strings"]["objective_"+team];
}

getObjectiveScoreText( team )
{
	if ( !isDefined( game["strings"]["objective_score_"+team] ) )
		return "";

	return game["strings"]["objective_score_"+team];
}

getObjectiveHintText( team )
{
	if ( !isDefined( game["strings"]["objective_hint_"+team] ) )
		return "";

	return game["strings"]["objective_hint_"+team];
}

checkOvertimeSwitch() {
    if ( !level.roundSwitch || level.gametype == "dm" || level.gametype == "sab" || level.gametype == "war" || level.gametype == "koth" )
        return false;

    if (hitOvertime() && level.overtimeRoundSwitch > 0) {
		//iPrintLnBold("Overtime switch");
		game["promod_do_readyup"] = isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "match" || getDvarInt("promod_allow_readyup") && isDefined(game["CUSTOM_MODE"]) && game["CUSTOM_MODE"];
			
		game["promod_timeout_called"] = false;
		game["promod_overtime_active"] = true;
		game["promod_overtime_count"]++;
		[[level.onRoundSwitch]]();
		
		return true;
    }

    return false;
}

hitOvertime() {
    if (level.roundLimit <= 0)
        return false;

    if (game["promod_overtime_active"]) {
        return game["teamScores"]["allies"] / game["teamScores"]["axis"] == 1 && game["roundsplayed"] >= level.overtimeRoundSwitch * 2;
    } else {
        return game["teamScores"]["allies"] > 0 && game["teamScores"]["axis"] > 0 && game["teamScores"]["allies"] / game["teamScores"]["axis"] == 1 && game["roundsplayed"] >= level.roundLimit;
    }
}