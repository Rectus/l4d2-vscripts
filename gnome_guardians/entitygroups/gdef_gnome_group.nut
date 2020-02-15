//-------------------------------------------------------
// Autogenerated from 'gdef_gnome.vmf'
//-------------------------------------------------------
GdefGnome <-
{
	//-------------------------------------------------------
	// Required Interface functions
	//-------------------------------------------------------
	function GetPrecacheList()
	{
		local precacheModels =
		[
			EntityGroup.SpawnTables.gnome_crate,
			EntityGroup.SpawnTables.exclusion_zone_gnome,
			EntityGroup.SpawnTables.gnome,
		]
		return precacheModels
	}

	//-------------------------------------------------------
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.gnome_crate,
			EntityGroup.SpawnTables.exclusion_zone_gnome,
			EntityGroup.SpawnTables.gdef_timescale,
			EntityGroup.SpawnTables.gnome,
			EntityGroup.SpawnTables.gdef_gnome_hint,
			EntityGroup.SpawnTables.gdef_gnome_particle2,
			EntityGroup.SpawnTables.gdef_gnome_particle1,
			EntityGroup.SpawnTables.gdef_gnome_particle,
		]
		return spawnEnts
	}

	//-------------------------------------------------------
	function GetEntityGroup()
	{
		return EntityGroup
	}

	//-------------------------------------------------------
	// Table of entities that make up this group
	//-------------------------------------------------------
	EntityGroup =
	{
		SpawnTables =
		{
			gnome_crate = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 180, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_crates/static_crate_40.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "gnome_crate"
					origin = Vector( 2.76251e-008, -0.631988, 0.00559235 )
				}
			}
			exclusion_zone_gnome = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 180, 0 )
					body = "0"
					disablereceiveshadows = "0"
					disableshadows = "1"
					ExplodeDamage = "0"
					ExplodeRadius = "0"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "0"
					glowrangemin = "0"
					glowstate = "0"
					LagCompensate = "0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/exclusion_zone_128.mdl"
					PerformanceMode = "0"
					pressuredelay = "0"
					RandomAnimation = "0"
					renderamt = "255"
					rendercolor = "255 0 0"
					renderfx = "0"
					rendermode = "0"
					SetBodyGroup = "0"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					StartDisabled = "1"
					targetname = "exclusion_zone_gnome"
					updatechildren = "0"
					origin = Vector( 2.30926e-014, -0.315995, 4.00559 )
				}
			}
			gnome = 
			{
				SpawnInfo =
				{
					classname = "prop_physics"
					angles = Vector( 0, 180, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowcolor = "0 0 0"
					inertiaScale = "1.0"
					model = "models/props_junk/gnome.mdl"
					physdamagescale = "0.1"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					spawnflags = "520"
					targetname = "gnome"
					vscripts = "gdef_gnome"
					origin = Vector( -6, 7.36801, 50.0056 )
					connections =
					{
						OnBreak =
						{
							cmd1 = "gdef_timescaleStart0-1"
							cmd2 = "gdef_gnome_particleStart0-1"
							cmd3 = "gdef_timescaleStop2.9-1"
						}
					}
				}
			}
			gdef_timescale = 
			{
				SpawnInfo =
				{
					classname = "func_timescale"
					acceleration = "0.25"
					angles = Vector( 0, 0, 0 )
					blendDeltaMultiplier = "3.0"
					desiredTimescale = "0.1"
					minBlendRate = "0.1"
					targetname = "gdef_timescale"
					origin = Vector( 52.4168, 133.138, 9 )
				}
			}
			gdef_gnome_particle = 
			{
				SpawnInfo =
				{
					classname = "info_particle_system"
					angles = Vector( 0, 0, 0 )
					effect_name = "fireworks_explosion_01"
					targetname = "gdef_gnome_particle"
					origin = Vector( 0, 0, 56 )
				}
			}
			gdef_gnome_particle1 = 
			{
				SpawnInfo =
				{
					classname = "info_particle_system"
					angles = Vector( 0, 0, 0 )
					effect_name = "gas_explosion_fireball2"
					targetname = "gdef_gnome_particle"
					origin = Vector( 0, 0, 57 )
				}
			}
			gdef_gnome_particle2 = 
			{
				SpawnInfo =
				{
					classname = "info_particle_system"
					angles = Vector( 0, 0, 0 )
					effect_name = "boomer_explode"
					targetname = "gdef_gnome_particle"
					origin = Vector( 0, 0, 58 )
				}
			}
			gdef_gnome_hint = 
			{
				SpawnInfo =
				{
					classname = "env_instructor_hint"
					hint_allow_nodraw_target = "1"
					hint_auto_start = "1"
					hint_caption = "Protect the gnome"
					hint_color = "255 255 255"
					hint_display_limit = "1"
					hint_icon_offscreen = "icon_shield"
					hint_icon_offset = "16"
					hint_icon_onscreen = "icon_shield"
					hint_instance_type = "0"
					hint_name = "gdef_hint"
					hint_range = "0"
					hint_target = "gnome"
					hint_timeout = "8"
					targetname = "gdef_gnome_hint"
					origin = Vector( -12, 50, 9.00001 )
				}
			}
		} // SpawnTables
	} // EntityGroup
} // GdefGnome

RegisterEntityGroup( "GdefGnome", GdefGnome )