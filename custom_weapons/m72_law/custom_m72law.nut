/* 
 * M72 LAW rocket launcher script.
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
 */

viewmodel <- null 		// Viewmodel entity
currentPlayer <- null 	// The player using the weapon

rocketCount <- 1

hurtEnt <- null
hurtSurvivorEnt <- null
explosionEnt <- null
fireFrame <- 0
fireHoldCounter <- 0
infiniteAmmo <- false
deployReadyTimer <- 0
deployHoldFire <- false

DEPLOY_READY_TIME <- 1.3
FIRE_HOLD_TIME <- 0
FIRE_ANIM_FRAMES <- 15
FIRE_ANIM_RELEASE <- 0

weaponController <- null 

function OnPrecache(context)
{
	context.PrecacheModel("models/weapons/melee/m72law/rocket.mdl")
	context.PrecacheModel("models/weapons/melee/m72law/law_used.mdl")
	context.PrecacheScriptSound("GrenadeLauncher.Fire")
	context.PrecacheScriptSound("GrenadeLauncher.Explode")
	PrecacheEntityFromTable(ROCKET_ENTITY)
	PrecacheEntityFromTable(LAUNCHER_USED)
	PrecacheEntityFromTable(SMOKE_EXHAUST)
	
	local rocketScript = {}
	DoIncludeScript("prop_rocket", rocketScript)
	PrecacheEntityFromTable(rocketScript.PHYSEXPLOSION_ENTITY)
	PrecacheEntityFromTable(rocketScript.EXPLOSION_ENTITY)
	PrecacheEntityFromTable(rocketScript.ROCKET_FIREBALL)
}

// Called after the script has loaded.
function OnInitialize()
{
	printl("New custom LAW script on ent: " + self)
	
	self.PrecacheModel("models/weapons/melee/m72law/rocket.mdl")
	self.PrecacheModel("models/weapons/melee/m72law/law_used.mdl")
	self.PrecacheScriptSound("GrenadeLauncher.Fire")
	self.PrecacheScriptSound("GrenadeLauncher.Explode")
	PrecacheEntityFromTable(ROCKET_ENTITY)
	PrecacheEntityFromTable(LAUNCHER_USED)
	PrecacheEntityFromTable(SMOKE_EXHAUST)
	
	// Registers a function to run every frame.
	AddThinkToEnt(self, "Think")

}

// Called when a player swithces to the the weapon.
function OnEquipped(player, _viewmodel)
{
	viewmodel = _viewmodel
	currentPlayer = player
	fireHoldCounter = 0
	fireFrame = -1
	deployReadyTimer = DEPLOY_READY_TIME
}

// Called when a player switches away from the weapon.
function OnUnEquipped()
{
	currentPlayer = null
	viewmodel = null
	fireHoldCounter = 0
	fireFrame = -1
}

// Called when the player stats firing.
function OnStartFiring()
{
	local infAmmoCvar = Convars.GetFloat("sv_infinite_ammo")
	
	infiniteAmmo = (infAmmoCvar > 0)
	
	if(deployReadyTimer > 0)
	{
		deployHoldFire = true
	}
}

function Think()
{
	if((deployReadyTimer -= 0.1) <= 0)
	{
		deployReadyTimer = 0
	}

	if(viewmodel)
	{
		if(fireFrame > -1)
		{
			if(fireFrame == FIRE_ANIM_RELEASE)
			{
				FireRocket()
				fireFrame++
			}
			else if(fireFrame == FIRE_ANIM_FRAMES)
			{
				if(fireHoldCounter > 0)
				{
					fireFrame = 0
				}
				else
				{
					fireFrame = -1
				}
			}
			else
			{
				fireFrame++
			}
		}
	}
}

// Called every frame the player the player holds down the fire button.
function OnFireTick(playerButtonMask)
{	
	if(deployHoldFire) {return}

	if(fireHoldCounter++ == FIRE_HOLD_TIME)
	{
		if(fireFrame < 0)
		{
			fireFrame = FIRE_HOLD_TIME
		}
	}
}

// Called when the player ends firing.
function OnEndFiring()
{
	fireHoldCounter = 0
	deployHoldFire = false
}


