/* Gnome guardians flame turret script.
 *
 * Copyright (c) Rectus 2015
 */
 
IncludeScript("gdef_turret_base");

SCAN_ROTATE <- true;		// Rotate turret when no target found.

TRACK_RANGE <- 200;
//FIRE_RANGE <- 100;
// TRACK_MIN_RANGE <- 64;
TARGET_INTERVAL <- 20;
TRACK_INTERVAL <- 1;
FIRE_INTERVAL <- 1;
TRACK_PRECISION <- 0.001;
TRACK_RATE_H <- 10;
TRACK_RATE_V <- 0;
FIRE_ANGLE_H <- 20;
FIRE_ANGLE_V <- 90;
// TRACK_LIMIT_V <- 45;
sweep <- true;
SWEEP_CYCLES <- 15;
SWEEP_RATE <- 5;

HEAT_PER_SHOT <- 11.0;
MAX_HEAT <- 200.0;
HEAT_DECAY <- 3.3;
OVERHEAT_THRESHOLD <- 50;
HEAT_TEXTURE_OFFSET <- -2.0;

//MUZZLE_OFFSET <- Vector(52, 0, 2);
PLAYER_TARGET_MAX_FIXUP <- Vector(0, 0, 48);
playerTargetFixup <- PLAYER_TARGET_MAX_FIXUP;
TARGET_FIXUP_VARIAINCE <- 0.0;

//TARGET_CLASS <- "infected";


NAME <- "flame_turret_gun";
TRAVERSE_NAME <- "flame_turret_traverse";
EXCLUSION_ZONE_NAME <- "exclusion_zone_flame_turret";

EXCLUSION_ZONE_RADIUS <- 128;
BONUS_VALUE <- 35;

function TurretPostSpawn()
{
	exclusionZoneEnt = Entities.FindByName(null, prefix + EXCLUSION_ZONE_NAME + postfix);
	Assert(exclusionZoneEnt, "gdef_turret: Failed to find all entities!");
	
	printl("Flame turret initialized: " + prefix + NAME + postfix);
}


function FireWeapon()
{
	if(!sweepFire)
	{
		if(sweepCycle != 0 && !overheated)
		{	
			ApplyHeat();
		}
		return;
	}
		
	sweepFire = false;
	
	if(dbg)
		printl(self.GetName() + " Firing at target: " + target);
		
	ApplyHeat();
		
	EntFire(prefix + "flame_turret_muzzleflash" + postfix, "Stop");

	EntFire(prefix + "flame_turret_hurt" + postfix, "Enable", 0, 0.2);
	EntFire(prefix + "flame_turret_hurt" + postfix, "Disable", 0, 1.60);
	EntFire(prefix + "flame_turret_sound" + postfix, "PlaySound");

	EntFire(prefix + "flame_turret_muzzleflash" + postfix, "Start", 0 , 0.01);
	EntFire(prefix + "flame_turret_muzzleflash" + postfix, "Stop", 0, 1.5);
}
