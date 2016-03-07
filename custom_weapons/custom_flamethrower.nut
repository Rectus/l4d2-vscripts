/* 
 * Flamethrower weapon entity script.
 * 
 *
 * Copyright (c) 2016 Rectus
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


FUEL_RATE <- 0.3 // Fuel consumtion rate in units per frame.
FIRE_ANIMATION_FRAMES <- 10 // Number of think frames in the firing animation, set to half the animtion as a compromise.
MAX_FLAME_EXTENT <- 200.0 // How far the flames can project.
FUEL_LEFT_HINT <- 20 // Fuel level to throw the low fuel hint at.

viewmodel <- null // Viewmodel entity
currentPlayer <- null // The player using the weapon
fuel <- 100.0
fuelHintShown <- false
firing <- false // True while the weapon is firing
activeFiring <- false // True while the player holds the fire button
newPickup <- true 
animationFramesLeft <- 0
infinteFuel <- false

// Called after the script has loaded.
function OnInitialize()
{
	self.PrecacheScriptSound("ambient/atmosphere/firewerks_stage_pyro_01.wav")
	self.PrecacheScriptSound("c1m1.Fireloop03")
	self.PrecacheScriptSound("Molotov.IdleLoop")
	self.PrecacheModel("models/weapons/melee/w_flamethrower_debris.mdl")
	self.PrecacheScriptSound("PropaneTank.Burst")

	// Dynamic entities
	flame <- null
	fireball <- SpawnEntityOn(flamethrower_fireball)
	firestream <- SpawnEntityOn(flamethrower_firestream)	
	hurt1 <- SpawnEntityOn(flamethrower_hurt_sphere)
	hurt2 <- SpawnEntityOn(flamethrower_hurt_sphere)
	sound <- null

	printl("New flamethrower on ent: " + self)
}

// Called when the player switches to the weapon.
function OnEquipped(player, _viewmodel)
{
	viewmodel = _viewmodel
	currentPlayer = player
	
	if(viewmodel && viewmodel.IsValid() && !flame)
	{
		flame = SpawnEntityOn(flamethrower_flame)
		DoEntFire("!self", "SetParent", "!activator", 0, viewmodel, flame)
		DoEntFire("!self", "SetParentAttachment", "attach_nozzle", 0.01, flame, flame)
		EmitSoundOn("Molotov.IdleLoop", flame)
	}
	
	if(newPickup)
	{
		DoEntFire("!self", "SpeakResponseConcept", "PlayerLaugh", 0, currentPlayer, currentPlayer)
		newPickup = false
	}
	
	local infAmmoCvar = Convars.GetFloat("sv_infinite_ammo")
	if(infAmmoCvar)
	{
		infinteFuel = (infAmmoCvar > 0)
	}
}

// Called when the player switches away from the weapon.
function OnUnEquipped()
{
	EndedFiring()
	StopSoundOn("Molotov.IdleLoop", flame)
	DoEntFire("!self", "Kill", "", 0, flame, flame)
	flame = null
	currentPlayer = null
	viewmodel = null
}

// Called when the fire button is pressed.
function OnStartFiring()
{
	activeFiring = true

	if(!firing && fuel > 0 && currentPlayer)
	{
		firing = true
		animationFramesLeft = FIRE_ANIMATION_FRAMES
		DoEntFire("!self", "Start", "", 0, self, fireball)
		DoEntFire("!self", "Start", "", 0, self, firestream)
		EmitSoundOn("PropaneTank.Burst", currentPlayer)
		EmitSoundOn("c1m1.Fireloop03", currentPlayer)
	}
}

// Called every frame.
function OnFireTick(playerButtonMask)
{
	if(!firing || (playerButtonMask & DirectorScript.IN_ATTACK2))
	{
		return
	}

	if(currentPlayer)
	{
		local nozzlePos = currentPlayer.EyePosition() + RotatePosition(currentPlayer.EyePosition(), currentPlayer.EyeAngles(), Vector(50, -5, -13))
		
		
		local flameDistFraction = GetFlameExtent(currentPlayer.EyePosition())
		
		fireball.SetOrigin(nozzlePos + VectorFromQAngle(currentPlayer.EyeAngles(), 8 * flameDistFraction + 8))
		fireball.SetAngles(currentPlayer.EyeAngles())
		
		firestream.SetOrigin(nozzlePos + VectorFromQAngle(currentPlayer.EyeAngles(), 50 * flameDistFraction + 16))
		firestream.SetAngles(currentPlayer.EyeAngles())
		
		hurt1.SetOrigin(currentPlayer.EyePosition() + VectorFromQAngle(currentPlayer.EyeAngles(), 130 * flameDistFraction + 36))
		hurt1.__KeyValueFromInt("DamageRadius", 60 * flameDistFraction + 5)
		
		hurt2.SetOrigin(currentPlayer.EyePosition() + VectorFromQAngle(currentPlayer.EyeAngles(), 70 * flameDistFraction + 20))
		hurt2.__KeyValueFromInt("DamageRadius", 45 * flameDistFraction + 5)
		
		if(g_WeaponController.weaponDebug)
		{
			DebugDrawCircle(nozzlePos, Vector(0, 0, 255), 200, 2, false, 0.11)
			DebugDrawCircle(hurt1.GetOrigin(), Vector(255, 128, 0), 200, 45 * flameDistFraction + 5, false, 0.11)
			DebugDrawCircle(hurt2.GetOrigin(), Vector(255, 128, 0), 200, 30 * flameDistFraction + 5, false, 0.11)
		}

		DoEntFire("!self", "Hurt", "", 0, currentPlayer, hurt1)
		DoEntFire("!self", "Hurt", "", 0, currentPlayer, hurt2)
	}
	
	if(!infinteFuel)
	{
		fuel -= FUEL_RATE
	}
	
	if(fuel <= 0)
	{
		EndedFiring()
		DoEntFire("!self", "Stop", "", 0, self, flame)
		OnKilled()
			
		flamethrower_empty.origin <- currentPlayer.GetOrigin() + Vector(0, 0, 4)
		flamethrower_empty.angles <- currentPlayer.GetAngles() + QAngle(-90, 180, 0)
		local emptyFT = g_ModeScript.CreateSingleSimpleEntityFromTable(flamethrower_empty)
		flamethrower_refill.nozzle = emptyFT.GetName()
		flamethrower_refill.origin = self.GetOrigin()
		local nozzle = g_ModeScript.CreateSingleSimpleEntityFromTable(flamethrower_refill)
		DoEntFire("!self", "Activate", "", 0.1, nozzle, nozzle)
		nozzle.GetScriptScope().SetProp(emptyFT)
		
		currentPlayer.GiveItem("pistol")
		DoEntFire("!self", "Kill", "", 0, self, self)
	}
	else 
	{
		if(fuel < FUEL_LEFT_HINT && !fuelHintShown)
		{
			flamethrower_hint.hint_target = fireball.GetName()
			local hint = SpawnEntityOn(flamethrower_hint)
			DoEntFire("!self", "ShowHint", "!activator", 0.01, currentPlayer, hint)
			DoEntFire("!self", "kill", "", 5.00, hint, hint)
			fuelHintShown = true
		}
		
		if(--animationFramesLeft <= 0)
		{
			animationFramesLeft = FIRE_ANIMATION_FRAMES
			if(!activeFiring)
			{
				EndedFiring()
			}
		}
	}
}

// Calculates how far to project the flames.
function GetFlameExtent(origin)
{
	local traceAngles =
	[
		QAngle(0, 0, 0)
		QAngle(10, 0, 0)
		QAngle(-5, 0, 0)
		QAngle(0, -10, 0)
		QAngle(0, 10, 0)
	]
	local longestTrace = -1.0
	
	foreach(angles in traceAngles)
	{
		local traceParams =
		{
			start = origin
			end = origin + VectorFromQAngle(angles + currentPlayer.EyeAngles(), MAX_FLAME_EXTENT)
			ignore = currentPlayer
		}
		if(TraceLine(traceParams))
		{
			local traceEndPoint = origin + VectorFromQAngle(angles + currentPlayer.EyeAngles(), MAX_FLAME_EXTENT * traceParams.fraction)
			if(g_WeaponController.weaponDebug) {DebugDrawLine(origin, traceEndPoint, 255, 0, 0, false, 0.11)}
			
			if(MAX_FLAME_EXTENT * traceParams.fraction > longestTrace)
			{
				longestTrace = MAX_FLAME_EXTENT * traceParams.fraction
			}
		}
	}
	
	if(longestTrace < 0)
	{
		return 1
	}
	return longestTrace / MAX_FLAME_EXTENT
}

// Called when the fire button is released.
function OnEndFiring()
{
	activeFiring = false
}

// Called when firing cycle ends and the fire button isn't held in.
function EndedFiring()
{
	if(firing)
	{
		DoEntFire("!self", "Stop", "", 0, self, fireball)
		DoEntFire("!self", "Stop", "", 0, self, firestream)
		
		StopSoundOn("c1m1.Fireloop03", currentPlayer)
		
		firing = false
	}
}

// Unfortuantely there doesn't seem to be any way of detecting the entity being killed, 
// so these will leak if the entiy is directly killed from outside sources.
function OnKilled()
{
	DoEntFire("!self", "Kill", "", 0, self, fireball)
	DoEntFire("!self", "Kill", "", 0, self, firestream)
	DoEntFire("!self", "Kill", "", 0, self, hurt1)
	DoEntFire("!self", "Kill", "", 0, self, hurt2)
	DoEntFire("!self", "Kill", "", 0, flame, flame)
}

function SpawnEntityOn(keyValues)
{
	local spawnEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(keyValues)
	spawnEnt.SetOrigin(RotatePosition(self.GetOrigin(), self.GetAngles(), spawnEnt.GetOrigin()) + self.GetOrigin())
	spawnEnt.SetAngles(self.GetAngles())
	
	return spawnEnt
}

/*
 * Keyvalues for dynamically spawned entities.
 */
