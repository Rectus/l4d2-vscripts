/* 
 * Bow script.
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
modelIndices <- []

MAX_ARROWS <- 20
arrowCount <- MAX_ARROWS

hurtEnt <- null
hurtSurvivorEnt <- null
explosionEnt <- null
viewmodelSkin <- 6
fireFrame <- 0
fireHoldCounter <- 0
infiniteAmmo <- false

FIRE_HOLD_TIME <- 2
FIRE_ANIM_FRAMES <- 14
FIRE_ANIM_RELEASE <- 2
FIRE_ANIM_SKIN_CYCLE <- 7

arrowColors <-
[
	"255 0 0",
	"0 127 255",
	"127 255 0",
	"255 216 51",
	"230 0 179",
	"0 255 255"
]

function OnPrecache(contextEnt)
{
	contextEnt.PrecacheModel("models/weapons/melee/bow/arrow.mdl")
	contextEnt.PrecacheModel("models/weapons/melee/v_bow1.mdl")
	contextEnt.PrecacheModel("models/weapons/melee/v_bow2.mdl")
	contextEnt.PrecacheModel("models/weapons/melee/v_bow3.mdl")
	contextEnt.PrecacheModel("models/weapons/melee/v_bow4.mdl")
	contextEnt.PrecacheModel("models/weapons/melee/v_bow5.mdl")
	contextEnt.PrecacheModel("models/weapons/melee/v_bow6.mdl")
	contextEnt.PrecacheScriptSound("weapons/bow/bowstring.wav")
	contextEnt.PrecacheScriptSound("weapons/bow/arrow_impact.wav")
	contextEnt.PrecacheScriptSound("BaseCombatCharacter.AmmoPickup")
	PrecacheEntityFromTable(ARROW_HIT_EFFECT)
	PrecacheEntityFromTable(ARROW_HIT_EFFECT_BLOOD)
}

// Called after the script has loaded.
function OnInitialize()
{
	printl("New custom bow script on ent: " + self)

	InitModels()
	
	// Registers a function to run every frame.
	AddThinkToEnt(self, "Think")

}


function InitModels()
{
	local mdl = g_ModeScript.CreateSingleSimpleEntityFromTable({classname = "prop_dynamic", model = "models/weapons/melee/v_bow.mdl"})
	modelIndices.append(NetProps.GetPropInt(mdl, "m_nModelIndex"))
	
	for(local i = 1; i <= 6; i++)
	{
		//self.PrecacheModel("models/weapons/melee/v_bow" + i + ".mdl")
		local mdl = g_ModeScript.CreateSingleSimpleEntityFromTable({classname = "prop_dynamic", model = "models/weapons/melee/v_bow" + i + ".mdl"})
		modelIndices.append(NetProps.GetPropInt(mdl, "m_nModelIndex"))
		mdl.Kill()
	}
}


// Called when a player swithces to the the weapon.
function OnEquipped(player, _viewmodel)
{
	viewmodel = _viewmodel
	currentPlayer = player
	NetProps.SetPropInt(viewmodel, "m_nModelIndex", modelIndices[Clamp(arrowCount, 0, 6)])
	//viewmodelSkin = Clamp(arrowCount, 0, 6)
	fireHoldCounter = 0
	fireFrame = -1
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
	if(infAmmoCvar)
	{
		infiniteAmmo = (infAmmoCvar > 0)
	}
}

// A think function to decrement the delay timer.
function Think()
{
	if(viewmodel)
	{
		if(fireFrame > -1)
		{
			if(fireFrame == FIRE_ANIM_RELEASE)
			{
				ReleaseArrow()
				fireFrame++
			}
			else if(fireFrame == FIRE_ANIM_SKIN_CYCLE)
			{
				NetProps.SetPropInt(viewmodel, "m_nModelIndex", modelIndices[Clamp(arrowCount, 0, 6)])
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
		else
		{
			/*if(viewmodelSkin < 1)
			{
				viewmodelSkin = Clamp(arrowCount, 0, 1)
			}*/
		}
	
		//DoEntFire("!self", "Skin", viewmodelSkin.tostring() 0, self, viewmodel)
		//NetProps.SetPropInt(viewmodel, "m_nSkin", viewmodelSkin)
	}
	return 0.1
}

