main()
{
	ensureFragGlobals();
}

ensureFragGlobals()
{
	if ( !isDefined( level.promod_frags ) )
		level.promod_frags = [];

	if ( !isDefined( level.promod_fragIdCounter ) )
		level.promod_fragIdCounter = 0;

	if ( !isDefined( level.promod_fragFuseTime ) )
		level.promod_fragFuseTime = 3.0;
}

monitorFragGrenades()
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
	if ( weaponName != "frag_grenade_mp" && weaponName != "frag_grenade_short_mp" )
		return;

	addFragGrenade( grenade, thrower, weaponName );
}

addFragGrenade( grenadeEnt, thrower, weaponName )
{
	ensureFragGlobals();

	if ( isDefined( grenadeEnt ) && isDefined( grenadeEnt.promod_fragTracked ) && grenadeEnt.promod_fragTracked )
		return;

	if ( isDefined( grenadeEnt ) )
		grenadeEnt.promod_fragTracked = true;

	frag = spawnStruct();
	frag.id = level.promod_fragIdCounter;
	level.promod_fragIdCounter++;

	frag.weaponName = weaponName;
	frag.thrower = thrower;
	frag.grenade = grenadeEnt;
	frag.state = "moving";
	frag.stateStartTime = getTime();
	frag.throwTime = getTime();

	if ( isDefined( grenadeEnt ) )
		frag.origin = grenadeEnt.origin;
	else
		frag.origin = thrower.origin;

	frag.throwOrigin = frag.origin;
	frag.explodeOrigin = undefined;

	level.promod_frags[level.promod_frags.size] = frag;
	logFragEvent( "throw", frag );
	frag thread thinkFrag();
}

thinkFrag()
{
	explodeAt = self.throwTime + int( level.promod_fragFuseTime * 1000 );

	while ( getTime() < explodeAt )
	{
		if ( isDefined( self.grenade ) )
			self.origin = self.grenade.origin;

		self.state = "moving";
		wait 0.05;
	}

	self.state = "exploded";
	self.stateStartTime = getTime();
	self.explodeTime = self.stateStartTime;
	if ( isDefined( self.grenade ) )
		self.origin = self.grenade.origin;
	self.explodeOrigin = self.origin;
	logFragEvent( "explode", self );

	removeFragById( self.id );
}

removeFragById( fragId )
{
	ensureFragGlobals();

	for ( i = 0; i < level.promod_frags.size; i++ )
	{
		frag = level.promod_frags[i];
		if ( !isDefined( frag ) )
			continue;

		if ( frag.id == fragId )
		{
			level.promod_frags[i] = undefined;
			break;
		}
	}

	compactFragList();
}

compactFragList()
{
	ensureFragGlobals();

	compacted = [];
	for ( i = 0; i < level.promod_frags.size; i++ )
	{
		frag = level.promod_frags[i];
		if ( !isDefined( frag ) )
			continue;

		compacted[compacted.size] = frag;
	}

	level.promod_frags = compacted;
}

logFragEvent( eventType, frag )
{
	if ( !isDefined( frag ) )
		return;

	throwerGuid = "";
	throwerName = "";
	if ( isDefined( frag.thrower ) && isPlayer( frag.thrower ) )
	{
		throwerGuid = frag.thrower getGuid();
		throwerName = frag.thrower.name;
	}

	throwOrigin = "";
	if ( isDefined( frag.throwOrigin ) )
		throwOrigin = frag.throwOrigin;

	explodeOrigin = "";
	if ( isDefined( frag.explodeOrigin ) )
		explodeOrigin = frag.explodeOrigin;

	logPrint( "P_FRAG;" + eventType + ";" + frag.id + ";" + frag.state + ";" + frag.throwTime + ";" + frag.stateStartTime + ";" + throwerGuid + ";" + throwerName + ";" + throwOrigin + ";" + explodeOrigin + ";" + frag.origin + "\n" );

	if ( isDefined( frag.thrower ) && isPlayer( frag.thrower ) )
		thread promod\stats::fragReport( frag.thrower, eventType, frag );
}
