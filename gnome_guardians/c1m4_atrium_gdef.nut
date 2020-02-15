printl("Atrium gdef map script");

MapSpawns <-  
[
	["GdefWorkbench"],
	["GdefGnome"],
	["GdefBarricadeBuild"],
	["GdefVendingMachine"]
	//["WrongwayBarrier"]
]

MapOptions <-
{
	SpawnSetRule = SPAWN_FINALE
	//SpawnSetRadius = 1500
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	ShouldConstrainLargeVolumeSpawn = false
}                   


SanitizeTable <-
[
	{ classname		= "weapon_*", input = "kill" }
	{ classname		= "prop_physics", input = "kill" }
	{ classname		= "prop_door_rotating", input = "kill" }
	{ classname		= "trigger_finale", input = "kill" }
	{ classname		= "point_prop_use_target", input = "kill" }
	{ targetname	= "gas_nozzle", input = "kill" }
]