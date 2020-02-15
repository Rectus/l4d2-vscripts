printl("Park gnome defence map script");

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
	SpawnSetRadius = 2000
	SpawnSetPosition = Vector(-6236, -2214, -233)
	ShouldIgnoreClearStateForSpawn = true
	//PreferredMobDirection = SPAWN_LARGE_VOLUME
	//PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	//ShouldConstrainLargeVolumeSpawn = false
}                   


SanitizeTable <-
[
	{ classname		= "weapon_*", input = "kill" }
]


