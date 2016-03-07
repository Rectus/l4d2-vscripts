/* Sentry turret system base script. Specific turret types include this.
 * Do not use this directly as an entity script, use one of the specific types. 
 *
 *
 * Copyright (c) 2015 Rectus
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
 * 
 */
 
 
 // Turret parameters. Override them on the individual turret type scripts.
 
TRACK_RANGE <- 500;			// Max distance targets can be aquired.
TRACK_MIN_RANGE <- 64;		// Min distance targets can be aquired.
TARGET_INTERVAL <- 20;		// How many frames between checking target validity and aquiring.
TRACK_INTERVAL <- 1;		// How many frames between turning toward target.
FIRE_INTERVAL <- 10;		// How many frames between each shot.
HEATTEXTURE_INTERVAL <- 1;	// How many frames between updating the heat texture effects.	
SHELL_RANGE <- 1000;			// How far the projectiles get traced.
TARGET_TRACE_TOLERANCE <- 32;	// How close to a target a trace can be to count as seen.

// Variables
timeLeft <- 1;				// Frame interval counter-
target <- null;				// Handle of the current target.
targetVector <- null;		// Vector from gun to target.

SCAN_ROTATE <- false;		// Rotate turret when no target found.
SCAN_ROTATE_RATE <- 3;		// How fast to rotate.

TRACK_PRECISION <- 0.001;	// How well aimed the turret has to be before stopping tracking. Dot product of angle to target.
TRACK_RATE_H <- 15;			// Horizontal track rate in degrees per track interval.
TRACK_RATE_V <- 1;			// Vertical track rate in degrees per track interval.
FIRE_ANGLE_H <- 3;			// Tolerance for considering being aimed at the target.
FIRE_ANGLE_V <- 20;		
TRACK_LIMIT_V <- 45;		// Vertical gun range in degrees.
sweep <- false;				// Whether to sweep horizontally instead of aiming at the target.
SWEEP_CYCLES <- 5;			// How many frames to sweep.
SWEEP_RATE <- 5;			// Degerres to rotate each frame,

// Variables
sweepCycle <- 0;
sweepFire <- false;

HEAT_PER_SHOT <- 5.0;		// How much heat each frame firing produces.
MAX_HEAT <- 100.0;			// How much heat it takes to overheat.
HEAT_DECAY <- 1.0;			// How much it cools down each frame.
OVERHEAT_THRESHOLD <- 50.0;		// How cool to be before ending overheat.
HEAT_TEXTURE_OFFSET <- 127.0;
HEAT_TEXTURE_MULTIPLY <- 1;

MUZZLE_OFFSET <- Vector(52, 0, 2);				// Local muzzle coordinates.
PLAYER_TARGET_MAX_FIXUP <- Vector(0, 0, 48);	// Local vector telling where to aim on a target.
playerTargetFixup <- PLAYER_TARGET_MAX_FIXUP;
TARGET_FIXUP_VARIAINCE <- 0.3;					// Adds a random variance between this far toward the origin of the target. (fraction)

TGT_MODE_RANDOM <- 0;
TGT_MODE_CLOSEST <- 1;
TGT_MODE_FURTHEST <- 2;
targetingMode <- TGT_MODE_RANDOM;	// how to choose a taget from the set of highest priority targets

// Generates sets of targes using these criteria; chooses a target from the first non-empty set.
TARGET_PRIORITY <-
[
	// Targets special infected
	{
		tgtClass = ["player"],	// Entity class
		isSurvivor = false		// if "player", wheter the target is a survivor.
	},
	// Targets common infected
	{
		tgtClass = ["infected"]
	}
]

// Targetname of the turret. Used for finding the name prefix and postfix for spawned turrets.
// NAME <- "turret_gun";					
// TRAVERSE_NAME <- "turret_traverse";		// Name of the yawing part of the turret.

// Names for a material_modify_control and env_particle_system to show overheating effects.
// HEAT_EFFECT_NAME <- "turret_heat_effect";
// HEAT_TEXTURE_NAME <-"turret_heattexture";



//Variables
active <- false;
dbg <- false;	// Flip to enable debug info.
dbgText <- "";
targetAimedAt <- false;
heat <- 0.0;
prevHeat <- 0.0;
overheated <- false;
gunFired <- false;
turretBase <- null;	// Yawing part of the turret.

prefix <- "";
postfix <- "";

hitTargetEnt <- null;

