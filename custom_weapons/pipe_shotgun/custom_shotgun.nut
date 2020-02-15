/* 
 * Pipe shotgun script.
 *
 * Copyright (c) 2017 Rectus
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

viewmodel <- null 		// Viewmodel entity
currentPlayer <- null 	// The player using the weapon

hitEffects <- {}
muzzleFlash <- null
tracer <- null
tracerEnd <- null
explosionEnt1 <- null
explosionEnt2 <- null
fireFrame <- 0
infiniteAmmo <- false
timesShot <- 0

FLESHY_ENTS <- 
{
	player = null,
	infected = null,
	witch = null,
	tank = null,
}


FIRE_ANIM_FRAMES <- 30
FIRE_ANIM_FRAMES_INF <- 3


SHOT_DISTANCE <- 768
SHOT_DAMAGE <- 40
SHOT_IMPULSE <- 20
SURVIVOR_DAMAGE_MULTIPLIER <- 0.5
WITCH_DAMAGE_MULTIPLIER <- 1.4
TANK_DAMAGE_MULTIPLIER <- 1.5

CENTER_SPREAD_RADIUS <- 4 // In degrees
SHOT_SPREAD_RADIUS <- 6
NUM_SHOT <- 12
SHOT_SECTOR_SIZE <- 360 / 6
NUM_HIT_EFFECTS <- 8 // Maximim effect entities to spawn per type
MAX_PENETRATIONS <- 2
MAX_PENETRATION_DISTANCE <- 512.0
PENETRATION_DAMAGE_FACTOR <- 0.5
PENETRATION_OFFSET <- 32

MIN_SHOTS_BEFORE_EXPLOSION <- 10
EXPLOSION_CHANCE_CONSTANT <- 0.0015

// Called after the script has loaded.
function OnInitialize()
{
	PrecacheEntityFromTable(TRACER_PARTICLE)
	PrecacheEntityFromTable(PARTICLE_TARGET)
	PrecacheEntityFromTable(MUZZLE_PARTICLE)
	PrecacheEntityFromTable(SHOT_HIT_EFFECT_METAL)
	PrecacheEntityFromTable(SHOT_HIT_EFFECT_BLOOD)
	PrecacheEntityFromTable(EXPLOSION_ENTITY)	
	self.PrecacheScriptSound("Shotgun.Fire")
	self.PrecacheScriptSound("AutoShotgun.Fire")
	self.PrecacheModel("models/weapons/melee/pipe_shotgun_broken.mdl")

	printl("New custom shotgun script on ent: " + self)
	
	// Registers a function to run every frame.
	AddThinkToEnt(self, "Think")
}


// Called when a player swithces to the the weapon.
function OnEquipped(player, _viewmodel)
{
	viewmodel = _viewmodel
	currentPlayer = player
	fireFrame = 0
}


// Called when a player switches away from the weapon.
function OnUnEquipped()
{
	Cleanup()
	currentPlayer = null
	viewmodel = null
	fireFrame = 0
}


// Called when the player stats firing.
function OnStartFiring()
{
	local infAmmoCvar = Convars.GetFloat("sv_infinite_ammo")
	if(infAmmoCvar)
	{
		infiniteAmmo = (infAmmoCvar > 0)
	}
	
	if(fireFrame == 0)
	{
		if(infiniteAmmo) {fireFrame = FIRE_ANIM_FRAMES_INF}
		else 			 {fireFrame = FIRE_ANIM_FRAMES}

		FireShotgun()
	}
}


// A think function to decrement the delay timer.
function Think()
{
	if(viewmodel && fireFrame > 0)
	{
		fireFrame--
	}
}


// Called every frame the player the player holds down the fire button.
function OnFireTick(playerButtonMask)
{	
	if(fireFrame == 0)
	{
		if(infiniteAmmo) {fireFrame = FIRE_ANIM_FRAMES_INF}
		else 			 {fireFrame = FIRE_ANIM_FRAMES}
		
		FireShotgun()
	}
}


// Called when the player ends firing.
function OnEndFiring()
{

}


function FireShotgun()
{
	if(++timesShot > MIN_SHOTS_BEFORE_EXPLOSION && !infiniteAmmo)
	{
		local roll = RandomFloat(0, 1)
		//printl(timesShot + ": "+ roll + "/" + EXPLOSION_CHANCE_CONSTANT * (timesShot - MIN_SHOTS_BEFORE_EXPLOSION - 1))
		if(roll < EXPLOSION_CHANCE_CONSTANT * (timesShot - MIN_SHOTS_BEFORE_EXPLOSION - 1))
		{
			Explode()
			return
		}
	}
	
	EmitSoundOn("Shotgun.Fire", currentPlayer) 
	local shotOrigin = currentPlayer.EyePosition() + RotatePosition(Vector(0,0,0), currentPlayer.EyeAngles(), Vector(16, -3, -1))
	local ang = RandomFloat(0, 360)
	local radius = CENTER_SPREAD_RADIUS * sqrt(RandomFloat(0, 1))
	local spreadCenter = RotateOrientation(currentPlayer.EyeAngles(), QAngle(radius * sin(ang), radius * cos(ang)) )
	
	FirePointBlank(shotOrigin, spreadCenter)
	TraceShot(shotOrigin, spreadCenter)
	
	
	if(!muzzleFlash || !muzzleFlash.IsValid())
	{
		local keyvalues = clone MUZZLE_PARTICLE
		keyvalues.origin = shotOrigin
		keyvalues.angles = spreadCenter
		muzzleFlash = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
		weaponController.RegisterTrackedEntity(muzzleFlash, self)
		DoEntFire("!self", "Start", "", 0, muzzleFlash, muzzleFlash)
		DoEntFire("!self", "Stop", "", 1, muzzleFlash, muzzleFlash)
	}
	else
	{
		muzzleFlash.SetOrigin(shotOrigin)
		muzzleFlash.SetAngles(spreadCenter)
		DoEntFire("!self", "Start", "", 0, muzzleFlash, muzzleFlash)
		DoEntFire("!self", "Stop", "", 1, muzzleFlash, muzzleFlash)
	}
}


function FirePointBlank(shotOrigin, spreadCenter)
{
	
	if(!explosionEnt1 || !explosionEnt1.IsValid())
	{
		explosionEnt1 = g_ModeScript.CreateSingleSimpleEntityFromTable(EXPLOSION_ENTITY)
		weaponController.RegisterTrackedEntity(explosionEnt1, self)
		NetProps.SetPropEntity(explosionEnt1, "m_hOwnerEntity", currentPlayer)
	}
	
	//DebugDrawCircle(shotOrigin + spreadCenter.Forward() * 40, Vector(255, 0, 0), 0, 32, true, 5)
	explosionEnt1.SetOrigin(shotOrigin + spreadCenter.Forward() * 40)
	DoEntFire("!self", "Explode", "" 0, currentPlayer, explosionEnt1)
	
	local traceParams =
	{
		start = shotOrigin
		end = shotOrigin + spreadCenter.Forward() * (40 + 32)
		ignore = currentPlayer
	}
	if(TraceLine(traceParams) && (!traceParams.hit || traceParams.enthit && traceParams.enthit.GetEntityIndex() > 0))
	{
	
		if(!explosionEnt2 || !explosionEnt2.IsValid())
		{
			local keyvalues = clone EXPLOSION_ENTITY
			keyvalues.iRadiusOverride = 56
			explosionEnt2 = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
			weaponController.RegisterTrackedEntity(explosionEnt2, self)
			NetProps.SetPropEntity(explosionEnt2, "m_hOwnerEntity", currentPlayer)
		}
		
		//DebugDrawCircle(shotOrigin + spreadCenter.Forward() * 72, Vector(255, 0, 0), 128, 56, true, 5)
		explosionEnt2.SetOrigin(shotOrigin + spreadCenter.Forward() * 80)
		DoEntFire("!self", "Explode", "" 0, currentPlayer, explosionEnt2)
	}
}

function TraceShot(origin, spreadDir)
{
	local ffFactor = GetFriendlyFireFactor()

	
	local entDamage = {}
	
	for(local i = 0; i < NUM_SHOT; i++)
	{
		local penetrations = 0
		local ang = RandomFloat(SHOT_SECTOR_SIZE * i, SHOT_SECTOR_SIZE * (i + 1)) + 180 * i
		local radius = SHOT_SPREAD_RADIUS * sqrt(RandomFloat(0, 1))
		local shotAng = RotateOrientation(spreadDir, QAngle(radius * sin(ang), radius * cos(ang), 0) )
		local hitAng = RotateOrientation(shotAng, QAngle(0, 180, RandomInt(0, 360)))
	
		local traceParams =
		{
			start = origin
			end = origin + VectorFromQAngle(shotAng, SHOT_DISTANCE)
			ignore = currentPlayer
		}
		while(TraceLine(traceParams) && traceParams.hit)
		{
			local penMultiplier = (penetrations > 0 ? PENETRATION_DAMAGE_FACTOR : 1)
		
			if(g_WeaponController.weaponDebug) {DebugDrawLine(traceParams.start, traceParams.pos, 255, 0, 0, false, 5)}
			
			if(("enthit" in traceParams) && traceParams.enthit && traceParams.enthit.GetEntityIndex() > 0)
			{
				local entClass = traceParams.enthit.GetClassname()
				
				if(!(traceParams.enthit in entDamage)) 
				{
					entDamage[traceParams.enthit] <- 0
					
					if(entClass in FLESHY_ENTS)
					{
						SpawnEffect(SHOT_HIT_EFFECT_BLOOD, traceParams.pos, hitAng)
					}
					else {SpawnEffect(SHOT_HIT_EFFECT_METAL, traceParams.pos, hitAng)}		
				} 		
			
				if(entClass == "player")
				{
					if(traceParams.enthit.IsSurvivor())
					{
						entDamage[traceParams.enthit] += SHOT_DAMAGE * ffFactor * SURVIVOR_DAMAGE_MULTIPLIER * penMultiplier
					}
					else if(traceParams.enthit.GetZombieType() == 8)
					{
						entDamage[traceParams.enthit] += SHOT_DAMAGE * TANK_DAMAGE_MULTIPLIER * penMultiplier
					}
					else
					{
						entDamage[traceParams.enthit] += SHOT_DAMAGE * penMultiplier
					}
				}
				else if(entClass == "witch")
				{
					entDamage[traceParams.enthit] += SHOT_DAMAGE * WITCH_DAMAGE_MULTIPLIER * penMultiplier
				}
				else
				{
					entDamage[traceParams.enthit] += SHOT_DAMAGE * penMultiplier

					if(penetrations == 0 && entClass.find("prop_door") == null)
					{
						traceParams.enthit.ApplyAbsVelocityImpulse(shotAng.Forward() * SHOT_IMPULSE)
					}
				}
			}
			else  // Hit world
			{
				SpawnEffect(SHOT_HIT_EFFECT_METAL, traceParams.pos, hitAng)
			}
			
			if(++penetrations > MAX_PENETRATIONS || traceParams.fraction > MAX_PENETRATION_DISTANCE / SHOT_DISTANCE)
			{
				break
			}
			
			traceParams.start = traceParams.pos + VectorFromQAngle(shotAng, PENETRATION_OFFSET)
			if(("enthit" in traceParams) && traceParams.enthit)
			{
				traceParams.ignore = traceParams.enthit
			}
		}
		
		SpawnEffect(TRACER_PARTICLE, origin, null, 1.0, traceParams.end)
	}
	
	foreach(entity, damage in entDamage)
	{
		if(damage > 0 && damage < 1) {damage = 1}
		//printl(damage)
		entity.TakeDamage(damage, DirectorScript.DMG_BULLET, currentPlayer) //DirectorScript.DMG_BUCKSHOT
	}
	
}


function Explode()
{
	EmitSoundOn("Shotgun.Fire", currentPlayer) 
	EmitSoundOn("explode_3", currentPlayer)
	local explosionPos = self.GetOrigin() + Vector(0, 0, 40) + VectorFromQAngle(currentPlayer.EyeAngles(), 16)

	local keyvalues = clone EXPLOSION_PARTICLE
	keyvalues.origin = explosionPos
	keyvalues.angles = currentPlayer.EyeAngles()
	local effect = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
	DoEntFire("!self", "Kill", "", 2, effect, effect)
	
	local keyvals = clone SHOTGUN_BROKEN
	keyvals.origin = self.GetOrigin() + Vector(0, 0, 40) + VectorFromQAngle(currentPlayer.EyeAngles(), 20)
	keyvals.angles = currentPlayer.GetAngles() + QAngle(0, 90, 0)
	local brokenShotgun = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvals)
	
	if(!explosionEnt2 || !explosionEnt2.IsValid())
	{
		local keyvalues = clone EXPLOSION_ENTITY
		keyvalues.iRadiusOverride = 128
		explosionEnt2 = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
		weaponController.RegisterTrackedEntity(explosionEnt2, self)
		NetProps.SetPropEntity(explosionEnt2, "m_hOwnerEntity", currentPlayer)
	}
	explosionEnt2.SetOrigin(explosionPos)
	DoEntFire("!self", "Explode", "" 0, currentPlayer, explosionEnt2)

	Cleanup()
	
	currentPlayer.Stagger(explosionPos)
	currentPlayer.GiveItem("pistol")
	DoEntFire("!self", "Kill", "", 0, self, self)
}


function GetFriendlyFireFactor()
{
	switch(Convars.GetStr("z_difficulty").tolower())
	{
	case "easy":
		return Convars.GetFloat("survivor_friendly_fire_factor_easy")
		
	case "normal":
		return Convars.GetFloat("survivor_friendly_fire_factor_normal")
		
	case "hard":
		return Convars.GetFloat("survivor_friendly_fire_factor_hard")
		
	case "impossible":
		return Convars.GetFloat("survivor_friendly_fire_factor_expert")
	
	default:
		return 1.0
	}
}

// Creates a tracked particle effect using a pool of entitites.
function SpawnEffect(keyvals, origin, angles, lifeTime = 2.0, targetPos = null)
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
				DoEntFire("!self", "Start", "", 0.0, ent, ent)
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
			local targetKeys = clone PARTICLE_TARGET
			targetKeys.targetname = "target"
			targetKeys.origin = origin
			target = g_ModeScript.CreateSingleSimpleEntityFromTable(targetKeys)
			targetName = target.GetName()
			weaponController.RegisterTrackedEntity(target, self)
		}
	
		local keyvalues = clone keyvals
		keyvalues.origin = origin
		angles ? keyvalues.angles = angles : null
		targetPos ? keyvalues.cpoint1 = targetName : null
		local effect = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
		hitEffects[keyvals][effect] <- {time = Time() + lifeTime, target = target}
		weaponController.RegisterTrackedEntity(effect, self)
		DoEntFire("!self", "Start", "", 0.0, effect, effect)
		DoEntFire("!self", "Stop", "", lifeTime, effect, effect)
	}
}


function Cleanup()
{
	if("cleaned" in this) {return}
	cleaned <- true

	foreach(keyvals, list in hitEffects)
	{
		foreach(ent, params in list)
		{
			if(ent.IsValid())
			{
				weaponController.UnregisterTrackedEntity(ent, self)
				ent.Kill()
				if(params.target && params.target.IsValid())
				{
					weaponController.UnregisterTrackedEntity(params.target, self)
					params.target.Kill()
				}
			}	
		}
	}
	hitEffects = {}
	
	if(muzzleFlash && muzzleFlash.IsValid())
	{
		weaponController.UnregisterTrackedEntity(muzzleFlash, self)
		muzzleFlash.Kill()
	}
	muzzleFlash = null
	
	if(explosionEnt1 && explosionEnt1.IsValid())
	{
		weaponController.UnregisterTrackedEntity(explosionEnt1, self)
		explosionEnt1.Kill()
	}
	explosionEnt1 = null
	
	if(explosionEnt2 && explosionEnt2.IsValid())
	{
		weaponController.UnregisterTrackedEntity(explosionEnt2, self)
		explosionEnt2.Kill()
	}
	explosionEnt2 = null
}


// Converts a QAngle to a vector, with a optional length.
function VectorFromQAngle(angles, radius = 1.0)
{
	local function ToRad(angle)
	{
		return (angle * PI) / 180;
	}
   
	local yaw = ToRad(angles.Yaw());
	local pitch = ToRad(-angles.Pitch());
   
	local x = radius * cos(yaw) * cos(pitch);
	local y = radius * sin(yaw) * cos(pitch);
	local z = radius * sin(pitch);
   
	return Vector(x, y, z);
}


function Clamp(val, min, max)
{
	if(val > max)
	{
		return max
	}
	else if(val > min)
	{
		return val
	}

	return min
}


/*
	weapon_shell_casing_shotgun
	weapon_muzzle_flash_shotgun_FP
	weapon_muzzle_flash_shotgun
	weapon_tracers
	ricochet_sparks
	impact_ricochet
	weapon_grenadelauncher
*/

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
	effect_name = "weapon_muzzle_flash_shotgun_FP"
	render_in_front = "0"
	start_active = "0"
	targetname = ""
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}

EXPLOSION_PARTICLE <-
{
	classname = "info_particle_system"
	effect_name = "weapon_grenadelauncher"
	render_in_front = "0"
	start_active = "1"
	targetname = ""
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
	iRadiusOverride = 32
	fireballsprite = "sprites/zerogxplode.spr"
	ignoredClass = 0
	iMagnitude = 25
	rendermode = 5
	spawnflags = 1918 // No effects
	origin = Vector(0, 0, 0)
}

SHOTGUN_BROKEN <-
{
	classname = "prop_physics"
	model = "models/weapons/melee/pipe_shotgun_broken.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	spawnflags = 4 // Debris
}
