/* Gnome guardians minigun turret script.
 *
 * Copyright (c) Rectus 2015
 */
 
IncludeScript("gdef_turret_base");

TRACK_RANGE <- 500;
TRACK_MIN_RANGE <- 32;
TARGET_INTERVAL <- 10;
TRACK_INTERVAL <- 1;
FIRE_INTERVAL <- 3;
// TRACK_PRECISION <- 0.001;
TRACK_RATE_H <- 15;
TRACK_RATE_V <- 5;
FIRE_ANGLE_H <- 5;
FIRE_ANGLE_V <- 25;
TRACK_LIMIT_V <- 30;

MUZZLE_OFFSET <- Vector(26, 0, -1);
//PLAYER_TARGET_MAX_FIXUP <- Vector(0, 0, 48);
//playerTargetFixup <- PLAYER_TARGET_MAX_FIXUP;
//TARGET_CLASS <- "infected";

HEAT_PER_SHOT <- 2.3 * 3;
MAX_HEAT <- 100.0;
HEAT_DECAY <- 0.65;
OVERHEAT_THRESHOLD <- 50;
HEAT_TEXTURE_OFFSET <- 130.0;

SHELL_RANGE <- 700;
STAGGER_RANGE <- 10;

level0EffectsRan <- false;

NAME <- "mg_turret_gun";
TRAVERSE_NAME <- "mg_turret_traverse";
HIT_TARGET_NAME <- "mg_turret_hit_target";
TRACER_START_NAME <- "mg_turret_tracer";
TRACER_END_NAME <- "mg_turret_tracer_target";
//SHELL_EFFECT_NAME <- "mg_turret_shell_effect";
SHELL_HURT_NAME <- "mg_turret_shell_hurt";
HEAT_EFFECT_NAME <- "mg_turret_heat_effect";
HEAT_TEXTURE_NAME <-"mg_turret_heattexture";
EXCLUSION_ZONE_NAME <- "exclusion_zone_mg_turret";

EXCLUSION_ZONE_RADIUS <- 128;
BONUS_VALUE <- 17;

hitTargetEnt <- null;
//tracerStartEnt <- null;
// tracerEndEnt <- null;
//shellEffectEnt <- null;
shellHurtEnt <- null;
exclusionZoneEnt <- null;

animateSpin <- false;
spunDown <- true;
SPINDOWN_DELAY <- 2;
spinDownCounter <- 0;


function Precache()
{
	if(!g_ModeScript.SessionState.Precache) { return; }

	self.PrecacheScriptSound("Minigun.SpinUp");
	self.PrecacheScriptSound("Minigun.SpinDown");
	self.PrecacheScriptSound("Minigun.Fire");
}

function TurretPostSpawn()
{
	hitTargetEnt = Entities.FindByName(null, prefix + HIT_TARGET_NAME + postfix);
	shellHurtEnt = Entities.FindByName(null, prefix + SHELL_HURT_NAME + postfix);
	exclusionZoneEnt = Entities.FindByName(null, prefix + EXCLUSION_ZONE_NAME + postfix);
	
	
	Assert(hitTargetEnt && shellHurtEnt && exclusionZoneEnt, 
		"gdef_turret_mg: Failed to find all entities!");
		

	printl("Machine gun turret initialized: " + prefix + NAME + postfix);
}

function SetSpinAnimation()
{
	if(animateSpin)
	{
		DoEntFire("!self", "SetAnimation", "spin" , 0.0, self, self);
		EntFire(prefix + "mg_turret_muzzleflash" + postfix, "Start", 0 , 0.0);
		animateSpin = false;
		EmitSoundOn("Minigun.Fire", self);
		spinDownCounter = SPINDOWN_DELAY;
		if(!g_ModeScript.OPTIMIZE_NETCODE  || g_ModeScript.optimizationLevel <= 0)
		{
			EntFire(prefix + "mg_turret_casing" + postfix, "Start", 0 , 0.0);
		}
	}
}

function FireWeapon()
{
	if(dbg)
		printl(self.GetName() + " Firing at target: " + target);
		
	
	if(spunDown)
	{
		EmitSoundOn("Minigun.SpinUp", self);
		DoEntFire("!self", "SetAnimation", "spinup" , 0.0, self, self);
		DoEntFire("!self", "RunScriptCode", "SetSpinAnimation()" , 1.0, self, self);	
		animateSpin = true;
		spunDown = false;
	}
	else if(!animateSpin)
	{
		ApplyHeat();

		local hitPos = GetBulletTrace();

		hitTargetEnt.SetOrigin(hitPos);
		shellHurtEnt.SetOrigin(hitPos);
		EntFire(prefix + SHELL_HURT_NAME + postfix, "Hurt", 0 , 0.01);
		
		
		if(!g_ModeScript.OPTIMIZE_NETCODE  || g_ModeScript.optimizationLevel <= 0)
		{
			level0EffectsRan = true;
			EntFire(prefix + TRACER_START_NAME + postfix, "Stop");
			EntFire(prefix + TRACER_START_NAME + postfix, "Start", 0 , 0.01);
		}
	}
	
}

function StopFiring()
{
	if(!spunDown)
	{
		if(--spinDownCounter > 0)
		{
			return;
		}
		animateSpin = false;
		spunDown = true;
		DoEntFire("!self", "SetAnimation", "spindown" , 0.0, self, self);
		EntFire(prefix + "mg_turret_muzzleflash" + postfix, "Stop");
		StopSoundOn("Minigun.Fire", self);
		EmitSoundOn("Minigun.SpinDown", self);
		
		if(!g_ModeScript.OPTIMIZE_NETCODE || g_ModeScript.optimizationLevel <= 0 || level0EffectsRan)
		{
			level0EffectsRan = false;
			EntFire(prefix + "mg_turret_casing" + postfix, "Stop");
		}
	}
}
