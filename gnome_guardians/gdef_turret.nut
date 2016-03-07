
TRACK_RANGE <- 900;
TRACK_MIN_RANGE <- 64;
TARGET_INTERVAL <- 10;
TRACK_INTERVAL <- 1;
FIRE_INTERVAL <- 5;
timeLeft <- 1;
target <- null;
targetVector <- null;
TRACK_PRECISION <- 0.001;
TRACK_RATE_H <- 15;
TRACK_RATE_V <- 1;
FIRE_ANGLE_H <- 3;
FIRE_ANGLE_V <- 20;
TRACK_LIMIT_V <- 45;

MUZZLE_OFFSET <- Vector(52, 0, 2);
PLAYER_TARGET_MAX_FIXUP <- Vector(0, 0, 56);
playerTargetFixup <- PLAYER_TARGET_MAX_FIXUP;
TARGET_FIXUP_VARIAINCE <- 1.0;

TARGET_CLASS <- "infected";

active <- false;
dbg <- false;
dbgText <- "";
targetAimedAt <- false;

LASER_TURRET <- 1;
EXPLOSIVE_SHELL <- 2;
MACHINEGUN <- 3;
TURRET_TYPE <- EXPLOSIVE_SHELL;

SHELL_RANGE <- 700;
STAGGER_RANGE <- 10;

NAME <- "turret_gun";
TRAVERSE_NAME <- "turret_traverse";
HIT_TARGET_NAME <- "turret_hit_target";
//TRACER_START_NAME <- "turret_tracer";
TRACER_END_NAME <- "turret_tracer_target";
SHELL_EFFECT_NAME <- "turret_shell_effect";
SHELL_HURT_NAME <- "turret_shell_hurt";

//EFFECT_DURATION <- 0.40;
postfix <- "";

