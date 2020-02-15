Msg("Plan B map 1 script initialized.\n");

IncludeScript("vscript_hint_recreate");

g_ModeScript.HowitzerShellsPicked <- {};
::BunkerHowitzerLoaded <- true;
::BunkerDoorDestroyed <- false;



g_ModeScript.PlanBState <-
{
	TransferShell = false,
	BunkerDoorDestroyed = false,
	Geiger =
	{
		x = 0,
		y = 0,
		z = 0,
		Yaw = 0,
		pitch = 0,
		Roll = 0
	},
	HasRunFinale = false,
	MedStation1Uses = 3,
	MedStation2Uses = 0,
	MedStation3Uses = 0,
	ElevatorUsed = false
}


ShellPickupHint <-
[
	{
		hint_name = "shell_pickup_hint"
		hint_caption = "Picked up shell", 
		hint_timeout = "3", 
		hint_static = "1",
		hint_icon_onscreen = "icon_info",
		hint_instance_type = "2",
		hint_range = "96" 
	}
]

ShellDeniedHint <-
[
	{
		hint_name = "shell_pickup_hint"
		hint_caption = "You are already carrying a shell", 
		hint_timeout = "3", 
		hint_static = "1",
		hint_icon_onscreen = "icon_info",
		hint_instance_type = "2",
		hint_range = "96" 
	}
]

BookPickupHint <-
[
	{
		hint_name = "book_pickup_hint"
		hint_caption = "Picked up codebook", 
		hint_timeout = "3", 
		hint_static = "1",
		hint_icon_onscreen = "icon_info",
		hint_instance_type = "2",
		hint_range = "96" 
	}
]

// Allows players to pick up howitzer shells and use them.
function OnGameEvent_player_use(params)
{
	if(("targetid" in params))
	{
		if((item <- EntIndexToHScript(params.targetid)))
		{
			if(item.GetName().find("howitzer_shell") == 0)
			{
				if(!(params.userid in g_ModeScript.HowitzerShellsPicked)
					|| !g_ModeScript.HowitzerShellsPicked[params.userid])
				{
					EmitSoundOnClient("Player.PickupWeapon", GetPlayerFromID(params.userid));
					item.Kill();
					g_ModeScript.HowitzerShellsPicked[params.userid] <- true;
					CreateHintOn(null, item.GetOrigin(), null, ShellPickupHint);
				}
				else
				{
					CreateHintOn(null, item.GetOrigin(), null, ShellDeniedHint);
				}
			}
			else if(item.GetName() == "howitzer_reload_button")
			{
				if((params.userid in g_ModeScript.HowitzerShellsPicked)
					&& g_ModeScript.HowitzerShellsPicked[params.userid]
					&& !::BunkerHowitzerLoaded)
				{
					::BunkerHowitzerLoaded <- true;
					g_ModeScript.HowitzerShellsPicked[params.userid] <- false;
					EntFire(item.GetName(), "Enable");
					EntFire("howitzer_reload_prop", "StartGlowing");
					EmitSoundOn("Strongman.PuckImpact", item);
				}
			}
			else if(item.GetName() == "codebook")
			{
				item.Kill();
				EntFire("bunker_door_codebook_found", "Trigger");
				EmitSoundOnClient("Player.PickupWeapon", GetPlayerFromID(params.userid));
				CreateHintOn(null, item.GetOrigin(), null, BookPickupHint);
			}
		}
	}
}

function OnGameEvent_player_death(params)
{
	if(("userid" in params) 
		&& (params.userid in g_ModeScript.HowitzerShellsPicked)
		&&  g_ModeScript.HowitzerShellsPicked[params.userid])
	{
		Entities.FindByName(null, "shell_spawn_death")
			.SetOrigin(Vector(params.victim_x, params.victim_y, params.victim_z));
		EntFire("shell_spawn_death", "ForceSpawn");
		EntFire("howitzer_shell", "Wake");
		g_ModeScript.HowitzerShellsPicked[params.userid] <- false;
		printl("Shell dropped by dead player at " + Vector(params.victim_x, params.victim_y, params.victim_z));
	}
}

function MapStateTransfer()
{
	printl("Saving campaign state.");
	
		
	foreach(id, hasShell in g_ModeScript.HowitzerShellsPicked)
	{
		if(hasShell)
		{
			g_ModeScript.PlanBState.TransferShell <- true;
			break;
		}
	}

	g_ModeScript.PlanBState.BunkerDoorDestroyed = ::BunkerDoorDestroyed;

	g_ModeScript.PlanBState.MedStation1Uses = Entities.FindByName(null, "med_station1_use").GetScriptScope().uses;
	
	SaveTable("PlanBState", g_ModeScript.PlanBState);
}

::MapStateTransfer <- MapStateTransfer;

function GetPlayerFromID(playerid)
{
	local player = null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(player.GetPlayerUserId() == playerid)
		{
			return player;
		}
	}
}