#include maps\mp\gametypes\_hud_util;

mainLoop() 
{
    self endon("disconnect");
   
	self.velocity["current_speed"] = 0;
    self.velocity["max_speed"] = 0;
    self.velocity["speed"] = true;
    self.velocity["speedHUD"] = newClientHudElem(self);
    self.velocity["speedHUD"].horzAlign = "center";
    self.velocity["speedHUD"].vertAlign = "middle";
    self.velocity["speedHUD"].alignX = "center";
    self.velocity["speedHUD"].alignY = "top";
    self.velocity["speedHUD"].font = "default";
    self.velocity["speedHUD"].hideWhenInMenu = true;
    self.velocity["speedHUD"].color = (1, 1, 1);
    self.velocity["speedHUD"].fontScale = 1.4;
    self.velocity["speedHUD"].alpha = 1;
    self.velocity["speedHUD"].x = -43;
    self.velocity["speedHUD"].y = -240;
	self.velocity["speedHUD"].archived = false;
    
    self.velocity["speedMHUD"] = newClientHudElem(self);
    self.velocity["speedMHUD"].horzAlign = "center";
    self.velocity["speedMHUD"].vertAlign = "middle";
    self.velocity["speedMHUD"].alignX = "center";
    self.velocity["speedMHUD"].alignY = "top";
    self.velocity["speedMHUD"].font = "default";
    self.velocity["speedMHUD"].hideWhenInMenu = true;
    self.velocity["speedMHUD"].color = (1, 1, 1);
    self.velocity["speedMHUD"].fontScale = 1.4;
    self.velocity["speedMHUD"].alpha = 1;
    self.velocity["speedMHUD"].x = 43;
    self.velocity["speedMHUD"].y = -240;
	self.velocity["speedMHUD"].archived = false;
	
	// self.velocity["speedLine"] = newClientHudElem( self );
	// self.velocity["speedLine"].x = -6;
	// self.velocity["speedLine"].y = -242;
	// self.velocity["speedLine"].horzAlign = "center";
	// self.velocity["speedLine"].vertAlign = "middle";
	// self.velocity["speedLine"].alignX = "center";
	// self.velocity["speedLine"].alignY = "middle";
	// self.velocity["speedLine"].color =  (1, 1, 1);
	// self.velocity["speedLine"].hidewheninmenu = 1;
	// self.velocity["speedLine"] setShader( "line_horizontal", 135, 2 );
	// self.velocity["speedLine"].alpha =1;
	// self.velocity["speedLine"].archived = false;

		
   while(1)
	{
        velocity = self promod\client::get_config( "PROMOD_VELOCITY" );

        self.velocity["speedHUD"].alpha = 1;
        self.velocity["speedMHUD"].alpha = 1;
        self.velocity["speedHUD"].label = &"SPEED ";
        self.velocity["speedHUD"] setValue(self.velocity["current_speed"]);
        self.velocity["speedMHUD"].label = &"MAX ";
        self.velocity["speedMHUD"] setValue(self.velocity["max_speed"]);

        if(velocity){        
            speed = calculateSpeed(self getVelocity());
            
            if(speed > 50000)
                speed = 50000;
            
            if(speed > self.velocity["max_speed"]) 
            {
                self.velocity["max_speed"] = speed;
                self.velocity["speedMHUD"] setValue(speed);
            }
            
            self.velocity["current_speed"] = speed;
            self.velocity["speedHUD"] setValue(speed);
            if(speed > 350 && speed < 700) 
                self.velocity["speedHUD"].color = (0, 1, 0);
            else if(speed > 700 && speed < 1200) 
                self.velocity["speedHUD"].color = (1, 0.4, 0);
            else if(speed > 1200)
                self.velocity["speedHUD"].color = (1, 0, 0);
            else 
                self.velocity["speedHUD"].color = ( 1, 1, 1);
            wait .05;
        }else {
            self.velocity["speedHUD"].alpha = 0;
            self.velocity["speedMHUD"].alpha = 0;
            wait 1;
        }
    }
}
 
calculateSpeed(velocity) 
{
    speed = Int(length((velocity[0], velocity[1], 0)));
    return speed;
}

