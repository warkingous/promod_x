#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

/*
--------------------------------------------------------------------------------------------------------
This map is re-created from Battalion 1944, the idea is to play with friends in Call of Duty 4 promod.
Map version: v1.0
Compatible only with CoD4x.
Supported modes: SD, WAR, FFA, SAB, KOTH, DOM.
--------------------------------------------------------------------------------------------------------
Any bug? tell me, mail: gamemapping@outlook.es, dc:andyx#6777.
--------------------------------------------------------------------------------------------------------
Thanks to: 
xoxor4d for his great work on Radiant.
Spi and his community for answering my questions.
--------------------------------------------------------------------------------------------------------
Note:
None of the textures and assets belong to me, everything remains their respective owners.
--------------------------------------------------------------------------------------------------------
*/

main()
{
	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "allies";
    game["defenders"] = "axis";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";
	
maps\mp\_compass::setupMiniMap("compass_map_mp_liberation");
setdvar("compassmaxrange","2000");

PreCacheModel("propelax35_v3");
PreCacheModel("wind_backx35");
thread windmill_1();
thread windmill_2();
}



windmill_1(){

	wait 5;
	rotate_obj = getent("wind01","targetname");
	for(;;)
	{	rotate_obj rotateRoll(-360,60);
		wait (60-0.1);
	}
}


windmill_2(){

	wait 5;
	rotate_obj = getent("wind02","targetname");
	for(;;)
	{	rotate_obj rotateRoll(360,60);
		wait (60-0.1);
	}
}

