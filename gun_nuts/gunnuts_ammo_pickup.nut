// Gun Nuts ammo pickup script
//
// Author: Rectus
// Copyright 2014

function PickupAmmo()
{
	if(!IsPlayerABot(activator))
	{
		GiveBotsAmmo();
	
		local weaponName = GetPrimaryWeaponName(activator);
		
		if(weaponName && weaponName in g_ModeScript.AmmoPickupSize)
		{
			activator.GiveAmmo(g_ModeScript.AmmoPickupSize[weaponName]);
			EmitSoundOnClient("Player.PickupWeapon", activator);
			self.Kill();
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
			weaponName = GetPrimaryWeaponName(player);
			if(weaponName && weaponName in g_ModeScript.AmmoPickupSize)
				player.GiveAmmo(g_ModeScript.AmmoPickupSize[weaponName] 
					* g_ModeScript.BOT_AMMO_MULTIPLIER);
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


self.ConnectOutput("OnPlayerTouch", "PickupAmmo");

DoEntFire("!activator", "Kill", "", 60, self, self);	// Remove the pickup after 60 seconds.