Msg("Plan B map 2 script initialized.\n");


IncludeScript("vscript_hint_recreate", this);

::PlanBElevatorUsed <- false;

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
	//printl("AllowPickup ran on: " + object);
	if(object.GetName() == "geiger_counter"
		|| object.GetName() == "howitzer_shell"
		|| object.GetName() == "fire_extinguisher")
		return true;
		
		
	return false;
}


	
function MapStateRestore()
{
	printl("Restoring campaign state.");
	
	RestoreTable("PlanBState", g_ModeScript.PlanBState);
	
	g_ModeScript.DeepPrintTable(g_ModeScript.PlanBState);

	if(g_ModeScript.PlanBState.TransferShell) 
	{
		EntFire("howitzer_shell_temp", "ForceSpawn");	
	}

	if(g_ModeScript.PlanBState.BunkerDoorDestroyed)
	{
		EntFire("bunker_door_damage_relay", "Trigger");	
	}
	
	Entities.FindByName(null, "med_station1_use").GetScriptScope().SetUses(g_ModeScript.PlanBState.MedStation1Uses);
	
	SaveTable("PlanBState", g_ModeScript.PlanBState);
	
	Entities.FindByName(null, "med_station2_use").GetScriptScope().SetUses(RandomInt(0, 3));
	Entities.FindByName(null, "med_station3_use").GetScriptScope().SetUses(RandomInt(0, 3));
}

::BunkerMapStateRestore <- MapStateRestore;

function MapStateTransfer()
{
	printl("Saving campaign state.");

	local geigerCounter = Entities.FindByName(null, "geiger_counter");

	if(geigerCounter != null)
	{
		local origin = geigerCounter.GetOrigin();
		local angles = geigerCounter.GetAngles();
		local geiger = {};
	
		geiger.x <- origin.x;
		geiger.y <- origin.y;
		geiger.z <- origin.z;
		geiger.Yaw <- angles.Yaw();
		geiger.pitch <- angles.Pitch();
		geiger.Roll <- angles.Roll();
		
		g_ModeScript.PlanBState.Geiger = geiger;
		printl("Geiger counter at " + origin + " saved.");
	}
	
	g_ModeScript.PlanBState.MedStation2Uses = Entities.FindByName(null, "med_station2_use").GetScriptScope().uses;
	g_ModeScript.PlanBState.MedStation3Uses = Entities.FindByName(null, "med_station3_use").GetScriptScope().uses;
	
	g_ModeScript.PlanBState.ElevatorUsed = PlanBElevatorUsed;
	
	g_ModeScript.DeepPrintTable(g_ModeScript.PlanBState);
	
	SaveTable("PlanBState", g_ModeScript.PlanBState);
}

::MapStateTransfer <- MapStateTransfer;