
/* 
 * Sentry turret machine gun script
 *
 * Copyright (c) 2019 Rectus
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

FLESHY_ENTS <- 
{
	player = null,
	infected = null,
	witch = null,
	tank = null,
}

SHOT_DISTANCE <- 768
SHOT_DAMAGE <- 20
SHOT_IMPULSE <- 20
SURVIVOR_DAMAGE_MULTIPLIER <- 0.3
WITCH_DAMAGE_MULTIPLIER <- 1.4
TANK_DAMAGE_MULTIPLIER <- 1.5
COMMON_DAMAGE_MULTIPLIER <- 0.7
SI_DAMAGE_MULTIPLIER <- 1.5

SHOT_SPREAD_RADIUS <- 15
PERFECT_SHOT_INTERVAL <- 12
SHOT_SECTOR_SIZE <- 360 / 6
NUM_HIT_EFFECTS <- 8 // Maximum effect entities to spawn per type
AMMO_MAX <- 500
REARM_AMMO_USE_FRAC <- 0.34

// Player max primary ammo per type
ammoTable <- {}
ammoTable[3] <- 360,
ammoTable[5] <- 650,
ammoTable[7] <- 56,
ammoTable[8] <- 90,
ammoTable[9] <- 150,
ammoTable[10] <- 180


shotSeqCount <- 0
hitEffects <- {}
muzzleFlash <- null
brassParticle <- null
tracer <- null
tracerEnd <- null
explosionEnt1 <- null
explosionEnt2 <- null
fireFrame <- 0
infiniteAmmo <- false
ammoLeft <- AMMO_MAX
owningPlayer <- null
owningTurret <- null
weaponController <- null



function Precache(contextEnt)
{
	PrecacheEntityFromTable(TRACER_PARTICLE)
	PrecacheEntityFromTable(PARTICLE_TARGET)
	PrecacheEntityFromTable(MUZZLE_PARTICLE)
	PrecacheEntityFromTable(SHOT_HIT_EFFECT_METAL)
	PrecacheEntityFromTable(SHOT_HIT_EFFECT_BLOOD)
	PrecacheEntityFromTable(EXPLOSION_ENTITY)	
	contextEnt.PrecacheScriptSound("SMG.Fire")
}

function Initialize(player, turret, controller, ammoFrac)
{
	owningPlayer = player
	owningTurret = turret
	weaponController = controller.weakref()
	ammoLeft = AMMO_MAX * ammoFrac
}

function GetAmmoFraction()
{
	return ammoLeft.tofloat() / AMMO_MAX.tofloat() 
}

function Rearm(usingPlayer)
{
	local playerWeapon = GetPrimaryWeapon(usingPlayer)
	if(!playerWeapon) {return 0.0}
	
	local ammoType = NetProps.GetPropInt(playerWeapon, "m_iPrimaryAmmoType")
		
	if(!(ammoType in ammoTable)) {return 0.0}

	local ammoStore = NetProps.GetPropIntArray(usingPlayer, "m_iAmmo", ammoType)
	
	local playerAmmoFrac = ammoStore.tofloat() / ammoTable[ammoType].tofloat()

	
	local ammoLeftFrac = ammoLeft.tofloat() / AMMO_MAX.tofloat() 
	if(playerAmmoFrac  > REARM_AMMO_USE_FRAC * (1.0 - ammoLeftFrac))
	{
		
		ammoLeft = AMMO_MAX
		playerAmmoFrac -= REARM_AMMO_USE_FRAC * (1.0 - ammoLeftFrac)
		
	}
	else
	{
		ammoLeft = ((playerAmmoFrac / REARM_AMMO_USE_FRAC) * AMMO_MAX).tointeger() + ammoLeft
		playerAmmoFrac = 0.0
	}

	NetProps.SetPropIntArray(usingPlayer, "m_iAmmo", (playerAmmoFrac * ammoTable[ammoType]).tointeger(), ammoType)
	
	return ammoLeft.tofloat() / AMMO_MAX.tofloat() 
}


function OnStartFiring()
{
	if(!muzzleFlash || !muzzleFlash.IsValid())
	{
		MUZZLE_PARTICLE.parentname = owningTurret.GetName() + ",muzzle"
		muzzleFlash = g_ModeScript.CreateSingleSimpleEntityFromTable(MUZZLE_PARTICLE)
		muzzleFlash.SetOrigin(Vector(0,0,0))
		muzzleFlash.SetAngles(QAngle(0,0,0))
	}
	
	if(!brassParticle || !brassParticle.IsValid())
	{
		BRASS_PARTICLE.parentname = owningTurret.GetName() + ",brass_eject"
		brassParticle = g_ModeScript.CreateSingleSimpleEntityFromTable(BRASS_PARTICLE)
		brassParticle.SetOrigin(Vector(0,0,0))
		brassParticle.SetAngles(QAngle(0,0,0))
	}
}

function OnEndFiring()
{

}


function FireWeapon(origin, direction)
{
	//DebugDrawLine(origin, origin + direction.Forward() * 32, 255, 0, 0, false, 5)
	local infiniteAmmo = Convars.GetFloat("sv_infinite_ammo") > 0

	if(!infiniteAmmo && ammoLeft-- <= 0)
	{
		ammoLeft = 0
		return false
	}
	
	EmitSoundOn("SMG.Fire", owningTurret) 
	
	
	FirePointBlank(origin, direction)
	TraceShot(origin, direction)
	
	if(muzzleFlash && muzzleFlash.IsValid())
	{
		DoEntFire("!self", "Stop", "", 0, muzzleFlash, muzzleFlash)
		DoEntFire("!self", "Start", "", 0.01, muzzleFlash, muzzleFlash)
	}
	
	if(brassParticle && brassParticle.IsValid())
	{
		brassParticle.SetAngles(RotateOrientation(direction, QAngle(0, 180, 0)))
		DoEntFire("!self", "Stop", "", 0, brassParticle, brassParticle)
		DoEntFire("!self", "Start", "", 0.01, brassParticle, brassParticle)
	}
	
	return true
}


function FirePointBlank(shotOrigin, direction)
{
	
	if(!explosionEnt1 || !explosionEnt1.IsValid())
	{
		explosionEnt1 = g_ModeScript.CreateSingleSimpleEntityFromTable(EXPLOSION_ENTITY)
		weaponController.RegisterTrackedEntity(explosionEnt1, owningTurret)
		NetProps.SetPropEntity(explosionEnt1, "m_hOwnerEntity", owningPlayer)
	}
	
	//DebugDrawCircle(shotOrigin + direction.Forward() * 40, Vector(255, 0, 0), 0, 32, true, 5)
	explosionEnt1.SetOrigin(shotOrigin + direction.Forward() * 40)
	DoEntFire("!self", "Explode", "" 0, owningPlayer, explosionEnt1)
	
}


function GetPrimaryWeapon(player)
{
	local invTable = {};
	GetInvTable(player, invTable);

	if(!("slot0" in invTable))
		return null;
		
	local weapon = invTable.slot0;
	
	if(weapon)
		return weapon;
		
	return null;
}



function GetFriendlyFireFactor()
{
	switch(Convars.GetStr("z_difficulty").tolower())
	{
	case "easy":
		return 0.0 //Convars.GetFloat("survivor_friendly_fire_factor_easy")
		
	case "normal":
		return 0.0 //Convars.GetFloat("survivor_friendly_fire_factor_normal")
		
	case "hard":
		return Convars.GetFloat("survivor_friendly_fire_factor_hard")
		
	case "impossible":
		return Convars.GetFloat("survivor_friendly_fire_factor_expert")
	
	default:
		return 0.0
	}
}


function TraceShot(origin, spreadDir)
{
	local ffFactor = GetFriendlyFireFactor()
	local attacker = owningPlayer

	shotSeqCount = (shotSeqCount + 1) % PERFECT_SHOT_INTERVAL
	
	local entDamage = {}
	
	local shotAng = spreadDir
	
	if(shotSeqCount > 0)
	{
		local ang = RandomFloat(SHOT_SECTOR_SIZE * shotSeqCount, 
			SHOT_SECTOR_SIZE * (shotSeqCount + 1)) + 180 * shotSeqCount
		local radius = SHOT_SPREAD_RADIUS * sqrt(RandomFloat(0, 1))
		shotAng = RotateOrientation(spreadDir, QAngle(radius * sin(ang), radius * cos(ang), 0) )
	}

	local traceParams =
	{
		start = origin
		end = origin + shotAng.Forward() * SHOT_DISTANCE
		ignore = owningTurret
	}
	if(TraceLine(traceParams) && traceParams.hit)
	{
	
		local hitAng = RotateOrientation(shotAng, QAngle(0, 180, RandomInt(0, 360)))
	
		if(g_WeaponController.weaponDebug) {DebugDrawLine(traceParams.start, traceParams.pos, 255, 0, 0, false, 5)}
		
		if(("enthit" in traceParams) && traceParams.enthit && traceParams.enthit.GetEntityIndex() > 0)
		{
			local entClass = traceParams.enthit.GetClassname()	
				
			if(entClass in FLESHY_ENTS)
			{
				SpawnEffect(SHOT_HIT_EFFECT_BLOOD, traceParams.pos, hitAng)
			}
			else {SpawnEffect(SHOT_HIT_EFFECT_METAL, traceParams.pos, hitAng)}			
		
			local damage = SHOT_DAMAGE
		
			if(entClass == "player")
			{
				if(traceParams.enthit.IsSurvivor())
				{
					if(traceParams.enthit.IsIncapacitated() || IsPlayerABot(traceParams.enthit))
						{damage = 0}
					else
						{damage = SHOT_DAMAGE * ffFactor * SURVIVOR_DAMAGE_MULTIPLIER}
					attacker = null
				}
				else if(traceParams.enthit.GetZombieType() == 8) // Tank
				{
					damage = SHOT_DAMAGE * TANK_DAMAGE_MULTIPLIER
				}
				else // Other SI
				{
					damage = SHOT_DAMAGE * SI_DAMAGE_MULTIPLIER
				}
			}
			else if(entClass == "witch")
			{
				damage = SHOT_DAMAGE * WITCH_DAMAGE_MULTIPLIER
			}
			else if(entClass == "infected")
			{
				damage = SHOT_DAMAGE * COMMON_DAMAGE_MULTIPLIER
			}
			else
			{
				if(entClass.find("prop_door") == null)
				{
					traceParams.enthit.ApplyAbsVelocityImpulse(shotAng.Forward() * SHOT_IMPULSE)
				}
			}
			
			traceParams.enthit.TakeDamage(damage.tointeger(), DirectorScript.DMG_BULLET, attacker)
			
		}
		else  // Hit world
		{
			SpawnEffect(SHOT_HIT_EFFECT_METAL, traceParams.pos, hitAng)
		}
	}
	
	SpawnEffect(TRACER_PARTICLE, origin, null, 0.2, traceParams.end)
}


// Creates a tracked particle effect using a pool of entities.
function SpawnEffect(keyvals, origin, angles, lifeTime = 1.0, targetPos = null)
{
	if(!(keyvals in hitEffects))
	{
		hitEffects[keyvals] <- {}
	}
	
	foreach(ent, params in hitEffects[keyvals])
	{
		if(Time() > params.time)
		{
			if(ent.IsValid())
			{
				if(targetPos)
				{
					if(!hitEffects[keyvals][ent].target || !hitEffects[keyvals][ent].target.IsValid())
					{
						ent.Kill()
						delete hitEffects[keyvals][ent]
						continue
					}
					hitEffects[keyvals][ent].target.SetOrigin(targetPos)
				}		
				ent.SetOrigin(origin)
				angles ? ent.SetAngles(angles) : null
				DoEntFire("!self", "Stop", "", 0.0, ent, ent)
				DoEntFire("!self", "Start", "", 0.01, ent, ent)
				DoEntFire("!self", "Stop", "", lifeTime, ent, ent)
				hitEffects[keyvals][ent].time = Time() + lifeTime
				return
			}
			else
			{
				delete hitEffects[keyvals][ent]
			}
		}
	}
	
	if(hitEffects[keyvals].len() < NUM_HIT_EFFECTS)
	{
		local target = null
		local targetName = ""
		if(targetPos)
		{
			PARTICLE_TARGET.targetname = "target"
			PARTICLE_TARGET.origin = origin
			target = g_ModeScript.CreateSingleSimpleEntityFromTable(PARTICLE_TARGET)
			targetName = target.GetName()
			weaponController.RegisterTrackedEntity(target, owningTurret)
		}
	
		keyvals.origin = origin
		angles ? keyvals.angles = angles : null
		targetPos ? keyvals.cpoint1 = targetName : null
		local effect = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvals)
		hitEffects[keyvals][effect] <- {time = Time() + lifeTime, target = target}
		weaponController.RegisterTrackedEntity(effect, owningTurret)
		DoEntFire("!self", "Start", "", 0.0, effect, effect)
		DoEntFire("!self", "Stop", "", lifeTime, effect, effect)
	}
}



TRACER_PARTICLE <-
{
	classname = "info_particle_system"
	effect_name = "weapon_tracers"
	render_in_front = "0"
	start_active = "0"
	cpoint1 = ""
	targetname = ""
	origin = Vector(0, 0, 0)
}

PARTICLE_TARGET <-
{
	classname = "info_particle_target"
	targetname = ""
	origin = Vector(0, 0, 0)
}

MUZZLE_PARTICLE <-
{
	classname = "info_particle_system"
	effect_name = "weapon_muzzle_flash_smg"
	render_in_front = "0"
	start_active = "0"
	parentname = ""
	targetname = ""
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}

BRASS_PARTICLE <-
{
	classname = "info_particle_system"
	effect_name = "weapon_shell_casing_9mm"
	render_in_front = "0"
	start_active = "0"
	targetname = ""
	parentname = ""
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}


SHOT_HIT_EFFECT_METAL <-
{
	classname = "info_particle_system"
	effect_name = "impact_ricochet"
	render_in_front = "0"
	start_active = "0"
	targetname = "impact"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}

SHOT_HIT_EFFECT_BLOOD <-
{
	classname = "info_particle_system"
	effect_name = "blood_impact_infected_01"
	render_in_front = "0"
	start_active = "0"
	targetname = "impact"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}

EXPLOSION_ENTITY <-
{
	classname = "env_explosion"
	targetname = ""
	iRadiusOverride = 10
	fireballsprite = "sprites/zerogxplode.spr"
	ignoredClass = 0
	iMagnitude = 1
	rendermode = 5
	spawnflags = 1918 // No effects
	origin = Vector(0, 0, 0)
}