monitorPing()
{
	self endon("disconnect");

    self.isExcludedFromPing = false;

    if( isDefined(level.steamIds) && isDefined(level.fps_max_ping) )
    {
        if( level.steamIds.size > 0)
        {
            for( i = 0;i < level.steamIds.size; i++)
            {
                if( level.steamIds[i] == self getsteamid64())
                {
                    self.isExcludedFromPing = true;
                }
            }
        }

        if(!self.isExcludedFromPing)
        {
            self.pingStrikes = 0;
            for(;;)
            {
                ping = self getPing();
                iprintln("You exceeded max ping - ^1" + ping + "^7!");
                wait 1;

                if(ping > level.fps_max_ping)
                    self.pingStrikes++;

                if(self.pingStrikes > 5)
                    kick( self getentitynumber() );
            }
        }
    }        
}