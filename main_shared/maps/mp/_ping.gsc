monitorPing()
{
	self endon("disconnect");

    self.isExcludedFromPing = false;

    if( isDefined(level.steamIds) && isDefined(level.max_ping) )
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
                wait 1;

                if(ping > level.max_ping)
                {
                    self iprintln("You exceeded max ping - ^1" + ping + "^7!");
                    self.pingStrikes++;
                }

                if(self.pingStrikes > 5)
                {
                    kick( self getentitynumber() );
                }
                    
            }
        }
    }        
}