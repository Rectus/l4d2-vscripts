/* Gnome guardians flame turret script.
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

TRACK_RANGE <- 200;
TARGET_INTERVAL <- 20;
TRACK_INTERVAL <- 1;
FIRE_INTERVAL <- 1;
TRACK_PRECISION <- 0.001;
TRACK_RATE_H <- 10;
TRACK_RATE_V <- 0;
FIRE_ANGLE_H <- 20;
FIRE_ANGLE_V <- 90;

sweep <- true;
SWEEP_CYCLES <- 15;
SWEEP_RATE <- 5;

HEAT_PER_SHOT <- 11.0;
MAX_HEAT <- 200.0;
HEAT_DECAY <- 3.3;
OVERHEAT_THRESHOLD <- 50;
HEAT_TEXTURE_OFFSET <- -2.0;

PLAYER_TARGET_MAX_FIXUP <- Vector(0, 0, 48);
playerTargetFixup <- PLAYER_TARGET_MAX_FIXUP;
TARGET_FIXUP_VARIAINCE <- 0.0;

NAME <- "flame_turret_gun";
TRAVERSE_NAME <- "flame_turret_traverse";

function TurretPostSpawn()
{
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
	{
		printl(self.GetName() + " Firing at target: " + target);
	}
		
	ApplyHeat();
		
	EntFire(prefix + "flame_turret_muzzleflash" + postfix, "Stop");

	EntFire(prefix + "flame_turret_hurt" + postfix, "Enable", 0, 0.2);
	EntFire(prefix + "flame_turret_hurt" + postfix, "Disable", 0, 1.60);
	EntFire(prefix + "flame_turret_sound" + postfix, "PlaySound");

	EntFire(prefix + "flame_turret_muzzleflash" + postfix, "Start", 0 , 0.01);
	EntFire(prefix + "flame_turret_muzzleflash" + postfix, "Stop", 0, 1.5);
}
