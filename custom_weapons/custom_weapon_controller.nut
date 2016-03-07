/* 
 * Custom wepon controller script. 
 * 
 * Tracks melee weapon entities and allows attaching scipts to them.
 * You shouldn't need to modify this script directly.
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

printl("Custom weapon controller by Rectus")
 
 
// Add a global reference to the controller.
if(!("g_WeaponController" in getroottable()))
{
	::g_WeaponController <- this 
}

weaponDebug <- false
replaceTable <- {}
weaponTypes <- {}
weaponList <- {}
viewmodelList <- {}
activeWeapons <- {}
grabbedPlayers <- {}
firingStates <- {}
weaponsReplaced <- false

// Entity to get Think function from.
controlEntity <- g_ModeScript.CreateSingleSimpleEntityFromTable
(
	{
		targetname = "custom_weapon_controller"
		classname = "logic_script"
	}
)

controlEntity.ValidateScriptScope()
controlEntity.GetScriptScope().Think <- function()
{
	g_WeaponController.Think()
}
AddThinkToEnt(controlEntity, "Think")
DoEntFire("!self", "RunScriptCode", "g_WeaponController.ReplaceMeleeSpawns()", 1.0, controlEntity, controlEntity)

// Adds a weapon type to track.
function AddCustomWeapon(viewModel, scriptName)
{
	local testScope = {}
	DoIncludeScript(scriptName, testScope)
	
	if("OnInitialize" in testScope)
	{
		weaponTypes[viewModel] <- scriptName
		printl("Registered custom weapon script " + scriptName)
		return true
	}
	
	return false
}

// Replaces a certain number of melee weapon spawns with the custom weapon (in addition to normal spawns).
function SetReplacePercentage(weaponName, percentage)
{
	replaceTable[weaponName] <- percentage
}

// Run by the script to do the spawn replacement.
function ReplaceMeleeSpawns()
{
	if(weaponsReplaced)
	{
		return
	}
	weaponsReplaced = true

	printl("Replacing melee weapon spawns with custom weapons")
	local meleeSpawns = []
	local spawn = null
	
	while(spawn = Entities.FindByClassname(spawn, "weapon_melee_spawn"))
	{
		meleeSpawns.append(spawn)
	}
	
	foreach(weaponName, percentage in replaceTable)
	{
		local flamethrowerSpawn =
		{
			classname = "weapon_melee_spawn"
			angles = Vector(0, 0, 0)
			melee_weapon = weaponName
			spawnflags = "3"
			count = "1"
			solid = "6"
			origin = Vector(0, 0, 0)
		}
		local numToConvert = (meleeSpawns.len() * percentage / 100).tointeger();
		
		if(meleeSpawns.len() > numToConvert + 4)
		{
			numToConvert += RandomInt(0, 2)
		}
		
		while(numToConvert-- > 0)
		{
			local oldSpawn = meleeSpawns.remove(RandomInt(0, meleeSpawns.len() - 1))
			
			flamethrowerSpawn.angles = oldSpawn.GetAngles()
			flamethrowerSpawn.origin = oldSpawn.GetOrigin()
			oldSpawn.Kill()		
			g_ModeScript.CreateSingleSimpleEntityFromTable(flamethrowerSpawn)
			printl("Replaced spawn at " + flamethrowerSpawn.origin)
		}
	}
}


// Game event callback to detect new weapons.
function OnGameEvent_item_pickup(params)
{
	OnPlayerFreed(params.userid)

	foreach(viewModel, scriptName in weaponTypes)
	{
		local ent = null
		
		while(ent = Entities.FindByModel(ent, viewModel))
		{
			if(ent.GetClassname() == "weapon_melee" && !(ent in weaponList))
			{
				ent.ValidateScriptScope()
				if(DoIncludeScript(scriptName, ent.GetScriptScope()))
				{
					weaponList[ent] <- ent.GetScriptScope()
					ent.GetScriptScope().OnInitialize()
				}
				else
				{
					// Removes broken weapon types from the being loaded in the future.
					delete weaponTypes[viewModel]
				}
			}
			else if(ent.GetClassname() == "predicted_viewmodel" && !(ent in viewmodelList))
			{
				viewmodelList[ent] <- null
			}
		}
	}
}

// Game event callbacks to detect the player being unable to fire.
function OnGameEvent_tongue_grab(params)
{
	OnPlayerGrabbed(params.victim)	
}
function OnGameEvent_choke_start(params)
{
	OnPlayerGrabbed(params.victim)	
}
function OnGameEvent_lunge_pounce(params)
{
	OnPlayerGrabbed(params.victim)	
}
function OnGameEvent_charger_carry_start(params)
{
	OnPlayerGrabbed(params.victim)	
}
function OnGameEvent_charger_pummel_start(params)
{
	OnPlayerGrabbed(params.victim)	
}
function OnGameEvent_jockey_ride(params)
{
	OnPlayerGrabbed(params.victim)	
}

function OnPlayerGrabbed(playerIdx)
{
	local player = GetPlayerFromUserID(playerIdx)
	if(player && (player in activeWeapons))
	{
		grabbedPlayers[player] <- null
		weaponList[activeWeapons[player]].OnUnEquipped()
		delete activeWeapons[player]
	}
}


// Game event callbacks to detect the player being able to fire again.
function OnGameEvent_tongue_release(params)
{
	if("victim" in params)
	{
		OnPlayerFreed(params.victim)
	}
}
function OnGameEvent_choke_end(params)
{
	if("victim" in params)
	{
		OnPlayerFreed(params.victim)
	}
}
function OnGameEvent_pounce_end(params)
{
	if("victim" in params)
	{
		OnPlayerFreed(params.victim)
	}
}
function OnGameEvent_pounce_stopped(params)
{
	if("victim" in params)
	{
		OnPlayerFreed(params.victim)
	}
}
function OnGameEvent_charger_carry_end(params)
{
	if("victim" in params)
	{
		OnPlayerFreed(params.victim)
	}
}
function OnGameEvent_charger_pummel_end(params)
{
	if("victim" in params)
	{
		OnPlayerFreed(params.victim)
	}
}
function OnGameEvent_jockey_ride_end(params)
{
	if("victim" in params)
	{
		OnPlayerFreed(params.victim)
	}
}

function OnPlayerFreed(playerIdx)
{
	local player = GetPlayerFromUserID(playerIdx)
	if(player && (player in grabbedPlayers))
	{
		delete grabbedPlayers[player]
	}
}

// Registers the event callback functions.
__CollectEventCallbacks(g_WeaponController, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener)

// Retruns a tracked viewmodel.
function GetViewModel(player)
{
	if(!player ||!player.IsValid())
	{
		return null
	}

	foreach(model, _ in viewmodelList)
	{
		if(!model || !model.IsValid())
		{
			delete viewmodelList[model]
			continue
		}
	
		if(model.GetMoveParent() == player)
		{
			return model
		}
	}
	return null
}

// Think function for tracking state changes.
function Think()
{
	local player = null
	
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(player.GetActiveWeapon() in weaponList)
		{
			if(!(player in activeWeapons) && !(player in grabbedPlayers))
			{
				activeWeapons[player] <- player.GetActiveWeapon()
				weaponList[activeWeapons[player]].OnEquipped(player, GetViewModel(player))
			}
			// If the player switches between tracked weapons.
			else if((player in activeWeapons) && (activeWeapons[player] != player.GetActiveWeapon())  && !(player in grabbedPlayers))
			{
				if(weaponList[activeWeapons[player]].currentPlayer == player)
				{
					firingStates[activeWeapons[player]] <- false
					weaponList[activeWeapons[player]].OnUnEquipped()
				}
				activeWeapons[player] <- player.GetActiveWeapon()
				weaponList[activeWeapons[player]].OnEquipped(player, GetViewModel(player))
			}
		}
		else if(player in activeWeapons)
		{
			if(activeWeapons[player])
			{
				firingStates[activeWeapons[player]] <- false
				weaponList[activeWeapons[player]].OnUnEquipped()
			}
			delete activeWeapons[player]
		}
	}
	
	foreach(user, ent in activeWeapons)
	{
		if(!user || !user.IsValid() || !ent || !ent.IsValid())
		{
			delete activeWeapons[user]
			continue
		}
	
		local mask = user.GetButtonMask()
		if(mask & DirectorScript.IN_ATTACK && !user.IsIncapacitated() && !user.IsHangingFromLedge())
		{
			if(weaponDebug)
			{	
				local weaponOrigin = ent.GetOrigin() + Vector(0, 0, 48)
				local endPoint = weaponOrigin + VectorFromQAngle(ent.GetAngles(), 32)
				DebugDrawLine(weaponOrigin, endPoint, 255, 0, 0, false, 0.11)
			}
			if(!(ent in firingStates) || firingStates[ent] == false)
			{
				firingStates[ent] <- true
				weaponList[ent].OnStartFiring()
			}
		}
		else
		{
			if(weaponDebug)
			{	
				local weaponOrigin = ent.GetOrigin() + Vector(0, 0, 48)
				local endPoint = weaponOrigin + VectorFromQAngle(ent.GetAngles(), 32)
				DebugDrawLine(weaponOrigin, endPoint, 0, 255, 0, false, 0.11)
			}
			
			if(!(ent in firingStates) || firingStates[ent] == true)
			{
				firingStates[ent] <- false
				weaponList[ent].OnEndFiring()
			}
		}
		
		if((ent in firingStates) && firingStates[ent] == true)
		{
			weaponList[ent].OnFireTick(mask)
		}
	}
}