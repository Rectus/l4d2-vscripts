// Diescraper ammo box script
//
// Author: Rectus
// Copyright 2014
//
// Makes a prop behave like an ammo box that every player can use once to refill their ammo.


playersGivenAmmoTo <- {};
uses <- 4;

function PickupAmmo()
{
	local player = Entities.FindByClassnameNearest("player", self.GetOrigin(), 256);
	
	if(player && !IsPlayerABot(player))
	{
		local weaponName = GetPrimaryWeaponName(player);

		if(weaponName)
		{
			if(!(player in playersGivenAmmoTo))
			{
				playersGivenAmmoTo[player] <- true;
				player.GiveAmmo(999);
				EmitSoundOnClient("Player.PickupWeapon", player);
				GiveBotsAmmo();
				DoEntFire("!self", "SetBodyGroup", "1", 0, null, self);
				if(--uses <= 0)
				{
					// Remove from the spawned item list in holdout mode.
					if(Director.GetGameMode() == "holdout")
						g_ModeScript.SessionState.SpawnedItems.remove(self.GetEntityIndex());
						
					self.Kill();
				}
			}
			else
			{
				DisplayInstructorHint(AmmoUsedHint);
			}
		}
		else
		{
			DisplayInstructorHint(AmmoDeniedHint);
		}
	}
}

function GiveBotsAmmo()
{
	local player = null;
	local weaponName = null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(IsPlayerABot(player))
		{
			player.GiveAmmo(999);
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

AmmoDeniedHint <-
{
	hint_name = "gunnuts_ammobox_denied"
	hint_caption = "You must have a primary weapon to pick up ammo", 
	hint_timeout = 3, 
	hint_icon_onscreen = "icon_no",
	hint_instance_type = 2,
	hint_color = "255 255 255"
}

AmmoUsedHint <-
{
	hint_name = "gunnuts_ammobox_used"
	hint_caption = "You have already used this ammo box", 
	hint_timeout = 3, 
	hint_icon_onscreen = "icon_no",
	hint_instance_type = 2,
	hint_color = "255 255 255"
}

self.ConnectOutput("OnPlayerUse", "PickupAmmo");