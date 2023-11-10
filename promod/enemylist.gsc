// init()
// {
//     thread onPlayerConnect();
// }

// onPlayerConnect()
// {
// 	for(;;)
// 	{
// 		level waittill("connected", player);
// 		player thread updatePlayerInfoLoop();
// 	}
// }

// updatePlayerInfoLoop()
// {
//     self endon("disconnect");
//     for(;;)
//     {
//         for( i = 0;i < level.players.size; i++)
//             if(isDefined(level.players[i].pers["infonum"]))
//                 iprintln( level.players[i].name + " - " + level.players[i].pers["infonum"] );
//             else 
//                 iprintln(level.players[i].name + " not defined num yet");
//         wait 2;
        
//     }
// }

updatePlayerInfo()
{
    for( i = 0;i < level.players.size; i++)
        if( level.players[i].pers["team"] != "spectator" && isDefined(self.pers["infonum"] ) )
            level.players[i] setClientDvars("info_name"+self.pers["infonum"], self.name, "info_health"+self.pers["infonum"], self.health);
}

addPlayerInfo()
{
    if( isDefined( self.pers["class"] ) && !isDefined( self.pers["infonum"] ) && ( self.pers["team"] == "allies" || self.pers["team"] == "axis" ) )
	{
        //iprintln("adding player info for " + self.name);
		offset = int(self.pers["team"] == "axis")*5;
		for(i = 0; i < 5; i++)
			if( !isDefined( level.infobars[ i + offset ] ) )
			{
				self.pers["infonum"] = i + offset;
				level.infobars[ self.pers["infonum"] ] = self;
				self updatePlayerInfo();
				break;
			}
        loadAllPlayers();
	}
}

removePlayerInfo()
{
    if(isDefined(self.pers["infonum"]))
	{
		level.infobars[self.pers["infonum"]] = undefined;
		self.pers["infonum"] = undefined;

		// Find replacements for current slots.
		for(i = 0; i < level.players.size; i++)
			level.players[i] addPlayerInfo();

		// pad others to the top
		for(i = 0; i < 5; i++)
			if( !isDefined( level.infobars[ i ] ) )
				for(j = i + 1; j < 5; j++)
					if( isDefined( level.infobars[ j ] ) )
					{
						level.infobars[i] = level.infobars[ j ];
						level.infobars[i].pers["infonum"] = i;
						level.infobars[j] = undefined;
						break;
					}

		for(i = 5; i < 10; i++)
			if( !isDefined( level.infobars[ i ] ) )
				for(j = i + 1; j < 10; j++)
					if( isDefined( level.infobars[ j ]))
					{
						level.infobars[i] = level.infobars[j];
						level.infobars[i].pers["infonum"] = i;
						level.infobars[j] = undefined;
						break;
					}

		loadAllPlayers();
	}
}

loadAllPlayers()
{
	for( i = 0; i < level.players.size; i++)
		if( level.players[i].pers["team"] != "spectator" && level.players[i].pers["team"] != "none")
			level.players[i] loadOnePlayer();
}

loadOnePlayer()
{
	for(j = 0; j < 10; j++)
		if( isDefined( level.infobars[ j ] ) )
			self setClientDvars("info_name"+j, level.infobars[ j ].name, "info_health"+j, level.infobars[ j ].health);
		else
			self setClientDvars("info_name" + j, "", "info_health" + j, "");
}