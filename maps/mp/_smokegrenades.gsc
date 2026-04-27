main()
{
	ensureSmokeGlobals();
}

ensureSmokeGlobals()
{
	if ( !isDefined( level.promod_smokes ) )
		level.promod_smokes = [];

	if ( !isDefined( level.promod_smokeIdCounter ) )
		level.promod_smokeIdCounter = 0;

	if ( !isDefined( level.promod_smokeRadius ) )
		level.promod_smokeRadius = 255;

	if ( !isDefined( level.promod_smokeDuration ) )
		level.promod_smokeDuration = 11.5;

	if ( !isDefined( level.promod_smokeFuseTime ) )
		level.promod_smokeFuseTime = 1.0;
}

monitorSmokeGrenades()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "grenade_fire", grenade, weaponName );
		onGrenadeFire( self, grenade, weaponName );
	}
}

onGrenadeFire( thrower, grenade, weaponName )
{
	if ( getDvarInt( "promod_smoke_debug" ) )
		smokeDebugPrint( "grenade_fire weapon:" + weaponName );

	if ( weaponName != "smoke_grenade_mp" && weaponName != "smoke_grenade" )
		return;

	addSmokeGrenade( grenade, thrower, weaponName );
}

addSmokeGrenade( grenadeEnt, thrower, weaponName )
{
	ensureSmokeGlobals();

	if ( isDefined( grenadeEnt ) && isDefined( grenadeEnt.promod_smokeTracked ) && grenadeEnt.promod_smokeTracked )
		return;

	if ( isDefined( grenadeEnt ) )
		grenadeEnt.promod_smokeTracked = true;

	smoke = spawnStruct();
	smoke.id = level.promod_smokeIdCounter;
	level.promod_smokeIdCounter++;

	smoke.weaponName = weaponName;
	smoke.thrower = thrower;
	smoke.grenade = grenadeEnt;
	smoke.state = "moving";
	smoke.stateStartTime = getTime();
	smoke.throwTime = getTime();

	if ( isDefined( grenadeEnt ) )
		smoke.origin = grenadeEnt.origin;
	else
		smoke.origin = thrower.origin;

	smoke.throwOrigin = smoke.origin;
	smoke.landOrigin = undefined;

	level.promod_smokes[level.promod_smokes.size] = smoke;
	logSmokeEvent( "throw", smoke );
	smoke thread thinkSmoke();
}

thinkSmoke()
{
	smokeStartAt = self.throwTime + int( level.promod_smokeFuseTime * 1000 );

	while ( getTime() < smokeStartAt )
	{
		if ( isDefined( self.grenade ) )
			self.origin = self.grenade.origin;
		self.state = "moving";
		wait 0.05;
	}

	self.state = "smoking";
	self.stateStartTime = getTime();
	self.smokeStartTime = self.stateStartTime;
	if ( isDefined( self.grenade ) )
		self.origin = self.grenade.origin;
	self.landOrigin = self.origin;
	logSmokeEvent( "land", self );

	smokeEndAt = self.smokeStartTime + int( level.promod_smokeDuration * 1000 );
	while ( getTime() < smokeEndAt )
	{
		if ( isDefined( self.grenade ) )
			self.origin = self.grenade.origin;
		wait 0.05;
	}

	self.state = "expired";
	self.stateStartTime = getTime();
	self.smokeEndTime = self.stateStartTime;
	logSmokeEvent( "expire", self );

	removeSmokeById( self.id );
}

removeSmokeById( smokeId )
{
	ensureSmokeGlobals();

	for ( i = 0; i < level.promod_smokes.size; i++ )
	{
		smoke = level.promod_smokes[i];
		if ( !isDefined( smoke ) )
			continue;

		if ( smoke.id == smokeId )
		{
			level.promod_smokes[i] = undefined;
			break;
		}
	}

	compactSmokeList();
}

compactSmokeList()
{
	ensureSmokeGlobals();

	compacted = [];

	for ( i = 0; i < level.promod_smokes.size; i++ )
	{
		smoke = level.promod_smokes[i];
		if ( !isDefined( smoke ) )
			continue;

		compacted[compacted.size] = smoke;
	}

	level.promod_smokes = compacted;
}

