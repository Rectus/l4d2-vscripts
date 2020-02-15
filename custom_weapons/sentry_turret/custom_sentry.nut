/* 
 * Sentry turret placing script.
 *
 * Copyright (c) 2019 Rectus
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
 

// End position, height offset pairs for tracing a valid turret placement space. 
SPACE_TRACES <-{}
SPACE_TRACES[Vector(0, 0, 18)] <- 4
SPACE_TRACES[Vector(-11, 0, 4)] <- 4
SPACE_TRACES[Vector(5.5, 9.5, 4)] <- 4
SPACE_TRACES[Vector(5.5, -9.5, 4)] <- 4

TRACE_MAX_DISTANCE <- 128
PLACE_HOLD_DELAY <- 0.2
PLACE_OFFSET <- Vector(0, 0, 12)

viewmodel <- null 		// Viewmodel entity
currentPlayer <- null 	// The player using the weapon
fireStartTime <- 0
placing <- false
placePoint <- null
ammoFrac <- 1.0
ghostProp <- null



function OnPrecache(contextEnt)
{
	contextEnt.PrecacheModel("models/weapons/melee/sentry/sentry_base.mdl")
	contextEnt.PrecacheModel("models/weapons/melee/sentry/sentry_top.mdl")
	PrecacheEntityFromTable(SENTRY_PROP)
	PrecacheEntityFromTable(SENTRY_GUN)
	PrecacheEntityFromTable(SENTRY_GHOST)
}


// Called after the script has loaded.
function OnInitialize()
{
	printl("New custom sentry script on ent: " + self)
}


// Called when a player swithces to the the weapon.
function OnEquipped(player, _viewmodel)
{
	viewmodel = _viewmodel
	currentPlayer = player

}


// Called when a player switches away from the weapon.
function OnUnEquipped()
{
	currentPlayer = null
	viewmodel = null
	placing = false
	
	if(ghostProp) {ghostProp.Kill()}
	ghostProp = null
}


// Called when the player stats firing.
function OnStartFiring()
{
	fireStartTime = Time()
	
	EmitSoundOn("Player.WeaponSelected", self)
}


function OnFireTick(playerButtonMask)
{

	if(!placing)
	{
		if(Time() >= fireStartTime + PLACE_HOLD_DELAY)
		{
			placing = true
			NetProps.SetPropInt(viewmodel, "m_nSequence", 4)
			ghostProp = g_ModeScript.CreateSingleSimpleEntityFromTable(SENTRY_GHOST)
			ghostProp.SetAngles(viewmodel.GetAngles())
			ghostProp.SetOrigin(viewmodel.GetOrigin())
			DoEntFire("!self", "SetParent", "!activator", 0.0, viewmodel, ghostProp)
			
			TracePlacePoint()
		}
	}
	else
	{
		TracePlacePoint()
	}
}

// Called when the player ends firing.
function OnEndFiring()
{
	if(ghostProp) {ghostProp.Kill()}
	ghostProp = null

	if(placing)
	{
		NetProps.SetPropInt(viewmodel, "m_nSequence", 1)
		if(placePoint)
		{
			PlaceSentry()
		}
		placing = false
		placePoint = null
	}
}


function PlaceSentry()
{
	if(!placing) {return}
	placing = false
	if(!currentPlayer) {return}

	local infAmmoCvar = Convars.GetFloat("sv_infinite_ammo") > 0
	
	EmitSoundOnClient("Player.PickupWeapon", currentPlayer) 
	
	SENTRY_PROP.origin = placePoint + PLACE_OFFSET
	SENTRY_PROP.angles = currentPlayer.GetAngles()
	SENTRY_GUN.origin = placePoint + PLACE_OFFSET
	SENTRY_GUN.angles = currentPlayer.GetAngles()
	local sentryBase = g_ModeScript.CreateSingleSimpleEntityFromTable(SENTRY_PROP)
	sentryBase.SetHealth(200)
	
	SENTRY_GUN.parentname = sentryBase.GetName()
	local sentry = g_ModeScript.CreateSingleSimpleEntityFromTable(SENTRY_GUN)
	
	if(sentry.ValidateScriptScope())
	{
		sentry.GetScriptScope().Initialize(currentPlayer, weaponController, ammoFrac)
	}
	
	
	if(!infAmmoCvar)
	{
		currentPlayer.GiveItem("pistol")
		self.Kill()
	}
}


function TracePlacePoint()
{
	local traceStartPoint = currentPlayer.EyePosition()	
	local traceEndpoint = currentPlayer.EyePosition() + currentPlayer.EyeAngles().Forward() * TRACE_MAX_DISTANCE
		
	local traceTable =
	{
		start = currentPlayer.EyePosition()
		end = traceEndpoint
		mask = DirectorScript.TRACE_MASK_PLAYER_SOLID
		ignore = currentPlayer
	}
	TraceLine(traceTable)
	if(traceTable.hit && CheckValidSpace(traceTable.pos))
	{
		placePoint = traceTable.pos
	}
	else
	{
		placePoint = null		
	}
	
	if(ghostProp && ghostProp.IsValid())
	{
		if(placePoint)
		{
			DoEntFire("!self", "color", "30 120 70", 0.0, ghostProp, ghostProp)
		}
		else
		{
			DoEntFire("!self", "color", "60 10 10", 0.0, ghostProp, ghostProp)
		}
		ghostProp.SetOrigin(Vector(TRACE_MAX_DISTANCE * traceTable.fraction , 0, 0))
		ghostProp.SetAngles(RotateOrientation(viewmodel.GetAngles(), QAngle(-currentPlayer.EyeAngles().Pitch(), 0, 0)))
	}
}


function CheckValidSpace(origin)
{
	foreach(endPos, ZOffset in SPACE_TRACES)
	{
		local traceTable =
		{
			start = origin + Vector(0, 0, ZOffset)
			end = origin + endPos
			mask = DirectorScript.TRACE_MASK_PLAYER_SOLID
			//ignore = currentPlayer
		}
		TraceLine(traceTable)
		if(traceTable.hit || "startsolid" in traceTable)
		{
			return false
		}
	}
	return true
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


SENTRY_GHOST <-
{
	classname = "prop_dynamic"
	targetname = "sentry_ghost"
	solid = 0
	rendermode = 5
	renderamt = 96
	color = Vector(150, 200, 150)
	fademindist = "160"
	fademaxdist = "256"
	fadescale = "0"
	model = "models/weapons/melee/sentry/sentry_ghost.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}


SENTRY_PROP <-
{
	classname = "prop_physics"
	targetname = "sentry"
	//solid = 0
	//glowstate = 1
	//glowrange = 96
	//glowcolor = Vector(255, 255, 255)
	_health = 200
	fademindist = "-1"
	fadescale = "0"
	model = "models/weapons/melee/sentry/sentry_base.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}

SENTRY_GUN <-
{
	classname = "prop_dynamic"
	targetname = "sentry_gun"
	vscripts = "sentry_turret"
	parentname = ""
	fademindist = "-1"
	fadescale = "0"
	//solid = 0
	//glowstate = 3
	//glowrange = 128
	//glowcolor = Vector(255, 0, 0)
	model = "models/weapons/melee/sentry/sentry_top.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
}

