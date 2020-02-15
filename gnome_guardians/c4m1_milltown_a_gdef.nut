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
	SpawnSetRule = SPAWN_POSITIONAL
	SpawnSetRadius = 3000
	SpawnSetPosition = Vector( 846, 5267, 158 )
}

SanitizeTable <-
[
	{ model 		= "models/props_interiors/chair_cafeteria.mdl", input = "kill" }, // chairs
	{ model 		= "models/props_debris/wood_board05a.mdl", input = "kill" }, // boards
	{ model 		= "models/props_debris/wood_board04a.mdl", input = "kill" }, // boards

	// car alarms
	{ targetname	= "ptemplate_alarm_on-car3", input = "kill" },
	{ targetname	= "InstanceAuto28-case_car_color", input = "kill" },
	{ targetname	= "alarmtimer1-car2", input = "kill" },
	{ targetname	= "carchirp1-car2", input = "kill" },
	{ targetname	= "case_car_color-car2", input = "kill" },
	{ targetname	= "relay_caralarm_on-car2", input = "kill" },
	{ targetname	= "relay_caralarm_off-car2", input = "kill" },	
	{ targetname	= "branch_caralarm-car2", input = "kill" },
	{ targetname	= "ptemplate_alarm_on-car2", input = "kill" },
	{ targetname	= "InstanceAuto34-case_car_color", input = "kill" },
	{ targetname	= "InstanceAuto28-car_physics", input = "kill" },
	{ targetname	= "InstanceAuto34-car_physics", input = "kill" },
	
	{ targetname	= "relay_intro_start", input = "kill" }, // stops the intro choreo scene from triggering
	{ classname		= "info_survivor_position", input = "kill" },
	{ targetname	= "caralarm*", input = "kill" },
	{ targetname	= "event_getgas", input = "kill" },
	{ classname		= "func_breakable", input = "break" },
	{ classname		= "info_survivor_rescue", input = "kill" },
	{ classname		= "prop_door_rotating", input = "kill" },
	{ classname		= "info_remarkable", input = "kill" },
	{ classname		= "weapon_*", input = "kill" },
	{ classname		= "upgrade_spawn", input = "kill" },
	{ model 		= "models/props_junk/gascan001a.mdl", input = "kill" }, // gascans
	{ model 		= "models/props/de_inferno/ceiling_fan_blade.mdl", input = "kill" }, // ceiling fan blade

	// sanitize by region "sanitize_region_front" (from the start docks to the holdout street)
	{ classname		= "logic*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "trigger*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "point*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "prop*", input = "kill", region = "sanitize_region_front" },
	{ classname		= "ambient_generic", input = "kill", region = "sanitize_region_front" },
	{ classname		= "keyframe_rope", input = "kill", region = "sanitize_region_front" },
	{ classname		= "move_rope", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_soundscape", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_player_blocker", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_physics_blocker", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_fade", input = "kill", region = "sanitize_region_front" },
	{ classname		= "env_fire", input = "kill", region = "sanitize_region_front" },
	{ classname		= "info_game_event_proxy", input = "kill", region = "sanitize_region_front" },
	{ classname		= "info_gamemode", input = "kill", region = "sanitize_region_front" },
	{ classname		= "math_counter", input = "kill", region = "sanitize_region_front" },
	{ classname		= "info_particle_system", input = "kill", region = "sanitize_region_front" },
	{ classname		= "func_areaportalwindow", input = "kill", region = "sanitize_region_front" },
	{ classname		= "func_brush", input = "kill", region = "sanitize_region_front" },
	
	// sanitize by region "sanitize_region_back" (back streets to the saferoom exit)
	{ classname		= "weapon_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "func_brush", input = "kill", region = "sanitize_region_back" },
	{ classname		= "prop_health_cabinet", input = "kill", region = "sanitize_region_back" },
	{ classname		= "env_sprite", input = "kill", region = "sanitize_region_back" },
	{ classname		= "env_soundscape", input = "kill", region = "sanitize_region_back" },
	{ classname		= "keyframe_rope", input = "kill", region = "sanitize_region_back" },
	{ classname		= "move_rope", input = "kill", region = "sanitize_region_back" },
	{ classname		= "prop_physics", input = "kill", region = "sanitize_region_back" },
	{ classname		= "info_game_event_proxy", input = "kill", region = "sanitize_region_back" },
	{ classname		= "info_changelevel", input = "kill", region = "sanitize_region_back" },
	{ classname		= "info_landmark", input = "kill", region = "sanitize_region_back" },
	{ classname		= "upgrade_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "func_areaportalwindow", input = "kill", region = "sanitize_region_back" },
	{ classname		= "logic_director_query", input = "kill", region = "sanitize_region_back" },
	{ classname		= "logic_*", input = "kill", region = "sanitize_region_back" },
	{ classname		= "ambient_generic", input = "kill", region = "sanitize_region_back" },
]