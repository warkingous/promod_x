/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

init()
{
	filename = "promod/destructible.csv";
	level.destructible_effects = [];
	for(i=0;i<8;i++)
		level.destructible_effects[tablelookup(filename, 0, i, 1)] = LoadFX(tablelookup(filename, 0, i, 2));

	level.destructible_breakable_objects = [];
	for(i=8;i<22;i++)
		level.destructible_breakable_objects[tablelookup(filename, 0, i, 1)] = 1;

	entities = getentarray("destructible", "targetname");
	for(i=0;i<entities.size;i++)
		entities[i] thread dmg();
}

veh_hud(msg, attacker)
{
    // if (isdefined(attacker) && isPlayer(attacker))
    // {
    //     attacker iprintln("^3[VEH]^7 " + msg);
    //     return;
    // }

    // Fallback: broadcast to everyone
    // players = getentarray("player", "classname");
    // pcount = int(players.size);
    // for (i = 0; i < pcount; i++)
    //     players[i] iprintln("^3[VEH]^7 " + msg);
}

// Returns a world-space position by offsetting vehicle origin along its local
// forward/right/up axes. Useful to synthesize undercarriage/low points.
__ax(offF, offR, offU)
{
    f = anglestoforward(self.angles);
    r = anglestoright(self.angles);
    u = anglestoup(self.angles);
    return self.origin + f*offF + r*offR + u*offU;
}

// Gathers points to aim the LOS rays at:
//  - entity center
//  - synthetic low/undercarriage points (help with curbs/ledges)
//  - all model parts (names cached on the entity in __losAllParts), with stride+cap
// ---- gathers LOS target points (center + undercarriage + filtered parts)
__collectLosTargets()
{
    pts = [];

    // center
    pts[pts.size] = self.origin;

    // synthetic undercarriage points (helps with curbs)
    base = -20;
    pts[pts.size] = __ax(  50,   0, base);
    pts[pts.size] = __ax( -50,   0, base);
    pts[pts.size] = __ax(   0,  30, base);
    pts[pts.size] = __ax(   0, -30, base);
    pts[pts.size] = __ax(  50,  30, base);
    pts[pts.size] = __ax(  50, -30, base);
    pts[pts.size] = __ax( -50,  30, base);
    pts[pts.size] = __ax( -50, -30, base);

    // cap & stride (no ceil/ternary)
    maxPts = 96;
    count = 0;
    if (isdefined(self.__losAllParts))
        count = int(self.__losAllParts.size);

    stride = 1;
    if (count > maxPts)
    {
        q = int(count / maxPts);
        r = count - q * maxPts;
        if (r > 0) q += 1;
        stride = q; // ~= ceil(count/maxPts)
    }

    // horizontal radius cap to ignore mirrors/bumper corners
    keepXY2 = 44 * 44; // 2D squared

    used = 0;
    for (i = 0; i < count && used < maxPts; i += stride)
    {
        name = self.__losAllParts[i];
        if (!isdefined(name))
            continue;

        pt = self gettagorigin(name);

        dx = pt[0] - self.origin[0];
        dy = pt[1] - self.origin[1];
        dist2 = dx*dx + dy*dy;

        if (dist2 <= keepXY2)
        {
            pts[pts.size] = pt;
            used++;
        }
    }

    return pts;
}



// ---- world-only line trace: WORLD blocks; car/props ignored
__losTraceWorldOnly(s, t)
{
    maxSkips = 12;
    eps = 2;

    for (k = 0; k < maxSkips; k++)
    {
        hit = bulletTrace(s, t, 1, self); // includeDetail=1, ignore=self

        if (hit["fraction"] >= 1)
            return true; // clear (no hit)

        if (!isdefined(hit["entity"]))
            return false; // WORLD brush blocks

        ent = hit["entity"];

        // Safe classname fetch (GSC has no ternary operator).
        entClass = "";
        if (isdefined(ent.classname))
            entClass = ent.classname;

        // Explicit worldspawn should block too (engine may return it instead of undefined).
        if (entClass == "worldspawn")
            return false;

        // Only whitelist we skip:
        //  - this vehicle (self)
        //  - players
        //  - dropped weapons / active grenades
        //  - other destructible vehicles (have .destructible_type)
        if ( ent == self
          || isPlayer(ent)
          || entClass == "weapon"
          || entClass == "grenade"
          || isdefined(ent.destructible_type) )
        {
            dir = vectornormalize(t - s);
            if (distance((0,0,0), dir) == 0) dir = (0,0,1);
            s = hit["position"] + dir * eps; // Move start behind the obstacle and continue.
            continue;
        }

        // Everything else (incl. script_model/misc_model/script_vehicle/door, etc.) blocks.
        return false;
    }

    return false; // safety
}



