/* 
 * Custom wepon controller script. 
 * 
 * Tracks melee weapon entities and allows attaching scipts to them.
 * You shouldn't need to modify this script directly.
 *
 * Copyright (c) 2016-2018 Rectus
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
trackedEntities <- {}
MAX_REPLACE_PRECENTAGE <- 50

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
	DoEntFire("!self", "CallScriptFunction", "Think", 0.03, self, self)
	g_WeaponController.Think()
}

controlEntity.GetScriptScope().FixedThink <- function()
{
	g_WeaponController.FixedThink()
}

AddThinkToEnt(controlEntity, "FixedThink")
DoEntFire("!self", "CallScriptFunction", "Think", 2, controlEntity, controlEntity)
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
		
		// Allows precaching of assets as early as possible
		if("OnPrecache" in testScope)
		{
			testScope.OnPrecache(controlEntity)
		}
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
	
	local totalPercent = 0
	local factor = 1
	
	foreach(_, percentage in replaceTable) {totalPercent += percentage}
	
	// If the total percentage of weapons to replace is higher than the max, scale each percentage down to fit.
	if(totalPercent > MAX_REPLACE_PRECENTAGE)
	{
		factor = MAX_REPLACE_PRECENTAGE / totalPercent
	}
	
	foreach(weaponName, percentage in replaceTable)
	{
		local keyvalues =
		{
			classname = "weapon_melee_spawn"
			angles = Vector(0, 0, 0)
			melee_weapon = weaponName
			spawnflags = "3"
			count = "1"
			solid = "6"
			origin = Vector(0, 0, 0)
		}
		local numToConvert = (meleeSpawns.len() * percentage * factor / 100).tointeger();
		
		if(meleeSpawns.len() > numToConvert + 4)
		{
			numToConvert += RandomInt(0, 2)
		}
		
		while(numToConvert-- > 0)
		{
			local oldSpawn = meleeSpawns.remove(RandomInt(0, meleeSpawns.len() - 1))
			
			keyvalues.angles = oldSpawn.GetAngles()
			keyvalues.origin = oldSpawn.GetOrigin()
			oldSpawn.Kill()		
			g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
			printl("Replaced spawn at " + keyvalues.origin)
		}
	}
}

// Registers an entity to the watchdog system. If the owner weapon no longer exists, the entity is killed.
function RegisterTrackedEntity(ent, owner)
{
	trackedEntities[ent] <- owner
}

function UnregisterTrackedEntity(ent, owner)
{
	if(ent in trackedEntities)
	{
		delete trackedEntities[ent]
	}
}

// Removes invalid weapons and kills any of their tracked entities.
function RunEntityWatchdog()
{
	foreach(weapon, script in weaponList)
	{
		if(weapon && !weapon.IsValid())
		{
			if(weaponDebug)
			{
				printl("Weapon controller: Watchdog found invalid weapon: " + weapon)
			}
		
			delete weaponList[weapon]
		}
	}
	
	foreach(ent, owner in trackedEntities)
	{
		if(!(owner in weaponList))
		{
			if(ent && ent.IsValid())
			{
				if(weaponDebug)
				{
					printl("Weapon controller: Watchdog deleting orphaned entity: " + ent)
				}
			
				ent.Kill()
			}
			delete trackedEntities[ent]
		}
	}
}

// Game event callback to detect new weapons.
function OnGameEvent_item_pickup(params)
{
	RunEntityWatchdog()
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
					weaponList[ent] <- ent.GetScriptScope().weakref()
					ent.GetScriptScope().weaponController <- this.weakref()
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


// Check for ammo pile use
function OnGameEvent_player_use(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if(!player)
	{
		return
	}
	
	local target = EntIndexToHScript(params.targetid)

	if(!target || target.GetClassname() != "weapon_ammo_spawn")
	{
		return
	}
	
	OnGameEvent_ammo_pickup(params)
}

function OnGameEvent_ammo_pickup(params)
{
	local player = GetPlayerFromUserID(params.userid)
	if(!player)
	{
		return
	}
	
	local invTable = {}
	GetInvTable(player, invTable)
	if("slot1" in invTable)
	{
		if(invTable.slot1 && invTable.slot1.GetScriptScope() && ("OnAmmoRefilled" in invTable.slot1.GetScriptScope()))
		{
			invTable.slot1.GetScriptScope().OnAmmoRefilled()
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
		if(player.GetActiveWeapon() in weaponList && weaponList[player.GetActiveWeapon()] != null)
		{
			if(!(player in activeWeapons) && !(player in grabbedPlayers))
			{
				activeWeapons[player] <- player.GetActiveWeapon()
				weaponList[activeWeapons[player]].OnEquipped(player, GetViewModel(player))
			}
			// If the player switches between tracked weapons.
			else if((player in activeWeapons) && (activeWeapons[player] != player.GetActiveWeapon())  && !(player in grabbedPlayers) && (activeWeapons[player] in weaponList))
			{
				if(("currentPlayer" in weaponList[activeWeapons[player]]) && 
				weaponList[activeWeapons[player]].currentPlayer == player)
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
				if(activeWeapons[player] in weaponList && weaponList[activeWeapons[player]] != null)
				{
					weaponList[activeWeapons[player]].OnUnEquipped()
				}
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
			if(!(ent in firingStates) || firingStates[ent] == false)
			{
				firingStates[ent] <- true
				weaponList[ent].OnStartFiring()
			}
		}
		else
		{		
			if(!(ent in firingStates) || firingStates[ent] == true)
			{
				firingStates[ent] <- false
				weaponList[ent].OnEndFiring()
			}
		}

	}
}


// Thinks at a a fixed 0.1s interval.
function FixedThink()
{
	foreach(user, ent in activeWeapons)
	{
		if(!user || !user.IsValid() || !ent || !ent.IsValid())
		{
			delete activeWeapons[user]
			continue
		}
		
		if((ent in firingStates) && firingStates[ent] == true)
		{
			if(weaponDebug)
			{	
				local weaponOrigin = ent.GetOrigin() + Vector(0, 0, 48)
				local endPoint = weaponOrigin + VectorFromQAngle(ent.GetAngles(), 32)
				DebugDrawLine(weaponOrigin, endPoint, 255, 0, 0, false, 0.11)
			}
			local mask = user.GetButtonMask()
			weaponList[ent].OnFireTick(mask)
		}
		else
		{
			if(weaponDebug)
			{	
				local weaponOrigin = ent.GetOrigin() + Vector(0, 0, 48)
				local endPoint = weaponOrigin + VectorFromQAngle(ent.GetAngles(), 32)
				DebugDrawLine(weaponOrigin, endPoint, 0, 255, 0, false, 0.11)
			}
		}
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