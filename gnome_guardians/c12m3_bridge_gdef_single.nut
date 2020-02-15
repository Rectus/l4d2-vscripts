printl("Bridge gnome defence map script");

MapSpawns <-  
[
	["GdefWorkbench"],
	["GdefGnome"],
	["GdefBarricadeBuild"],
	["GdefVendingMachine"]
]

MapOptions <-
{
	SpawnSetRule = SPAWN_POSITIONAL
	SpawnSetRadius = 2000
	SpawnSetPosition = Vector(6900, -13560, -30)
	ShouldIgnoreClearStateForSpawn = true
	//PreferredMobDirection = SPAWN_LARGE_VOLUME
	//PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	//ShouldConstrainLargeVolumeSpawn = false
}                   


SanitizeTable <-
[
	{ classname		= "weapon_*", input = "kill" }
	{ targetname	= "train_engine_button", input = "kill" }
	{ classname		= "info_game_event_proxy", input = "kill" }
	{ classname		= "trigger_*", input = "kill" }
	{ classname		= "info_changelevel", input = "kill" }
	{ classname		= "prop_door_*", input = "kill" }
]


