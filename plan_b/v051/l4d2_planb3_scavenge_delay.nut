Msg("Initiating Bunker Secret Finale Onslaught stage\n");


DirectorOptions <-
{

	ProhibitBosses = true
	ZombieSpawnRange = 2000
	MobRechargeRate = 2.0
	
	MusicDynamicMobSpawnSize = 8
	MusicDynamicMobStopSize = 2
	MusicDynamicMobScanStopSize = 1

	function RecalculateLimits()
	{
	}
	
	MobSpawnMinTime = 10
	MobSpawnMaxTime = 25
	
	IntensityRelaxThreshold = 1.1
	RelaxMinInterval = 2
	RelaxMaxInterval = 4
	SustainPeakMinTime = 25
	SustainPeakMaxTime = 30
	
	MobMinSize = 2
	MobMaxSize = 6
	CommonLimit = 5
	
	SpecialRespawnInterval = 100
}

Director.ResetMobTimer();

