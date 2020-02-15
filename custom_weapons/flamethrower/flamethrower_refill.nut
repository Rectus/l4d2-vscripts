
prop <- null
self.ConnectOutput("OnUseFinished", "Refilled")

function SetProp(_prop)
{
	prop = _prop
	
	local refillHint = 
	{
		classname = "env_instructor_hint"
		hint_name = "flamethrower_refill_hint"
		hint_caption = "This flamethower is empty, use a gas can to refuel it"
		hint_auto_start = 1
		hint_target = prop.GetName()
		hint_timeout = 8
		hint_static = 0
		hint_forcecaption = 0
		hint_icon_onscreen = "icon_tip"
		hint_instance_type = 2
		hint_range = 256
		hint_allow_nodraw_target = 1
		hint_icon_offset = 8
		hint_color = "255 255 255"
		origin = prop.GetOrigin() + Vector(0, 0, 8)
	}
	printl(g_ModeScript.CreateSingleSimpleEntityFromTable(refillHint))
}

function Refilled()
{
	local weaponKeyvalues =
	{
		classname = "weapon_melee_spawn"
		melee_weapon = "flamethrower"
		spawnflags = 3
		count = 1
		solid = 6
		origin = self.GetOrigin()
		angles = QAngle(-90, 180, 0)
	}

	if(prop)
	{
		weaponKeyvalues.origin = prop.GetOrigin() + Vector(0, 0, 2)
		weaponKeyvalues.angles = prop.GetAngles()
		DoEntFire("!self", "Kill", "", 0, prop, prop)
	}
	g_ModeScript.CreateSingleSimpleEntityFromTable(weaponKeyvalues)
	
	DoEntFire("!self", "Kill", "", 0, self, self)
	
}