getSmokes()
{
	ensureSmokeGlobals();
	return level.promod_smokes;
}

getSmokeCount()
{
	ensureSmokeGlobals();
	return level.promod_smokes.size;
}

getSmokingCount()
{
	ensureSmokeGlobals();

	count = 0;
	for ( i = 0; i < level.promod_smokes.size; i++ )
	{
		smoke = level.promod_smokes[i];
		if ( !isDefined( smoke ) )
			continue;

		if ( smoke.state == "smoking" )
			count++;
	}

	return count;
}

getSmokeStateAtPoint( point, radius )
{
	ensureSmokeGlobals();

	if ( !isDefined( radius ) )
		radius = level.promod_smokeRadius;

	radiusSq = radius * radius;
	state = "none";

	for ( i = 0; i < level.promod_smokes.size; i++ )
	{
		smoke = level.promod_smokes[i];
		if ( !isDefined( smoke ) )
			continue;

		if ( !isDefined( smoke.origin ) )
			continue;

		if ( distanceSquared( point, smoke.origin ) > radiusSq )
			continue;

		if ( smoke.state == "smoking" )
			return "smoking";

		if ( smoke.state == "moving" )
			state = "moving";
	}

	return state;
}

isPointInSmoke( point, radius )
{
	return getSmokeStateAtPoint( point, radius ) == "smoking";
}

isPlayerInSmoke( radius )
{
	if ( !isDefined( self ) || !isDefined( self.origin ) )
		return false;

	return isPointInSmoke( self.origin, radius );
}

SmokeTrace( start, end, radius )
{
	ensureSmokeGlobals();

	if ( !isDefined( radius ) )
		radius = level.promod_smokeRadius;

	for ( i = 0; i < level.promod_smokes.size; i++ )
	{
		smoke = level.promod_smokes[i];
		if ( !isDefined( smoke ) )
			continue;

		if ( smoke.state != "smoking" )
			continue;

		if ( !isDefined( smoke.origin ) )
			continue;

		if ( !raySphereIntersect( start, end, smoke.origin, radius ) )
			continue;

		return false;
	}

	return true;
}

getTraceSmokeStats( start, end, radius )
{
	ensureSmokeGlobals();

	if ( !isDefined( radius ) )
		radius = level.promod_smokeRadius;

	stats = spawnStruct();
	stats.blocked = false;
	stats.hitCount = 0;
	stats.coverageUnits = 0;
	stats.segmentUnits = distance( start, end );
	stats.coverageRatioPermille = 0;

	for ( i = 0; i < level.promod_smokes.size; i++ )
	{
		smoke = level.promod_smokes[i];
		if ( !isDefined( smoke ) )
			continue;

		if ( smoke.state != "smoking" )
			continue;

		if ( !isDefined( smoke.origin ) )
			continue;

		chord = getSegmentSphereCoverage( start, end, smoke.origin, radius );
		if ( chord <= 0 )
			continue;

		stats.blocked = true;
		stats.hitCount++;
		stats.coverageUnits += chord;
	}

	if ( stats.segmentUnits > 0 )
		stats.coverageRatioPermille = int( ( stats.coverageUnits / stats.segmentUnits ) * 1000 + 0.5 );

	return stats;
}

