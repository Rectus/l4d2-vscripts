/* Gdef ammo pack script. For use with scripted_item_drop entity.
 *
 * Copyright (c) 2014-2015 Rectus
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */


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