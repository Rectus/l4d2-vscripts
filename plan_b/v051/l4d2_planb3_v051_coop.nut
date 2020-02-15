Msg("Plan B map 3 script initialized.\n");

IncludeScript("vscript_hint_recreate");

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

function g_ModeScript::CanPickupObject(object)
{
	if(object.GetName() == "geiger_counter"
		|| object.GetName() == "fire_extinguisher")
		return true;
		
	return false;
}

function MapStateRestore()
{
	printl("Restoring campaign state.");
	
	RestoreTable("PlanBState", g_ModeScript.PlanBState);

	g_ModeScript.DeepPrintTable(g_ModeScript.PlanBState);
	
	if(g_ModeScript.PlanBState.BunkerDoorDestroyed)
	{
		EntFire("bunker_door_damage_relay", "Trigger");	
	}

	local geigerCounter = Entities.FindByName(null, "geiger_counter");
	if(geigerCounter != null)
	{
		geigerCounter.SetOrigin(Vector(	g_ModeScript.PlanBState.Geiger.x,
										g_ModeScript.PlanBState.Geiger.y,
										g_ModeScript.PlanBState.Geiger.z));
		geigerCounter.SetAngles(QAngle(	g_ModeScript.PlanBState.Geiger.pitch,
										g_ModeScript.PlanBState.Geiger.Yaw,
										g_ModeScript.PlanBState.Geiger.Roll));
		printl("Geiger counter at " + geigerCounter.GetOrigin() + " restored.");
	}
	
	if(g_ModeScript.PlanBState.HasRunFinale)
	{
		printl("Finale start shortcut activated.");
		EntFire("generator_button_relay", "Disable");
		EntFire("generator_panel_enable", "Enable");
		EntFire("generator_button_relay_shortcut", "Enable");
		EntFire("light_emerg_relay", "SetValueTest", 1);
		EntFire("pump_lever_button", "Press");
		EntFire("generator_fuelvalve_button", "Press");
		
	}
	else
	{
		printl("Finale run first time.");
		g_ModeScript.PlanBState.HasRunFinale <- true;
	}
	
	Entities.FindByName(null, "med_station2_use").GetScriptScope().SetUses(g_ModeScript.PlanBState.MedStation2Uses);
	Entities.FindByName(null, "med_station3_use").GetScriptScope().SetUses(g_ModeScript.PlanBState.MedStation3Uses);
	
	if(g_ModeScript.PlanBState.ElevatorUsed)
	{
		EntFire("elevator_stuck_relay", "Trigger");
	}
	
	SaveTable("PlanBState", g_ModeScript.PlanBState);
}

::MapStateRestore <- MapStateRestore;

LastCanDOpts <-
{
	MobRechargeRate = 4.0
	
	MobSpawnMinTime = 2
	MobSpawnMaxTime = 5
}


function AddTableToTable( dest, src )
{
	foreach( key, val in src )
	{
		dest[key] <- val
	}
}

NumCansNeeded <- 8
GasCansPoured <- 0

function GasCanPoured()
{
    GasCansPoured++
    Msg("Poured: " + GasCansPoured + "\n")   
	Director.ResetMobTimer();

    if (GasCansPoured >= NumCansNeeded)
    {
        Msg("Got enough cans: " + NumCansNeeded + "\n") 
        EntFire( "apc3_escape_ready", "trigger" )
		EntFire( "director", "EndCustomScriptedStage" )
    }
	else if(GasCansPoured >= (NumCansNeeded - 1))
	{
		Msg("Last can!\n");
		AddTableToTable(::DirectorScript.DirectorOptions, LastCanDOpts);
		
	}
}