function FireRocket()
{
	if(!infiniteAmmo)
	{
		if(rocketCount < 1)
		{
			return
		}
		rocketCount--
	}
	
	local exhaust = SpawnEntityOn(SMOKE_EXHAUST)
	DoEntFire("!self", "SetParent", "!activator", 0, viewmodel, exhaust)
	DoEntFire("!self", "SetParentAttachment", "attach_nozzle", 0.01, exhaust, exhaust)
	DoEntFire("!self", "Kill", "", 5, exhaust, exhaust)
	
	local keyvalues = clone ROCKET_ENTITY
	local playerDir = VectorFromQAngle(currentPlayer.EyeAngles())
	local rightDir = playerDir.Cross(Vector(0,0,1))
	rightDir = rightDir * (1 / rightDir.Length())
	local downDir = playerDir.Cross(rightDir)
	keyvalues.origin = currentPlayer.EyePosition() + playerDir * 24 + downDir * 2  + rightDir * 6
	keyvalues.angles = currentPlayer.EyeAngles() + QAngle(-1, 0, 0)
	local rocket = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
	weaponController.RegisterTrackedEntity(rocket, self)
	rocket.ValidateScriptScope()
	rocket.GetScriptScope().usingPlayer = currentPlayer

	EmitSoundOn("GrenadeLauncher.Fire", self)
	EmitSoundOnClient("GrenadeLauncher.Fire", currentPlayer)
	
	
	if(rocketCount < 1)
	{
		DoEntFire("!self", "CallScriptFunction", "DiscardLauncher", 1.3, self, self)
	}
}

function DiscardLauncher()
{
	if(currentPlayer)
	{
		LAUNCHER_USED.origin <- self.GetOrigin() + Vector(0, 0, 40) + VectorFromQAngle(currentPlayer.EyeAngles(), 16)
		LAUNCHER_USED.angles <- self.GetAngles() + QAngle(0, 90, 0)
		local usedLauncher = g_ModeScript.CreateSingleSimpleEntityFromTable(LAUNCHER_USED)
		DoEntFire("!self", "Kill", "", 20, usedLauncher, usedLauncher)
		currentPlayer.GiveItem("pistol")
	}
	DoEntFire("!self", "Kill", "", 0, self, self)
}

function SpawnEntityOn(keyValues)
{
	local spawnEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(keyValues)
	
	if(spawnEnt)
	{
		spawnEnt.SetOrigin(RotatePosition(self.GetOrigin(), self.GetAngles(), spawnEnt.GetOrigin()) + self.GetOrigin())
		spawnEnt.SetAngles(self.GetAngles())
		
		weaponController.RegisterTrackedEntity(spawnEnt, self)
	}
	
	return spawnEnt
}

// Converts a QAngle to a vector, with a optional length.
function VectorFromQAngle(angles, radius = 1.0)
{
	local function ToRad(angle)
	{
		return (angle * PI) / 180;
	}
   
	local yaw = ToRad(angles.Yaw());
	local pitch = ToRad(-angles.Pitch());
   
	local x = radius * cos(yaw) * cos(pitch);
	local y = radius * sin(yaw) * cos(pitch);
	local z = radius * sin(pitch);
   
	return Vector(x, y, z);
}

function Clamp(val, min, max)
{
	if(val > max)
	{
		return max
	}
	else if(val > min)
	{
		return val
	}

	return min
}

ROCKET_ENTITY <-
{
	classname = "prop_physics"
	targetname = "rocket"
	vscripts = "prop_rocket"
	model = "models/weapons/melee/m72law/rocket.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}

LAUNCHER_USED <-
{
	classname = "prop_physics"
	model = "models/weapons/melee/m72law/law_used.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	spawnflags = 4 // Debris
}

SMOKE_EXHAUST <-
{
	classname = "info_particle_system"
	angles = Vector(0, 0, 0)
	effect_name = "weapon_grenade_explosion"
	render_in_front = "0"
	start_active = "1"
	targetname = "smoke_exhaust"
	origin = Vector(0, 0, 0)
}
