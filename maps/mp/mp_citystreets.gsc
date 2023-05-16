/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_citystreets");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	level.sunlight = 0.78;

	maps\mp\_explosive_barrels::main();

	precacheModel( "ch_corkboard_metaltrim_4x8" );
	
	// Fixed L corner so you cant see to carpark
	corner = spawn("script_model", (5860, -543, 60));
	corner.angles = (90,90,0);
	corner setmodel( "ch_corkboard_metaltrim_4x8" );

	// Fixed ticket so you cant see under
	ticket = spawn("script_model", (3104, -465, -115));
	ticket.angles = (0,100,0);
	ticket setmodel( "ch_corkboard_metaltrim_4x8" );

	ticket2 = spawn("script_model", (3106, -484, -115));
	ticket2.angles = (0,100,0);
	ticket2 setmodel( "ch_corkboard_metaltrim_4x8" );

	ticket3 = spawn("script_model", (3156, -521, -140));
	ticket3.angles = (90,10,180);
	ticket3 setmodel( "ch_corkboard_metaltrim_4x8" );

	ticket4 = spawn("script_model", (3138, -527, -140));
	ticket4.angles = (90,10,180);
	ticket4 setmodel( "ch_corkboard_metaltrim_4x8" );
	
}