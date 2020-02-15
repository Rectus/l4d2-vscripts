Msg("Onslaught script intiated\n")

	DirectorOptions <-
	{
		// This turns off tanks and witches.
		ProhibitBosses = true
		
		//LockTempo = true
		MobSpawnMinTime = 5
		MobSpawnMaxTime = 10
		MobMinSize = 12
		MobMaxSize = 17
		MobMaxPending = 25
		SustainPeakMinTime = 3
		SustainPeakMaxTime = 6
		IntensityRelaxThreshold = 0.99
		RelaxMinInterval = 5
		RelaxMaxInterval = 10
		RelaxMaxFlowTravel = 300
		SpecialRespawnInterval = 5
		NumReservedWanderers = 0

		PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
		ZombieSpawnRange = 1500
	}


Director.ResetMobTimer()
Director.PlayMegaMobWarningSounds()