flamethrower_flame <-
{
	classname = "info_particle_system"
	angles = Vector( 30, 0, 0 )
	effect_name = "weapon_molotov_fp"
	render_in_front = "0"
	start_active = "1"
	targetname = "flamethrower_fire"
	origin = Vector(0, -39, 45.7)
}

flamethrower_firestream <-
{
	classname = "info_particle_system"
	angles = Vector( 0, 0, 0 )
	effect_name = "fire_jet_01"
	render_in_front = "0"
	start_active = "0"
	targetname = "flamethrower_fire"
	origin = Vector( 50, 1, 44.25 )
}

flamethrower_fireball <-
{
	classname = "info_particle_system"
	angles = Vector( 110, 0, 0 )
	effect_name = "fire_small_03"
	render_in_front = "0"
	start_active = "0"
	targetname = "flamethrower_fire"
	origin = Vector( 80, 1, 44.25 )
}

flamethrower_hurt_sphere <-
{
	classname = "point_hurt"
	Damage = "20"
	DamageType = "8"
	origin = Vector(0, 0, 0)
	targetname = "flamethrower_hurt"
	DamageRadius = "72"
	DamageDelay = "1"
}

flamethrower_empty <-
{
	classname = "prop_dynamic_override"
	targetname = "flamethrower_empty"
	model = "models/weapons/melee/w_flamethrower_debris.mdl"
	origin = Vector( 0, 0, 48 )
	solid = 0
	glowstate = 3
	glowrange = 128
	glowcolor = Vector(255, 0, 0)
}

flamethrower_refill <-
{
	classname = "point_prop_use_target"
	targetname = "flamethrower_refill"
	vscripts = "flamethrower_refill"
	nozzle = ""
	spawnflags = 1
	origin = Vector(0, 0, 0)
}

flamethrower_hint <- 
{
	classname = "env_instructor_hint"
	hint_name = "flamethrower_hint"
	hint_caption = "Flamethrower low on fuel!"
	hint_auto_start = 0
	hint_target = ""
	hint_timeout = 5
	hint_static = 1
	hint_forcecaption = 1
	hint_icon_onscreen = "icon_alert_red"
	hint_instance_type = 2
	hint_color = "255 255 255"
}