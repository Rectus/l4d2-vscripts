EXTINGUISH_RADIUS <- 150;
used <-false;

effect1 <-
{
	classname = "info_particle_system"
	effect_name = "RPG_Smoke"
	start_active = 1
}

effect2 <-
{
	classname = "info_particle_system"
	effect_name = "weapon_pipebomb_water_child_smoke"
	start_active = 1
}

function Precache()
{
	self.PrecacheScriptSound("PhysicsCannister.ThrusterLoop");
	PrecacheEntityFromTable(effect1);
	PrecacheEntityFromTable(effect2);
}

function Extinguish()
{
	if(used)
		return;
		
	used = true;
	self.DisconnectOutput("OnHealthChanged", "Extinguish");
	EntFire("!self", "stopglowing");

	local inferno = null;
	
	while(inferno = Entities.FindByClassnameWithin(inferno, "inferno", self.GetOrigin(), EXTINGUISH_RADIUS))
	{
		DoEntFire("!self", "Kill", "", 0.5, "", inferno);
	}
	
	local effect = g_ModeScript.CreateSingleSimpleEntityFromTable(effect1, self);
	DoEntFire("!self", "Kill", "", 0.5, "", effect);
	
	
	effect = g_ModeScript.CreateSingleSimpleEntityFromTable(effect2, self);
	DoEntFire("!self", "Kill", "", 8, "", effect);
	
	
	EmitSoundOn("PhysicsCannister.ThrusterLoop", self);
	EntFire("!self", "runscriptcode", "StopSound()", 3);
}

function StopSound()
{
	StopSoundOn("PhysicsCannister.ThrusterLoop", self);
}

self.ConnectOutput("OnHealthChanged", "Extinguish");