
/* Sentry turret script.
 * By: Rectus
 *
 */
TRACK_RANGE <- 1200;		// Max distance targets can be aquired.
TRACK_MIN_RANGE <- 64;		// Min distance targets can be aquired.
TARGET_INTERVAL <- 20;		// How many frames between checking target validity and aquiring.
TRACK_INTERVAL <- 1;		// How many frames between turning toward target.
FIRE_INTERVAL <- 2;			// How many frames between each shot.
FIRE_RANGE <- 650;
SHELL_RANGE <- 1500;
TARGET_TRACE_TOLERANCE <- 32;

timeLeft <- 1;
target <- null;
targetVector <- null;
retargetTimer <- 0;
RETARGET_INTERVAL <- 2;

TRACK_PRECISION <- 0.00005;	// How well aimed the turret has to be before stopping tracking.
TRACK_RATE_H <- 10;			// Horizontal track rate in degrees per track interval.
TRACK_RATE_V <- 2;			// Vertical track rate in degrees per track interval.
FIRE_ANGLE_H <- 3;
FIRE_ANGLE_V <- 20;
TRACK_LIMIT_V <- 45;
SWEEP <- false;
SWEEP_CYCLES <- 5;
SWEEP_RATE <- 5;
sweepCycle <- 0;

HEAT_PER_SHOT <- 5.0;
MAX_HEAT <- 100.0;
HEAT_DECAY <- 1.0;
OVERHEAT_THRESHOLD <- 50.0;

MUZZLE_OFFSET <- Vector(52, 0, 2);
LASER_OFFSET <- Vector(0, 0 10.5);
PLAYER_TARGET_MAX_FIXUP <- Vector(0, 0, 48);
playerTargetFixup <- PLAYER_TARGET_MAX_FIXUP;
TARGET_FIXUP_VARIAINCE <- 0.3;

TGT_MODE_RANDOM <- 0;
TGT_MODE_CLOSEST <- 1;
TGT_MODE_FURTHEST <- 2;
targetingMode <- TGT_MODE_CLOSEST;

// Generates sets of targes using these criteria; chooses a target from the first non-empty set.
TARGET_PRIORITY <-
[
	{
		tgtClass = ["player"],
		zombieType = 8
	},
	{
		tgtClass = ["player"]
		//isSurvivor = true		// if "player", wheter the target is a survivor.
	},
	{
		tgtClass = ["infected"]
	}
]

active <- false;
dbg <- false;
dbgText <- "";
targetAimedAt <- false;


NAME <- "turret_gun";
TRAVERSE_NAME <- "turret_traverse";
HIT_TARGET_NAME <- "turret_hit_target";
TRACER_END_NAME <- "turret_tracer_target";
SHELL_EFFECT_NAME <- "turret_shell_effect";
SHELL_HURT_NAME <- "turret_shell_hurt";
TARGETING_LASER_NAME <- "turret_laser";
LASER_TARGET_NAME <- "turret_laser_target";

hitTargetEnt <- null;
tracerEndEnt <- null;
shellEffectEnt <- null;
shellHurtEnt <- null;
targetingLaserEnt <- null;
laserTargetEnt <- null;
turretBase <- null;


postfix <- "";



function Think()
{
	if(!active)
		return;

	timeLeft -= 1;
	if(timeLeft <= 0)
	{
		timeLeft = TARGET_INTERVAL;
		FindTarget();
	}
	
	if(timeLeft % TRACK_INTERVAL == 0)
		TrackTarget();
		
	if(timeLeft % FIRE_INTERVAL == 0 && targetAimedAt)
		FireWeapon();		
}

function OnPostSpawn()
{
	active <- true;
	postfix = self.GetName().slice(NAME.len());
	
	
	tracerEndEnt = Entities.FindByName(null, TRACER_END_NAME + postfix);
	//shellEffectEnt = Entities.FindByName(null, SHELL_EFFECT_NAME + postfix);
	hitTargetEnt = Entities.FindByName(null, HIT_TARGET_NAME + postfix);
	shellHurtEnt = Entities.FindByName(null, SHELL_HURT_NAME + postfix);
	targetingLaserEnt = Entities.FindByName(null, TARGETING_LASER_NAME + postfix);
	laserTargetEnt = Entities.FindByName(null, LASER_TARGET_NAME + postfix);
	turretBase = Entities.FindByName(null, TRAVERSE_NAME + postfix);
	
	Assert(tracerEndEnt && hitTargetEnt && shellHurtEnt && targetingLaserEnt 
		&& laserTargetEnt && turretBase, 
		"gdef_turrret: Failed to find all entities!");
		
	printl("Sentry turret initialized: " + NAME + postfix);
	
}

// Use 'ent_text_allow_script 1' and 'ent_text' to see this.
function OnEntText()
{
	return dbgText;
}

