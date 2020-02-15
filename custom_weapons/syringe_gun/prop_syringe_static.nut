

EmitSoundOn("Adrenaline.NeedleIn", self)
DoEntFire("!self", "CallScriptFunction", "ActivateThink", 2, self, self)
function ActivateThink()
{
	AddThinkToEnt(self, "Think")
}

function Think()
{
	local player = null
	
	while(player = Entities.FindByClassnameWithin(player, "player", self.GetOrigin(), 48))
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
				if("syringeCount" in weapon.GetScriptScope())
				{
					weapon.GetScriptScope().syringeCount++
					EmitSoundOnClient("Player.PickupWeapon", player)
					self.Kill()
				}
			}
		}
	}
}