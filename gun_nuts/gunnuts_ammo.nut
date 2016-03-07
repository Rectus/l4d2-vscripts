// Gun Nuts mode script
//
// Author: Rectus
// Copyright 2014

AMMO_PICKUP_CHANCE <- 50;
BOT_AMMO_MULTIPLIER <- 2;

ClipSize <-
{
	weapon_rifle 			= 25,
	weapon_shotgun_spas 	= 5,
	weapon_sniper_military 	= 10,
	weapon_rifle_ak47 		= 20,
	weapon_autoshotgun 		= 5,
	weapon_rifle_desert 	= 30,
	weapon_hunting_rifle 	= 10,
	
	weapon_grenade_launcher	= 1,
	
	weapon_smg_silenced		= 25,
	weapon_smg				= 25,
	weapon_shotgun_chrome	= 5,
	weapon_pumpshotgun		= 5
}

AmmoPickupSize <-
{
	weapon_rifle			= 3,
	weapon_shotgun_spas 	= 1,
	weapon_sniper_military 	= 1,
	weapon_rifle_ak47 		= 2,
	weapon_autoshotgun 		= 1,
	weapon_rifle_desert 	= 3,
	weapon_hunting_rifle 	= 1,
	
	//weapon_grenade_launcher	= 1,
	
	weapon_smg_silenced		= 3,
	weapon_smg				= 3,
	weapon_shotgun_chrome	= 1,
	weapon_pumpshotgun		= 1
}

// ent: Classname of the item. The spawn list currently supports the entities specified below.
// prob: This is the probability for the item to spawn. It's relative to the other items.
// ammo: The ammo reserves primary weapons spawn with. Weapons spawn with double the value set. 
// 		 Set to null on other items.
// melee_type: Works the same way as on a weapon_melee_spawn. Set to null if not a melee weapon.
SpawnListCommon <-
[
	//Entity:						Probability:	Ammo:			Melee type:
	{ent = "weapon_rifle"			prob = 5,		ammo = 0,	melee_type = null	},
	{ent = "weapon_shotgun_spas"	prob = 5,		ammo = 0,	melee_type = null	},
	{ent = "weapon_sniper_military"	prob = 5,		ammo = 0,	melee_type = null	},
	{ent = "weapon_rifle_ak47"		prob = 5,		ammo = 0,	melee_type = null	},
	{ent = "weapon_autoshotgun"		prob = 5,		ammo = 0,	melee_type = null	},
	{ent = "weapon_rifle_desert"	prob = 5,		ammo = 0,	melee_type = null	},
	{ent = "weapon_hunting_rifle"	prob = 5,		ammo = 0,	melee_type = null	},
	
	{ent = "weapon_rifle_m60"		prob = 1,		ammo = null,	melee_type = null	},
	{ent = "weapon_grenade_launcher"	prob = 2,		ammo = 1,	melee_type = null	},
	
	{ent = "weapon_smg_silenced"	prob = 50,		ammo = 0,	melee_type = null	},
	{ent = "weapon_smg"				prob = 50,		ammo = 0,	melee_type = null	},
	{ent = "weapon_shotgun_chrome"	prob = 50,		ammo = 0,	melee_type = null	},
	{ent = "weapon_pumpshotgun"		prob = 50,		ammo = 0,	melee_type = null	},
	
	//{ent = "weapon_pistol_magnum"	prob = 2,		ammo = null,	melee_type = null	},
	//{ent = "weapon_pistol"			prob = 5,		ammo = null,	melee_type = null	},
	
	{ent = "weapon_adrenaline" 		prob = 20,		ammo = null,	melee_type = null	},	
	{ent = "weapon_pain_pills" 		prob = 30,		ammo = null,	melee_type = null	},
	{ent = "weapon_vomitjar" 		prob = 10,		ammo = null,	melee_type = null	},
	{ent = "weapon_molotov" 		prob = 20,		ammo = null,	melee_type = null	},
	{ent = "weapon_pipe_bomb" 		prob = 20,		ammo = null,	melee_type = null	},
	{ent = "weapon_first_aid_kit" 	prob = 5,		ammo = null,	melee_type = null	},
	{ent = "weapon_defibrillator" 	prob = 5,		ammo = null,	melee_type = null	},
	
	
	// Note: These items don't retain their entities when spawned, and cannot be tracked.
	{ent = "weapon_melee_spawn"		prob = 100,		ammo = null,	melee_type = "any"	},
	{ent = "upgrade_spawn" 			prob = 3,		ammo = null,	melee_type = null	}, // Laser sight
	{ent = "weapon_upgradepack_explosive" 		prob = 1,		ammo = null,	melee_type = null	},
	{ent = "weapon_upgradepack_incendiary" 		prob = 1,		ammo = null,	melee_type = null	},	
	
	{ent = "custom_ammo_pack" 		prob = 10,		ammo = 2,	melee_type = null	},
	{ent = null						prob = 3000,		ammo = 0,	melee_type = null	},
]

