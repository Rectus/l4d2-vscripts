/* Minigun turret script.
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

TRACK_RANGE <- 500;
TRACK_MIN_RANGE <- 32;
TARGET_INTERVAL <- 10;
TRACK_INTERVAL <- 1;
FIRE_INTERVAL <- 1;
// TRACK_PRECISION <- 0.001;
TRACK_RATE_H <- 15;
TRACK_RATE_V <- 5;
FIRE_ANGLE_H <- 5;
FIRE_ANGLE_V <- 25;
TRACK_LIMIT_V <- 30;

MUZZLE_OFFSET <- Vector(26, 0, -1);


HEAT_PER_SHOT <- 2.3;
MAX_HEAT <- 100.0;
HEAT_DECAY <- 0.65;
OVERHEAT_THRESHOLD <- 50;
HEAT_TEXTURE_OFFSET <- 130.0;

SHELL_RANGE <- 700;
STAGGER_RANGE <- 10;

NAME <- "mg_turret_gun";
TRAVERSE_NAME <- "mg_turret_traverse";
HIT_TARGET_NAME <- "mg_turret_hit_target";
TRACER_START_NAME <- "mg_turret_tracer";
SHELL_HURT_NAME <- "mg_turret_shell_hurt";
HEAT_EFFECT_NAME <- "mg_turret_heat_effect";
HEAT_TEXTURE_NAME <-"mg_turret_heattexture";


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
	self.PrecacheScriptSound("Minigun.SpinUp");
	self.PrecacheScriptSound("Minigun.SpinDown");
	self.PrecacheScriptSound("Minigun.Fire");
}

function TurretPostSpawn()
{
	hitTargetEnt = Entities.FindByName(null, prefix + HIT_TARGET_NAME + postfix);
	shellHurtEnt = Entities.FindByName(null, prefix + SHELL_HURT_NAME + postfix);
	
	Assert(hitTargetEnt && shellHurtEnt, "turretsystem_turret_mg: Failed to find all entities!");

	printl("Minigun turret initialized: " + prefix + NAME + postfix);
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

		EntFire(prefix + "mg_turret_casing" + postfix, "Start", 0 , 0.0);
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
		
		EntFire(prefix + TRACER_START_NAME + postfix, "Stop");
		EntFire(prefix + TRACER_START_NAME + postfix, "Start", 0 , 0.01);

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
		
		EntFire(prefix + "mg_turret_casing" + postfix, "Stop");
	}
}