// Run every 0.1 seconds.
function Think()
{
	if(!active)
	{
		return;
	}

	timeLeft -= 1;
	if(timeLeft <= 0 && !overheated)
	{
		timeLeft = TARGET_INTERVAL;
		FindTarget();
	}
	
	if(timeLeft % (TRACK_INTERVAL) == 0)
	{
		TrackTarget();
	}
		
	if(timeLeft % FIRE_INTERVAL == 0)
	{
		if((targetAimedAt || sweep) && !overheated)
		{
			FireWeapon();
			gunFired = true;
		}
		else if(!targetAimedAt || overheated)
			StopFiring();
	}
		

	heat -= HEAT_DECAY;	
	if(heat < 0)
	{
		heat = 0;
	}
		
	if(heat > MAX_HEAT)
	{
		heat = MAX_HEAT;
	}

	if(overheated && (heat < OVERHEAT_THRESHOLD))
	{
		HeatCooldown();
	}

	
	local heatFactor = (heat / MAX_HEAT) * HEAT_TEXTURE_MULTIPLY * 255.0 - HEAT_TEXTURE_OFFSET;
	if(heatFactor < 0)
	{
		heatFactor = 0.0;
	}
	else if(heatFactor >= 255)
	{
		heatFactor = 255.0;
	}

	if(timeLeft % HEATTEXTURE_INTERVAL == 0)
	{
		if(prevHeat != heat && "HEAT_TEXTURE_NAME" in this)
		{
			EntFire(prefix + HEAT_TEXTURE_NAME + postfix, "SetMaterialVar", "" + heatFactor);
		}
		
		prevHeat = heat;
	}
}

// Called after entity spawned
function OnPostSpawn()
{
	active <- true;
	
	Assert(self.GetName().find(NAME) >= 0, "turretsystem_turret_base: Invalid turret name");
	
	prefix = self.GetName().slice(0, self.GetName().find(NAME));
	postfix = self.GetName().slice(prefix.len() + NAME.len());
	
	// Adds a yawing base if specified, otherwise applies yaws to self.
	if("TRAVERSE_NAME" in this)
	{
		turretBase = Entities.FindByName(null, prefix + TRAVERSE_NAME + postfix);
	}
	else
	{
		turretBase = self;
	}
	
	if("TurretPostSpawn" in this)
	{
		TurretPostSpawn();
	}
	
	AddThinkToEnt(self, "Think");
}

// Use 'ent_text_allow_script 1' and 'ent_text' to see this.
function OnEntText()
{
	return dbgText;
}

// Tracks the turret toward the target one frame.
function TrackTarget()
{
	if(dbg)
		DebugDrawLine(self.GetOrigin(), self.GetOrigin() + VectorFromQAngle(self.GetAngles(), 64), 0, 255, 0, true, 0.5)

	if(IsValidTarget(target))
	{
		targetVector = target.GetOrigin() - self.GetOrigin() + playerTargetFixup;
		
		local myAngle = self.GetAngles();
		local myAngleVector = self.GetForwardVector();// VectorFromQAngle(myAngle);
		
		if(dbg)
		{
			dbgText = "Turret: " + self + "\n\nTarget: " + target + "\nYaw: " + turretBase.GetAngles().Yaw() + "\nPitch: " + myAngle.Pitch() + "\ntargetAimedAt: " + targetAimedAt + "\nheat: " + heat;
			DebugDrawText(self.GetOrigin(), dbgText, true, 0.1 * TRACK_INTERVAL + 0.05);
		
			DebugDrawLine(self.GetOrigin(), targetVector + self.GetOrigin(), 255, 255, 0, true, 0.5)
		}
		
		local difference = (targetVector * (1 / targetVector.Length())).Dot(myAngleVector * (1 / myAngleVector.Length()))
		
		if(dbg)
			printl("difference: " + difference);
		
		if(difference < (1 - TRACK_PRECISION) || gunFired)
		{		
			gunFired = false;
			local targetAngle = QAngleFromVector(targetVector)			
			
			if(dbg)
				printl("\tfrom: " + myAngle + " to: " + targetAngle);
			
			local yaw = GetAngleBetween( myAngle.Yaw(), targetAngle.Yaw());
			local pitch = GetAngleBetween(myAngle.Pitch(), targetAngle.Pitch());
			
			targetAimedAt = ((abs(yaw) < FIRE_ANGLE_H) && (abs(pitch) < FIRE_ANGLE_V));
			
			if(abs(pitch) > TRACK_RATE_V)
				pitch = TRACK_RATE_V * GetSign(pitch);	
					
				
			if(sweep && ((targetAimedAt && !overheated) || sweepCycle != 0))
			{
				if(sweepCycle == 0)
				{
					sweepFire = true;
					sweepCycle = SWEEP_CYCLES * GetSign(yaw);
				}
				else
					sweepCycle -= GetSign(sweepCycle);
				
				yaw = SWEEP_RATE * GetSign(sweepCycle);
				pitch =	0.0;
			}
			else
			{
				if(abs(yaw) > TRACK_RATE_H)
					yaw = TRACK_RATE_H * GetSign(yaw);	
			}
			
			
			if(abs(pitch + myAngle.Pitch()) > TRACK_LIMIT_V)
				pitch = 0;
							
			
			local rotate = QAngle(pitch, 0, 0);
			
			if(dbg)
			{
				printl("\trot: " + rotate + " yaw: " + GetAngleBetween( myAngle.Yaw(), targetAngle.Yaw()) + " pitch: " + GetAngleBetween(myAngle.Pitch(), targetAngle.Pitch()));

				DebugDrawLine(self.GetOrigin(), VectorFromQAngle(rotate + self.GetAngles(), 32) + self.GetOrigin(), 0, 0, 255, true, 0.5);
			}
			
			self.SetAngles(myAngle + rotate);
			
			rotate = QAngle(0, yaw, 0);
			turretBase.SetAngles(NormalizeAngles(turretBase.GetAngles() + rotate));
			
			
		}
		else
		{
			targetAimedAt = true;
		}
	}
	else if(sweep && sweepCycle != 0)
	{
		sweepCycle -= GetSign(sweepCycle);
		
		local rotate = QAngle(0, SWEEP_RATE * GetSign(sweepCycle), 0);
		turretBase.SetAngles(NormalizeAngles(turretBase.GetAngles() + rotate));
		targetAimedAt = false;
	}
	else
	{
		targetAimedAt = false;
		
		if(SCAN_ROTATE && !overheated)
		{
			turretBase.SetAngles(NormalizeAngles(turretBase.GetAngles() + QAngle(0, SCAN_ROTATE_RATE, 0)));
		}
	}
}


