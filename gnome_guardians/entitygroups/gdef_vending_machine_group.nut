//-------------------------------------------------------
// Autogenerated from 'gdef_vending_machine.vmf'
//-------------------------------------------------------
GdefVendingMachine <-
{
	//-------------------------------------------------------
	// Required Interface functions
	//-------------------------------------------------------
	function GetPrecacheList()
	{
		local precacheModels =
		[
			EntityGroup.SpawnTables.vending_machine,
			EntityGroup.SpawnTables.vend_button_00,
			EntityGroup.SpawnTables.vend_button_01,
			EntityGroup.SpawnTables.vend_button_02,
			EntityGroup.SpawnTables.vend_button_03,
			EntityGroup.SpawnTables.vend_button_04,
			EntityGroup.SpawnTables.vend_button_09,
			EntityGroup.SpawnTables.vend_button_08,
			EntityGroup.SpawnTables.vend_button_07,
			EntityGroup.SpawnTables.vend_button_06,
			EntityGroup.SpawnTables.vend_button_05,
			EntityGroup.SpawnTables.vend_button_14,
			EntityGroup.SpawnTables.vend_button_13,
			EntityGroup.SpawnTables.vend_button_12,
			EntityGroup.SpawnTables.vend_button_11,
			EntityGroup.SpawnTables.vend_button_10,
			EntityGroup.SpawnTables.vend_button_19,
			EntityGroup.SpawnTables.vend_button_18,
			EntityGroup.SpawnTables.vend_button_17,
			EntityGroup.SpawnTables.vend_button_16,
			EntityGroup.SpawnTables.vend_button_15,
			EntityGroup.SpawnTables.vend_button_24,
			EntityGroup.SpawnTables.vend_button_23,
			EntityGroup.SpawnTables.vend_button_22,
			EntityGroup.SpawnTables.vend_button_21,
			EntityGroup.SpawnTables.vend_button_20,
		]
		return precacheModels
	}

	//-------------------------------------------------------
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.vend_button_06,
			EntityGroup.SpawnTables.vend_button_07,
			EntityGroup.SpawnTables.vending_machine,
			EntityGroup.SpawnTables.vend_position,
			EntityGroup.SpawnTables.vend_button_14,
			EntityGroup.SpawnTables.vend_button_03,
			EntityGroup.SpawnTables.vend_button_12,
			EntityGroup.SpawnTables.vend_button_11,
			EntityGroup.SpawnTables.vend_button_01,
			EntityGroup.SpawnTables.vend_button_23,
			EntityGroup.SpawnTables.vend_button_13,
			EntityGroup.SpawnTables.vend_button_00,
			EntityGroup.SpawnTables.vend_button_16,
			EntityGroup.SpawnTables.vend_button_04,
			EntityGroup.SpawnTables.vend_button_21,
			EntityGroup.SpawnTables.vend_button_09,
			EntityGroup.SpawnTables.vend_button_22,
			EntityGroup.SpawnTables.vend_button_05,
			EntityGroup.SpawnTables.vend_button_19,
			EntityGroup.SpawnTables.vending_machine_controller,
			EntityGroup.SpawnTables.vend_button_02,
			EntityGroup.SpawnTables.vend_button_08,
			EntityGroup.SpawnTables.vend_button_24,
			EntityGroup.SpawnTables.vend_button_18,
			EntityGroup.SpawnTables.vend_button_20,
			EntityGroup.SpawnTables.vend_button_10,
			EntityGroup.SpawnTables.vend_button_15,
			EntityGroup.SpawnTables.vend_button_17,
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
			vending_machine = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_big.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					targetname = "vending_machine"
					origin = Vector( -5, 0, 0.250008 )
				}
			}
			vend_button_00 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_00"
					origin = Vector( 15, -24, 78.25 )
				}
			}
			vend_button_01 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_01"
					origin = Vector( 15, -15, 78.25 )
				}
			}
			vend_button_02 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_02"
					origin = Vector( 15, -6, 78.25 )
				}
			}
			vend_button_03 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_03"
					origin = Vector( 15, 3, 78.25 )
				}
			}
			vend_button_04 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_04"
					origin = Vector( 15, 12, 78.25 )
				}
			}
			vend_button_09 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_09"
					origin = Vector( 15, 12, 69.25 )
				}
			}
			vend_button_08 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_08"
					origin = Vector( 15, 3, 69.25 )
				}
			}
			vend_button_07 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_07"
					origin = Vector( 15, -6, 69.25 )
				}
			}
			vend_button_06 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_06"
					origin = Vector( 15, -15, 69.25 )
				}
			}
			vend_button_05 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_05"
					origin = Vector( 15, -24, 69.25 )
				}
			}
			vend_button_14 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_14"
					origin = Vector( 15, 12, 60.25 )
				}
			}
			vend_button_13 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_13"
					origin = Vector( 15, 3, 60.25 )
				}
			}
			vend_button_12 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_12"
					origin = Vector( 15, -6, 60.25 )
				}
			}
			vend_button_11 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_11"
					origin = Vector( 15, -15, 60.25 )
				}
			}
			vend_button_10 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_10"
					origin = Vector( 15, -24, 60.25 )
				}
			}
			vend_button_19 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_19"
					origin = Vector( 15, 12, 51.25 )
				}
			}
			vend_button_18 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_18"
					origin = Vector( 15, 3, 51.25 )
				}
			}
			vend_button_17 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_17"
					origin = Vector( 15, -6, 51.25 )
				}
			}
			vend_button_16 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_16"
					origin = Vector( 15, -15, 51.25 )
				}
			}
			vend_button_15 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_15"
					origin = Vector( 15, -24, 51.25 )
				}
			}
			vend_button_24 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_24"
					origin = Vector( 15, 12, 42.25 )
				}
			}
			vend_button_23 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_23"
					origin = Vector( 15, 3, 42.25 )
				}
			}
			vend_button_22 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_22"
					origin = Vector( 15, -6, 42.25 )
				}
			}
			vend_button_21 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_21"
					origin = Vector( 15, -15, 42.25 )
				}
			}
			vend_button_20 = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic"
					angles = Vector( 0, 270, 0 )
					disablereceiveshadows = "1"
					disableshadows = "1"
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					glowrange = "100"
					glowstate = "3"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/props_gdef/vending_machine_button.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "6"
					spawnflags = "0"
					targetname = "vend_button_20"
					origin = Vector( 15, -24, 42.25 )
				}
			}
			vend_position = 
			{
				SpawnInfo =
				{
					classname = "info_target"
					angles = Vector( 0, 90, 0 )
					spawnflags = "0"
					targetname = "vend_position"
					origin = Vector( 1.90735e-006, -17.02, 32.25 )
				}
			}
			vending_machine_controller = 
			{
				SpawnInfo =
				{
					classname = "logic_script"
					Group00 = "vend_position"
					targetname = "vending_machine_controller"
					vscripts = "gdef_vending_machine"
					origin = Vector( 28, 32, 56.25 )
				}
			}
		} // SpawnTables
	} // EntityGroup
} // GdefVendingMachine

RegisterEntityGroup( "GdefVendingMachine", GdefVendingMachine )