function TrackTarget()
{
	if(dbg)
		DebugDrawLine(self.GetOrigin(), self.GetOrigin() + VectorFromQAngle(self.GetAngles(), 64), 0, 255, 0, true, 0.5)

	if(IsValidTarget(target))
	{
		targetVector = target.GetOrigin() - self.GetOrigin() + playerTargetFixup;
		
		local myAngle = self.GetAngles();
		local myAngleVector = self.GetForwardVector();// VectorFromQAngle(myAngle);
		
		local targetLoc = GetTrace(targetingLaserEnt.GetOrigin());
		local targetDist = abs((targetLoc - self.GetOrigin()).Length());		
		laserTargetEnt.SetOrigin(Vector(targetDist, 0, 0) + LASER_OFFSET);
		
		if(dbg)
		{
			dbgText = "Turret: " + self + "\n\nTarget: " + target + "\nYaw: " + turretBase.GetAngles().Yaw() + "\nPitch: " + myAngle.Pitch() + "\ntargetAimedAt: " + targetAimedAt + "\nheat: " + heat;
			DebugDrawText(self.GetOrigin(), dbgText, true, 0.1 * TRACK_INTERVAL + 0.05);
		
			DebugDrawLine(self.GetOrigin(), targetVector + self.GetOrigin(), 255, 255, 0, true, 0.5)
		}
		
		local difference = (targetVector * (1 / targetVector.Length())).Dot(myAngleVector * (1 / myAngleVector.Length()))
		
		if(dbg)
		{
			printl("difference: " + difference);
		}
		
		if(difference < (1 - TRACK_PRECISION))
		{		
			local targetAngle = QAngleFromVector(targetVector)			
			
			if(dbg)
				printl("\tfrom: " + myAngle + " to: " + targetAngle);
			
			local yaw = GetAngleBetween( myAngle.Yaw(), targetAngle.Yaw());
			local pitch = GetAngleBetween(myAngle.Pitch(), targetAngle.Pitch());
			
			targetAimedAt = ((abs(yaw) < FIRE_ANGLE_H) && (abs(pitch) < FIRE_ANGLE_V));
			
			if(abs(pitch) > TRACK_RATE_V)
				pitch = TRACK_RATE_V * GetSign(pitch);	
					
				
			
			if(abs(yaw) > TRACK_RATE_H)
				yaw = TRACK_RATE_H * GetSign(yaw);	
			
			
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
	else
	{
		targetAimedAt = false;
	}
}


// Chooses a new target.
function FindTarget()
{
	local distance = 0;

	// Check curret target for validity.
	if(IsValidTarget(target) && ((distance = GetDistance(target.GetOrigin())) > FIRE_RANGE)
		&& (distance < TRACK_RANGE)
		&& TargetInLOS(targetingLaserEnt.GetOrigin(), target)
		&& --retargetTimer > 0)
	{
		return;
	}
	
	retargetTimer = RETARGET_INTERVAL;

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
					&& TargetInLOS(targetingLaserEnt.GetOrigin(), tempTarget))
					{
						if((!("isSurvivor" in targetType) || targetType.isSurvivor == tempTarget.IsSurvivor())
							&& (!("zombieType" in targetType) || targetType.zombieType == tempTarget.GetZombieType()))
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
		
	if(target)
	{
		printl(self.GetName() + " found target: " + target);
		EntFire(TARGETING_LASER_NAME + postfix, "Start", 0 , 0.01);
	}
	else
	{
		EntFire(TARGETING_LASER_NAME + postfix, "Stop", 0 , 0.01);
		laserTargetEnt.SetOrigin(Vector(8.5, 0, -1) + LASER_OFFSET);
	}
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


function FireWeapon()
{
	if(GetDistance(target.GetOrigin()) > FIRE_RANGE)
		return;

	if(dbg)
	printl(self.GetName() + " Firing at target: " + target);
		
	EntFire("turret_muzzleflash" + postfix, "Stop");
	EntFire("turret_casing" + postfix, "Stop");
	EntFire("turret_tracer" + postfix, "Stop");
	EntFire(SHELL_EFFECT_NAME + postfix, "Stop");

	local hitPos = GetTrace(self.GetOrigin() + RotatePosition(Vector(0,0,0), self.GetAngles(), MUZZLE_OFFSET));

	hitTargetEnt.SetOrigin(hitPos);
	shellHurtEnt.SetOrigin(hitPos);
	

	EntFire("turret_shell_hurt" + postfix, "Hurt", 0 , 0.01);
	EntFire("turret_muzzleflash" + postfix, "Start", 0 , 0.01);
	EntFire("turret_casing" + postfix, "Start", 0 , 0.01);
	EntFire("turret_tracer" + postfix, "Start", 0 , 0.01);
	EntFire("turret_shell_sound" + postfix, "PlaySound");
	EntFire(SHELL_EFFECT_NAME + postfix, "Start", 0 , 0.01);
}


function GetTrace(muzzlePos)
{
	local hitPos = null;
	
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
	//g_ModeScript.DeepPrintTable(bulletTraceTable);
	
	return hitPos;
}

function TargetInLOS(muzzlePos, target)
{
	local hitPos = null;
	
	local bulletTraceTable =
	{
		start = muzzlePos
		end = target.GetOrigin() + PLAYER_TARGET_MAX_FIXUP
		mask = g_ModeScript.TRACE_MASK_SHOT
	}
	
	if(TraceLine(bulletTraceTable)) 
	{
		hitPos = bulletTraceTable.pos;
	
		if(dbg)
			DebugDrawLine(muzzlePos, hitPos, 255, 0, 0, true, 0.5);
			
		
	}
	//g_ModeScript.DeepPrintTable(bulletTraceTable);
	
	
	return (hitPos - target.GetOrigin() - PLAYER_TARGET_MAX_FIXUP).LengthSqr() 
		< (TARGET_TRACE_TOLERANCE * TARGET_TRACE_TOLERANCE);
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


