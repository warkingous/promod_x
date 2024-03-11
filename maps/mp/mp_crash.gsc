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
	maps\mp\_compass::setupMiniMap("compass_map_mp_crash");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	level.sunlight = 1.3;

	precacheModel( "me_concrete_barrier" );
	precacheModel( "ch_corkboard_metaltrim_4x8" );
	
	// Fixed long concrete so you cant see under
	long = spawn("script_model", (-326, -874, 110));
	long.angles = (180,-16,0);
	long setmodel( "me_concrete_barrier" );

	// Fixed A wooden stairs so you cant see bottom A
	wooden = spawn("script_model", (1522, 405, 307));
	wooden.angles = (0,0,90);
	wooden setmodel( "ch_corkboard_metaltrim_4x8" );
}