getSegmentSphereCoverage( start, end, sphereOrigin, radius )
{
	dp = end - start;
	a = dp[0] * dp[0] + dp[1] * dp[1] + dp[2] * dp[2];
	if ( a <= 0 )
		return 0;

	b = 2 * ( dp[0] * ( start[0] - sphereOrigin[0] ) + dp[1] * ( start[1] - sphereOrigin[1] ) + dp[2] * ( start[2] - sphereOrigin[2] ) );
	c = sphereOrigin[0] * sphereOrigin[0] + sphereOrigin[1] * sphereOrigin[1] + sphereOrigin[2] * sphereOrigin[2];
	c += start[0] * start[0] + start[1] * start[1] + start[2] * start[2];
	c -= 2 * ( sphereOrigin[0] * start[0] + sphereOrigin[1] * start[1] + sphereOrigin[2] * start[2] );
	c -= radius * radius;

	bb4ac = b * b - 4 * a * c;
	if ( bb4ac < 0 )
		return 0;

	sqrtDisc = sqrt( bb4ac );
	t0 = ( 0 - b - sqrtDisc ) / ( 2 * a );
	t1 = ( 0 - b + sqrtDisc ) / ( 2 * a );

	if ( t0 > t1 )
	{
		tmp = t0;
		t0 = t1;
		t1 = tmp;
	}

	segStart = max( t0, 0 );
	segEnd = min( t1, 1 );
	if ( segEnd <= segStart )
		return 0;

	return ( segEnd - segStart ) * distance( start, end );
}

raySphereIntersect( start, end, sphereOrigin, radius )
{
	dp = end - start;
	a = dp[0] * dp[0] + dp[1] * dp[1] + dp[2] * dp[2];
	b = 2 * ( dp[0] * ( start[0] - sphereOrigin[0] ) + dp[1] * ( start[1] - sphereOrigin[1] ) + dp[2] * ( start[2] - sphereOrigin[2] ) );
	c = sphereOrigin[0] * sphereOrigin[0] + sphereOrigin[1] * sphereOrigin[1] + sphereOrigin[2] * sphereOrigin[2];
	c += start[0] * start[0] + start[1] * start[1] + start[2] * start[2];
	c -= 2 * ( sphereOrigin[0] * start[0] + sphereOrigin[1] * start[1] + sphereOrigin[2] * start[2] );
	c -= radius * radius;

	bb4ac = b * b - 4 * a * c;
	if ( bb4ac < 0 )
		return false;

	mu1 = ( 0 - b + sqrt( bb4ac ) ) / ( 2 * a );
	ip1 = start + mu1 * dp;

	myDist = distanceSquared( start, end );
	if ( distanceSquared( start, ip1 ) > myDist )
		return false;

	dpAngles = vectorToAngles( dp );
	if ( getConeDot( ip1, start, dpAngles ) < 0 )
		return false;

	return true;
}

getConeDot( to, from, dir )
{
	dirToTarget = vectorNormalize( to - from );
	forward = anglesToForward( dir );
	return vectorDot( dirToTarget, forward );
}

logSmokeEvent( eventType, smoke )
{
	if ( !isDefined( smoke ) )
		return;

	throwerGuid = "";
	throwerName = "";
	if ( isDefined( smoke.thrower ) && isPlayer( smoke.thrower ) )
	{
		throwerGuid = smoke.thrower getGuid();
		throwerName = smoke.thrower.name;
	}

	throwOrigin = "";
	if ( isDefined( smoke.throwOrigin ) )
		throwOrigin = smoke.throwOrigin;

	landOrigin = "";
	if ( isDefined( smoke.landOrigin ) )
		landOrigin = smoke.landOrigin;

	logPrint( "P_SMOKE;" + eventType + ";" + smoke.id + ";" + smoke.state + ";" + smoke.throwTime + ";" + smoke.stateStartTime + ";" + throwerGuid + ";" + throwerName + ";" + throwOrigin + ";" + landOrigin + ";" + smoke.origin + "\n" );
	smokeDebugPrint( "smoke " + eventType + " id:" + smoke.id + " by:" + throwerName + " state:" + smoke.state );

	if ( isDefined( smoke.thrower ) && isPlayer( smoke.thrower ) )
		thread promod\stats::smokeReport( smoke.thrower, eventType, smoke );
}

smokeDebugPrint( msg )
{
	if ( !getDvarInt( "promod_stats_debug" ) && !getDvarInt( "promod_smoke_debug" ) )
		return;

	if ( !isDefined( level.players ) )
		return;

	for ( i = 0; i < level.players.size; i++ )
	{
		p = level.players[i];
		if ( isDefined( p ) && isPlayer( p ) )
			p iprintln( "^2[smoke]^7 " + msg );
	}
}
