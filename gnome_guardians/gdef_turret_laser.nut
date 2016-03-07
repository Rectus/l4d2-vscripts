/* Gnome guardians laser turret script.
 *
 * Copyright (c) Rectus 2015
 */

IncludeScript("gdef_turret_base");

SCAN_ROTATE <- true;		// Rotate turret when no target found.

TRACK_RANGE <- 800;
// TRACK_MIN_RANGE <- 64;
TARGET_INTERVAL <- 20;
TRACK_INTERVAL <- 1;
FIRE_INTERVAL <- 1;
TRACK_PRECISION <- 0.00001;
TRACK_RATE_H <- 8;
TRACK_RATE_V <- 8;
FIRE_ANGLE_H <- 30;
FIRE_ANGLE_V <- 10;
// TRACK_LIMIT_V <- 45;
sweep <- true;
SWEEP_CYCLES <- 18;
SWEEP_RATE <- 5;
endedFiring <- false;

HEAT_PER_SHOT <- 15.0;
MAX_HEAT <- 200.0;
HEAT_DECAY <- 5.0;
OVERHEAT_THRESHOLD <- 1;
HEAT_TEXTURE_OFFSET <- -112.0;
HEAT_TEXTURE_MULTIPLY <- -1.0;

//MUZZLE_OFFSET <- Vector(52, 0, 2);
PLAYER_TARGET_MAX_FIXUP <- Vector(0, 0, 48);
playerTargetFixup <- PLAYER_TARGET_MAX_FIXUP;
TARGET_FIXUP_VARIAINCE <- 0.0;

//TARGET_CLASS <- "infected";


NAME <- "laser_turret_gun";
TRAVERSE_NAME <- "laser_turret_traverse";
HEAT_TEXTURE_NAME <-"laser_turret_heattexture";
HEAT_EFFECT_NAME <- "laser_turret_heat_effect";
EXCLUSION_ZONE_NAME <- "exclusion_zone_laser_turret";

EXCLUSION_ZONE_RADIUS <- 128;
BONUS_VALUE <- 125;

function Precache()
{
	if(!g_ModeScript.SessionState.Precache) { return; }

	self.PrecacheScriptSound("ambient.electrical_zap_8");
}

function TurretPostSpawn()
{
	exclusionZoneEnt = Entities.FindByName(null, prefix + EXCLUSION_ZONE_NAME + postfix);
	Assert(exclusionZoneEnt, "gdef_turret: Failed to find all entities!");

	printl("Laser turret initialized: " + prefix + NAME + postfix);
}


function FireWeapon()
{
	if(!sweepFire)
	{
		if(sweepCycle != 0)
		{
			ApplyHeat();
			if(overheated && !endedFiring)
			{
				EntFire(prefix + "laser_turret_beam" + postfix, "TurnOff");
				EntFire(prefix + "laser_turret_muzzleflash" + postfix, "HideSprite");
				endedFiring = true;
			}
		}	
		return;
	}
	
	
	endedFiring = false;
	sweepFire = false;
	
	if(dbg)
		printl(self.GetName() + " Firing at target: " + target);
		
	ApplyHeat();
		
	EntFire(prefix + "laser_turret_muzzleflash" + postfix, "HideSprite");
	EntFire(prefix + "laser_turret_beam" + postfix, "TurnOff", 0, 0);

	EntFire(prefix + "laser_turret_beam" + postfix, "TurnOn", 0, 0.2);
	EntFire(prefix + "laser_turret_beam" + postfix, "TurnOff", 0, 1.60);
	EmitSoundOn("ambient.electrical_zap_8", self);

	EntFire(prefix + "laser_turret_muzzleflash" + postfix, "ShowSprite", 0 , 0.1);
	EntFire(prefix + "laser_turret_muzzleflash" + postfix, "HideSprite", 0, 1.60);
}
