Msg("Initiating Bunker Secret Finale Onslaught stage\n");


DirectorOptions <-
{

	ProhibitBosses = true
	ZombieSpawnRange = 2000
	
	MusicDynamicMobSpawnSize = 8
	MusicDynamicMobStopSize = 2
	MusicDynamicMobScanStopSize = 1

	function RecalculateLimits()
	{
	}
	
	MobSpawnMinTime = 10
	MobSpawnMaxTime = 25
	
	IntensityRelaxThreshold = 1.1
	RelaxMinInterval = 10
	RelaxMaxInterval = 20
	SustainPeakMinTime = 25
	SustainPeakMaxTime = 30
	
	MobMinSize = 10
	MobMaxSize = 20
	CommonLimit = 20
	
	//SpecialRespawnInterval = 100
}

Director.ResetMobTimer();

