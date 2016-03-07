// random_item_spawner.nut
// Spawns random items on predefined spawnpoints. 
//
// By: Rectus
// Copyright 2013

// Usage:
// The script can either use manually placed spawnpoints, or the locations of already exsisting spawns.
// For the former, any entites named "randomspawner_item_spawn" will be used, these can either be places with the entity placer in game, or the level editor for new maps. 
// If no manually placed spawnpoints are found exsisting spawns will be used. 
// 
// The script needs to be initialized before it can be used with:
// InitializeRandomItemSpawns(itemList = null, flags = 0)
// The optional arguments consist of:
// itemList: Use a custom item list of the same format as the one below.
// flags: 
// 	RANDOM_USEPARTICLES: Spawns a fireworks particle effect where an item spawns.
//	RANDOM_ALLOWMULTIPLEITEMS: Can spawn multiple items on the same spawnpoint during the same run of
//		 SpawnRandomItems().
//
//	Items are spawned with: SpawnRandomItems(amount)
//	Where amount is the number of items spawned.


// Flags
RANDOM_USEPARTICLES <- 1;
RANDOM_ALLOWMULTIPLEITEMS <- 2;


// ent: Classname of the item. The spawn list currently supports the entities specified below.
// prob: This is the probability for the item to spawn. It's relative to the other items.
// ammo: The ammo reserves primary weapons spawn with. Weapons spawn with double the value set. 
// 		 Set to null on other items.
// melee_type: Works the same way as on a weapon_melee_spawn. Set to null if not a melee weapon.
DefaultItemSpawnList <-
[
	//Entity:						Probability:	Ammo:			Melee type:
	{ent = "weapon_rifle"			prob = 10,		ammo = 50,	melee_type = null	},
	{ent = "weapon_shotgun_spas"	prob = 10,		ammo = 10,	melee_type = null	},
	{ent = "weapon_sniper_military"	prob = 10,		ammo = 15,	melee_type = null	},
	{ent = "weapon_rifle_ak47"		prob = 10,		ammo = 40,	melee_type = null	},
	{ent = "weapon_autoshotgun"		prob = 10,		ammo = 10,	melee_type = null	},
	{ent = "weapon_rifle_desert"	prob = 10,		ammo = 60,	melee_type = null	},
	{ent = "weapon_hunting_rifle"	prob = 15,		ammo = 15,	melee_type = null	},
	
	{ent = "weapon_rifle_m60"		prob = 2,		ammo = null,	melee_type = null	},
	{ent = "weapon_grenade_launcher"	prob = 2,		ammo = 5,	melee_type = null	},
	
	{ent = "weapon_smg_silenced"	prob = 20,		ammo = 50,	melee_type = null	},
	{ent = "weapon_smg"				prob = 20,		ammo = 50,	melee_type = null	},
	{ent = "weapon_shotgun_chrome"	prob = 20,		ammo = 10,	melee_type = null	},
	{ent = "weapon_pumpshotgun"		prob = 20,		ammo = 10,	melee_type = null	},
	
	{ent = "weapon_pistol_magnum"	prob = 5,		ammo = null,	melee_type = null	},
	{ent = "weapon_pistol"			prob = 10,		ammo = null,	melee_type = null	},
	
	{ent = "weapon_adrenaline" 		prob = 10,		ammo = null,	melee_type = null	},	
	{ent = "weapon_pain_pills" 		prob = 20,		ammo = null,	melee_type = null	},
	{ent = "weapon_vomitjar" 		prob = 3,		ammo = null,	melee_type = null	},
	{ent = "weapon_molotov" 		prob = 10,		ammo = null,	melee_type = null	},
	{ent = "weapon_pipe_bomb" 		prob = 10,		ammo = null,	melee_type = null	},
	{ent = "weapon_first_aid_kit" 	prob = 1,		ammo = null,	melee_type = null	},
	
	
	// Note: These items don't retain their entities when spawned, and cannot be tracked.
	{ent = "weapon_melee_spawn"		prob = 10,		ammo = null,	melee_type = "any"	},
	{ent = "upgrade_spawn" 			prob = 3,		ammo = null,	melee_type = null	}, // Laser sight
	{ent = "weapon_upgradepack_explosive" 		prob = 5,		ammo = null,	melee_type = null	},
	{ent = "weapon_upgradepack_incendiary" 		prob = 7,		ammo = null,	melee_type = null	},	
	
	{ent = "custom_ammo_pack" 		prob = 40,		ammo = 2,	melee_type = null	},

]

