// Gun Nuts script
//
// Author: Rectus
// Copyright 2014

SPAWN_OFFSET <- Vector(0, 0, 24);


// Entity keyvalues for precaching the ammo models.
AmmoPickupPrecache <-
{
	classname	= "scripted_item_drop"
	model		= "models/props_gunnuts/ammo_pack.mdl"
}

AmmoBoxPrecache <-
{
	classname	= "prop_physics"
	model		= "models/props_gunnuts/ammo_box.mdl"
}

AmmoDeniedHint <-
{
	hint_name = "gunnuts_ammobox_denied"
	hint_caption = "You must have a primary weapon to pick up ammo", 
	hint_timeout = 3, 
	hint_icon_onscreen = "icon_no",
	hint_instance_type = 2,
	hint_color = "255 255 255"
}


AmmoUsageHint <-
{
	hint_name = "gunnuts_ammobox_usage"
	hint_caption = "Ammoboxes have limited capacity", 
	hint_timeout = 8, 
	hint_icon_onscreen = "icon_info",
	hint_instance_type = 2,
	hint_range = 300,
	hint_display_limit = 2,
	hint_color = "255 255 255"
}


AllowedItemSpawns <-
{
	weapon_first_aid_kit = true
	weapon_gascan = true
	weapon_propanetank = true
	weapon_oxygentank = true
	weapon_fireworkcrate = true
}

MutationOptions <-
{
	function AllowWeaponSpawn(classname)
	{		
		printl(classname)
		if(classname in g_ModeScript.AllowedItemSpawns)
		{
			return true;
		}
		return false;
	}
}

MutationState <-
{
	AmmoBoxHintShown = false
}


function Precache()
{
	printl("Precache");
	PrecacheEntityFromTable(AmmoPickupPrecache);
	PrecacheEntityFromTable(AmmoBoxPrecache);
}

function CalcTotalProbability(list)
{
	local totalProb = 0;
	foreach(item in list)
		totalProb += item.prob;
		
	return totalProb;
}

// Spawns a random item.
function SpawnRandomItem(list, location)
{
	// Make melee weapons and laser sights spawnable.
	if(!("weapon_melee" in g_ModeScript.AllowedItemSpawns))
	{
		g_ModeScript.AllowedItemSpawns.upgrade_item <- true;
		g_ModeScript.AllowedItemSpawns.weapon_melee <- true;
	}

	local spawnedItem = null;

	local probCount = RandomInt(1, CalcTotalProbability(list));
	
	foreach(item in list)
	{
		if((probCount -= item.prob) <= 0)
		{
			spawnedItem = SpawnSingleItem(item.ent, item.ammo, item.melee_type, location);
				
			break;
		}
	}
	
	return spawnedItem;
}


// Generates an entity table and spawns an item of the spaecified type.
function SpawnSingleItem(ent, ammo, melee_type, origin)
{
	entTable <- {}
	
	if(ent == null)
	{
		return;
	}
	else if(ent == "custom_ammo_pack" ) // Ammo pickup
		entTable <-
		{
			targetname	= "random_spawned_ammo"
			classname	= "prop_physics"
			model		= "models/props_gunnuts/ammo_box.mdl"
			glowstate	= "1"
			glowrange	= "256"
			spawnflags	= "41282"
			ammo		= ammo
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "0" 
			//vscripts	= "gunnuts_ammo_pack"
		}
	else if(ammo != null) // Gun
		entTable <-
		{
			targetname	= "random_spawned_item"
			classname	= ent
			ammo		= ammo
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), (RandomInt(0,1) * 180 - 90))
			solid		= "6" // Vphysics
		}
	else if(melee_type != null) // Melee weapon
	{
		entTable <-
		{
			targetname	= "random_spawned_nontrackable"
			classname	= ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), (RandomInt(0,1) * 180 - 90))
			solid		= "6" // Vphysics
			melee_weapon	= melee_type
			spawnflags	= "3"
		}
	}
	else if(ent == "upgrade_spawn") // Laser upgrade
	{
		entTable <-
		{
			targetname	= "random_spawned_nontrackable"
			classname	= ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "6" // Vphysics
			laser_sight = 1
			upgradepack_incendiary = 0
			upgradepack_explosive = 0
		}
	}
	else if((ent == "weapon_upgradepack_explosive") || (ent == "weapon_upgradepack_incendiary"))
	{
		entTable <-
		{
			targetname	= "random_spawned_nontrackable"
			classname	= ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "6" // Vphysics
		}
	}	
	else // Any other item
	{
		entTable <-
		{
			targetname	= "random_spawned_item"
			classname	= ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "6" // Vphysics
		}
	}
		
	local itemEntity = CreateSingleSimpleEntityFromTable(entTable);
	
	if(itemEntity)
	{
		if(entTable.targetname == "random_spawned_ammo")
		{
			itemEntity.SetHealth(ammo); // Stores the ammo amount in the entity health keyvalue.

			if(!SessionState.AmmoBoxHintShown)
				DisplayInstructorHint(AmmoUsageHint, itemEntity);
			SessionState.AmmoBoxHintShown <- true;
			
			return itemEntity;
		}
		else if(entTable.targetname == "random_spawned_item")
			return itemEntity;
	}
	return null;
}

