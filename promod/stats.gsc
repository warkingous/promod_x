mapStarted()
{

}

publicMapStarted()
{

}

initPlayers( )
{

}

processKillData()
{

}

sendData()
{
    
}

halftime()
{

}

findTeamName( team )
{
    teamIdCheck = 0;
    teamTempIds = [];
    teamSize = 0;
	majorityTeamName = "none";

    for (i = 0; i < level.players.size; i++)
    {
        // Check if the player has a valid teamId
        if (isDefined(level.players[i].pers["teamName"]) && level.players[i].pers["team"] == team)
        {
            teamTempIds[teamSize] = level.players[i].pers["teamName"];
            teamSize++;
        }
    }

	// Handle 1v1 scenario
    if (teamSize == 1)
    {
        return teamTempIds[0]; // Return the teamId for the solo player
    }

    // Check if the team has players with the same teamId
    if (teamSize > 1)
    {
        bubbleSort(teamTempIds);
        majorityTeamName = findMajority(teamTempIds);

        if (countOccurrences(teamTempIds, majorityTeamName) >= teamSize / 2)
        {
            teamIdCheck = 1;
        }
    }

    // Return the majority teamId for the specified team or 0 if no majority teamId found
    if (teamIdCheck == 1)
	{
		return majorityTeamName;
	}
	else
	{
		return 0;
	}
}

findTeamTag( team )
{
    teamIdCheck = 0;
    teamTempIds = [];
    teamSize = 0;
	majorityTag = "none";

    for (i = 0; i < level.players.size; i++)
    {
        // Check if the player has a valid teamId
        if (isDefined(level.players[i].pers["teamTag"]) && level.players[i].pers["team"] == team)
        {
            teamTempIds[teamSize] = level.players[i].pers["teamTag"];
            teamSize++;
        }
    }

	// Handle 1v1 scenario
    if (teamSize == 1)
    {
        return teamTempIds[0]; // Return the teamId for the solo player
    }

    // Check if the team has players with the same teamId
    if (teamSize > 1)
    {
        bubbleSort(teamTempIds);
        majorityTag = findMajority(teamTempIds);

        if (countOccurrences(teamTempIds, majorityTag) >= teamSize / 2)
        {
            teamIdCheck = 1;
        }
    }

    // Return the majority teamId for the specified team or 0 if no majority teamId found
    if (teamIdCheck == 1)
	{
		return majorityTag;
	}
	else
	{
		return 0;
	}
}

findTeamId( team )
{
    teamIdCheck = 0;
    teamTempIds = [];
    teamSize = 0;
	majorityTeamId = -1;

    for (i = 0; i < level.players.size; i++)
    {
        // Check if the player has a valid teamId
        if (isDefined(level.players[i].pers["teamId"]) && level.players[i].pers["team"] == team)
        {
            teamTempIds[teamSize] = level.players[i].pers["teamId"];
            teamSize++;
        }
    }

	// Handle 1v1 scenario
    if (teamSize == 1)
    {
        setTeamId( teamTempIds[0], team ); // Return the teamId for the solo player
    }

    // Check if the team has players with the same teamId
    if (teamSize > 1)
    {
        bubbleSort(teamTempIds);
        majorityTeamId = findMajority(teamTempIds);

        if (countOccurrences(teamTempIds, majorityTeamId) >= teamSize / 2)
        {
            teamIdCheck = 1;
        }
    }

    // Return the majority teamId for the specified team or 0 if no majority teamId found
    if (teamIdCheck == 1)
	{
		setTeamId( majorityTeamId, team );
	}
	else
	{
		return 0;
	}
}


// findTeamTag( team )
// {
//     for (i = 0; i < level.players.size; i++)
//         if (isDefined(level.players[i].pers["teamId"]) && level.players[i].pers["team"] == team)
//             return level.players[i].pers["teamTag"];
// }

// findTeamName( team )
// {
//     for (i = 0; i < level.players.size; i++)
//         if (isDefined(level.players[i].pers["teamId"]) && level.players[i].pers["team"] == team)
//             return level.players[i].pers["teamName"];
// }

setTeamId( id, team )
{
	game[team+"TeamId"] = id;
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
    //jsonreleaseobject( handle );
}

mapFinished( attack_score, defence_score, winner_team_id )
{

}

sendPublicStatsData()
{

}


sendStatsData()
{

}


selfDataCallback( handle )
{
	//jsonreleaseobject( handle );
}

getPersStat( dataName )
{
	return self.pers[dataName];
}