// Chooses a new target.
function FindTarget()
{
	local distance = 0;

	// Check curret target for validity.
	if(IsValidTarget(target) && ((distance = GetDistance(target.GetOrigin())) > TRACK_MIN_RANGE)
		&& (distance < TRACK_RANGE)
		&& TargetInLOS(self.GetOrigin(), target))
	{
		return;
	}

	targetAimedAt <- false;
	//target = null;
	local tempTarget = null;
	
	local targets = [];
			
	// Compiles a list of valid targets.
	foreach(targetType in TARGET_PRIORITY)
	{
		foreach(targetClass in targetType.tgtClass)
		{
			while(tempTarget = Entities.FindByClassnameWithin(tempTarget, targetClass, self.GetOrigin(), TRACK_RANGE))
			{

				if(IsValidTarget(tempTarget) && (GetDistance(tempTarget.GetOrigin()) > TRACK_MIN_RANGE)
					&& TargetInLOS(self.GetOrigin(), tempTarget))
					{
						if(!("isSurvivor" in targetType) || targetType.isSurvivor == tempTarget.IsSurvivor())
						{
							targets.append(tempTarget);
						}
					}
			}		
		}
		if(targets.len() > 0)
			break;
	}

	switch(targetingMode)
	{
		case TGT_MODE_RANDOM: // Selects a random target.
		{		
			if(targets.len() > 0)
				target = targets[RandomInt(0, targets.len() - 1)];
			else
				target = null;
			break;
		}
		
		case TGT_MODE_CLOSEST: // Selects the closest target.
		{
			local bestTarget = null;
		
			foreach(candidate in targets)
			{
				if(bestTarget == null || GetDistance(candidate.GetOrigin()) > GetDistance(bestTarget.GetOrigin()))
					bestTarget = candidate;
			}
			target = bestTarget;
			break;
		}
		
		case TGT_MODE_FURTHEST: // Selects the furthest away target.
		{
			local bestTarget = null;
		
			foreach(candidate in targets)
			{
				if(bestTarget == null || GetDistance(candidate.GetOrigin()) < GetDistance(bestTarget.GetOrigin()))
					bestTarget = candidate;
			}
			target = bestTarget;
			break;
		}
	}
	
	// Locks onto a random height of the target. It is currently not possible to find the actual height of the target, 
	// so this can be used to make it easier to aim at the center of the target.
	playerTargetFixup = PLAYER_TARGET_MAX_FIXUP * RandomFloat(1.0 - TARGET_FIXUP_VARIAINCE, 1.0); 
	if(dbg)
		printl(self.GetName() + " found target: " + target);
}