// Spawns a small ammo pickup
function SpawnAmmoDrop(location)
{
	entTable <-
	{
		classname	= "scripted_item_drop"
		origin		= location
		angles		= Vector(0, RandomFloat(0, 360), 0)
		model		= "models/props_gunnuts/ammo_pack.mdl"
		vscripts	= "gunnuts_ammo_pickup"
	}
	
	local itemEntity = CreateSingleSimpleEntityFromTable(entTable);
	
}

// Creates and forcefully displays a hint. 
function DisplayInstructorHint(keyvalues, target = null, player = null)
{
	keyvalues.classname <- "env_instructor_hint";
	keyvalues.hint_auto_start <- 0;
	keyvalues.hint_allow_nodraw_target <- 1;

	if(!target)
	{
		if(Entities.FindByName(null, "static_hint_target") == null)
			SpawnEntityFromTable("info_target_instructor_hint", {targetname = "static_hint_target"});
	
		keyvalues.hint_target <- "static_hint_target";
		keyvalues.hint_static <- 1;
		keyvalues.hint_range <- 0;
	}
	else
	{
		keyvalues.hint_target <- target.GetName();
		keyvalues.hint_static <- 0;
	}
	DeepPrintTable(keyvalues);
	local hint = SpawnEntityFromTable("env_instructor_hint", keyvalues);
	printl(hint);
	
	if(player)
	{
		DoEntFire("!self", "ShowHint", "", 0, player, hint);
	}
	else
	{
		while(player = Entities.FindByClassname(player, "player"))
		{
			printl(player)
			DoEntFire("!self", "ShowHint", "", 0, player, hint);
		}
	}
	if(keyvalues.hint_timeout && keyvalues.hint_timeout != 0)
	{
		DoEntFire("!self", "Kill", "", keyvalues.hint_timeout, null, hint);
	}
	
	return hint;
}


function OnGameEvent_player_death(params)
{
	/*
	"userid"	"short"   	// user ID who died				
	"entityid"	"long"   	// entity ID who died, userid should be used first, to get the dead Player.  Otherwise, it is not a player, so use this.		
	"attacker"	"short"	 	// user ID who killed
	"attackername" "string" // What type of zombie, so we don't have zombie names
	"attackerentid" "long"	// if killer not a player, the entindex of who killed.  Again, use attacker first
	"weapon"	"string" 	// weapon name killer used 
	"headshot"	"bool"		// singals a headshot
	"attackerisbot" "bool"  // is the attacker a bot
	"victimname" "string"   // What type of zombie, so we don't have zombie names
	"victimisbot" "bool"    // is the victim a bot
	"abort" "bool"    // did the victim abort
	"type"		"long"		// damage type
	"victim_x"	"float"
	"victim_y"	"float"
	"victim_z"	"float"
	*/

	if("entityid" in params)
	{
		local entity = EntIndexToHScript(params.entityid);
		if(entity && entity.IsValid())
		{
			if(entity.GetClassname() == "infected")
			{
				//printl("Infected " + entity + " died.");
				SpawnRandomItem(SpawnListCommon, entity.GetOrigin() + SPAWN_OFFSET);
				
				if(RandomInt(0, 100) <= AMMO_PICKUP_CHANCE)
					SpawnAmmoDrop(entity.GetOrigin() + SPAWN_OFFSET);
			}
		}
	}
	else if("userid" in params)
	{
		local origin = Vector(params.victim_x, params.victim_y, params.victim_z);

		//printl("Special at " + origin + " died.");
		SpawnRandomItem(SpawnListSpecial, origin + SPAWN_OFFSET);
	}
}


function OnGameEvent_player_use(params)
{
	local item = null;
	local player = null;

	if(("targetid" in params) && (item = EntIndexToHScript(params.targetid))
		&& item.GetName().find("random_spawned_ammo")
		&& ("userid" in params) && (player = GetPlayerFromUserID(params.userid)))
	{
		local weaponName = GetPrimaryWeaponName(player);
		
		if(weaponName && weaponName in g_ModeScript.ClipSize)
		{
			player.GiveAmmo(g_ModeScript.ClipSize[weaponName]);
			EmitSoundOnClient("Player.PickupWeapon", player);
			item.SetHealth(item.GetHealth() - 1);
			DoEntFire("!self", "SetBodyGroup", "1", 0, null, item);
			
			if(item.GetHealth() <= 0)
				item.Kill();
		}
		else
		{
			DisplayInstructorHint(AmmoDeniedHint, item, player);
		}
	}
}

function GetPrimaryWeaponName(player)
{
	local invTable = {};
	GetInvTable(player, invTable);

	if(!("slot0" in invTable))
		return null;
		
	local weapon = invTable.slot0;
	
	if(weapon)
		return weapon.GetClassname();
		
	return null;
}