__horizDist2D(a, b)
{
    dx = a[0] - b[0];
    dy = a[1] - b[1];
    return sqrt(dx*dx + dy*dy);
}

// Performs a strict line-of-sight test from the explosion point to the vehicle,
// with DETAIL brushes enabled so walls actually block.
__isVisibleFromExplosion(start, attacker)
{
    pts = __collectLosTargets();

    // tight seed cloud (no tall lifts, minimal XY jitter)
    seeds = [];
    seeds[seeds.size] = start + (0, 0, 0);
    seeds[seeds.size] = start + (0, 0, 2);
    seeds[seeds.size] = start + (0, 0, 4);
    seeds[seeds.size] = start + ( 3,  0, 2);
    seeds[seeds.size] = start + (-3,  0, 2);
    seeds[seeds.size] = start + ( 0,  3, 2);
    seeds[seeds.size] = start + ( 0, -3, 2);
    seeds[seeds.size] = start + ( 2,  2, 2);
    seeds[seeds.size] = start + (-2,  2, 2);
    seeds[seeds.size] = start + ( 2, -2, 2);
    seeds[seeds.size] = start + (-2, -2, 2);

    for (si = 0; si < seeds.size; si++)
    {
        s = seeds[si];

        // seed-guard: seed must be in same "room" as start
        if (!__losTraceWorldOnly(start, s))
            continue;

        for (i = 0; i < pts.size; i++)
        {
            t = pts[i];

            if (__losTraceWorldOnly(s, t))
                return true;

            // tiny epsilon trim (won't bypass wall due to guard)
            dir = vectornormalize(t - s);
            if (distance((0,0,0), dir) == 0) dir = (0,0,1);
            s2 = s + dir * 2;
            t2 = t - dir * 2;

            if (__losTraceWorldOnly(s2, t2))
                return true;
        }
    }

    return false;
}

dmg()
{
    self endon("explosion");

    dt = self.destructible_type;
    precachemodel(dt+"_destroyed");
    precachemodel(dt+"_mirror_R");
    precachemodel(dt+"_mirror_L");

    mdl = self.model;
    np = int(getnumparts(mdl));
    while (np)
    {
        np--;
        pn = getpartname(mdl, int(np));
        if (isdefined(pn) && getsubstr(pn, pn.size-2) == "_d")
            self hidepart(pn);
    }

    self setcandamage(1);
    self.damageTaken = 0;
    self.damageOwner = undefined;
    smk = true;
    brn = true;

    self thread explosion();

    // cache all part names once
    self.__losAllParts = [];
    n = int(getnumparts(mdl));
    for (i = 0; i < n; i++)
    {
        part = getpartname(mdl, int(i));
        if (isdefined(part))
            self.__losAllParts[self.__losAllParts.size] = part;
    }

    self.__isVisibleFromExplosion = ::__isVisibleFromExplosion;
    self.__collectLosTargets      = ::__collectLosTargets;
    self.__ax                     = ::__ax;

    for (;;)
    {
        self waittill("damage", damage, attacker, direction_vec, point, type, modelname, tagname, partname);

        if (isdefined(damage) && isdefined(partname)
            && partname != "left_wheel_01_jnt" && partname != "right_wheel_01_jnt"
            && partname != "left_wheel_02_jnt" && partname != "right_wheel_02_jnt")
        {
            if (isdefined(level.destructible_breakable_objects[partname]))
            {
                self breakpart(partname);
            }
            else if (type != "MOD_MELEE" && type != "MOD_IMPACT")
            {
                if (type == "MOD_GRENADE" || type == "MOD_GRENADE_SPLASH"
                 || type == "MOD_PROJECTILE" || type == "MOD_PROJECTILE_SPLASH"
                 || type == "MOD_EXPLOSIVE")
                {
                    start = point; // seeds already add small Z

                    if (!self __isVisibleFromExplosion(start, attacker))
                        continue;

                    numparts = int(getnumparts(mdl));
                    closest = undefined;
                    distCenter = distance(point, self.origin);

                    for (i = 0; i < numparts; i++)
                    {
                        part = getpartname(mdl, int(i));
                        dist = distance(point, self gettagorigin(part));

                        if (dist <= 256 && isdefined(level.destructible_breakable_objects[part]))
                            self breakpart(part);

                        if (!isdefined(closest) || dist < closest)
                            closest = dist;

                        if ((isSubStr(part, "tag_hood") || isSubStr(part, "tag_trunk")
                          || isSubStr(part, "tag_door_") || isSubStr(part, "tag_bumper_"))
                          && dist < distCenter)
                        {
                            distCenter = dist;
                        }
                    }

                    if (!isdefined(closest))
                        closest = distCenter;

                    old = damage;
                    damage = int(11 * damage - 5.6 * distCenter + 4 * closest);
                }

                if (damage > 0)
                {
                    self.damageOwner = attacker;
                    self.damageTaken += damage;
                }
            }
        }

        if (self.damageTaken > 250 && smk)
        {
            smk = false;
            self thread smoke();
        }
        if (self.damageTaken > 550 && brn)
        {
            brn = false;
            self thread burn();
        }
    }
}

