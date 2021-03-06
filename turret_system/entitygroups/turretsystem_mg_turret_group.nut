//-------------------------------------------------------
// Autogenerated from 'turretsystem_mg_turret.vmf'
//-------------------------------------------------------
TurretsystemMgTurret <-
{
	//-------------------------------------------------------
	// Required Interface functions
	//-------------------------------------------------------
	function GetPrecacheList()
	{
		local precacheModels =
		[
			EntityGroup.SpawnTables.mg_turret_traverse,
			EntityGroup.SpawnTables.mg_turret_gun,
			EntityGroup.SpawnTables.mg_turret_base,
		]
		return precacheModels
	}

	//-------------------------------------------------------
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.mg_turret_shell_hurt,
			EntityGroup.SpawnTables.mg_turret_shell_effect,
			EntityGroup.SpawnTables.mg_turret_comp_use,
			EntityGroup.SpawnTables.mg_turret_hit_target,
			EntityGroup.SpawnTables.mg_turret_muzzleflash,
			EntityGroup.SpawnTables.mg_turret_heat_effect,
			EntityGroup.SpawnTables.mg_turret_gun,
			EntityGroup.SpawnTables.mg_turret_casing,
			EntityGroup.SpawnTables.mg_turret_tracer_target,
			EntityGroup.SpawnTables.mg_turret_traverse,
			EntityGroup.SpawnTables.mg_turret_tracer,
			EntityGroup.SpawnTables.mg_turret_base,
			EntityGroup.SpawnTables.mg_turret_heattexture,
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
			mg_turret_traverse = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 0, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/turret/minigun_traverse.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "mg_turret_traverse"
					origin = Vector( 0, 0, 34 )
				}
			}
			mg_turret_gun = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 0, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/turret/minigun_gun.mdl"
					parentname = "mg_turret_traverse"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "mg_turret_gun"
					vscripts = "turretsystem_turret_mg"
					origin = Vector( 1.5, 0, 45 )
					connections =
					{
						OnUser1 =
						{
							cmd1 = "mg_turret_traverseKill0-1"
							cmd2 = "mg_turret_baseKill0-1"
							cmd3 = "mg_turret_heattextureKill0-1"
							cmd4 = "mg_turret_casingKill0-1"
							cmd5 = "mg_turret_tracerKill0-1"
							cmd6 = "mg_turret_muzzleflashKill0-1"
							cmd7 = "mg_turret_tracer_targetKill0-1"
							cmd8 = "mg_turret_shell_effectKill0-1"
							cmd9 = "mg_turret_shell_hurtKill0-1"
							cmd10 = "mg_turret_heat_effectKill0-1"
							cmd11 = "mg_turret_comp_useKill0-1"
							cmd12 = "mg_turret_gunKill0-1"
						}
					}
				}
			}
			mg_turret_base = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 0, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/turret/minigun_base.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "mg_turret_base"
					origin = Vector( 0, 0, 0 )
				}
			}
			mg_turret_heattexture = 
			{
				SpawnInfo =
				{
					classname = "material_modify_control"
					materialName = "models/props_gdef/turret/w_minigun"
					materialVar = "$HeatAmount"
					parentname = "mg_turret_gun"
					targetname = "mg_turret_heattexture"
					origin = Vector( 7.78601, -31.587, 9.25002 )
				}
			}
			mg_turret_muzzleflash = 
			{
				SpawnInfo =
				{
					classname = "info_particle_system"
					angles = Vector( 0, 0, 0 )
					cpoint1_parent = "0"
					cpoint2_parent = "0"
					cpoint3_parent = "0"
					cpoint4_parent = "0"
					cpoint5_parent = "0"
					cpoint6_parent = "0"
					cpoint7_parent = "0"
					effect_name = "weapon_muzzle_flash_minigun"
					parentname = "mg_turret_gun"
					render_in_front = "0"
					start_active = "0"
					targetname = "mg_turret_muzzleflash"
					origin = Vector( 26, 0, 43.75 )
				}
			}
			mg_turret_tracer = 
			{
				SpawnInfo =
				{
					classname = "info_particle_system"
					angles = Vector( 0, 0, 0 )
					cpoint1 = "mg_turret_tracer_target"
					cpoint1_parent = "0"
					cpoint2_parent = "0"
					cpoint3_parent = "0"
					cpoint4_parent = "0"
					cpoint5_parent = "0"
					cpoint6_parent = "0"
					cpoint7_parent = "0"
					effect_name = "weapon_tracers"
					parentname = "mg_turret_gun"
					render_in_front = "0"
					start_active = "0"
					targetname = "mg_turret_tracer"
					origin = Vector( 28, 0, 43.75 )
				}
			}
			mg_turret_casing = 
			{
				SpawnInfo =
				{
					classname = "info_particle_system"
					angles = Vector( 0, 225, 0 )
					cpoint1_parent = "0"
					cpoint2_parent = "0"
					cpoint3_parent = "0"
					cpoint4_parent = "0"
					cpoint5_parent = "0"
					cpoint6_parent = "0"
					cpoint7_parent = "0"
					effect_name = "weapon_shell_casing_minigun"
					parentname = "mg_turret_gun"
					render_in_front = "0"
					start_active = "0"
					targetname = "mg_turret_casing"
					origin = Vector( -8, -6, 40.5 )
				}
			}
			mg_turret_heat_effect = 
			{
				SpawnInfo =
				{
					classname = "info_particle_system"
					angles = Vector( 0, 0, 0 )
					cpoint1_parent = "0"
					cpoint2_parent = "0"
					cpoint3_parent = "0"
					cpoint4_parent = "0"
					cpoint5_parent = "0"
					cpoint6_parent = "0"
					cpoint7_parent = "0"
					effect_name = "minigun_overheat_smoke"
					parentname = "mg_turret_gun"
					render_in_front = "0"
					start_active = "0"
					targetname = "mg_turret_heat_effect"
					origin = Vector( 26, 0, 43.75 )
				}
			}
			mg_turret_tracer_target = 
			{
				SpawnInfo =
				{
					classname = "info_particle_target"
					angles = Vector( 0, 0, 0 )
					parentname = "mg_turret_hit_target"
					targetname = "mg_turret_tracer_target"
					origin = Vector( 84, 0, 43.75 )
				}
			}
			mg_turret_shell_effect = 
			{
				SpawnInfo =
				{
					classname = "info_particle_system"
					angles = Vector( 0, 0, 0 )
					cpoint1_parent = "0"
					cpoint2_parent = "0"
					cpoint3_parent = "0"
					cpoint4_parent = "0"
					cpoint5_parent = "0"
					cpoint6_parent = "0"
					cpoint7_parent = "0"
					effect_name = "impact_explosive_ammo_large"
					parentname = "mg_turret_hit_target"
					render_in_front = "0"
					start_active = "0"
					targetname = "mg_turret_shell_effect"
					origin = Vector( 84, 0, 43.75 )
				}
			}
			mg_turret_shell_hurt = 
			{
				SpawnInfo =
				{
					classname = "point_hurt"
					Damage = "20"
					DamageDelay = "1"
					DamageRadius = "35"
					DamageType = "-2147483646"
					targetname = "mg_turret_shell_hurt"
					origin = Vector( 84, 0, 43.75 )
				}
			}
			mg_turret_hit_target = 
			{
				SpawnInfo =
				{
					classname = "info_target_instructor_hint"
					targetname = "mg_turret_hit_target"
					origin = Vector( 84, 0, 43.75 )
				}
			}
			mg_turret_comp_use = 
			{
				SpawnInfo =
				{
					classname = "point_script_use_target"
					model = "mg_turret_gun"
					origin = Vector( -3.28, 28, 8.25 )
					targetname = "mg_turret_comp_use"
					vscripts = "usetargets/turretsystem_turret_mg_comp"
				}
			}
		} // SpawnTables
	} // EntityGroup
} // TurretsystemMgTurret

RegisterEntityGroup( "TurretsystemMgTurret", TurretsystemMgTurret )
