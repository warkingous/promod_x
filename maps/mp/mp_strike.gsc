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
	maps\mp\_compass::setupMiniMap("compass_map_mp_strike");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	level.sunlight = 1;

	preCacheModel( "mil_sandbag_desert_long" );
	preCacheModel( "mil_sandbag_desert_single_flat" );
	preCacheModel( "ch_corkboard_metaltrim_4x8" );
	preCacheModel( "me_corrugated_metal4x4" );
	precacheModel( "ch_corkboard_metaltrim_3x4" );
	precacheModel( "com_plainchair_shardrail" );

	// Fixed A bins sandbags - one way vision
	bags = spawn("script_model", (-155, 850, 18 ));
	bags.angles = (0,90,0);
	bags setmodel( "mil_sandbag_desert_long" );


	// Fixed statue sandbags corners
	bag1 = spawn("script_model", (-462, 975, 51 ));
	bag1.angles = (0,90,0);
	bag1 setmodel( "mil_sandbag_desert_single_flat" );

	bag2 = spawn("script_model", (-470, 598, 51 ));
	bag2.angles = (0,0,0);
	bag2 setmodel( "mil_sandbag_desert_single_flat" );

	bag3 = spawn("script_model", (-840, 598, 51 ));
	bag3.angles = (0,180,0);
	bag3 setmodel( "mil_sandbag_desert_single_flat" );

	bag4 = spawn("script_model", (-847, 975, 51 ));
	bag4.angles = (0,90,0);
	bag4 setmodel( "mil_sandbag_desert_single_flat" );


	// Fixed missing textures on balconies
	balcony1 = spawn("script_model", (921, 399, 212 ));
	balcony1.angles = (0,0,180);
	balcony1 setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony_1 = spawn("script_model", (872, 48, 212 ));
	balcony_1.angles = (90,90,0);
	balcony_1 setmodel( "me_corrugated_metal4x4" );

	balcony_1x = spawn("script_model", (872, 96, 212 ));
	balcony_1x.angles = (90,90,00);
	balcony_1x setmodel( "me_corrugated_metal4x4" );

	balcony_2 = spawn("script_model", (872, 144, 212 )); 
	balcony_2.angles = (90,90,0);
	balcony_2 setmodel( "me_corrugated_metal4x4" );

	balcony_3 = spawn("script_model", (872, 192, 212 )); 
	balcony_3.angles = (90,90,0);
	balcony_3 setmodel( "me_corrugated_metal4x4" );

	balcony_4 = spawn("script_model", (872, 240, 212 )); 
	balcony_4.angles = (90,90,0);
	balcony_4 setmodel( "me_corrugated_metal4x4" );

	balcony_5 = spawn("script_model", (872, 288, 212 ));
	balcony_5.angles = (90,90,0);
	balcony_5 setmodel( "me_corrugated_metal4x4" );

	balcony_6 = spawn("script_model", (872, 336, 212 ));
	balcony_6.angles = (90,90,0);
	balcony_6 setmodel( "me_corrugated_metal4x4" );

	balcony_7 = spawn("script_model", (872, 384, 212 )); 
	balcony_7.angles = (90,90,0);
	balcony_7 setmodel( "me_corrugated_metal4x4" );

	balcony6 = spawn("script_model", (921, 33, 212 ));
	balcony6.angles = (0,0,0);
	balcony6 setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony1g = spawn("script_model", (920, 383, 196 ));
	balcony1g.angles = (0,0,90);
	balcony1g setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony2g = spawn("script_model", (920, 335, 196 ));
	balcony2g.angles = (0,0,90);
	balcony2g setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony3g = spawn("script_model", (920, 287, 196 ));
	balcony3g.angles = (0,0,90);
	balcony3g setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony4g = spawn("script_model", (920, 239, 196 ));
	balcony4g.angles = (0,0,90);
	balcony4g setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony5g = spawn("script_model", (920, 191, 196 ));
	balcony5g.angles = (0,0,90);
	balcony5g setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony6g = spawn("script_model", (920, 143, 196 ));
	balcony6g.angles = (0,0,90);
	balcony6g setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony7g = spawn("script_model", (920, 95, 196 ));
	balcony7g.angles = (0,0,90);
	balcony7g setmodel( "ch_corkboard_metaltrim_4x8" );

	balcony8g = spawn("script_model", (920, 49, 196 ));
	balcony8g.angles = (0,0,90);
	balcony8g setmodel( "ch_corkboard_metaltrim_4x8" );

	// Fixed balconies next to Stevys spot
	stevy_1 = spawn("script_model", (738, -114, 176 ));
	stevy_1.angles = (0,90,0);
	stevy_1 setmodel( "me_corrugated_metal4x4" );

	stevy_2 = spawn("script_model", (738, -160, 176 ));
	stevy_2.angles = (0,90,0);
	stevy_2 setmodel( "me_corrugated_metal4x4" );

	stevy_3 = spawn("script_model", (738, -206, 176 ));
	stevy_3.angles = (0,90,0);
	stevy_3 setmodel( "me_corrugated_metal4x4" );

	stevy_4 = spawn("script_model", (738, -457, 176 ));
	stevy_4.angles = (0,90,0);
	stevy_4 setmodel( "me_corrugated_metal4x4" );

	stevy_5 = spawn("script_model", (738, -503, 176 ));
	stevy_5.angles = (0,90,0);
	stevy_5 setmodel( "me_corrugated_metal4x4" );

	stevy_6 = spawn("script_model", (738, -549, 176 ));
	stevy_6.angles = (0,90,0);
	stevy_6 setmodel( "me_corrugated_metal4x4" );

	// water = spawn("script_model", (-1193, 2049, 21 ));
	// water.angles = (0,0,0);
	// water setmodel( "ch_corkboard_metaltrim_3x4" );

	// water2 = spawn("script_model", (-1112, 2049, 21 ));
	// water2.angles = (0,0,0);
	// water2 setmodel( "ch_corkboard_metaltrim_3x4" );
	water1 = spawn("script_model", (-1170, 2051, 16 ));
	water1.angles = (0,0,0);
	water1 setmodel( "ch_corkboard_metaltrim_4x8" );

	water2 = spawn("script_model", (-1104, 2051, 16 ));
	water2.angles = (90,0,0);
	water2 setmodel( "ch_corkboard_metaltrim_3x4" );

	water3 = spawn("script_model", (-1170, 1725, 16 ));
	water3.angles = (0,180,0);
	water3 setmodel( "ch_corkboard_metaltrim_4x8" );

	water4 = spawn("script_model", (-1104, 1725, 16 ));
	water4.angles = (90,0,180);
	water4 setmodel( "ch_corkboard_metaltrim_3x4" );

	water5 = spawn("script_model", (-1218, 1774, 14 ));
	water5.angles = (0,90,0);
	water5 setmodel( "ch_corkboard_metaltrim_4x8" );

	water6 = spawn("script_model", (-1218, 1870, 14 ));
	water6.angles = (0,90,0);
	water6 setmodel( "ch_corkboard_metaltrim_4x8" );

	water7 = spawn("script_model", (-1218, 1966, 14 ));
	water7.angles = (0,90,0);
	water7 setmodel( "ch_corkboard_metaltrim_4x8" );

	water9 = spawn("script_model", (-1218, 2032, 14 ));
	water9.angles = (90,90,0);
	water9 setmodel( "ch_corkboard_metaltrim_3x4" );
	
	water10 = spawn("script_model", (-1086, 1870, 14 ));
	water10.angles = (0,90,180);
	water10 setmodel( "ch_corkboard_metaltrim_4x8" );

	water11 = spawn("script_model", (-1086, 1774, 14 ));
	water11.angles = (0,90,180);
	water11 setmodel( "ch_corkboard_metaltrim_4x8" );

	water11 = spawn("script_model", (-1086, 1966, 14 ));
	water11.angles = (0,90,180);
	water11 setmodel( "ch_corkboard_metaltrim_4x8" );

	water12 = spawn("script_model", (-1086, 2032, 14 ));
	water12.angles = (90,90,180);
	water12 setmodel( "ch_corkboard_metaltrim_3x4" );

	
	
}