
AddThinkToEnt(self, "Think")

function Think()
{
	local player = null
	
	while(player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 72))
	{
		if(!player.IsSurvivor())
		{
			continue
		}
		local invTable = {}
		GetInvTable(player, invTable)
		if("slot1" in invTable)
		{
			local weapon = invTable.slot1
			if(weapon.GetClassname() == "weapon_melee")
			{
				weapon.ValidateScriptScope()
				if("arrowCount" in weapon.GetScriptScope())
				{				
					if(weapon.GetScriptScope().GiveArrow())
					{
						EmitSoundOnClient("Player.PickupWeapon", player)
						self.Kill()
					}
					return 1.0
				}
			}
		}
	}
	return 0.1
}