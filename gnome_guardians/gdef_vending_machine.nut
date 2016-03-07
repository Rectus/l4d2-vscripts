
NAME <- "vending_machine_controller"; // Base targetname of this entity.
UseTargets <- [];	// List of button use targets.

// Get the point to spawn items from.
VendOrigin <- EntityGroup[0].GetOrigin();
VendAngles <- EntityGroup[0].GetAngles();

// List of the different kinds of items to vend.
ItemList <-
{
	empty = {empty = true},	// Empty item, displays an out-of-stock message.
	
	pistol =
	{
		price = 75,	// Resource price of the item.
		buttonSkin = 12, // Sets the skin of the button.
		displayTitle = "Extra Pistol", // What to display on the use panel.
		angles = QAngle(0,0,0),	// Angle offset of the item.
		keyValues =	// Entity keyvalues for the entity to spawn. The angles and origin get filled in by the spawner.
		{
			classname 	= "weapon_pistol",
			solid		= "6" // Vphysics
		}
	},
	pistol_magnum =
	{
		price = 200,
		buttonSkin = 24,
		displayTitle = "Desert Eagle",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_pistol_magnum",
			solid		= "6" // Vphysics
		}
	},
	smg =
	{
		price = 125,
		buttonSkin = 5,
		displayTitle = "UZI Submachine Gun",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_smg",
			ammo		= "500",
			solid		= "6" // Vphysics
		}
	},
	smg_silenced =
	{
		price = 125,
		buttonSkin = 6,
		displayTitle = "MAC-10 Submachine Gun",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_smg_silenced",
			ammo		= "500",
			solid		= "6" // Vphysics
		}
	},
	pumpshotgun =
	{
		price = 100,
		buttonSkin = 8,
		displayTitle = "Remington Shotgun",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_pumpshotgun",
			ammo		= "56",
			solid		= "6" // Vphysics
		}
	},
	shotgun_chrome =
	{
		price = 100,
		buttonSkin = 11,
		displayTitle = "Remington Chrome Shotgun",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_shotgun_chrome",
			ammo		= "56",
			solid		= "6" // Vphysics
		}
	},
	hunting_rifle =
	{
		price = 200,
		buttonSkin = 3,
		displayTitle = "Hunting Rifle",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_hunting_rifle",
			ammo		= "150",
			solid		= "6" // Vphysics
		}
	},
	rifle_ak47 =
	{
		price = 300,
		buttonSkin = 10,
		displayTitle = "AK47 Assault Rifle",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_rifle_ak47",
			ammo		= "360",
			solid		= "6" // Vphysics
		}
	},
	rifle =
	{
		price = 300,
		buttonSkin = 9,
		displayTitle = "M16 Assault Rifle",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_rifle",
			ammo		= "360",
			solid		= "6" // Vphysics
		}
	},
	rifle_desert =
	{
		price = 300,
		buttonSkin = 23,
		displayTitle = "SCAR Assault Rifle",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_rifle_desert",
			ammo		= "360",
			solid		= "6" // Vphysics
		}
	},
	autoshotgun =
	{
		price = 300,
		buttonSkin = 25,
		displayTitle = "M1014 Autoshotgun",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_autoshotgun",
			ammo		= "90",
			solid		= "6" // Vphysics
		}
	},
	shotgun_spas =
	{
		price = 300,
		buttonSkin = 7,
		displayTitle = "SPAS-12 Autoshotgun",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_shotgun_spas",
			ammo		= "90",
			solid		= "6" // Vphysics
		}
	},
	sniper_military =
	{
		price = 300,
		buttonSkin = 4,
		displayTitle = "Military Sniper Rifle",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_sniper_military",
			ammo		= "180",
			solid		= "6" // Vphysics
		}
	},
	rifle_m60 =
	{
		price = 500,
		buttonSkin = 19,
		displayTitle = "M60 Machinegun",
		angles = QAngle(0,20,0),
		keyValues =
		{
			classname 	= "weapon_rifle_m60",
			solid		= "6" // Vphysics
		}
	},
	grenade_launcher =
	{
		price = 500,
		buttonSkin = 13,
		displayTitle = "M79 Grenade Launcher",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_grenade_launcher",
			ammo		= "30",
			solid		= "6" // Vphysics
		}
	},
	pain_pills =
	{
		price = 50,
		buttonSkin = 15,
		displayTitle = "Pain Pills",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_pain_pills",
			solid		= "6" // Vphysics
		}
	},
	adrenaline =
	{
		price = 50,
		buttonSkin = 22,
		displayTitle = "Adrenaline",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_adrenaline",
			solid		= "6" // Vphysics
		}
	},
	defibrillator =
	{
		price = 100,
		buttonSkin = 20,
		displayTitle = "Defibrillator",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_defibrillator",
			solid		= "6" // Vphysics
		}
	},
	first_aid_kit =
	{
		price = 100,
		buttonSkin = 18,
		displayTitle = "Fist Aid Kit",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_first_aid_kit",
			solid		= "6" // Vphysics
		}
	},
	molotov =
	{
		price = 150,
		buttonSkin = 16,
		displayTitle = "Molotov Cocktail",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_molotov",
			solid		= "6" // Vphysics
		}
	},
	pipe_bomb =
	{
		price = 150,
		buttonSkin = 14,
		displayTitle = "Pipe Bomb",
		angles = QAngle(0,90,0),
		keyValues =
		{
			classname 	= "weapon_pipe_bomb",
			solid		= "6" // Vphysics
		}
	},
	vomitjar =
	{
		price = 100,
		buttonSkin = 21,
		displayTitle = "Boomer Bile",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "weapon_vomitjar",
			solid		= "6" // Vphysics
		}
	},
	prop_cola =
	{
		price = 99,
		buttonSkin = 17,
		displayTitle = "Cola 6-pack",
		angles = QAngle(0,0,0),
		keyValues =
		{
			classname 	= "prop_physics",
			model		= "models/w_models/weapons/w_cola.mdl"
		}
	},
	prop_ammopack =
	{
		price = 50,
		buttonSkin = 26,
		displayTitle = "Ammo Pack (One Use)",
		angles = QAngle(-45, -90, 0),
		keyValues =
		{
			classname 	= "scripted_item_drop",
			targetname	= "ammo_pack",
			model		= "models/props_gdef/ammopack.mdl",
			vscripts	= "gdef_ammopack"
		}
	},
}

