/* Example turret script. Makes a simple gun turret.
 * 
 * Add this to the Entity Scripts keyvalue of an entiyt to make it behave like a turret.
 * It needs some support entitties to find the hit location and show graphical effects, 
 * as well as for hurting the target.
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
 
// Adds the base turret logic to the script.
IncludeScript("turretsystem_turret_base");

// These values can be adjusted to change the turret behavior.
// There are more in the base script, but these are the most useful to change.

TRACK_RANGE <- 500;				// Max distance targets can be aquired.
TARGET_INTERVAL <- 10;			// How many frames between checking target validity and aquiring.
TRACK_INTERVAL <- 1;			// How many frames between turning toward target.
FIRE_INTERVAL <- 3;				// How many frames between each shot.
TRACK_PRECISION <- 0.001;		// How well aimed the turret has to be before stopping tracking. Dot product of angle to target.
TRACK_RATE_H <- 10;				// Horizontal track rate in degrees per track interval.
TRACK_RATE_V <- 5;				// Vertical track rate in degrees per track interval.
FIRE_ANGLE_H <- 5;				// How small horizontal angle to taget before firing.
FIRE_ANGLE_V <- 7;				// How small vertical angle to taget before firing.
TRACK_LIMIT_V <- 45;			// How many degrees the turret can elevate.
SHELL_RANGE <- 1500;			// How far bullets go.

MUZZLE_OFFSET <- Vector(48, 0, 0);	// Vector local to the turret of where the LOS and bullet traces start.

NAME <- "example_turret_gun";	// Needs to be set to the name of the turret gun.
//TRAVERSE_NAME <- "example_turret_traverse";	// Set to make an entity the turret is parented to receive the yaw commands.
HIT_TARGET_NAME <- "example_turret_hit_target";	// This target is set to to a info_target entity that dispalys graphical effects on the impact location for bullet firing turrets.
SHELL_HURT_NAME <- "example_turret_shell_hurt";	// This point_hurt damages the target.

// Generates sets of targes using these criteria; chooses a target from the first non-empty set.
TARGET_PRIORITY <-
[
	//  First priority, targets special infected
	{
		tgtClass = ["player"],	// Entity class
		isSurvivor = false		// if "player", wheter the target is a survivor.
	},
	// second priority, targets common infected
	{
		tgtClass = ["infected"]
	},
	// Third priority, targets survivors. (Remove this for friendly turrets)
	{
		tgtClass = ["player"],	// Entity class
		isSurvivor = true		// if "player", wheter the target is a survivor.
	},
]

dbg <- true;	// Enables debug mode

// Handles for entitites that need their position moved.
hitTargetEnt <- null;
shellHurtEnt <- null;

// Called by game to precache sounds and models.
function Precache()
{
	self.PrecacheScriptSound("50cal.Fire");
}

// Called byt base script when the turret spawns.
function TurretPostSpawn()
{
	// Tries to find the handles to the entities we need to access.
	hitTargetEnt = Entities.FindByName(null, prefix + HIT_TARGET_NAME + postfix);
	shellHurtEnt = Entities.FindByName(null, prefix + SHELL_HURT_NAME + postfix);
	
	Assert(hitTargetEnt && shellHurtEnt, 
		"turretsystem_turrret_example: Failed to find all entities! This usually means that an entity needed for the turret hasn't been properly spawned, or the name has been mistyped.");

	printl("Example turret initialized: " + prefix + NAME + postfix);
	
	active <- false; // remove this to have the turret be active on spawn.
}

// Called by the base script when the turret is aimed at the target every fire interval.
function FireWeapon()
{
	if(dbg)
	{
		printl(self.GetName() + " Firing at target: " + target);
	}	
	
	// Ends praticle effects so they can be replayed.
	EntFire(prefix + "example_turret_muzzleflash" + postfix, "Stop");
	EntFire(prefix + "example_turret_tracer" + postfix, "Stop");

	// Calculates the bullet hit position.
	local hitPos = GetBulletTrace();

	// Sets the entities positions to the hit location.
	hitTargetEnt.SetOrigin(hitPos);
	shellHurtEnt.SetOrigin(hitPos);

	// Hurts anything at the hit location. Proper hitscan damaging is not possible AFAIK.
	DoEntFire("!self", "Hurt", "", 0.01, self, shellHurtEnt);
	
	// Plays the gun particle effects.
	EntFire(prefix + "example_turret_muzzleflash" + postfix, "Start", 0 , 0.01);
	EntFire(prefix + "example_turret_tracer" + postfix, "Start", 0 , 0.01);
	
	// Plays a gunfire sound on the turret.
	EmitSoundOn("50cal.Fire", self);
}