hitTargetEnt <- null;
//tracerStartEnt <- null;
tracerEndEnt <- null;
shellEffectEnt <- null;
shellHurtEnt <- null;

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
	//tracerStartEnt = Entities.FindByName(null, TRACER_START_NAME + postfix);
	tracerEndEnt = Entities.FindByName(null, TRACER_END_NAME + postfix);
	shellEffectEnt = Entities.FindByName(null, SHELL_EFFECT_NAME + postfix);
	hitTargetEnt = Entities.FindByName(null, HIT_TARGET_NAME + postfix);
	shellHurtEnt = Entities.FindByName(null, SHELL_HURT_NAME + postfix);
	
	Assert(tracerEndEnt && shellEffectEnt && hitTargetEnt && shellHurtEnt, 
		"gdef_turrret: Failed to find all entities!");
		
	//tracerStartEnt.__KeyValueFromString("cpoint1", TRACER_END_NAME + postfix);
	g_ModeScript.TurretBuilt(this);
	printl("Turret initialized: " + NAME + postfix);
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

	if(target != null && target.IsValid())
	{
		targetVector = target.GetOrigin() - self.GetOrigin() + playerTargetFixup;
		local turretBase = Entities.FindByName(null, TRAVERSE_NAME + postfix);
		local myAngle = self.GetAngles();
		local myAngleVector = self.GetForwardVector();// VectorFromQAngle(myAngle);
		
		if(dbg)
		{
			dbgText = "Turret: " + self + "\n\nTarget: " + target + "\nYaw: " + turretBase.GetAngles().Yaw() + "\nPitch: " + myAngle.Pitch() + "\ntargetAimedAt: " + targetAimedAt;
			DebugDrawText(self.GetOrigin(), dbgText, true, 0.1 * TRACK_INTERVAL + 0.05);
		
			DebugDrawLine(self.GetOrigin(), targetVector + self.GetOrigin(), 255, 255, 0, true, 0.5)
		}
		
		local difference = (targetVector * (1 / targetVector.Length())).Dot(myAngleVector * (1 / myAngleVector.Length()))
		
		if(dbg)
			printl("difference: " + difference);
		
		if(difference < (1 - TRACK_PRECISION))
		{		
			local targetAngle = QAngleFromVector(targetVector)			
			
			if(dbg)
				printl("\tfrom: " + myAngle + " to: " + targetAngle);
			
			local yaw = GetAngleBetween( myAngle.Yaw(), targetAngle.Yaw());
			local pitch = -GetAngleBetween(myAngle.Pitch(), targetAngle.Pitch());
			
			targetAimedAt = ((abs(yaw) < FIRE_ANGLE_V) && (abs(pitch) < FIRE_ANGLE_H));
			
			if(abs(yaw) > TRACK_RATE_H)
				yaw = TRACK_RATE_H * GetSign(yaw);
				
			
			
			if(abs(pitch) > TRACK_RATE_V)
				pitch = TRACK_RATE_V * GetSign(pitch);	

			
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
function FindTarget()
{
	targetAimedAt <- false;
	target = null;
	local tempTarget = null;

	// if((tempTarget = Entities.FindByClassnameNearest("player", self.GetOrigin(), TRACK_RANGE)) 
		// && !target.IsSurvivor() && GetDistance(tempTarget.GetOrigin()) > TRACK_MIN_RANGE)
		// return;
	
	tempTarget = Entities.FindByClassnameNearest(TARGET_CLASS, self.GetOrigin(), TRACK_RANGE);
	
	while((tempTarget == null) || !tempTarget.IsValid() || (tempTarget.GetHealth() <= 0) || (GetDistance(tempTarget.GetOrigin()) < TRACK_MIN_RANGE))
	{
		tempTarget = Entities.FindByClassnameWithin(tempTarget, TARGET_CLASS, self.GetOrigin(), TRACK_RANGE);
		
		if(tempTarget == null)
			return;
	}
	
	target = tempTarget;
	playerTargetFixup = PLAYER_TARGET_MAX_FIXUP * RandomFloat(1.0 - TARGET_FIXUP_VARIAINCE, 1.0); // Locks onto a random height of the target.
	printl(self.GetName() + " found target: " + target);
}

function GetDistance(pos)
{
	return (self.GetOrigin() - pos).Length();
}

function FireWeapon()
{
	if(dbg)
		printl(self.GetName() + " Firing at target: " + target);
		
	switch(TURRET_TYPE)
	{
		case LASER_TURRET:
		{	
			EntFire("turret_gunfire" + postfix, "TurnOn", 0, 0.2);
			EntFire("turret_gunfire" + postfix, "TurnOff", 0, 0.70);
			EntFire("turret_laser_sound" + postfix, "PlaySound");
			EntFire("turret_heattexture" + postfix, "SetMaterialVar", "1", 0.2);
			EntFire("turret_heattexture" + postfix, "StartFloatLerp", "1 0 0.2 0", 0.7);
		}
		case EXPLOSIVE_SHELL:
		{
			EntFire("turret_muzzleflash" + postfix, "Stop");
			EntFire("turret_casing" + postfix, "Stop");
			EntFire("turret_tracer" + postfix, "Stop");
			EntFire(SHELL_EFFECT_NAME + postfix, "Stop");
		
			local hitPos = GetBulletTrace();
		
			hitTargetEnt.SetOrigin(hitPos);
			shellHurtEnt.SetOrigin(hitPos);
			
			//StaggerHitPlayers();
			
			//EntFire("turret_shell_explosion" + postfix, "Explode", 0 , 0.01);
			EntFire("turret_shell_hurt" + postfix, "Hurt", 0 , 0.01);
			EntFire("turret_muzzleflash" + postfix, "Start", 0 , 0.01);
			EntFire("turret_casing" + postfix, "Start", 0 , 0.01);
			EntFire("turret_tracer" + postfix, "Start", 0 , 0.01);
			EntFire("turret_shell_sound" + postfix, "PlaySound");
			EntFire(SHELL_EFFECT_NAME + postfix, "Start", 0 , 0.01);
		}
		case MACHINEGUN:
		{
			EntFire("turret_muzzleflash" + postfix, "Stop");
			EntFire("turret_casing" + postfix, "Stop");
			EntFire("turret_tracer" + postfix, "Stop");

		
			local hitPos = GetBulletTrace();
		
			hitTargetEnt.SetOrigin(hitPos);
			shellHurtEnt.SetOrigin(hitPos);
			
			EntFire("turret_shell_hurt" + postfix, "Hurt", 0 , 0.01);
			EntFire("turret_muzzleflash" + postfix, "Start", 0 , 0.01);
			EntFire("turret_casing" + postfix, "Start", 0 , 0.01);
			EntFire("turret_tracer" + postfix, "Start", 0 , 0.01);
			EntFire("turret_shell_sound" + postfix, "PlaySound");
		}
	}
}

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
		// if(bulletTraceTable.hit)
			// hitPos = bulletTraceTable.pos;
		// else
			hitPos = bulletTraceTable.pos;
	
		if(dbg)
			DebugDrawLine(muzzlePos, hitPos, 255, 0, 0, true, 0.5);
			
		
	}
	//g_ModeScript.DeepPrintTable(bulletTraceTable);
	
	return hitPos;
}

function StaggerHitPlayers()
{
	local player = null;

	while(player = Entities.FindByClassnameWithin(player, "player", hitTargetEnt.GetOrigin(), STAGGER_RANGE))
	{
		player.Stagger(hitTargetEnt.GetOrigin());
	}
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
	
	
function OverflowAngle(angle)
{
	if(angle > 180)
		angle = 180 - angle;
		
	if(angle < -180)
		angle = 180 - angle;	
	
	if(abs(angle % 180) < TRACK_PRECISION * 180)
		angle = 0;
	
	return angle % 180;
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

        local pitch = -ToDeg(atan(vector.z/vector.Length2D())) - 180;
		
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