breakpart(partname)
{
	switch(partname)
	{
		case "tag_glass_left_front":
		case "tag_glass_right_front":
		case "tag_glass_left_back":
		case "tag_glass_right_back":
		case "tag_glass_front":
		case "tag_glass_back":
		case "tag_glass_left_back2":
		case "tag_glass_right_back2":
			self playsound("veh_glass_break_large");
			fx = "medium";
			if(strtok(partname, "_").size == 3)
				fx = "large";
			playfxontag(level.destructible_effects["car_glass_"+fx], self, partname+"_fx");
			self hidepart(partname);
			break;
		case "tag_light_left_front":
		case "tag_light_right_front":
		case "tag_light_left_back":
		case "tag_light_right_back":
			self playsound("veh_glass_break_small");
			playfxontag(level.destructible_effects["light_"+strtok(partname, "_")[3]], self, partname);
			self hidepart(partname);
			self showpart(partname+"_d");
			break;
		case "tag_mirror_left":
		case "tag_mirror_right":
			self hidepart(partname);
			physicsobject = spawn("script_model", self gettagorigin(partname));
			physicsobject.angles = self gettagangles(partname);
			s = "R";
			if(getsubstr(partname, 11, 12) == "l") s = "L";
			physicsobject setmodel(self.destructible_type+"_mirror_"+s);
			physicsobject physicslaunch(self gettagorigin(partname), vectornormalize(self gettagorigin(partname)) * 200);
			physicsobject thread deleteovertime();
			break;
	}
}

deleteovertime()
{
	wait 5;
	self delete();
}

smoke()
{
	self endon("explosion");

	for(fx="white_smoke";;)
	{
		if(self.damageTaken > 550)
			fx = "black_smoke_fire";
		else if(self.damageTaken > 450)
			fx = "black_smoke";

		playfxontag(level.destructible_effects[fx], self, "tag_hood_fx");
		wait 0.4;
	}
}

burn()
{
	self endon("explosion");

	self playsound("fire_vehicle_flareup_med");
	self playloopsound("fire_vehicle_med");

	for(;self.damageTaken < 1250;wait 0.2)
		self.damageTaken += 12;
}

explosion()
{
	while(self.damageTaken < 1250)
		wait 0.05;

	self stoploopsound("fire_vehicle_med");

	self notify("explosion");

	self playsound("car_explode");
	playfxontag(level.destructible_effects["small_vehicle_explosion"], self, "tag_death_fx");
	origin = self.origin+(0, 0, 80);
	rng = 250;
	if(getsubstr(self.destructible_type, 0, 19) == "vehicle_80s_sedan1_")
		rng = 375;
	if(isdefined(self.damageOwner))
		self radiusdamage(origin, rng, 300, 20, self.damageOwner);
	else
		self radiusdamage(origin, rng, 300, 20);

	self movez(16, 0.3, 0, 0.2);
	self rotatepitch(10, 0.3, 0, 0.2);
	self setmodel(self.destructible_type+"_destroyed");
	wait 0.3;
	self movez(-16, 0.3, 0.15, 0);
	self rotatepitch(-10, 0.3, 0.15, 0);
}