// List of items to apply to each button in order.
Items <-
[
	ItemList.empty,
	ItemList.empty,
	ItemList.empty,
	ItemList.empty,
	ItemList.empty,
	
	ItemList.pistol,
	ItemList.pistol_magnum,
	ItemList.smg,
	ItemList.smg_silenced,
	ItemList.pumpshotgun,
	
	ItemList.shotgun_chrome,
	ItemList.hunting_rifle,
	ItemList.rifle_ak47,
	ItemList.rifle,
	ItemList.rifle_desert,
	
	ItemList.autoshotgun,
	ItemList.shotgun_spas,
	ItemList.sniper_military,
	ItemList.molotov,
	ItemList.pipe_bomb,
	
	ItemList.prop_ammopack,
	ItemList.empty,
	ItemList.empty,
	ItemList.empty,
	ItemList.prop_cola
]

function Precache()
{
	self.PrecacheModel("models/props_gdef/moneywad.mdl");
	self.PrecacheModel("models/props_gdef/ammopack.mdl");
}

function OnPostSpawn()
{
	g_ModeScript.SessionState.VendingMachineList.append(self);
	DoEntFire("!self", "runscriptcode", "AddButtons(25)", 0.01, self, self);
}

// Adds use targts to the button props.
function AddButtons(amount)
{

	for(local i = 0; i < amount; i++)
	{
		local button = null;
		
		local idxString = "00";
		if(i < 10) {idxString = "0" + i;}
		else {idxString = i.tostring();}
		
		local prefix = self.GetName().slice(0, self.GetName().find(NAME));
		local postfix = self.GetName().slice(prefix.len() + NAME.len());

		button = Entities.FindByName(null, prefix + "vend_button_" + idxString + postfix);
		
		local keyValues =
		{
			classname = "point_script_use_target"
			targetname = "vend_button_use"
			vscripts = "usetargets/gdef_vend_button"
			model = button.GetName()
		}
		
		local useTarget = g_ModeScript.CreateSingleSimpleEntityFromTable(keyValues);

		if(useTarget)
		{
			useTarget.ValidateScriptScope();
			UseTargets.append(useTarget);
			local item = Items[UseTargets.len() - 1];

			useTarget.GetScriptScope().Initialize(this, item);
		}
	}
}

// Enables vending.
function OpenForBusiness()
{
	foreach(useTarget in UseTargets)
	{
		useTarget.GetScriptScope().TurnOn();
	}
}

// Called by buttons to spawn items.
function SpawnItem(item)
{
	item.keyValues.origin <- VendOrigin;
	item.keyValues.angles <- VendAngles + item.angles;
	
	local entity = g_ModeScript.CreateSingleSimpleEntityFromTable(item.keyValues);
	EmitSoundOn("Christmas.GiftDrop", entity);
}