SpawnListSpecial <-
[
	//Entity:						Probability:	Ammo:			Melee type:
	{ent = "weapon_rifle"			prob = 10,		ammo = 0,	melee_type = null	},
	{ent = "weapon_shotgun_spas"	prob = 10,		ammo = 0,	melee_type = null	},
	{ent = "weapon_sniper_military"	prob = 10,		ammo = 0,	melee_type = null	},
	{ent = "weapon_rifle_ak47"		prob = 10,		ammo = 0,	melee_type = null	},
	{ent = "weapon_autoshotgun"		prob = 10,		ammo = 0,	melee_type = null	},
	{ent = "weapon_rifle_desert"	prob = 10,		ammo = 0,	melee_type = null	},
	{ent = "weapon_hunting_rifle"	prob = 10,		ammo = 0,	melee_type = null	},
	
	{ent = "weapon_rifle_m60"		prob = 2,		ammo = null,	melee_type = null	},
	{ent = "weapon_grenade_launcher"	prob = 5,		ammo = 1,	melee_type = null	},
	
	{ent = "weapon_smg_silenced"	prob = 20,		ammo = 0,	melee_type = null	},
	{ent = "weapon_smg"				prob = 20,		ammo = 0,	melee_type = null	},
	{ent = "weapon_shotgun_chrome"	prob = 20,		ammo = 0,	melee_type = null	},
	{ent = "weapon_pumpshotgun"		prob = 20,		ammo = 0,	melee_type = null	},
	
	//{ent = "weapon_pistol_magnum"	prob = 3,		ammo = null,	melee_type = null	},
	//{ent = "weapon_pistol"			prob = 5,		ammo = null,	melee_type = null	},
	
	{ent = "weapon_adrenaline" 		prob = 20,		ammo = null,	melee_type = null	},	
	{ent = "weapon_pain_pills" 		prob = 20,		ammo = null,	melee_type = null	},
	{ent = "weapon_vomitjar" 		prob = 10,		ammo = null,	melee_type = null	},
	{ent = "weapon_molotov" 		prob = 20,		ammo = null,	melee_type = null	},
	{ent = "weapon_pipe_bomb" 		prob = 20,		ammo = null,	melee_type = null	},
	{ent = "weapon_first_aid_kit" 	prob = 10,		ammo = null,	melee_type = null	},
	{ent = "weapon_defibrillator" 	prob = 10,		ammo = null,	melee_type = null	},
	
	
	// Note: These items don't retain their entities when spawned, and cannot be tracked.
	{ent = "weapon_melee_spawn"		prob = 20,		ammo = null,	melee_type = "any"	},
	{ent = "upgrade_spawn" 			prob = 5,		ammo = null,	melee_type = null	}, // Laser sight
	{ent = "weapon_upgradepack_explosive" 		prob = 3,		ammo = null,	melee_type = null	},
	{ent = "weapon_upgradepack_incendiary" 		prob = 3,		ammo = null,	melee_type = null	},	
	
	{ent = "custom_ammo_pack" 		prob = 10,		ammo = 2,	melee_type = null	},
	//{ent = null						prob = 20,		ammo = 0,	melee_type = null	},

]

// Include the actual code.
DoIncludeScript("gunnuts_base", this);