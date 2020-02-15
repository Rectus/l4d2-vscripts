



MapSpawns <-  
[
	["GdefWorkbench"],
	["GdefGnome"],
	[ "Empty64"],
	[ "Empty256"],
	[ "WrongwayBarrier"],
	["GdefBarricadeBuild"],
	["GdefVendingMachine"]
]


MapOptions <-
{
	SpawnSetRule = SPAWN_BATTLEFIELD
	ShouldIgnoreClearStateForSpawn = true
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	ShouldConstrainLargeVolumeSpawn = false
}                   


SanitizeTable <-
[
	// fire these outputs on map spawn
	{ targetname	= "relay_intro_start", input = "kill" }, // stops the intro choreo scene from triggering
	{ targetname	= "survival_spawnpoints", input = "kill" },
	{ targetname	= "ferry_*", input = "kill" },
	{ targetname	= "rope_ferry_*", input = "kill" },
	{ targetname	= "rope_winch_*", input = "kill" },
	{ classname		= "move_rope", position = Vector( -5424, 5987, 38 ), input = "kill" } // unnamed ferry rope
	{ targetname	= "WorldC3M1Ferry*", input = "kill" },
	{ classname		= "func_breakable", input = "break" },
	{ classname		= "prop_door_rotating", input = "kill" },
	{ classname		= "weapon_*", input = "kill" },
	{ model 		= "models/props_junk/gascan001a.mdl", input = "kill" }, // gascans
	{ model 		= "models/props_urban/boat002.mdl", input = "kill" }, // dock boat
	{ model 		= "models/props/cs_office/shelves_metal.mdl", input = "kill" }, // dock shelves
	{ model 		= "models/props_urban/shopping_cart001.mdl", input = "kill" }, // shopping carts
	{ model 		= "models/props_vehicles/cara_69sedan.mdl", input = "kill" }, // car
	{ classname		= "trigger_once", position = Vector( -8095.920, 8124.910, 128 ), input = "kill" } // trigger_once

	// sanitize by region "sanitize_region_front"
	{ classname		= "logic*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "point*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "prop*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "ambient_generic", input = "kill", region = "sanitize_region_front" },
	{ classname		= "keyframe_rope", input = "kill", region = "sanitize_region_front" },
	{ classname		= "move_rope", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_soundscape", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_fade", input = "kill", region = "sanitize_region_front" },
	{ classname		= "info_*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "func_*", input = "kill", region = "sanitize_region_front" },
	
	// sanitize by region "sanitize_region_back"
	{ classname		= "env_phys*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "env_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "keyframe_rope", input = "kill", region = "sanitize_region_back" },
	{ classname		= "move_rope", input = "kill", region = "sanitize_region_back" },
	{ classname		= "beam_spotlight", input = "kill", region = "sanitize_region_back" },
	{ classname		= "prop_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "point_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "info_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "func_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "logic_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "ambient_generic", input = "kill", region = "sanitize_region_back" },
]
