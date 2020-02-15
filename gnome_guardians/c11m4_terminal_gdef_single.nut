printl("Terminal gnome defence map script");

MapSpawns <-  
[
	["GdefWorkbench"],
	["GdefGnome"],
	["GdefBarricadeBuild"],
	["GdefVendingMachine"]
]

/*MapState <-
{

}*/

MapOptions <-
{
	SpawnSetRule = SPAWN_POSITIONAL
	SpawnSetRadius = 1500
	SpawnSetPosition = Vector(-84, 3950, 16)
	ShouldIgnoreClearStateForSpawn = true
	//PreferredMobDirection = SPAWN_LARGE_VOLUME
	//PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	//ShouldConstrainLargeVolumeSpawn = false
}                   


SanitizeTable <-
[
	{ classname		= "weapon_*", input = "kill" }
	{ classname		= "trigger_*", input = "kill" }
	{ classname		= "info_changelevel", input = "kill" }
	{ classname		= "prop_door_*", input = "break" }
	{ classname		= "func_button", input = "kill" }
	{ classname		= "func_areaportal*", input = "open" }
]