// Called every frame the player the player holds down the fire button.
function OnFireTick(playerButtonMask)
{	
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
}


function ReleaseArrow()
{
	if(!infiniteAmmo)
	{
		if(arrowCount < 1)
		{
			return
		}
		arrowCount--
	}
	
	local keyvalues = clone ARROW_ENTITY
	
	local eyeVec = VectorFromQAngle(currentPlayer.EyeAngles(), 1)
	local spawnPoint = currentPlayer.EyePosition() + eyeVec * 24 + eyeVec.Cross(Vector(0, 0, 1)) * 6 + Vector(0, 0, -8)
	keyvalues.origin = spawnPoint
	keyvalues.angles = currentPlayer.EyeAngles() + QAngle(-1, 1, 0)
	
	//keyvalues.origin = currentPlayer.EyePosition() + VectorFromQAngle(currentPlayer.EyeAngles(), 16) + Vector(0, 0, -8)
	//keyvalues.angles = currentPlayer.EyeAngles() + QAngle(-1, 0, 0)
	local arrow = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
	NetProps.SetPropInt(arrow, "m_CollisionGroup", 8)
	arrow.ValidateScriptScope()
	arrow.GetScriptScope().bowScript <- this
	arrow.GetScriptScope().usingPlayer <- currentPlayer
	arrow.GetScriptScope().SetColor(arrowColors[RandomInt(0, arrowColors.len() - 1)])
	if(!arrow.GetScriptScope().TraceDirectHit(false))
	{
		arrow.ApplyAbsVelocityImpulse(VectorFromQAngle(currentPlayer.EyeAngles() + QAngle(-1, 0, 0), 5000))
		arrow.ApplyLocalAngularVelocityImpulse(VectorFromQAngle(QAngle(0, 0, 0), 5000))
	}
	EmitSoundOn("weapons/bow/bowstring.wav", currentPlayer)
}


function GiveArrow()
{
	if(arrowCount < MAX_ARROWS)
	{
		arrowCount++

		NetProps.SetPropInt(viewmodel, "m_nModelIndex", modelIndices[Clamp(arrowCount, 0, 6)])
		return true
	}
	false
}


function OnAmmoRefilled()
{
	if(arrowCount < MAX_ARROWS)
	{
		arrowCount = MAX_ARROWS
		EmitSoundOnClient("BaseCombatCharacter.AmmoPickup", currentPlayer)
		NetProps.SetPropInt(viewmodel, "m_nModelIndex", modelIndices[Clamp(arrowCount, 0, 6)])
		return true
	}
	return false
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

ARROW_ENTITY <-
{
	classname = "prop_physics"
	targetname = "arrow"
	vscripts = "prop_arrow"
	//vscripts = "prop_rocket"
	model = "models/weapons/melee/bow/arrow.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	//solid = 0
	//glowstate = 3
	//glowrange = 128
	//glowcolor = Vector(255, 0, 0)
}

ARROW_STATIC <-
{
	classname = "prop_dynamic_override"
	targetname = "arrow"
	vscripts = "prop_arrow_static"
	model = "models/weapons/melee/bow/arrow.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	solid = 0
	glowstate = 3
	glowrange = 128
	glowcolor = Vector(128, 128, 255)
}


ARROW_HIT_EFFECT <-
{
	classname = "info_particle_system"
	effect_name = "impact_concrete_cheap"
	render_in_front = "0"
	start_active = "1"
	targetname = "impact"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}

ARROW_HIT_EFFECT_BLOOD <-
{
	classname = "info_particle_system"
	effect_name = "blood_impact_infected_01"
	render_in_front = "0"
	start_active = "1"
	targetname = "impact"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}
