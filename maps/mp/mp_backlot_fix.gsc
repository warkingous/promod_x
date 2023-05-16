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
	maps\mp\_compass::setupMiniMap("compass_map_mp_backlot");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	level.sunlight = 1.3;

	precacheModel( "com_plainchair_shardrail" );
	precacheModel( "ch_corkboard_metaltrim_4x8" );
	precacheModel( "ch_corkboard_metaltrim_3x4" );


	// bot A top A one-way fix
	stairs1 = spawn("script_model", (-1268, 33, 181));
	stairs1.angles = (0,0,0);
	stairs1 setmodel( "com_plainchair_shardrail" );

	stairs2 = spawn("script_model", (-1267, 33, 181));
	stairs2.angles = (0,0,0);
	stairs2 setmodel( "com_plainchair_shardrail" );

	// Fence gap fix
	fence = spawn("script_model", (209, -390, 75));
	fence.angles = (0,0,0);
	fence setmodel( "com_plainchair_shardrail" );

	fence_ = spawn("script_model", (208, -390, 75));
	fence_.angles = (0,0,0);
	fence_ setmodel( "com_plainchair_shardrail" );

	fence2 = spawn("script_model", (209, -390, 91));
	fence2.angles = (0,0,0);
	fence2 setmodel( "com_plainchair_shardrail" );

	fence2_ = spawn("script_model", (208, -390, 91));
	fence2_.angles = (0,0,0);
	fence2_ setmodel( "com_plainchair_shardrail" );

	fence3 = spawn("script_model", (209, -390, 107));
	fence3.angles = (0,0,0);
	fence3 setmodel( "com_plainchair_shardrail" );

	fence3_ = spawn("script_model", (208, -390, 107));
	fence3_.angles = (0,0,0);
	fence3_ setmodel( "com_plainchair_shardrail" );

	fence4 = spawn("script_model", (209, -390, 123));
	fence4.angles = (0,0,0);
	fence4 setmodel( "com_plainchair_shardrail" );

	fence4_ = spawn("script_model", (208, -390, 123));
	fence4_.angles = (0,0,0);
	fence4_ setmodel( "com_plainchair_shardrail" );

	fence5 = spawn("script_model", (209, -390, 139));
	fence5.angles = (0,0,0);
	fence5 setmodel( "com_plainchair_shardrail" );

	fence5_ = spawn("script_model", (208, -390, 139));
	fence5_.angles = (0,0,0);
	fence5_ setmodel( "com_plainchair_shardrail" );

	fence6 = spawn("script_model", (209, -390, 155));
	fence6.angles = (0,0,0);
	fence6 setmodel( "com_plainchair_shardrail" );

	fence6_ = spawn("script_model", (208, -390, 155));
	fence6_.angles = (0,0,0);
	fence6_ setmodel( "com_plainchair_shardrail" );

	// Forward, Up 


	// Ruins stairs fix
	ruins1 = spawn("script_model", (1718, -334, 150));
	ruins1.angles = (180,90,56.8);
	ruins1 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins1 = spawn("script_model", (1814, -334, 87));
	ruins1.angles = (180,90,56.7);
	ruins1 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins2 = spawn("script_model", (1782, -334, 108));
	ruins2.angles = (180,90,56.8);
	ruins2 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins3 = spawn("script_model", (1750, -334, 129));
	ruins3.angles = (180,90,56.8);
	ruins3 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins4 = spawn("script_model", (1718, -334, 150));
	ruins4.angles = (180,90,56.8);
	ruins4 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins5 = spawn("script_model", (1686, -334, 171));
	ruins5.angles = (180,90,56.8);
	ruins5 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins6 = spawn("script_model", (1654, -334, 192));
	ruins6.angles = (180,90,56.8);
	ruins6 setmodel( "ch_corkboard_metaltrim_4x8" );
	
	ruins7 = spawn("script_model", (1622, -334, 213));
	ruins7.angles = (180,90,56.8);
	ruins7 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins8 = spawn("script_model", (1609, -329, 213));
	ruins8.angles = (180,90,90);
	ruins8 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins9 = spawn("script_model", (1561, -329, 213));
	ruins9.angles = (180,90,90);
	ruins9 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins10 = spawn("script_model", (1513, -329, 213));
	ruins10.angles = (180,90,90);
	ruins10 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins11 = spawn("script_model", (1465, -329, 213));
	ruins11.angles = (180,90,90);
	ruins11 setmodel( "ch_corkboard_metaltrim_4x8" );

	ruins12 = spawn("script_model", (1609, -377.7, 231));
	ruins12.angles = (180,180,0);
	ruins12 setmodel( "ch_corkboard_metaltrim_3x4" );

	ruins13 = spawn("script_model", (1561, -377.7, 231));
	ruins13.angles = (180,180,0);
	ruins13 setmodel( "ch_corkboard_metaltrim_3x4" );

	ruins13 = spawn("script_model", (1513, -377.7, 231));
	ruins13.angles = (180,180,0);
	ruins13 setmodel( "ch_corkboard_metaltrim_3x4" );

	ruins14 = spawn("script_model", (1465, -377.7, 231));
	ruins14.angles = (180,180,0);
	ruins14 setmodel( "ch_corkboard_metaltrim_3x4" );

	ruins15 = spawn("script_model", (1441, -353, 232));
	ruins15.angles = (0,90,0);
	ruins15 setmodel( "ch_corkboard_metaltrim_3x4" );

	ruins16 = spawn("script_model", (1441, -305, 232));
	ruins16.angles = (0,90,0);
	ruins16 setmodel( "ch_corkboard_metaltrim_3x4" );



	// Spawn palm fix

	test = spawn("script_model", (53, -1743, 194 ));
	test.angles = (0,0,90);

	// Spawn( "trigger_radius", origin, spawn flags, radius, height );
	collision = spawn("trigger_radius", test.origin, 0, 20 , 4);
	collision.angles = (0, 0, 0);
	collision setcontents(1);
}