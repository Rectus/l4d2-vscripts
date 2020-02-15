Msg("Initiating Bunker Secret Finale\n");

//-----------------------------------------------------
PANIC <- 0
TANK <- 1
DELAY <- 2
ONSLAUGHT <- 3
//-----------------------------------------------------


EntFire( "progress_display", "SetTotalItems", g_ModeScript.NumCansNeeded )

BaseOptions <-
{
	A_CustomFinale1 = DELAY
	A_CustomFinaleValue1 = 5

	A_CustomFinale2 = ONSLAUGHT
	A_CustomFinaleValue2 = "l4d2_planb3_scavenge_onslaught"
	
	A_CustomFinale3 = DELAY
	A_CustomFinaleValue3 = 1

	SpawnSetRule = SPAWN_FINALE
	EnforceFinaleNavSpawnRules = true

	ProhibitBosses = true
	ZombieSpawnRange = 3000
	MobRechargeRate = 2.0
	
	MusicDynamicMobSpawnSize = 8
	MusicDynamicMobStopSize = 2
	MusicDynamicMobScanStopSize = 1

	function RecalculateLimits()
	{
	}
	
	MobSpawnMinTime = 10
	MobSpawnMaxTime = 15
	
}

::DirectorScript.DirectorOptions <- BaseOptions;

NavMesh.UnblockRescueVehicleNav();