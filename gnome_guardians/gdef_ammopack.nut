// Gdef ammo pack script
//
// Author: Rectus
// Copyright 2014
//


function PickupAmmo()
{
	
	local player = activator; // scripted_item_drop sets activator correctly
	
	if(player)
	{
		local weapon = GetPrimaryWeaponName(player);

		if(weapon && weapon != "weapon_rifle_m60")
		{
			player.GiveAmmo(999);
			EmitSoundOnClient("Player.AwardUpgrade", player);
			DisplayInstructorHint(AmmoUsedHint, null, player);
			self.Kill();
		}
		else
		{
			DisplayInstructorHint(AmmoDeniedHint, null, player);
		}
	}
}


function GetPrimaryWeaponName(player)
{
	local invTable = {};
	GetInvTable(player, invTable);

	if(!("slot0" in invTable))
		return null;
		
	local weapon = invTable.slot0;
	
	if(weapon)
		return weapon.GetClassname();
		
	return null;
}

// Creates and forcefully displays a hint. 
function DisplayInstructorHint(keyvalues, target = null, player = null)
{
	keyvalues.classname <- "env_instructor_hint";
	keyvalues.hint_auto_start <- 0;
	keyvalues.hint_allow_nodraw_target <- 1;

	if(!target)
	{
		if(Entities.FindByName(null, "static_hint_target") == null)
			SpawnEntityFromTable("info_target_instructor_hint", {targetname = "static_hint_target"});
	
		keyvalues.hint_target <- "static_hint_target";
		keyvalues.hint_static <- 1;
		keyvalues.hint_range <- 0;
	}
	else
	{
		keyvalues.hint_target <- target.GetName();
		keyvalues.hint_static <- 0;
	}

	local hint = SpawnEntityFromTable("env_instructor_hint", keyvalues);
	
	if(player)
	{
		DoEntFire("!self", "ShowHint", "", 0, player, hint);
	}
	else
	{
		while(player = Entities.FindByClassname(player, "player"))
		{
			DoEntFire("!self", "ShowHint", "", 0, player, hint);
		}
	}
	if(keyvalues.hint_timeout && keyvalues.hint_timeout != 0)
	{
		DoEntFire("!self", "Kill", "", keyvalues.hint_timeout, null, hint);
	}
	
	return hint;
}

AmmoDeniedHint <-
{
	hint_name = "gunnuts_ammobox_denied"
	hint_caption = "You must have a primary weapon to pick up ammo", 
	hint_timeout = 3, 
	hint_icon_onscreen = "icon_no",
	hint_instance_type = 0,
	hint_color = "255 255 255"
}

AmmoUsedHint <-
{
	hint_name = "gunnuts_ammobox_used"
	hint_caption = "Primary ammo replenished", 
	hint_timeout = 3, 
	hint_icon_onscreen = "icon_info",
	hint_instance_type = 0,
	hint_color = "255 255 255"
}

self.ConnectOutput("OnPlayerPickup", "PickupAmmo");
//self.ConnectOutput("OnPlayerTouch", "PickupAmmo");