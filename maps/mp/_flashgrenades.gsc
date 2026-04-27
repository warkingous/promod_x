/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

main()
{
	precacheShellshock("flashbang");
	ensureFlashGlobals();
}

ensureFlashGlobals()
{
	if ( !isDefined( level.promod_flashes ) )
		level.promod_flashes = [];

	if ( !isDefined( level.promod_flashIdCounter ) )
		level.promod_flashIdCounter = 0;

	if ( !isDefined( level.promod_flashFuseTime ) )
		level.promod_flashFuseTime = 1.5;
}

monitorFlashGrenades()
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
	if ( weaponName != "flash_grenade_mp" && weaponName != "flash_grenade" )
		return;

	addFlashGrenade( grenade, thrower, weaponName );
}

addFlashGrenade( grenadeEnt, thrower, weaponName )
{
	ensureFlashGlobals();

	if ( isDefined( grenadeEnt ) && isDefined( grenadeEnt.promod_flashTracked ) && grenadeEnt.promod_flashTracked )
		return;

	if ( isDefined( grenadeEnt ) )
		grenadeEnt.promod_flashTracked = true;

	flash = spawnStruct();
	flash.id = level.promod_flashIdCounter;
	level.promod_flashIdCounter++;

	flash.weaponName = weaponName;
	flash.thrower = thrower;
	flash.grenade = grenadeEnt;
	flash.state = "moving";
	flash.stateStartTime = getTime();
	flash.throwTime = getTime();

	if ( isDefined( grenadeEnt ) )
		flash.origin = grenadeEnt.origin;
	else
		flash.origin = thrower.origin;

	flash.throwOrigin = flash.origin;
	flash.explodeOrigin = undefined;

	level.promod_flashes[level.promod_flashes.size] = flash;
	logFlashGrenadeEvent( "throw", flash );
	flash thread thinkFlashGrenade();
}

thinkFlashGrenade()
{
	explodeAt = self.throwTime + int( level.promod_flashFuseTime * 1000 );

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
	logFlashGrenadeEvent( "explode", self );

	removeFlashGrenadeById( self.id );
}

removeFlashGrenadeById( flashId )
{
	ensureFlashGlobals();

	for ( i = 0; i < level.promod_flashes.size; i++ )
	{
		flash = level.promod_flashes[i];
		if ( !isDefined( flash ) )
			continue;

		if ( flash.id == flashId )
		{
			level.promod_flashes[i] = undefined;
			break;
		}
	}

	compactFlashGrenadeList();
}

compactFlashGrenadeList()
{
	ensureFlashGlobals();

	compacted = [];
	for ( i = 0; i < level.promod_flashes.size; i++ )
	{
		flash = level.promod_flashes[i];
		if ( !isDefined( flash ) )
			continue;

		compacted[compacted.size] = flash;
	}

	level.promod_flashes = compacted;
}

logFlashGrenadeEvent( eventType, flash )
{
	if ( !isDefined( flash ) )
		return;

	throwerGuid = "";
	throwerName = "";
	if ( isDefined( flash.thrower ) && isPlayer( flash.thrower ) )
	{
		throwerGuid = flash.thrower getGuid();
		throwerName = flash.thrower.name;
	}

	throwOrigin = "";
	if ( isDefined( flash.throwOrigin ) )
		throwOrigin = flash.throwOrigin;

	explodeOrigin = "";
	if ( isDefined( flash.explodeOrigin ) )
		explodeOrigin = flash.explodeOrigin;

	logPrint( "P_FLASH;" + eventType + ";" + flash.id + ";" + flash.state + ";" + flash.throwTime + ";" + flash.stateStartTime + ";" + throwerGuid + ";" + throwerName + ";" + throwOrigin + ";" + explodeOrigin + ";" + flash.origin + "\n" );

	if ( isDefined( flash.thrower ) && isPlayer( flash.thrower ) )
		thread promod\stats::flashGrenadeReport( flash.thrower, eventType, flash );
}

startMonitoringFlash()
{
	self thread monitorFlash();
}

stopMonitoringFlash(disconnected)
{
	self notify("stop_monitoring_flash");
}

