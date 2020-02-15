// Gun Hunt mutation base script
// By: Rectus

IncludeScript("random_item_spawner", g_ModeScript);

local ITEM_SPAWN_FRACTION = 8;
local DEBUG = true;

MutationOptions <-
{
	ActiveChallenge = 1 
	
	DefaultItems =
	[
		"weapon_pistol",
		"weapon_pistol",
		"first_aid_kit"
	]

	// Set characters up with default items
	function GetDefaultItem( idx )
	{
		if ( idx < DefaultItems.len() )
		{
			return DefaultItems[idx];
		}
		return 0;
	}
}

MutationState <-
{
	NumSpawnsAtOnce = 0
	NumInitialSpawns = 0
	SpawnedItems = [] // Items that will be removed when new ones spawn
	SpawnsDeleted = false
	AmmoBoxHintShown = false
}

GunhuntAmmoDeniedHint <-
[
	{
		hint_name = "random_ammobox_denied"
		hint_caption = "You must have a primary weapon equipped to pick up ammo", 
		hint_static = "1", 
		hint_timeout = "3", 
		hint_icon_onscreen = "icon_no",
		hint_instance_type = "2",
		hint_range = "64" 
	}
]

GunhuntAmmoUsageHint <-
[
	{
		hint_name = "random_ammobox_usage"
		hint_caption = "Ammoboxes have limited uses", 
		hint_timeout = "6", 
		hint_static = "1",
		hint_icon_onscreen = "icon_info",
		hint_instance_type = "2",
		hint_range = "64" 
	}
]

GunhuntItemSpawnList <-
[
	//Entity:						Probability:	Ammo:			Melee type:
	{ent = "weapon_rifle"			prob = 10,		ammo = 50,	melee_type = null	},
	{ent = "weapon_shotgun_spas"	prob = 10,		ammo = 10,	melee_type = null	},
	{ent = "weapon_sniper_military"	prob = 10,		ammo = 15,	melee_type = null	},
	{ent = "weapon_rifle_ak47"		prob = 10,		ammo = 40,	melee_type = null	},
	{ent = "weapon_autoshotgun"		prob = 10,		ammo = 10,	melee_type = null	},
	{ent = "weapon_rifle_desert"	prob = 10,		ammo = 60,	melee_type = null	},
	{ent = "weapon_hunting_rifle"	prob = 15,		ammo = 15,	melee_type = null	},
	
	{ent = "weapon_rifle_m60"		prob = 5,		ammo = null,	melee_type = null	},
	{ent = "weapon_grenade_launcher"	prob = 5,		ammo = 5,	melee_type = null	},
	
	{ent = "weapon_smg_silenced"	prob = 20,		ammo = 50,	melee_type = null	},
	{ent = "weapon_smg"				prob = 20,		ammo = 50,	melee_type = null	},
	{ent = "weapon_shotgun_chrome"	prob = 20,		ammo = 10,	melee_type = null	},
	{ent = "weapon_pumpshotgun"		prob = 20,		ammo = 10,	melee_type = null	},
	
	{ent = "weapon_pistol_magnum"	prob = 5,		ammo = null,	melee_type = null	},
	//{ent = "weapon_pistol"			prob = 10,		ammo = null,	melee_type = null	},
	
	{ent = "weapon_adrenaline" 		prob = 10,		ammo = null,	melee_type = null	},
	{ent = "weapon_melee_spawn"		prob = 10,		ammo = null,	melee_type = "any"	},	
	{ent = "weapon_pain_pills" 		prob = 20,		ammo = null,	melee_type = null	},
	{ent = "weapon_vomitjar" 		prob = 3,		ammo = null,	melee_type = null	},
	{ent = "weapon_molotov" 		prob = 10,		ammo = null,	melee_type = null	},
	{ent = "weapon_pipe_bomb" 		prob = 10,		ammo = null,	melee_type = null	},
	{ent = "weapon_first_aid_kit" 	prob = 3,		ammo = null,	melee_type = null	},
	{ent = "upgrade_spawn" 			prob = 3,		ammo = null,	melee_type = null	},
	{ent = "weapon_upgradepack_explosive" 		prob = 5,		ammo = null,	melee_type = null	},
	{ent = "weapon_upgradepack_incendiary" 		prob = 7,		ammo = null,	melee_type = null	},
	
	{ent = "custom_ammo_pack" 		prob = 75,		ammo = 3,	melee_type = null	},

]


function DeleteItemSpawns()
{
	if(!SessionState.SpawnsDeleted)
	{
		local mapSpawnPoint = null;
		while(mapSpawnPoint = Entities.FindByClassname(mapSpawnPoint, "weapon_*"))
			EntFire(mapSpawnPoint.GetName(), "Kill");
		
		SessionState.SpawnsDeleted <- true;
	}
}

function DeleteOldItems()
{
	local count = 0;
	foreach(item in SessionState.SpawnedItems)
	{
		if(item)
		{
			CreateParticleSystemAt(item, Vector(0,0,0), "small_smoke");
			EntFire(item.GetName(), "Kill");
			count++;
		}
	}
	SessionState.SpawnedItems.clear();
	if(DEBUG)
		printl("Removed " + count + " old items.");
}


