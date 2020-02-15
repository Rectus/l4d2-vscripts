Msg("Bunker door onslaught script intiated\n")


DirectorOptions <-
{
	// This turns off tanks and witches.
	ProhibitBosses = false
	
	//LockTempo = true
	MobSpawnMinTime = 4
	MobSpawnMaxTime = 8
	MobMinSize = 15
	MobMaxSize = 20
	MobMaxPending = 25
	SustainPeakMinTime = 3
	SustainPeakMaxTime = 6
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 1
	RelaxMaxInterval = 3
	RelaxMaxFlowTravel = 0
	
	SpecialRespawnInterval = 20
	JockeyLimit = 0
	ChargerLimit = 0
	SpitterLimit = 2
	MaxSpecials = 3

	PreferredMobDirection = SPAWN_ABOVE_SURVIVORS
	ZombieSpawnRange = 1250
}


Director.ResetMobTimer()
Director.PlayMegaMobWarningSounds()