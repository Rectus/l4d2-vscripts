Msg("Barricade onslaught script intiated\n")

DirectorOptions <-
{
	// This turns off tanks and witches.
	ProhibitBosses = true
	
	//LockTempo = true
	MobSpawnMinTime = 5
	MobSpawnMaxTime = 10
	MobMinSize = 20
	MobMaxSize = 30
	MobMaxPending = 15
	SustainPeakMinTime = 5
	SustainPeakMaxTime = 10
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 3
	RelaxMaxInterval = 7


	ZombieSpawnInFog = true
	ZombieSpawnRange = 2200
}

Director.PlayMegaMobWarningSounds()
Director.ResetMobTimer()