function OnGameplayStart()
{
	InitializeRandomItemSpawns(GunhuntItemSpawnList, (RANDOM_USEPARTICLES | RANDOM_ALLOWMULTIPLEITEMS));

	if("MapSpawnCount" in g_MapScript)
		SessionState.NumSpawnsAtOnce = g_MapScript.MapSpawnCount;

	else
		SessionState.NumSpawnsAtOnce = abs(SessionState.RandomItemOptions.TotalSpawns / ITEM_SPAWN_FRACTION);
		
	SessionState.NumInitialSpawns = SessionState.NumSpawnsAtOnce * 2;

	DeleteItemSpawns();
	
}

function OnGameEvent_round_end(params)
{
	GunHuntHUD.Fields.timer.flags = GunHuntHUD.Fields.timer.flags & ~HUD_FLAG_NOTVISIBLE
	HUDManageTimers(1, TIMER_COUNTDOWN, 30);
	HUDManageTimers(1, TIMER_STOP, 0);
}


function OnGameEvent_survival_round_start(params)
{
	DeleteItemSpawns();
	HUDManageTimers(1, TIMER_COUNTDOWN, 30);
	SessionState.SpawnedItems.extend(SpawnRandomItems(SessionState.NumInitialSpawns));
	ScriptedMode_AddSlowPoll(TimerPoll);

}

function OnGameEvent_round_start(params)
{
	SessionState.SpawnsDeleted <- false;
}

/*function OnGameEvent_weapon_drop(params)
{
	DeepPrintTable(params);
	if(("propid" in params))
	{
		if(item <- EntIndexToHScript(params.propid)
			&& (item.GetName().find("gunhunt_spawned_item") != null))
		{
			SessionState.SpawnedItems[item] <- 1	
			if(DEBUG)
				printl("Dropped " + item);
		}
	}
}*/

function OnGameEvent_player_use(params)
{
	DeleteItemSpawns();
	if(("targetid" in params))
	{
		if((item <- EntIndexToHScript(params.targetid))
			&& ( idx <- SessionState.SpawnedItems.find(item)) != null)
		{
			if(item.GetName().find("random_spawned_ammo"))
			{
				if(GiveAmmoToPlayer(params.userid, 1))
					if(item.GetHealth() < 1)
						EntFire(item.GetName(), "Kill");
					else
					{
						if(!SessionState.AmmoBoxHintShown)
						{
							CreateHintOn(null, item.GetOrigin(), null, GunhuntAmmoUsageHint);
							SessionState.AmmoBoxHintShown <- true;
						}
						item.SetHealth(item.GetHealth() - 1);
						return;
					}
				else
				{
					CreateHintOn(null, item.GetOrigin(), null, GunhuntAmmoDeniedHint)
					return; // Leave the ammo if the player can't pick it up.
				}
			}
			SessionState.SpawnedItems.remove(idx);
			if(DEBUG)
				printl("Picked up " + item);
		}
	}
}

// Gives a player ammo based on the spawn list
function GiveAmmoToPlayer(playerid, amount)
{
	local ammoGiven = false;
	local player = null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(player.IsSurvivor() && (player.GetPlayerUserId() == playerid))
		{
			if(DEBUG)
				printl("Gave ammo for " + player + ", weapon: " + player.GetActiveWeapon())
			
			foreach(item in GunhuntItemSpawnList)
			{
				if((player.GetActiveWeapon().GetClassname() == item.ent) && (item.ammo != null))
				{
					EmitSoundOnClient("BaseCombatCharacter.AmmoPickup", player);
					player.GiveAmmo(amount * item.ammo);
					ammoGiven = true;
					break;
				}
			}
		}
		else if(player.IsSurvivor() && IsPlayerABot(player))
			player.GiveAmmo(25); // Gives all bots ammo too
	}
	return ammoGiven;
}

function TimerPoll()
{
	if(HUDReadTimer(1) <= 0)
	{
		g_ModeScript.DeleteOldItems();
		g_ModeScript.SessionState.SpawnedItems.extend(g_ModeScript.SpawnRandomItems(SessionState.NumSpawnsAtOnce));
		HUDManageTimers(1, TIMER_COUNTDOWN, 30);
	}
}

function SetupModeHUD( )
{
	GunHuntHUD <-
	{
		Fields =
		{
			timer = 
			{
				slot = HUD_FAR_RIGHT ,
				staticstring = "New items in: ",
				name = "timer",
				flags = HUD_FLAG_COUNTDOWN_WARN | HUD_FLAG_BEEP | HUD_FLAG_ALIGN_CENTER,
				special = HUD_SPECIAL_TIMER1
			}
		}
	}
	HUDPlace( HUD_FAR_RIGHT, 0.60, 0.15, 0.18, 0.05 )
	HUDSetLayout(GunHuntHUD);
}

// Prints out useful information when you say debug_print
function InterceptChat(str, SrcEnt)
{
	if(DEBUG && (str.find("debug_print") != null))
	{
		printl("DirectorOptions:");
		DeepPrintTable(DirectorOptions);
		printl("SessionOptions:");
		DeepPrintTable(SessionOptions);
		printl("SessionState:");
		DeepPrintTable(SessionState);
		printl("ItemSpawnList:");
		DeepPrintTable(ItemSpawnList);
		printl("SpawnedItems:");
		DeepPrintTable(SessionState.SpawnedItems);
	}
}
