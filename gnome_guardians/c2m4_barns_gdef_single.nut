printl("Barns gnome defence map script");

MapSpawns <-  
[
	["GdefWorkbench"],
	["GdefGnome"],
	["WrongwayBarrier"],
	["GdefBarricadeBuild"],
	["GdefVendingMachine"]
]

MapOptions <-
{
	SpawnSetRule = SPAWN_POSITIONAL
	SpawnSetRadius = 1500
	SpawnSetPosition = Vector(-384, 1222, -191)
	ShouldIgnoreClearStateForSpawn = true
	//PreferredMobDirection = SPAWN_LARGE_VOLUME
	//PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	//ShouldConstrainLargeVolumeSpawn = false
}                   


SanitizeTable <-
[
	{ classname		= "weapon_*", input = "kill" }
]


