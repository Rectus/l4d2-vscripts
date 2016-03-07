printl("gdef_test gnome defence script");



MapSpawns <-  
[
	["GdefWorkbench"],
	["GdefGnome"],
	["GdefBarricadeBuild"],
	["GdefVendingMachine"],
	["VendingMachine"]
]

MapState <-
{

}


MapOptions <-
{
	ZombieSpawnRange = 4000
	SpawnSetRule = SPAWN_SURVIVORS
	ShouldIgnoreClearStateForSpawn = true
	//PreferredMobDirection = SPAWN_LARGE_VOLUME
	//PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	//ShouldConstrainLargeVolumeSpawn = false
}                   


SanitizeTable <-
[


]


function PickupObject(object)
{
	if(object.GetName().find("scripted_item_drop")  != null)
		return true;
		
	if(object.GetName().find("carryable_minigun")  != null)
		return true;
		
	return false;
}

/*
function AllowTakeDamage( damageTable )
{	
	// mitigate mine damage on players
	if( damageTable.Attacker.GetName().find( "mine_1_exp") && damageTable.Victim.GetClassname() == "player" )
	{
		if( damageTable.Victim.IsSurvivor() )
		{
			ScriptedDamageInfo.DamageDone = 5
		}
		return true
	}

	// If a melee weapon hits a breakable door (barricades are doors)
	// then increase the damage so it breaks more quickly
	if ( damageTable.Victim.GetClassname() == "prop_door_rotating" )
	{
		if ( damageTable.Weapon != null )
		{
			if ( damageTable.Weapon.GetClassname() == "weapon_melee" )
			{
				ScriptedDamageInfo.DamageDone = 100.0
				return true
			}
		}
	}
	
	return true
}

*/
