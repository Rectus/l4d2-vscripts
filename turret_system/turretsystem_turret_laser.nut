/* Laser turret script.
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
 
IncludeScript("turretsystem_turret_base");

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


NAME <- "laser_turret_gun";
TRAVERSE_NAME <- "laser_turret_traverse";
HEAT_TEXTURE_NAME <-"laser_turret_heattexture";
HEAT_EFFECT_NAME <- "laser_turret_heat_effect";
EXCLUSION_ZONE_NAME <- "exclusion_zone_laser_turret";

function Precache()
{
	self.PrecacheScriptSound("ambient.electrical_zap_8");
}

function TurretPostSpawn()
{
	printl("Laser turret initialized: " + prefix + NAME + postfix);
}


function FireWeapon()
{
	if(!sweepFire)	 // If not elgible to start firing.
	{
		if(sweepCycle != 0)	// If in the middle of firing.
		{
			ApplyHeat();
			if(overheated && !endedFiring) // Turn off when the capacitor is empty.
			{
				EntFire(prefix + "laser_turret_beam" + postfix, "TurnOff");
				EntFire(prefix + "laser_turret_muzzleflash" + postfix, "HideSprite");
				endedFiring = true;
			}
		}	
		return;
	}
	
	// Start firing.
	
	endedFiring = false;
	sweepFire = false;
	
	if(dbg)
	{
		printl(self.GetName() + " Firing at target: " + target);
	}
		
	ApplyHeat();
		
	EntFire(prefix + "laser_turret_muzzleflash" + postfix, "HideSprite");
	EntFire(prefix + "laser_turret_beam" + postfix, "TurnOff", 0, 0);

	EntFire(prefix + "laser_turret_beam" + postfix, "TurnOn", 0, 0.2);
	EntFire(prefix + "laser_turret_beam" + postfix, "TurnOff", 0, 1.60);
	EmitSoundOn("ambient.electrical_zap_8", self);

	EntFire(prefix + "laser_turret_muzzleflash" + postfix, "ShowSprite", 0 , 0.1);
	EntFire(prefix + "laser_turret_muzzleflash" + postfix, "HideSprite", 0, 1.60);
}