// Checks whether the target is valid and alive.
function IsValidTarget(testTarget)
{
	return (testTarget != null && testTarget.IsValid() && (testTarget.GetHealth() > 0) 
		&& (testTarget.GetClassname() != "player" || (!testTarget.IsDead() 
		&& !testTarget.IsDying() && (!testTarget.IsSurvivor() || !testTarget.IsIncapacitated()))))
}

// Returns the distance between the turret and a global vector.
function GetDistance(pos)
{
	return (self.GetOrigin() - pos).Length();
}

// Handles firing logic.
function FireWeapon()
{
	//Stub!
}

function StopFiring()
{
	//Stub!
}

// Traces a bullet fired from the turret.
function GetBulletTrace()
{
	local hitPos = null;
	local muzzlePos = self.GetOrigin() + RotatePosition(Vector(0,0,0), self.GetAngles(), MUZZLE_OFFSET);
	
	local bulletTraceTable =
	{
		start = muzzlePos
		end = muzzlePos + self.GetForwardVector() * SHELL_RANGE
		mask = g_ModeScript.TRACE_MASK_SHOT
		
		/*
		ignore
		
		hit
		pos
		fraction
		enthit
		startsolid
		*/
	}
	
	if(TraceLine(bulletTraceTable)) 
	{
			hitPos = bulletTraceTable.pos;
	
		if(dbg)
			DebugDrawLine(muzzlePos, hitPos, 255, 0, 0, true, 0.5);
			
		
	}
	
	return hitPos;
}

// Checks whether the tuuret can see the target (really primitive).
function TargetInLOS(muzzlePos, target)
{
	local hitPos = null;
	
	local bulletTraceTable =
	{
		start = muzzlePos
		end = target.GetOrigin() + PLAYER_TARGET_MAX_FIXUP
		mask = g_ModeScript.TRACE_MASK_SHOT
		ignore = self
	}
	
	if(TraceLine(bulletTraceTable)) 
	{
		hitPos = bulletTraceTable.pos;
	
		if(dbg)
			DebugDrawLine(muzzlePos, hitPos, 255, 0, 0, true, 0.5);
			
		
	}
	
	return (hitPos - target.GetOrigin() - PLAYER_TARGET_MAX_FIXUP).LengthSqr() 
		< (TARGET_TRACE_TOLERANCE * TARGET_TRACE_TOLERANCE);
}

// Adds heat to the turret.
function ApplyHeat()
{
	heat += HEAT_PER_SHOT;
	
	if(heat >= MAX_HEAT)
	{
		heat = MAX_HEAT;
	
		if(heat >= OVERHEAT_THRESHOLD)
		{
			overheated = true;
			target = null;
		}

		if("HEAT_EFFECT_NAME" in this)
			EntFire(prefix + HEAT_EFFECT_NAME + postfix, "Start");
	}
}

// 1 tick cooldown.
function HeatCooldown()
{
	overheated = false;
	
	if("HEAT_EFFECT_NAME" in this)
		EntFire(prefix + HEAT_EFFECT_NAME + postfix, "Stop");
		
	FindTarget();
}

function GetSign(value)
{
	if(value > 0.0)
		return 1.0;
	else
		return -1.0;
}

function NormalizeAngles(angles)
{
	return QAngle(angles.Pitch() % 360,
				angles.Yaw() % 360,
				angles.Roll() % 360);
}
	
// Gives a normalized angle in the same direction as the original.
function OverflowAngle(angle)
{
	angle = angle % 360;

	// If the angle is bigger than a half turn, turn it the other way instead.
	if(angle > 180)
		angle -= 360;
	else if(angle < -180)
		angle += 360;	
	
	//if(abs(angle % 180) < TRACK_PRECISION * 180)
		//angle = 0;
	
	return angle;
}

function GetAngleBetween(angle1, angle2)
{	
	local value =  angle2 - angle1;

	return OverflowAngle(value);
}

// Only gives alt + azimuth
function QAngleFromVector(vector, roll = 0)
{
        local function ToDeg(angle)
        {
            return (angle * 180) / PI;
        }

		if(vector.LengthSqr() == 0.0)
			return QAngle(0, 0, roll);
	       
		
		local yaw = ToDeg(atan(vector.y/vector.x));

        local pitch = -ToDeg(atan(vector.z/vector.Length2D()));
		
		if(vector.x < 0)
		{
			yaw += 180;	
		}
       
        return QAngle(pitch, yaw, roll);
}

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