flashRumbleLoop( duration )
{
	self endon("stop_monitoring_flash");

	self endon("flash_rumble_loop");
	self notify("flash_rumble_loop");

	goalTime = getTime() + duration * 1000;

	while ( getTime() < goalTime )
	{
		self PlayRumbleOnEntity( "damage_heavy" );
		wait 0.05;
	}
}

monitorFlash()
{
	self endon("disconnect");

	self.flashEndTime = 0;
	for(;;)
	{
		self waittill( "flashbang", amount_distance, amount_angle, attacker );
		self._promod_flashAngleRaw = amount_angle;

		if ( !isalive( self ) || ( isDefined( level.rdyup ) && level.rdyup && ( !isDefined( self.ruptally ) || self.ruptally < 0 ) ) || isDefined( game["PROMOD_MATCH_MODE"] ) && game["PROMOD_MATCH_MODE"] == "strat" && isDefined( self.flying ) && self.flying || isDefined( game["PROMOD_KNIFEROUND"] ) && game["PROMOD_KNIFEROUND"] )
			continue;

		hurtattacker = false;
		hurtvictim = true;

		if ( amount_angle < 0.35 )
			amount_angle = 0.35;
		else if ( amount_angle > 0.8 )
			amount_angle = 1;

		duration = amount_distance * amount_angle * 6;

		if ( duration < 0.25 )
			continue;

		rumbleduration = undefined;
		if ( duration > 2 )
			rumbleduration = 0.75;
		else
			rumbleduration = 0.25;

		if (level.teamBased && isdefined(attacker) && isdefined(attacker.pers["team"]) && isdefined(self.pers["team"]) && attacker.pers["team"] == self.pers["team"] && attacker != self)
		{
			if(!level.friendlyfire)
				continue;
			else if(level.friendlyfire == 2)
			{
				duration = duration * 0.5;
				rumbleduration = rumbleduration * 0.5;
				hurtvictim = false;
				hurtattacker = true;
			}
			else if(level.friendlyfire == 3)
			{
				duration = duration * 0.5;
				rumbleduration = rumbleduration * 0.5;
				hurtattacker = true;
			}
		}

		if (hurtvictim)
		{
			// Last enemy flashbang (flash assist when teammate gets the kill)
			if ( level.teamBased && isPlayer( attacker ) && isDefined( attacker.pers["team"] ) && isDefined( self.pers["team"] ) && attacker.pers["team"] != self.pers["team"] && attacker != self )
			{
				self.lastEnemyFlashAttacker = attacker;
				self.lastEnemyFlashTime = getTime();
				// Engine breakdown: distance factor, angle (raw + clamped 0.35–1), whiteout duration
				self.lastEnemyFlashAmountDistance = amount_distance;
				self.lastEnemyFlashAmountAngleRaw = self._promod_flashAngleRaw;
				self.lastEnemyFlashAmountAngle = amount_angle;
				self.lastEnemyFlashDuration = duration;
			}
			self thread applyFlash(duration, rumbleduration);
		}
		if (hurtattacker)
			attacker thread applyFlash(duration, rumbleduration);
	}
}

applyFlash(duration, rumbleduration)
{
	if ( !isDefined( self.flashDuration ) || duration > self.flashDuration )
	{
		self notify ("strongerFlash");
		self.flashDuration = duration;
	}
	else if( duration < self.flashDuration )
		return;

	if ( !isDefined( self.flashRumbleDuration ) || rumbleduration > self.flashRumbleDuration )
		self.flashRumbleDuration = rumbleduration;

	wait 0.05;

	if ( isDefined( self.flashDuration ) )
	{
		self shellshock( "flashbang", self.flashDuration);
		self.flashEndTime = getTime() + (self.flashDuration * 1000);
	}

	self thread overlapProtect(duration);

	if ( isDefined( self.flashRumbleDuration ) )
		self thread flashRumbleLoop( self.flashRumbleDuration );

	self.flashRumbleDuration = undefined;
}

overlapProtect(duration)
{
	self endon( "disconnect" );
	self endon ( "strongerFlash" );
	for(;duration > 0;)
	{
		duration -= 0.05;
		self.flashDuration = duration;
		wait 0.05;
	}
}

isFlashbanged()
{
	return isDefined( self.flashEndTime ) && gettime() < self.flashEndTime;
}