// Initializes everything that's needed. Has to be called before any othe functions are used.
function InitializeRandomItemSpawns(itemList = null, flags = 0)
{

	if(itemList)
		ItemSpawnList <- itemList;
	else
		ItemSpawnList <- DefaultItemSpawnList;


	SessionState.RandomItemOptions <-
	{
		TotalProbability = 0
		TotalSpawns = 0
		ItemSpawnPoints = []
		UseParticleEffects = (flags & RANDOM_USEPARTICLES)
		AllowMultipleItemsOnPoint = (flags & RANDOM_ALLOWMULTIPLEITEMS)
	}
	FindItemSpawnPoints();
	CalcTotalProbability();
}

function FindItemSpawnPoints()
{
	
	local mapSpawnPoint = null;
	while(mapSpawnPoint = Entities.FindByName(mapSpawnPoint, "randomspawner_item_spawn"))
	{
		SessionState.RandomItemOptions.ItemSpawnPoints.append(mapSpawnPoint.GetOrigin());
		SessionState.RandomItemOptions.TotalSpawns++
	}
	
	// Use exsisting spawns if 0 points found.
	if(SessionState.RandomItemOptions.TotalSpawns <= 0)
	{
		while(mapSpawnPoint = Entities.FindByClassname(mapSpawnPoint, "weapon_*"))
		{
			SessionState.RandomItemOptions.ItemSpawnPoints.append(mapSpawnPoint.GetOrigin() 
				+ Vector(0,0,8));
			SessionState.RandomItemOptions.TotalSpawns++;
		}	
	}
	
	if(SessionState.RandomItemOptions.TotalSpawns <= 0)
		printl("Random item spawner: Error! No item spawns found!");
	else
		printl("Random item spawner: Found " + SessionState.RandomItemOptions.TotalSpawns 
		+ " item spawns.");
}


function CalcTotalProbability()
{
	local totalProb = 0;
	foreach(item in ItemSpawnList)
		totalProb += item.prob;
		
	SessionState.RandomItemOptions.TotalProbability = totalProb;
}

// Spawns the specified number of items at random spawnpoints.
function SpawnRandomItems(amount)
{
	local spawnedItems = [];
	local spawnSet = SessionState.RandomItemOptions.ItemSpawnPoints;

	for(local i = 0; i < amount; i++)
	{
		local probCount = RandomInt(1, SessionState.RandomItemOptions.TotalProbability);
		if(spawnSet.len() < 1)
		{
			printl("Random item spawner: Error! Ran out of spawns!");
			return spawnedItems;
		}
		local spawnPoint = spawnSet[RandomInt(0, spawnSet.len() -1)];
		
		if(!SessionState.RandomItemOptions.AllowMultipleItemsOnPoint)
			spawnSet.remove(spawnSet.find(spawnPoint))
		
		foreach(item in ItemSpawnList)
		{
			if((probCount -= item.prob) <= 0)
			{
				if(entity <- SpawnSingleItem(item.ent, item.ammo, item.melee_type, spawnPoint))
					spawnedItems.push(entity);
					
				break;
			}
		}
	}
	
	return spawnedItems;
}


// Generates an entity table and spawns an item of the spaecified type.
function SpawnSingleItem(ent, ammo, melee_type, origin)
{
	entTable <- {}
	
	if(ent == "custom_ammo_pack" ) // Ammo pickup
		entTable <-
		{
			targetname	= "random_spawned_ammo"
			classname	= "prop_physics"
			model		= "models/props/gunhunt/pickup_ammobox.mdl"
			glowstate	= "1"
			glowrange	= "256"
			spawnflags	= "41282"
			ammo		= ammo
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "0" 
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
		entTable <-
		{
			targetname	= "random_spawned_item"
			classname	= ent
			origin		= origin
			angles		= Vector(0, RandomFloat(0, 360), 0)
			solid		= "6" // Vphysics
		}
		
	
	local itemEntity = CreateSingleSimpleEntityFromTable(entTable);
	
	if(itemEntity)
	{
		if(SessionState.RandomItemOptions.UseParticleEffects)
			CreateParticleSystemAt(itemEntity, Vector(0,0,-8), "mini_fireworks");
		
		if(entTable.targetname == "random_spawned_ammo")
		{
			itemEntity.SetHealth(ammo); // Stores the ammo amount in the entity health keyvalue.
			return itemEntity;
		}
		
		if(entTable.targetname == "random_spawned_item")
			return itemEntity;
	}
	return null;
}
