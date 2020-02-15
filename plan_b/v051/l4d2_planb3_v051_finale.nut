
CustomOptions <-
{
	PanicForever = true
	PausePanicWhenRelaxing = true

	// Not sure if these have that much effect in a gauntlet.
	IntensityRelaxThreshold = 0.99
	RelaxMinInterval = 25
	RelaxMaxInterval = 35
	RelaxMaxFlowTravel = 400

	LockTempo = 0
	SpecialRespawnInterval = 20
	MaxSpecials = 3
	PreferredSpecialDirection = SPAWN_SPECIALS_IN_FRONT_OF_SURVIVORS
	PreTankMobMax = 15
	ZombieSpawnRange = 2000
	ZombieSpawnInFog = true

	MobSpawnSize = 5
	CommonLimit = 5

	// The movement bonus increases the time between hordes spawning when survivors aren't moving towards the goal. A timer continuosly increases the bonus size.
	
	GauntletMovementThreshold = 500.0	// Moving past this threshold increases it and clears the movement bonus.
	GauntletMovementTimerLength = 4.0	// How long between increasing the bonus length.
	GauntletMovementBonus = 3.0			// The amount the bonus is increased each timer length.
	GauntletMovementBonusMax = 30.0		// The max size of the bonus.

	// length of map to test progress against.
	TunnelSpan = 20000

	MobSpawnMinTime = 5
	MobSpawnMaxTime = 5

	
	// Local variables.
	MobSpawnSizeMin = 5
	MobSpawnSizeMax = 15
	MobSpawnSizeMaxProgress = 10	// How much the horde size is influenced by progress.

	minSpeed = 50
	maxSpeed = 200

	speedPenaltyZAdds = 15

	CommonLimitMax = 20

	function RecalculateLimits()
	{
	//Increase common limit based on progress  
		local progressPct = ( Director.GetFurthestSurvivorFlow() / TunnelSpan )
		
		if ( progressPct < 0.0 ) progressPct = 0.0;
		if ( progressPct > 1.0 ) progressPct = 1.0;
		
		MobSpawnSize = MobSpawnSizeMin + progressPct * ( MobSpawnSizeMaxProgress - MobSpawnSizeMin )


	//Increase common limit based on speed   
		local speedPct = ( Director.GetAveragedSurvivorSpeed() - minSpeed ) / ( maxSpeed - minSpeed );

		if ( speedPct < 0.0 ) speedPct = 0.0;
		if ( speedPct > 1.0 ) speedPct = 1.0;

		MobSpawnSize = MobSpawnSize + speedPct * ( speedPenaltyZAdds );
		
		CommonLimit = MobSpawnSize * 1.5
		
		if ( CommonLimit > CommonLimitMax ) 
			CommonLimit = CommonLimitMax;

	}
}

function AddTableToTable( dest, src )
{
	foreach( key, val in src )
	{
		dest[key] <- val
	}
}

AddTableToTable(DirectorOptions, CustomOptions);

function Update()
{
	DirectorOptions.RecalculateLimits();
}
