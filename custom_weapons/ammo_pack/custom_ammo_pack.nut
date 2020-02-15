/* 
 * Ammo pack script.
 *
 * Copyright (c) 2017 Rectus
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
placing <- false



// Called after the script has loaded.
function OnInitialize()
{
	PrecacheEntityFromTable(AMMO_PILE)
	

	printl("New custom ammo pack script on ent: " + self)
	//AddThinkToEnt(this, "Think")
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
	StopSoundOn("Player.AmmoPackUse", currentPlayer)
	currentPlayer = null
	viewmodel = null
	placing = false
}


// Called when the player stats firing.
function OnStartFiring()
{
	if(!placing)
	{
		placing = true
		EmitSoundOn("Player.AmmoPackUse", currentPlayer)
		DoEntFire("!self", "CallScriptFunction", "DropAmmo", 0.6, self, self)
	}
}


function OnFireTick(mask)
{

}

// Called when the player ends firing.
function OnEndFiring()
{

}


function DropAmmo()
{
	if(!placing) {return}
	placing = false
	if(!currentPlayer) {return}

	local infAmmoCvar = Convars.GetFloat("sv_infinite_ammo")
	if(!infAmmoCvar)
	{
		infAmmoCvar = 0
	}
	StopSoundOn("Player.AmmoPackUse", currentPlayer)
	EmitSoundOnClient("Player.AwardUpgrade", currentPlayer) 
	
	AMMO_PILE.origin = currentPlayer.GetOrigin() + VectorFromQAngle(currentPlayer.GetAngles(), 16)
	AMMO_PILE.angles = currentPlayer.GetAngles()
	local pile = g_ModeScript.CreateSingleSimpleEntityFromTable(AMMO_PILE)
	
	if(!infAmmoCvar)
	{
		currentPlayer.GiveItem("pistol")
		self.Kill()
	}
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


AMMO_PILE <-
{
	classname = "weapon_ammo_spawn"
	targetname = "ammo"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	spawnflags = 2
}

