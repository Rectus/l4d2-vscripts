/* Flak turret script.
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

TARGET_FIXUP_VARIAINCE <- 0.3;

HEAT_PER_SHOT <- 20;
MAX_HEAT <- 100.0;
HEAT_DECAY <- 2;
OVERHEAT_THRESHOLD <- 50;

SHELL_RANGE <- 1500;


NAME <- "flak_turret_gun";
TRAVERSE_NAME <- "flak_turret_traverse";
HIT_TARGET_NAME <- "flak_turret_hit_target";

TRACER_END_NAME <- "flak_turret_tracer_target";
SHELL_EFFECT_NAME <- "flak_turret_shell_effect";
SHELL_HURT_NAME <- "flak_turret_shell_hurt";
HEAT_EFFECT_NAME <- "flak_turret_heat_effect";
HEAT_TEXTURE_NAME <- "flak_turret_heattexture";

hitTargetEnt <- null;
tracerEndEnt <- null;
shellEffectEnt <- null;
shellHurtEnt <- null;

function Precache()
{
	self.PrecacheScriptSound("50cal.Fire");
}

function TurretPostSpawn()
{
	tracerEndEnt = Entities.FindByName(null, prefix + TRACER_END_NAME + postfix);
	shellEffectEnt = Entities.FindByName(null, prefix + SHELL_EFFECT_NAME + postfix);
	hitTargetEnt = Entities.FindByName(null, prefix + HIT_TARGET_NAME + postfix);
	shellHurtEnt = Entities.FindByName(null, prefix + SHELL_HURT_NAME + postfix);
	
	Assert(tracerEndEnt && shellEffectEnt && hitTargetEnt && shellHurtEnt, 
		"turretsystem_turrret_flak: Failed to find all entities!");

	printl("Flak turret initialized: " + prefix + NAME + postfix);
}


function FireWeapon()
{
	ApplyHeat();

	if(dbg)
	{
		printl(self.GetName() + " Firing at target: " + target);
	}	
	
	EntFire(prefix + "flak_turret_muzzleflash" + postfix, "Stop");
	EntFire(prefix + "flak_turret_casing" + postfix, "Stop");
	EntFire(prefix + "flak_turret_tracer" + postfix, "Stop");
	DoEntFire("!self", "Stop", "", 0, self, shellEffectEnt);

	local hitPos = GetBulletTrace();

	hitTargetEnt.SetOrigin(hitPos);
	shellHurtEnt.SetOrigin(hitPos);

	DoEntFire("!self", "Hurt", "", 0.01, self, shellHurtEnt);
	
	EntFire(prefix + "flak_turret_muzzleflash" + postfix, "Start", 0 , 0.01);
	EntFire(prefix + "flak_turret_casing" + postfix, "Start", 0 , 0.01);
	EntFire(prefix + "flak_turret_tracer" + postfix, "Start", 0 , 0.01);
	DoEntFire("!self", "Start", "", 0.01, self, shellEffectEnt);
	
	EmitSoundOn("50cal.Fire", self);
}

