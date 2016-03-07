/* Gnome guardians flak turret script.
 *
 * Copyright (c) Rectus 2015
 */
 
IncludeScript("gdef_turret_base");

TRACK_RANGE <- 1500;
// TRACK_MIN_RANGE <- 64;
TARGET_INTERVAL <- 10;
TRACK_INTERVAL <- 1;
FIRE_INTERVAL <- 5;
TRACK_PRECISION <- 0.02;
TRACK_RATE_H <- 10;
TRACK_RATE_V <- 2;
FIRE_ANGLE_H <- 4;
FIRE_ANGLE_V <- 7;
// TRACK_LIMIT_V <- 45;

//MUZZLE_OFFSET <- Vector(52, 0, 2);
//PLAYER_TARGET_MAX_FIXUP <- Vector(0, 0, 48);
//playerTargetFixup <- PLAYER_TARGET_MAX_FIXUP;
TARGET_FIXUP_VARIAINCE <- 0.3;

targetingMode <- TGT_MODE_RANDOM;
TARGET_CLASS <- ["infected"];

HEAT_PER_SHOT <- 20;
MAX_HEAT <- 100.0;
HEAT_DECAY <- 2;
OVERHEAT_THRESHOLD <- 50;

SHELL_RANGE <- 1500;
STAGGER_RANGE <- 10;

EXCLUSION_ZONE_RADIUS <- 128;
BONUS_VALUE <- 150;

level0EffectsRan <- false;
level1EffectsRan <- false;

NAME <- "flak_turret_gun";
TRAVERSE_NAME <- "flak_turret_traverse";
HIT_TARGET_NAME <- "flak_turret_hit_target";

TRACER_END_NAME <- "flak_turret_tracer_target";
SHELL_EFFECT_NAME <- "flak_turret_shell_effect";
SHELL_HURT_NAME <- "flak_turret_shell_hurt";
HEAT_EFFECT_NAME <- "flak_turret_heat_effect";
HEAT_TEXTURE_NAME <- "flak_turret_heattexture";
EXCLUSION_ZONE_NAME <- "exclusion_zone_flak_turret";

hitTargetEnt <- null;
tracerEndEnt <- null;
shellEffectEnt <- null;
shellHurtEnt <- null;
exclusionZoneEnt <- null;

function Precache()
{
	if(!g_ModeScript.SessionState.Precache) { return; }

	self.PrecacheScriptSound("50cal.Fire");
}

function TurretPostSpawn()
{
	tracerEndEnt = Entities.FindByName(null, prefix + TRACER_END_NAME + postfix);
	shellEffectEnt = Entities.FindByName(null, prefix + SHELL_EFFECT_NAME + postfix);
	hitTargetEnt = Entities.FindByName(null, prefix + HIT_TARGET_NAME + postfix);
	shellHurtEnt = Entities.FindByName(null, prefix + SHELL_HURT_NAME + postfix);
	exclusionZoneEnt = Entities.FindByName(null, prefix + EXCLUSION_ZONE_NAME + postfix);
	
	Assert(tracerEndEnt && shellEffectEnt && hitTargetEnt && shellHurtEnt && exclusionZoneEnt, 
		"gdef_turrret_flak: Failed to find all entities!");

	printl("Flak turret initialized: " + prefix + NAME + postfix);
}


function FireWeapon()
{
	ApplyHeat();

	if(dbg)
		printl(self.GetName() + " Firing at target: " + target);
		
	
	if(!g_ModeScript.OPTIMIZE_NETCODE || g_ModeScript.optimizationLevel <= 1 || level1EffectsRan)
	{
		level1EffectsRan = false;
		EntFire(prefix + "flak_turret_muzzleflash" + postfix, "Stop");
	}
	
	if(!g_ModeScript.OPTIMIZE_NETCODE || g_ModeScript.optimizationLevel <= 0 || level0EffectsRan)
	{
		level0EffectsRan = false;
		EntFire(prefix + "flak_turret_casing" + postfix, "Stop");
		EntFire(prefix + "flak_turret_tracer" + postfix, "Stop");
		DoEntFire("!self", "Stop", "", 0, self, shellEffectEnt);
	}
	
	local hitPos = GetBulletTrace();

	hitTargetEnt.SetOrigin(hitPos);
	shellHurtEnt.SetOrigin(hitPos);

	DoEntFire("!self", "Hurt", "", 0.01, self, shellHurtEnt);
	
	if(!g_ModeScript.OPTIMIZE_NETCODE  || g_ModeScript.optimizationLevel <= 1)
	{
		level1EffectsRan = true;
		EntFire(prefix + "flak_turret_muzzleflash" + postfix, "Start", 0 , 0.01);
	}
	
	if(!g_ModeScript.OPTIMIZE_NETCODE  || g_ModeScript.optimizationLevel <= 0)
	{
		level0EffectsRan = true;
		EntFire(prefix + "flak_turret_casing" + postfix, "Start", 0 , 0.01);
		EntFire(prefix + "flak_turret_tracer" + postfix, "Start", 0 , 0.01);
		DoEntFire("!self", "Start", "", 0.01, self, shellEffectEnt);
	}

	EmitSoundOn("50cal.Fire", self);
}

