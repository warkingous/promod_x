// Rcon / cfg: set promod_stats_debug 1 — iprintln chat z hooků v tomto souboru (0 = vypnuto)
debugPrint( msg )
{
	if ( !getDvarInt( "promod_stats_debug" ) )
		return;
	iprintln( "^3[stats]^7 " + msg );
}

mapStarted()
{
	debugPrint( "mapStarted()" );
}

publicMapStarted()
{
	debugPrint( "publicMapStarted()" );
}

initPlayers()
{
	debugPrint( "initPlayers()" );
}

processKillData( attacker, victim, attacker_data, victim_data, kill_data )
{
	an = "?";
	vn = "?";
	if ( isDefined( attacker ) && isPlayer( attacker ) )
		an = attacker.name;
	if ( isDefined( victim ) && isPlayer( victim ) )
		vn = victim.name;
	debugPrint( "processKillData " + an + " -> " + vn );
}

sendData()
{
	debugPrint( "sendData()" );
}

halftime()
{
	debugPrint( "halftime()" );
}

findTeamName( team )
{
	debugPrint( "findTeamName " + team );
}

findTeamTag( team )
{
	debugPrint( "findTeamTag " + team );
}

roundReport( round, allies_score, axis_score, endRoundReason, winner, knife_round, ot_active, ot_count )
{
	debugPrint( "roundReport r" + round + " A" + allies_score + " X" + axis_score + " win:" + winner + " kr:" + knife_round );
}

// type "plant" | "defuse"; label from bomb object (SD: self.label, SAB: getLabel()); filter match_id in here if needed
bombReport( player, label, type, round )
{
	pn = "?";
	if ( isDefined( player ) && isPlayer( player ) )
		pn = player.name;
	debugPrint( "bombReport " + pn + " " + label + " " + type + " r" + round );
}

// player = caller; action "called" | "cancelled"; team "allies" | "axis" | ""; round = totalroundsplayed+1 when defined
timeoutReport( player, action, team, round )
{
	pn = "?";
	if ( isDefined( player ) && isPlayer( player ) )
		pn = player.name;
	debugPrint( "timeoutReport " + action + " " + pn + " team:" + team + " r" + round );
}

// Timeout phase finished: reason "ready_up" (all ready) | "timer_expired" (countdown reached 0); round same as timeoutReport
timeoutEndReport( reason, round )
{
	debugPrint( "timeoutEnd " + reason + " r" + round );
}

findTeamId( team )
{
	debugPrint( "findTeamId " + team );
}

setTeamId( id, team )
{
	debugPrint( "setTeamId id:" + id + " team:" + team );
}

startServerRecord( ent )
{
	if ( isDefined( ent ) && isPlayer( ent ) )
		debugPrint( "startServerRecord " + ent.name );
	else
		debugPrint( "startServerRecord" );
}

stopServerRecord()
{
	debugPrint( "stopServerRecord()" );
}

cancelMatch( ids )
{
	debugPrint( "cancelMatch - Match cancelled" );
}

dmFinished( player )
{
	if ( isDefined( player ) )
		debugPrint( "dmFinished " + player.name );
	else
		debugPrint( "dmFinished" );
}

updateGunX( player, value )
{
	debugPrint( "updateGunX " + value );
}

updateFovScale( player, value )
{
	debugPrint( "updateFovScale " + value );
}

// Helper function to find the majority element in an array
findMajority(arr)
{
    count = 1;
    majorityElement = arr[0];
    
    for (i = 1; i < arr.size; i++)
    {
        if (arr[i] == majorityElement)
        {
            count++;
        }
        else
        {
            count--;

            if (count == 0)
            {
                majorityElement = arr[i];
                count = 1;
            }
        }
    }

    return majorityElement;
}

// Helper function to count occurrences of an element in an array
countOccurrences(arr, element)
{
    count = 0;
    
    for (i = 0; i < arr.size; i++)
    {
        if (arr[i] == element)
        {
            count++;
        }
    }

    return count;
}

bubbleSort(arr)
{
    for (i = 0; i < arr.size - 1; i++)
    {
        for (j = 0; j < arr.size - i - 1; j++)
        {
            if (arr[j] > arr[j + 1])
            {
                // Swap arr[j] and arr[j+1]
                temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

gameStartedCallback( handle )
{
	debugPrint( "gameStartedCallback" );
}

mapFinished( winner )
{
	debugPrint( "mapFinished winner:" + winner );
}

sendPublicStatsData()
{
	debugPrint( "sendPublicStatsData()" );
}

sendStatsData()
{
	debugPrint( "sendStatsData()" );
}

selfDataCallback( handle )
{
	debugPrint( "selfDataCallback" );
}

getPersStat( dataName )
{
	debugPrint( "getPersStat stub " + dataName );
}
