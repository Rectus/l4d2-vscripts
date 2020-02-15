
/* 
 * Sentry turret script
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

IncludeScript("libraries/mathutils", getroottable())

Gun <- {}
IncludeScript("sentry_ball_shotgun", Gun)

STATES <-
{
	INIT = 0
	SCANNING = 1
	TRACKING = 2
	READY_TO_FIRE = 3
	FIRING = 4
	LOST_TRACKING = 5
	OUT_OF_AMMO = 6
	FIRING_WIND_DOWN = 7
}

turretState <- STATES.INIT

LIGHT_GREEN <- "30 255 10"
LIGHT_AMBER <- "255 100 30"
LIGHT_RED <- "255 20 5"
LIGHT_YELLOW <- "255 255 80"

 
TRACK_RANGE <- 500	
TRACK_LOS_RANGE <- 32	// Below this distance line of sight is assumed
INFECTED_AGGRO_DISTANCE <- 64
RETARGET_WEIGHT <- 0.1

THINK_INTERVAL <- 0.05
TARGET_INTERVAL <- 0.5	
TRACK_INTERVAL <- 0.1		
FIRE_INTERVAL <- 0.75
AGGRO_INTERVAL <- 1.0
TRACKING_LOST_DELAY <- 0.25
FIRE_WIND_DOWN_DELAY <- 0.5

SHELL_RANGE <- 1000	
TARGET_TRACE_TOLERANCE <- 32

lastTargetTime <- 0.0
lastTrackTime <- 0.0
lastFireTime <- 0.0
lastAggroTime <- 0.0
trackingLostTime <- 0.0
fireWindDownTime <- 0.0

target <- null			// Handle of the current target.
targetClass <- null		// Criteria class of the current target from TARGET_CLASSES.

SCAN_ROTATE <- false		// Rotate turret when no target found.
SCAN_ROTATE_RATE <- 45	// How fast to rotate.
		

FIRE_ANGLE <- 20		// Tolerance for considering being aimed at the target.

JUMP_VEL_Z <- 250
JUMP_MIN_ANGLE <- 10
JUMP_MIN_POWER_FRAC <- 0.4
JUMP_FACTOR <- 1000
JUMP_INTERVAL_MIN <- 0.5
JUMP_INTERVAL_MAX <- 2
nextJumpTime <- 0


MUZZLE_OFFSET <- Vector(6.8, 0, 9)			// Local muzzle coordinates.
TRACKING_OFFSET <- Vector(0, 0, 9)
TARGET_MAX_FIXUP <- Vector(0, 0, 48)		// Local vector telling where to aim on a target.
targetFixup <- TARGET_MAX_FIXUP
TARGET_FIXUP_VARIAINCE <- 0.3					// Adds a random variance between this far toward the origin of the target. (fraction)


function SurvivorProximityWeight(ent, firePos, FireAng)
{
	local survivor = null
	local minWeight = 1
		
	while(survivor = Entities.FindByClassnameWithin(survivor, "player", firePos, TRACK_RANGE))
	{
		if(survivor.IsSurvivor() && !survivor.IsIncapacitated() && !survivor.IsDead()) 
		{
			local survivorDir = GetEntCenter(ent) - firePos
			survivorDir.Norm()
			local weight = 1 - FireAng.Forward().Dot(survivorDir) * 0.95
			if(weight < minWeight)
			{
				minWeight = weight
			}
		}
	}
	return minWeight
}


function TargetAngleWeight(ent, firePos, FireAng)
{
	local targetDir = GetEntCenter(ent) - firePos
	targetDir.Norm()
	return FireAng.Forward().Dot(targetDir) / 4 + 0.75
}


function TargetDistanceWeight(ent, firePos, FireAng)
{
	local targetDist = (GetEntCenter(ent) - firePos).Length()
	return 1 - targetDist / TRACK_RANGE / 4
}

// Generates sets of targets using these criteria. Chooses a target from the first non-empty set.
TARGET_CLASSES <-
[
	{
		tgtClasses = ["witch"],
		baseWeight = 1,
		modifierFuncs =
		[
			@(ent, firePos, FireAng) NetProps.GetPropFloat(ent, "m_rage") * 10	// Prioritize angry witches
		]
	},
	{
		tgtClasses = ["player"],	
		zombieTypes = [8],	// Alway prioritize tanks
		baseWeight = 5
	},
	{
		tgtClasses = ["player"],	
		zombieTypes = [1,2,3,4,5,6], // Rest of the SI
		baseWeight = 1.5,
		modifierFuncs =
		[
			SurvivorProximityWeight,
			TargetAngleWeight,
			TargetDistanceWeight
		]
	},
	{
		tgtClasses = ["infected"],	
		baseWeight = 1.0,
		modifierFuncs =
		[
			SurvivorProximityWeight,
			TargetAngleWeight,
			TargetDistanceWeight
		]
	},
]


dbg <- false	// Flip to enable debug info.
dbgText <- ""

turretSvivel <- null	// Yawing part of the turret.
turretBase <- null
owningPlayer <- null
weaponController <- null
lightSprite <- null

useTarget <- null
hitTargetEnt <- null


function Think()
{

	local currentTime = Time()
	
	switch(turretState)
	{
		case STATES.READY_TO_FIRE:
	
			// Tell the weapon we're ready to start firing.
			StartFiring()
			DoEntFire("!self", "color", LIGHT_AMBER, 0.0, lightSprite, lightSprite)
			turretState = STATES.FIRING
			
			// Fallthrough
	
		case STATES.FIRING_WIND_DOWN:
		
			// Fallthrough
		case STATES.FIRING:

			if(currentTime > lastFireTime + FIRE_INTERVAL)
			{
				lastFireTime = currentTime
			
				// Fire weapon!
				if(!FireWeapon())
				{
					StopFiring()
					turretState = STATES.OUT_OF_AMMO
					DoEntFire("!self", "color", LIGHT_RED, 0.0, lightSprite, lightSprite)
					break
				}
			}
			// Fallthrough

		case STATES.TRACKING:
	
			if(currentTime > lastTrackTime + TRACK_INTERVAL)
			{
				lastTrackTime = currentTime
				
				if(turretState == STATES.FIRING_WIND_DOWN 
					&& currentTime < fireWindDownTime + FIRE_WIND_DOWN_DELAY)
				{
					break
				}
				
				if(!CheckValidTarget(target))
				{
					if(turretState == STATES.FIRING)
					{
						StopFiring()
						fireWindDownTime = currentTime
						turretState = STATES.FIRING_WIND_DOWN
					}
					else
					{
						DoEntFire("!self", "color", "0 0 0", 0.0, lightSprite, lightSprite)
						turretState = STATES.LOST_TRACKING
						trackingLostTime = currentTime
					}
					break
				}
				
				// Track target and check if we can fire.
				 if(TrackTarget())
				{
					if(turretState == STATES.TRACKING)
						{turretState = STATES.READY_TO_FIRE}
				}
				else
				{
					if(turretState == STATES.FIRING)
					{
						StopFiring()
						DoEntFire("!self", "color", LIGHT_YELLOW, 0.0, lightSprite, lightSprite)
						turretState = STATES.TRACKING
					}
				}
				
				// Check weight for if we want to pick a better target.
				if(currentTime > lastTargetTime + TARGET_INTERVAL)
				{
					lastTargetTime = currentTime
					local trackingOrigin = MathUtils.TransformPosLocalToWorld(TRACKING_OFFSET, self)
					local weight = GetTargetWeight(target, targetClass, trackingOrigin, self.GetAngles())
					
					if(weight < RETARGET_WEIGHT)
					{
						if(TryRetarget())
						{
							DoEntFire("!self", "color", LIGHT_YELLOW, 0.0, lightSprite, lightSprite)
							turretState = STATES.TRACKING
						}
					}
				}
			}
			
			if(currentTime > lastAggroTime + AGGRO_INTERVAL)
			{
				lastAggroTime = currentTime
				AggroEnemiesInRange()
			}
			
			break

		case STATES.SCANNING:
		
			if(SCAN_ROTATE && self.GetAngles().Up().Dot(Vector(0,0,1)) > 0)
			{
				turretSvivel.SetAngles(RotateOrientation(
					turretSvivel.GetAngles(), QAngle(0, SCAN_ROTATE_RATE * THINK_INTERVAL, 0)))
			}
		
		
			if(currentTime > lastTargetTime + TARGET_INTERVAL)
			{
				lastTargetTime = currentTime
				if(TryRetarget(true))
				{
					DoEntFire("!self", "color", LIGHT_YELLOW, 0.0, lightSprite, lightSprite)
					turretState = STATES.TRACKING
				}
			}
			
			break
		
		case STATES.LOST_TRACKING:
		
			if(currentTime > trackingLostTime + TRACKING_LOST_DELAY)
			{		
				DoEntFire("!self", "color", LIGHT_GREEN, 0.0, lightSprite, lightSprite)
				turretState = STATES.SCANNING
			}
			
			break
	
		case STATES.INIT:
			// Fallthrough
			
		case STATES.OUT_OF_AMMO:
		
			break
		
	}
	DoEntFire("!self", "CallScriptFunction", "Think", THINK_INTERVAL, self, self)
}


function Precache()
{
	Gun.Precache(self)
	PrecacheEntityFromTable(SENTRY_LIGHT)
}


function OnPostSpawn()
{
	turretSvivel = self
	turretBase = self
}


function Initialize(player, controller, ammoFrac)
{
	owningPlayer = player
	weaponController = controller.weakref()
	
	SENTRY_USE_TARGET.model = turretBase.GetName()
	useTarget = g_ModeScript.CreateSingleSimpleEntityFromTable(SENTRY_USE_TARGET)
	
	SENTRY_LIGHT.parentname = self.GetName() + ",lamp"
	lightSprite = g_ModeScript.CreateSingleSimpleEntityFromTable(SENTRY_LIGHT)
	lightSprite.SetOrigin(Vector(0,0,0))
	DoEntFire("!self", "ShowSprite", "", 0, lightSprite, lightSprite)

	Gun.Initialize(player, self, controller, ammoFrac)
	
	DoEntFire("!self", "SetAnimation", "loaded", 0.0, self, self)
	
	if(ammoFrac > 0.0)
	{
		DoEntFire("!self", "color", LIGHT_GREEN, 0.0, lightSprite, lightSprite)
		turretState = STATES.SCANNING
	}
	else
	{
		DoEntFire("!self", "color", LIGHT_RED, 0.0, lightSprite, lightSprite)
		turretState = STATES.OUT_OF_AMMO
	}
	
	useTarget.GetScriptScope().Initialize(self)
	
	DoEntFire("!self", "CallScriptFunction", "Think", THINK_INTERVAL, self, self)
	
	printl("Sentry ball initialized")
}


// Use 'ent_text_allow_script 1' and 'ent_text' to see this.
function OnEntText()
{
	return dbgText
}


// Tracks the turret toward the target one frame.
function TrackTarget()
{
	if(!target || !target.IsValid()) {return false}
	
	local transform = MathUtils.TransformMatrix(self)
	
	local turretAngles = self.GetAngles()
	SetTargetFixup()
	
	local TargetVectorLocal = transform.GetInverse() * (target.GetOrigin() + targetFixup)
	TargetVectorLocal.Norm()

	local targetAngle = MathUtils.RadToDeg(acos(Vector(1, 0, 0).Dot(TargetVectorLocal)))

	local targetAimedAt = targetAngle < FIRE_ANGLE

	if(Time() >= nextJumpTime && targetAngle >= JUMP_MIN_ANGLE)
	{
		local jumpFrac = (targetAngle - JUMP_MIN_ANGLE) / (180 - JUMP_MIN_ANGLE)
		local jumpPower = MathUtils.Lerp(JUMP_MIN_POWER_FRAC, 1, jumpFrac)
		local gravFactor = Convars.GetFloat("sv_gravity") / 800
		local axisAngle = Vector(1, 0, 0).Cross(TargetVectorLocal)
		axisAngle.Norm()

		nextJumpTime = Time() + MathUtils.Lerp(JUMP_INTERVAL_MIN, JUMP_INTERVAL_MAX, jumpFrac)
		
		turretBase.ApplyLocalAngularVelocityImpulse(axisAngle * jumpPower * JUMP_FACTOR)
		turretBase.ApplyAbsVelocityImpulse(Vector(0, 0, 1) * jumpPower * JUMP_VEL_Z * gravFactor)
		DoEntFire("!self", "CallScriptFunction", "Stabilize", 0.15, turretBase, turretBase)
	}
	
	return targetAimedAt
}


function Stabilize()
{
	turretBase.ApplyLocalAngularVelocityImpulse(GetPhysAngularVelocity(turretBase) * -RandomFloat(0.7, 0.9))
}


// Check if the turret can track the target
function CheckValidTarget(testTarget)
{

	if(!testTarget || !IsTargetAlive(testTarget))
	{
		return false
	}
	
	local trackingOrigin = MathUtils.TransformPosLocalToWorld(TRACKING_OFFSET, self)
	local distance = GetDistance(trackingOrigin, testTarget.GetOrigin())
		
	if(distance < TRACK_RANGE && TargetInLOS(trackingOrigin, testTarget))
	{
		return true
	}
	
	return false
}


// Checks whether the target is valid and alive.
function IsTargetAlive(testTarget)
{
	return (testTarget != null && testTarget.IsValid() && (testTarget.GetHealth() > 0) 
		&& (testTarget.GetClassname() != "player" || (!testTarget.IsDead() 
		&& !testTarget.IsDying() && (!testTarget.IsSurvivor() || !testTarget.IsIncapacitated()))))
}


function TryRetarget(reset = false)
{
	local newTarget = FindBestTarget()
	if(newTarget && newTarget.target != target)
	{
		target = newTarget.target
		targetClass = newTarget.targetClass

		SetTargetFixup()
		
		if(dbg)
			{printl(self.GetName() + " found target: " + target)}
	
		return true
	}
	else if(newTarget)
	{
		target = newTarget.target
		targetClass = newTarget.targetClass
		return reset
	}
	target = null
	targetClass = null
	return false
}


function SetTargetFixup()
{
	if(target.GetMoveParent())
	{
		// Fix for jockey riding position - aim at the top of the ridden survivor
		targetFixup = NetProps.GetPropVector(target.GetMoveParent(), "m_Collision.m_vecMaxs")
	}
	else if(NetProps.HasProp(target, "m_Collision.m_vecMins"))
	{
		// Find target center of mass relative to its origin if possible
		local mins = NetProps.GetPropVector(target, "m_Collision.m_vecMins")
		local maxs = NetProps.GetPropVector(target, "m_Collision.m_vecMaxs")				
		targetFixup = (maxs - mins) * 0.5
	}
	else
	{
		targetFixup = TARGET_MAX_FIXUP * RandomFloat(1.0 - TARGET_FIXUP_VARIAINCE, 1.0) 
	}	
}


function GetEntCenter(ent)
{
	if(NetProps.HasProp(ent, "m_Collision.m_vecMins"))
	{
		local mins = NetProps.GetPropVector(ent, "m_Collision.m_vecMins")
		local maxs = NetProps.GetPropVector(ent, "m_Collision.m_vecMaxs")				
		return ((maxs - mins) * 0.5) + ent.GetOrigin()
	}
	else
	{
		return ent.GetOrigin()
	}
}


function GetTargetWeight(tempTarget, targetType, trackingOrigin, aimAngs)
{
	local weight = targetType.baseWeight
	
	if("modifierFuncs" in targetType)
	{
		foreach(func in targetType.modifierFuncs)
		{
			weight *= func(tempTarget, trackingOrigin, aimAngs)
		}
	}
	return weight
}


// Find the target with the best weight.
function FindBestTarget()
{
	local trackingOrigin = MathUtils.TransformPosLocalToWorld(TRACKING_OFFSET, self)
	local aimAngs = self.GetAngles()

	local bestTarget = null
	local bestWeight = 0
	local bestType = null
			
	foreach(targetType in TARGET_CLASSES)
	{
		foreach(targetClass in targetType.tgtClasses)
		{
			local tempTarget = null
			while(tempTarget = Entities.FindByClassnameWithin(tempTarget, targetClass, trackingOrigin, TRACK_RANGE))
			{
				if(IsTargetAlive(tempTarget) && TargetInLOS(trackingOrigin, tempTarget))			
				{
					if(!("zombieTypes" in targetType) || targetClass != "player" 
						|| targetType.zombieTypes.find(tempTarget.GetZombieType()) != null)
					{
						local weight = GetTargetWeight(tempTarget, targetType, trackingOrigin, aimAngs)
						if(weight > bestWeight)
						{
							bestTarget = tempTarget
							bestWeight = weight
							bestType = targetType
						}
					}
				}
			}		
		}
	}
	
	if(!bestTarget) {return null}
	
	return {target = bestTarget, targetClass = bestType}
}


function AggroEnemiesInRange()
{
	foreach(targetType in TARGET_CLASSES)
	{
		foreach(targetClass in targetType.tgtClasses)
		{
			local ent = null
		
			while(ent = Entities.FindByClassnameWithin(ent, targetClass, turretBase.GetOrigin()
				, INFECTED_AGGRO_DISTANCE))
			{
				if( (!("zombieTypes" in targetType) || targetClass != "player" 
					|| targetType.zombieTypes.find(ent.GetZombieType()) != null)
					&& (targetClass != "player"  || IsPlayerABot(ent)) )
				{
					CommandABot({ cmd = DirectorScript.BOT_CMD_ATTACK, bot = ent, target = turretBase })
				}
			}
		}
	}
}


function GetDistance(pos1, pos2)
{
	return (pos1 - pos2).Length()
}


function StartFiring()
{
	Gun.OnStartFiring()
	DoEntFire("!self", "SetAnimation", "fire", 0.0, self, self)
	
	if(target.IsValid() && (target.GetClassname() != "player" || IsPlayerABot(target)))
	{
		CommandABot({ cmd = DirectorScript.BOT_CMD_ATTACK, bot = target, target = turretBase })
	}
}


function FireWeapon()
{
	local muzzlePos = MathUtils.TransformPosLocalToWorld(MUZZLE_OFFSET, self)
	local hasAmmo = Gun.FireWeapon(muzzlePos, self.GetAngles())

	if(hasAmmo)
	{
		local magnitude = RandomFloat(80, 120) 
		turretBase.ApplyAbsVelocityImpulse(self.GetAngles().Forward() * -magnitude)
	}
	else
	{
		return false
	}
	return true
}


function StopFiring()
{
	Gun.OnEndFiring()
	DoEntFire("!self", "SetAnimation", "loaded", 0.0, self, self)
}


function GetAmmoFraction()
{
	return Gun.GetAmmoFraction()
}


function Rearm(usingPlayer)
{
	local ammoFrac = Gun.Rearm(usingPlayer)
	
	if(turretState == STATES.OUT_OF_AMMO && ammoFrac > 0.0)
	{
		DoEntFire("!self", "color", LIGHT_GREEN, 0.0, lightSprite, lightSprite)
		turretState = STATES.SCANNING
	}
	
	return ammoFrac
}


// Checks whether the turret can see the target (really primitive).
function TargetInLOS(muzzlePos, target)
{
	local endpos = GetEntCenter(target)
	
	if(GetDistance(muzzlePos, endpos) < TRACK_LOS_RANGE)
		{return true}

	local hitPos = null
	
	local bulletTraceTable =
	{
		start = muzzlePos
		end = endpos
		mask = g_ModeScript.TRACE_MASK_SHOT
		ignore = turretBase
	}
	
	if(TraceLine(bulletTraceTable)) 
	{
		hitPos = bulletTraceTable.pos
	
		if(dbg)
			{DebugDrawLine(muzzlePos, hitPos, 255, 0, 0, true, 0.5)}
	}
	
	return (hitPos - endpos).LengthSqr() 
		< (TARGET_TRACE_TOLERANCE * TARGET_TRACE_TOLERANCE)
}


function GetAngleBetween(angle1, angle2)
{	
	local value =  angle2 - angle1

	return MathUtils.NormalizeAngle(value)
}



SENTRY_LIGHT <- 
{
	classname = "env_sprite"
	targetname = "sentry_light"
	scale = 0.05
	GlowProxySize = 1.0
	parentname = ""
	model = "sprites/light_glow01.vmt"
	rendermode = 3
	renderamt = 200
	rendercolor = Vector(255, 20, 20)
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	fadescale = 0
	fademindist = 1000
	fasemaxdist = 3000
}


SENTRY_USE_TARGET <-
{
	classname = "point_script_use_target"
	targetname = "sentry_use"
	vscripts = "sentry_turret_use"
	model = ""
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}