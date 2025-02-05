#include maps\mp\gametypes\_hud_util;

mainLoop() 
{
    //self endon("disconnect");

    // clipCount = level.player GetWeaponAmmoClip( "uzi" );

    // self waittill("reload_start");
    // self waittill("reload");
	// currentweapon = self GetCurrentWeapon();
   

    // player SetMoveSpeedScale(0.4);

    // var_00 = self getcurrentweapon();
    // var_01 = self getweaponammostock(var_00);
    // var_02 = weaponclipsize(var_00);
		
//    while(1)
// 	{
//         self watchReloading();
//     }
}
 
calculateSpeed(velocity) 
{
    speed = Int(length((velocity[0], velocity[1], 0)));
    return speed;
}

watchReloading()
{
	// this only works on the player.
	self.isreloading = false;
	while(1)
	{
        self allowads(1); 
		self waittill("reload_start");
		self.isreloading = true;
        //iprintln("reload start");

        weap = self getCurrentWeapon();
		
        //if( self GetWeaponAmmoClip(weap) == weaponClipSize(weap)-1 )
        
		    self waittillreloadfinished();
        
            self.isreloading = false;
	}
}

waittillReloadFinished()
{

    self endon("weapon_fired");
    self endon("weapon_change");

    while(1)
    {
        weap = self getCurrentWeapon();
        if (weap == "none")
            break;

        //iprintln(self GetWeaponAmmoClip(weap));

        clipSize = weaponClipSize(weap);
        if (self GetWeaponAmmoClip(weap) >= clipSize){
            self allowads(0); 
            break;
        }
        
        wait 0.05; // Small delay to prevent infinite loop CPU hogging
    }

    //self setClientDvar("record_string", "stoprecord;record " + demo_name);
	//self closeMenu();
	//self closeInGameMenu();

    //-gostand

	// if( level.gametype == "sd" ){
	// 	self openMenu( game["menu_demo"] );
	// 	self closeMenu();

    // for(i = 0; i < 10; i++)
    // {
    //     self setClientDvar("record_string", "stoprecord;record " + demo_name);
    //     wait 0.1;
    // }

    wait 0.8;
    self allowads(1); 
    //self setMoveSpeedScale( ( 1.0 - 0.05 * int( self.class == "assault" ) ) );
    //iprintln("Reload finished");
}

