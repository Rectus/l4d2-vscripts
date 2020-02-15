IncludeScript("planb_pickupable_prop", this);

EXTINGUISH_RADIUS <- 300;
EXTINGUISH_DURATION <- 8;
used <-false;
effect1Ent <- null;
initialHealth <- 0;

effect1 <-
{
	classname = "info_particle_system"
	effect_name = "extinguisher_spray"//"RPG_Smoke"
	start_active = 1
}

effect2 <-
{
	classname = "info_particle_system"
	effect_name = "weapon_pipebomb_water_child_smoke"
	start_active = 1
}

fireTable <-
{
	classname = "env_fire"
	damagescale = 0
	firesize = 1
	spawnflags = 279
}

function Precache()
{
	self.PrecacheScriptSound("PhysicsCannister.ThrusterLoop");
	PrecacheEntityFromTable(effect1);
	PrecacheEntityFromTable(effect2);
}

function OnPostSpawn()
{
	printl("Extinguisher ID: " + self.GetEntityIndex());
	self.__KeyValueFromString("targetname", self.GetName() + self.GetEntityIndex());
	initialHealth = self.GetHealth();
}

function Extinguish()
{
	if(used || self.GetHealth() == initialHealth)
	{
		return;
	}
	
		
	used = true;
	self.DisconnectOutput("OnHealthChanged", "Extinguish");
	EntFire("!self", "stopglowing");

	for(local i = 0; i <= EXTINGUISH_DURATION; i++)
		DoEntFire("!self", "runscriptcode", "ExtinguishFires()", i, "", self);
	
	
	effect1.parentname <- self.GetName();
	effect1Ent = g_ModeScript.CreateSingleSimpleEntityFromTable(effect1, self);
	//DoEntFire("!activator", "SetParent", self.GetName(), 0.01, effect1Ent, self);
	DoEntFire("!activator", "Kill", "", 8, effect1Ent, "");
	
	
	local effect = g_ModeScript.CreateSingleSimpleEntityFromTable(effect2, self);
	DoEntFire("!self", "Kill", "", 8, "", effect);
	
	
	EmitSoundOn("PhysicsCannister.ThrusterLoop", self);
	EntFire("!self", "runscriptcode", "StopSound()", 3);
}

function ExtinguishFires()
{
	// if(effect1Ent)
		// effect1Ent.SetOrigin(self.GetOrigin());
	
	local inferno = null;
	
	while(inferno = Entities.FindByClassnameWithin(inferno, "inferno", self.GetOrigin(), EXTINGUISH_RADIUS))
	{
		//DebugDrawCircle(inferno.GetOrigin(), Vector(0, 128, 0), 192, 8, true, 0.5);
		DoEntFire("!self", "Kill", "", 0, "", inferno);
	}
	
	local turret = null;
	while(turret = Entities.FindByClassnameWithin(turret, "prop_dynamic", self.GetOrigin(), EXTINGUISH_RADIUS))
	{
		if(turret.GetName().find("turret_gun") == 0)
		{
			//DebugDrawCircle(turret.GetOrigin(), Vector(0, 0, 128), 192, 8, true, 0.5);
			turret.GetScriptScope().target = null;
		}
	}
}

function Ignite()
{
	self.DisconnectOutput("OnPlayerUse", "Ignite");
	
	if(RandomInt(1, 20) != 20)
	{
		return;
	}
	
	fireTable.origin <- self.GetOrigin() + Vector(0, 0, 16);
	local fire = g_ModeScript.CreateSingleSimpleEntityFromTable(fireTable);
	
	if(fire)
	{
		DoEntFire("!self", "SetParent", "!activator", 0, self, fire);
	}
}


function StopSound()
{
	StopSoundOn("PhysicsCannister.ThrusterLoop", self);
}

self.ConnectOutput("OnHealthChanged", "Extinguish");
self.ConnectOutput("OnPlayerUse", "Ignite");