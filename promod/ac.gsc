main()
{
    // Requires CoD4X server and http plugin, so commented out
	//thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

        if( !isDefined(player.pers["onAnticheat"] ))
		    player thread monitorAC();
	}
}

monitorAC()
{
	self endon("ac_online");
    self endon("disconnect");

	for(;;)
	{
        getAcStatus();
		wait 10;
	}
}

isOnAnticheat()
{
    if ( isDefined(self.pers["onAnticheat"]) && self.pers["onAnticheat"] )
        return true;
    else    
        return false;
}

setPlayerRank()
{
    if ( isOnAnticheat())
        self setRank(6, 0);
    else 
        self setRank(0, 1);
}

getAcStatus()
{
    // Requires CoD4X server and http plugin, so logic hidden
}

callback(handle)
{
    // Requires CoD4X server and http plugin, so logic hidden
}


