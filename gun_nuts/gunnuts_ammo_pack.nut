clips <- 2;

function PickupAmmo()
{

	local player = Entities.FindByClassnameNearest("player", self.GetOrigin(), 256);
	
	if(player && !IsPlayerABot(player))
	{
		GiveBotsAmmo();
		
		local weaponName = GetPrimaryWeaponName(player);

		if(weaponName && weaponName in g_ModeScript.ClipSize)
		{
			player.GiveAmmo(g_ModeScript.ClipSize[weaponName]);
			EmitSoundOnClient("Player.PickupWeapon", player);
			if(--clips <= 0)
			{
				self.Kill();
			}
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
			if(weaponName && weaponName in g_ModeScript.ClipSize)
				player.GiveAmmo(g_ModeScript.ClipSize[weaponName]);
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

self.ConnectOutput("OnPlayerUse", "PickupAmmo");