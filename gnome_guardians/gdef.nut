/* Gnome guardians mode script.
 *
 * Copyright (c) Rectus 2015
 */

printl("Gnome Guardians mode script")

if( !("g_ResourceManager" in getroottable()) )
{
	IncludeScript("sm_resources", this);
}

// Game state enums.
STATE_SETUP <- 0
STATE_ASSAULT <- 1
STATE_CLEAROUT <- 2
STATE_COOLDOWN <- 3
STATE_BEGIN <- 4
STATE_END <- 5


COMMON_DAMAGE_MODIFIER <- 0.5
GNOME_DAMAGE_MODIFIER <- 0.075
GNOME_LOWHEALTH <- 10.0

REPLACE_INFECTED_INTERVAL <- 5
COMMON_REWARD <- 1

// Exclusion zone enums.
EXCLUSION_RADIAL <- 0
EXCLUSION_RECTANGLE <- 1

STARTING_CASH <- 100

STAGE_BONUS_BASE <- 25
STAGE_BONUS_MULTIPLIER <- 5

MONEY_PICKUP_BASE <- 10
MONEY_WAD_DROP_CHANCE <- 0.05

TURRET_CAP <- 50

BARRICADE_BUY_TIME <- 3
BARRICADE_BUILD_TIME <- 7

OPTIMIZE_NETCODE <- true // Disables a lot of graphical effects in multiplayer.
optimizationLevel <- 0
trackIntervalMultiplier <- 1

UncommonSpawnEntity <- 
{
	classname = "info_zombie_spawn"
	population = "default"
}

UncommonList <-
{
	riot = 
	{
		model = "models/infected/common_male_riot.mdl"
		population = "gdef_riot"
		money = 4
		health = 200
	}
	clown = 
	{
		model = "models/infected/common_male_clown.mdl"
		population = "gdef_clown"
		money = 2
		health = 200
	}
	ceda = 
	{
		model = "models/infected/common_male_ceda.mdl"
		population = "gdef_ceda"
		money = 3
		health = 225
	}
	jimmy = 
	{
		model = "models/infected/common_male_jimmy.mdl"
		population = "gdef_jimmy"
		money = 5
		health = 1000
	}
}

WaveSettings <-
[

	{
		string = ""
		uncommon = []
		ratio = []
	},

	{
		string = ": Clowns"
		uncommon = [UncommonList.clown]
		ratio = [2]
	},

	{
		string = ": Hazmat suits"
		uncommon = [UncommonList.ceda]
		ratio = [2]
	},
	
	{
		string = ": Riot cops"
		uncommon = [UncommonList.riot]
		ratio = [3]
	},
	
	{
		string = ": Riot cops and Hazmat suits"
		uncommon = [UncommonList.riot, UncommonList.ceda]
		ratio = [4, 4]
	},
	{
		string = ": Jimmy Gibbs!"
		uncommon = [UncommonList.jimmy]
		ratio = [10]
	},
]

MoneyPileKeyvals <-
{
	classname	= "scripted_item_drop"
	targetname	= "money_wad"
	origin		= Vector(0,0,0)
	angles		= Vector(0,0,0)
	model		= "models/props_gdef/moneywad.mdl"
	vscripts	= "gdef_moneywad"
}


MutationState <-
{
	Precache = true
	Debug = false

	GnomeEntity = null
	GnomeHealth = 100.0
	UncommonEntity = null
	State = STATE_SETUP
	CrateList = {}
	NumHeldCrates = 0
	NumTurrets = 0
	TurretList = []
	ExclusionZoneList = {}
	TurretExclusionZoneList = {}
	CommonInfectedList = {}
	VendingMachineList = []
	
	InitialWaveSize = 35
	WaveSize = 35
	WaveIncrease = 5
	ZombiesSpawned = 0
	
	InitialMobSize = 6
	MobSize = 6
	MobIncrease = 3
	MobMaxSize = 60
	UncommonRatio = 0
	UncommonSpawn = 0
	
	WaveNum  = -1
	NumWaves = WaveSettings.len() // Munber of waves in the list to loop through.
	WaveMobs = 1
	CurrentWaveSettings = null
	
	InitialCooldownLength = 10
	CooldownLength = 20
	ZombiesLeft = 0	// How many infected are left in the wave.
	ReplaceInfectedCounter = 0
	
	ZombiesKilled = 0
	
	ZombieHealthMultiplier = 1.0
	ZombieHealthMultiplierIncrease = 0.2
	ZombieHealthMultiplierIncreaseChange = 0.075
	
	MoneyPickupMultiplier = 1.0
	MoneyPickupMultiplierIncrease = 0.1
}

MutationOptions <-
{	
	cm_NoSurvivorBots = true
	//cm_ShouldEscortHumanPlayers = 1
	
	SpawnSetRule = SPAWN_SURVIVORS
	JournalString = ""
	SpecialInfectedAssault = 0
	AllowWitchesInCheckpoints = 1
	AllowCrescendoEvents = 0
	EnforceFinaleNavSpawnRules = 0
	IgnoreNavThreatAreas = 1
	ZombieDiscardRange = 10000

	WanderingZombieDensityModifier = 0
	BoomerLimit  = 0
 	ChargerLimit = 0
 	HunterLimit  = 0
	JockeyLimit  = 0
	SpitterLimit = 0
	SmokerLimit  = 0
	MaxSpecials  = 0
	CommonLimit  = 50
	TankLimit    = 0
	PanicWavePauseMax = 5
	PanicWavePauseMin = 1
	AddToSpawnTimer = 0
	ShouldAllowMobsWithTank = true
	ShouldAllowSpecialsWithTank = true
	ZombieSpawnRange = 2000
	BileMobSize = 20
	EscapeSpawnTanks = true
	ZombieDontClear = 1
	MegaMobSize = 50	
	
	MusicDynamicMobSpawnSize = 5
	MusicDynamicMobStopSize = 2

	
	function EndScriptedMode()
	{
		return 0;
	}
	
	weaponsToRemove =
	{
		weapon_vomitjar = 0
		weapon_melee = 0

	}

	function AllowWeaponSpawn(classname)
	{
		if (classname in weaponsToRemove)
		{
			return false;
		}
		return true;
	}	
}


gdefHUD <-
{
	Fields =
	{
		zombies =
		{
			slot = HUD_RIGHT_TOP
			dataval = "Wave 0\nInfected left: 0/0"
			name = "ZombiesLeft"
			flags = HUD_FLAG_NOBG | HUD_FLAG_NOTVISIBLE | HUD_FLAG_ALIGN_LEFT
		}
	
		cash = 
		{
			slot = HUD_LEFT_TOP
			staticstring = "$"
			datafunc = @() g_ModeScript.HUDGetCashString()
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_RIGHT
			name = "Cash"
		}
		
		turrets = 
		{
			slot = HUD_LEFT_BOT
			staticstring = "Turrets: "
			datafunc = @() g_ModeScript.SessionState.NumTurrets
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_RIGHT
			name = "Turrets"
		}
		
		timer =
		{
			slot = HUD_RIGHT_BOT
			staticstring = "Next wave in: "
			special = HUD_SPECIAL_COOLDOWN
			flags = HUD_FLAG_COUNTDOWN_WARN | HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT | HUD_FLAG_NOTVISIBLE
			name = "CooldownTimer"
		}
		
		gnome =
		{
			slot = HUD_MID_TOP
			dataval = "Gnome health: 100%"
			flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_CENTER
			name = "GnomeHealth"
		}
		
		scoreboard =
		{
			slot = HUD_MID_BOX
			dataval = ""
			flags = HUD_FLAG_NOTVISIBLE
			name = "ScoreBoard"
		}
		
		topscores =
		{
			slot = HUD_MID_BOT
			dataval = ""
			flags = HUD_FLAG_NOTVISIBLE | HUD_FLAG_NOBG
			name = "TopScores"
		}
	}
}

function Precache()
{	
	// Compile the turret scripts so they hopefully won't lag the game.
	local turretScope = {};
	DoIncludeScript("gdef_turret_mg", turretScope);
	DoIncludeScript("gdef_turret_flame", turretScope);
	DoIncludeScript("gdef_turret_laser", turretScope);
	DoIncludeScript("gdef_turret_flak", turretScope);
	DoIncludeScript("usetargets/gdef_turret_mg_use", turretScope);
	DoIncludeScript("usetargets/gdef_turret_mg_comp", turretScope);
	DoIncludeScript("usetargets/gdef_turret_flame_use", turretScope);
	DoIncludeScript("usetargets/gdef_turret_flame_comp", turretScope);
	DoIncludeScript("usetargets/gdef_turret_laser_use", turretScope);
	DoIncludeScript("usetargets/gdef_turret_laser_comp", turretScope);
	DoIncludeScript("usetargets/gdef_turret_flak_use", turretScope);
	DoIncludeScript("usetargets/gdef_turret_flak_comp", turretScope);
	
	SessionState.Precache = false;
}

function HUDUpdateZombiesLeftString()
{
	gdefHUD.Fields.zombies.dataval = "Wave " + (SessionState.WaveNum + 1) + "\nInfected left: " 
		+ g_ModeScript.SessionState.ZombiesLeft + "/" + g_ModeScript.SessionState.WaveSize;
}

function HUDGetCashString()
{
	if( !("g_ResourceManager" in getroottable()) )
	{
		IncludeScript("sm_resources", this);
	}
	
	return g_ResourceManager.CurrentCount;
}


function OnGameplayStart()
{
	if( !("g_ResourceManager" in getroottable()) )
	{
		IncludeScript("sm_resources", this);
	}

	Scoring_LoadTable(SessionState.MapName, SessionState.ModeName);
	HUDSetLayout(gdefHUD);
	HUDPlace(HUD_LEFT_TOP, 0.0, 0.0, 0.35, 0.075);
	HUDPlace(HUD_LEFT_BOT, 0.0, 0.075, 0.35, 0.1);
	HUDPlace(HUD_MID_TOP, 0.35, 0.0, 0.3, 0.1);
	HUDPlace(HUD_RIGHT_TOP, 0.65, 0.0, 0.35, 0.2);
	HUDPlace(HUD_RIGHT_BOT, 0.65, 0.0, 0.35, 0.2);
	Ticker_AddToHud(gdefHUD, "");
	g_ResourceManager.AddResources(STARTING_CASH);
	SessionState.GnomeHealth = 100.0;
	
	SessionState.UncommonEntity = CreateSingleSimpleEntityFromTable(UncommonSpawnEntity);
	TeleportPlayersToStartPoints( "playerstart_*") ;
	
	if("OnMapStart" in g_MapScript)
	{
		g_MapScript.OnMapStart();
	}
}


function DisplayScores()
{
	local turretScore = GetTurretBonus();
	local scores = Scoring_AddScoreAndBuildStrings(Scoring_MakeName() + ", Wave " + (SessionState.WaveNum + 1), 
		g_ResourceManager.CurrentCount + turretScore, false, false);
	
	local scoreboardString = "\nGAME OVER\n\nWave " + (SessionState.WaveNum + 1) + 
		"\nZombies Killed: " + SessionState.ZombiesKilled + 
		"\n\nScore:\n\nCash: " + g_ResourceManager.CurrentCount + 
		"\nTurret Bonus: " + turretScore + 
		"\n\nTotal Score: " + (g_ResourceManager.CurrentCount + turretScore);
	
	local topScoreString = "";
	
	foreach(score in scores.topscores)
	{
		topScoreString += score;
	}
	
	printl(scoreboardString);
	printl(topScoreString);
	
	gdefHUD.Fields.scoreboard.dataval = scoreboardString;
	gdefHUD.Fields.topscores.dataval = "Top Scores:\n" + topScoreString;
	
	HUDPlace(HUD_MID_BOX, 0.33, 0.15, 0.34, 0.75);
	HUDPlace(HUD_MID_BOT, 0.33, 0.58, 0.34, 0.30);
	gdefHUD.Fields.timer.flags = gdefHUD.Fields.timer.flags | HUD_FLAG_NOTVISIBLE;
	gdefHUD.Fields.zombies.flags = gdefHUD.Fields.zombies.flags | HUD_FLAG_NOTVISIBLE;
	gdefHUD.Fields.cash.flags = gdefHUD.Fields.cash.flags | HUD_FLAG_NOTVISIBLE;
	gdefHUD.Fields.turrets.flags = gdefHUD.Fields.turrets.flags | HUD_FLAG_NOTVISIBLE;
	gdefHUD.Fields.gnome.flags = gdefHUD.Fields.gnome.flags | HUD_FLAG_NOTVISIBLE;
	gdefHUD.Fields.scoreboard.flags = gdefHUD.Fields.scoreboard.flags & ~HUD_FLAG_NOTVISIBLE;
	gdefHUD.Fields.topscores.flags = gdefHUD.Fields.topscores.flags & ~HUD_FLAG_NOTVISIBLE;
	
	Scoring_SaveTable(SessionState.MapName, SessionState.ModeName);
}

function GetTurretBonus()
{
	local bonus = 0;
	
	foreach(turret in SessionState.TurretList)
	{
		bonus +=turret.BONUS_VALUE;
	}
	
	return bonus;
}

function TurretBuilt(turret)
{
	if(SessionState.Debug)
		printl("Turret built: " + turret)
		
	SessionState.TurretList.append(turret);
	SessionState.NumTurrets = SessionState.TurretList.len();
	if(!OPTIMIZE_NETCODE)
	{
		optimizationLevel = 0
		trackIntervalMultiplier = 1
	}
	else if(SessionState.NumTurrets >= 45)
	{
		optimizationLevel = 2
		trackIntervalMultiplier = 2
	}
	else if(SessionState.NumTurrets >= 35)
	{
		optimizationLevel = 2
		trackIntervalMultiplier = 1
	}
	else if(SessionState.NumTurrets >= 20)
	{
		optimizationLevel = 1
		trackIntervalMultiplier = 1
	}
	else
	{
		optimizationLevel = 0
		trackIntervalMultiplier = 1
	}	
	
	if(SessionState.State == STATE_SETUP)
		StartAssault();
}

function BarricadeBuilt()
{
	if(SessionState.State == STATE_SETUP)
		StartAssault();
}

function CratePickedUp()
{	
	SessionState.NumHeldCrates++;
	
	if(SessionState.NumHeldCrates > 0)
	{
		local entity = null;
		while(entity = Entities.FindByClassname(entity, "prop_dynamic"))
		{
			if(entity.GetName().find("exclusion_zone") >= 0)
				DoEntFire("!self", "Enable", "", 0, entity, entity);
		}
	}
}

function CrateDropped()
{	
	SessionState.NumHeldCrates--;
	
	if(SessionState.NumHeldCrates < 1)
	{
		SessionState.NumHeldCrates = 0;
		local entity = null;
		while(entity = Entities.FindByClassname(entity, "prop_dynamic"))
		{
			if(entity.GetName().find("exclusion_zone") >= 0)
				DoEntFire("!self", "Disable", "", 0, entity, entity);
		}
	}
}


function StartAssault()
{
	AddThinkToEnt(SessionState.GnomeEntity, "Think");

	SessionState.State = STATE_BEGIN;
	SessionOptions.MegaMobSize <- SessionState.WaveSize;
	Director.ForceNextStage();
}


function GetNextStage()
{
	if(SessionState.Debug)
		Msg("Transferring from state: " + SessionState.State);
		
	switch(SessionState.State)
	{
		case STATE_SETUP:
		{
			DirectorOptions.ScriptedStageType <- STAGE_SETUP;
			Ticker_NewStr("Build a turret to start the game");
			
			if(SessionState.Debug)
				Msg(" to setup.\n");
				
			break;
		}
		
		case STATE_COOLDOWN: // Switch to assault
		{
			SessionState.WaveNum++;
			
			SessionState.CurrentWaveSettings = WaveSettings[SessionState.WaveNum % SessionState.NumWaves];
			
			local waveString = "Wave " + (SessionState.WaveNum + 1)
				+ SessionState.CurrentWaveSettings.string;
					
			
			if(SessionState.WaveNum > 0)
			{
				SessionState.MoneyPickupMultiplier += SessionState.MoneyPickupMultiplierIncrease;
				
				SessionState.MobSize += SessionState.MobIncrease;
				SessionState.WaveSize += SessionState.WaveIncrease;
				
				if(SessionState.MobSize > SessionState.MobMaxSize)
					SessionState.MobSize = SessionState.MobMaxSize;
					
				if(SessionState.WaveNum % SessionState.NumWaves == 0)
				{
					waveString += ", Increasing infected health"
					SessionState.ZombieHealthMultiplier += SessionState.ZombieHealthMultiplierIncrease;
					SessionState.ZombieHealthMultiplierIncrease += SessionState.ZombieHealthMultiplierIncreaseChange;
				}
			}
			
			Ticker_NewStr(waveString, 8);
			gdefHUD.Fields.zombies.flags = gdefHUD.Fields.zombies.flags & ~HUD_FLAG_NOTVISIBLE;
			gdefHUD.Fields.timer.flags = gdefHUD.Fields.timer.flags | HUD_FLAG_NOTVISIBLE;
			
			SessionState.CommonInfectedList = {};
			SessionState.ZombiesLeft = SessionState.WaveSize;
			SessionState.ZombiesSpawned = 0;
			SessionState.UncommonSpawn = 0;
		
			SessionOptions.CommonLimit <- SessionState.MobSize;
			SessionOptions.MegaMobSize <- SessionState.WaveSize;
			SessionOptions.MusicDynamicMobSpawnSize = SessionState.InitialMobSize - 1;
			HUDUpdateZombiesLeftString();
		
			SessionState.State = STATE_ASSAULT;
			DirectorOptions.ScriptedStageType <- STAGE_PANIC;
			DirectorOptions.ScriptedStageValue <- SessionState.WaveMobs;
			Director.ResetMobTimer();
			
			if(SessionState.Debug)
				Msg(" to assault.\n");
				
			break;
		}
		
		case STATE_BEGIN: // Start the game
		{
			gdefHUD.Fields.zombies.flags = gdefHUD.Fields.zombies.flags | HUD_FLAG_NOTVISIBLE;
			gdefHUD.Fields.timer.flags = gdefHUD.Fields.timer.flags & ~HUD_FLAG_NOTVISIBLE;
		
			SessionState.MobSize = SessionState.InitialMobSize;
			SessionState.WaveSize = SessionState.InitialWaveSize;
			
			SessionState.State = STATE_COOLDOWN;
			DirectorOptions.ScriptedStageType <- STAGE_DELAY;
			DirectorOptions.ScriptedStageValue <- SessionState.InitialCooldownLength;
			
			foreach(vendingMachine in SessionState.VendingMachineList)
			{
				vendingMachine.GetScriptScope().OpenForBusiness();
			}
			
			//PlaySoundForPlayers("Event.ScavengeRoundStart");
			
			if(SessionState.Debug)
				Msg(" to initial cooldown.\n");
				
			break;
		}
		
		case STATE_ASSAULT: // Switch to clearout
		{
			SessionState.State = STATE_CLEAROUT;
			DirectorOptions.ScriptedStageType <- STAGE_CLEAROUT;
			DirectorOptions.ScriptedStageValue <- 20;
			
			if(SessionState.Debug)
				Msg(" to clear out.\n");
				
			break;
		}
		
		case STATE_CLEAROUT: // Switch to cooldown
		{
			gdefHUD.Fields.zombies.flags = gdefHUD.Fields.zombies.flags | HUD_FLAG_NOTVISIBLE;
			gdefHUD.Fields.timer.flags = gdefHUD.Fields.timer.flags & ~HUD_FLAG_NOTVISIBLE;
		
			SessionState.State = STATE_COOLDOWN;
			DirectorOptions.ScriptedStageType <- STAGE_DELAY;
			DirectorOptions.ScriptedStageValue <- SessionState.CooldownLength;
			
			local bonus = ((STAGE_BONUS_BASE + SessionState.WaveNum * STAGE_BONUS_MULTIPLIER) * 
				(SessionState.GnomeHealth / 200 + 0.5)).tointeger();
			g_ResourceManager.AddResources(bonus);
			Ticker_NewStr("Stage " + (SessionState.WaveNum + 1) + " Clear Bonus: $" + bonus, 10);
			
			PlaySoundForPlayers("Event.ScavengeOvertimeEnd");
			
			if(SessionState.Debug)
				Msg(" to cooldown.\n");
				
			break;
		}
		
		case STATE_END: // Gnome destroyed
		{
			DirectorOptions.ScriptedStageType <- STAGE_RESULTS;
			DirectorOptions.ScriptedStageValue <- 3; // Factoring in the func_timescale
			
			PlaySoundForPlayers("Event.BleedingOutEnd_L4D1");
			
			
			if(SessionState.Debug)
				Msg(" to end.\n");
				
			DisplayScores();
			break;
		}
	}

}

function PlaySoundForPlayers(sound)
{
	local player = null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		EmitSoundOnClient(sound, player);
	}
}

function SpawnMoneyWad(location)
{
	MoneyPileKeyvals.origin <- location;
	CreateSingleSimpleEntityFromTable(MoneyPileKeyvals);
}

function OnMoneyPickup()
{
	g_ResourceManager.AddResources((MONEY_PICKUP_BASE * SessionState.MoneyPickupMultiplier).tointeger());
}

// Called by gnome think function.
function CollectInfected()
{
	if(SessionState.State != STATE_ASSAULT)
		return;
		
	if(SessionState.ReplaceInfectedCounter > 0)
	{
		SessionState.ReplaceInfectedCounter--;
		return;
	}
	
	local uncommonPending = 0;
	
	SessionState.ReplaceInfectedCounter = REPLACE_INFECTED_INTERVAL;
	local uncommonTypes = SessionState.CurrentWaveSettings.uncommon;
	
	local zombie = null;
	
	foreach(type in uncommonTypes)
	{
		while(zombie = Entities.FindByModel(zombie, type.model))
		{
			if(!(zombie.GetEntityIndex() in SessionState.CommonInfectedList) && (zombie.GetHealth() > 0))
			{
				SessionState.CommonInfectedList[zombie.GetEntityIndex()] <- type;
				zombie.SetHealth(type.health * SessionState.ZombieHealthMultiplier);
			}
		}		
	}
	
	zombie = null;
	
	while(zombie = Entities.FindByClassname(zombie, "infected"))
	{
		if(!(zombie.GetEntityIndex() in SessionState.CommonInfectedList) && (zombie.GetHealth() > 0))
		{
			if( SessionState.ZombiesSpawned >= SessionState.WaveSize)
			{
				zombie.Kill();
				continue;
			}
			if(SessionState.Debug)
				Msg("UncommonRatio: " + SessionState.UncommonRatio + " UncommonSpawn: " + SessionState.UncommonSpawn + "\n");
				
			SessionState.ZombiesSpawned++;
			
			zombie.SetHealth(zombie.GetHealth() * SessionState.ZombieHealthMultiplier);
		
			if((uncommonTypes.len() > 0) && (SessionState.UncommonRatio <= 0))
			{
				ReplaceInfected(zombie, uncommonTypes[SessionState.UncommonSpawn]);
				SessionState.UncommonSpawn = (SessionState.UncommonSpawn + 1) % uncommonTypes.len();
				SessionState.UncommonRatio = SessionState.CurrentWaveSettings.ratio[SessionState.UncommonSpawn];
			}
			else
			{
				SessionState.CommonInfectedList[zombie.GetEntityIndex()] <- null;
				if(SessionState.UncommonRatio > 0)
					SessionState.UncommonRatio--;
			}
		}
	}
	
	AttackGnome();
}

function ReplaceInfected(zombie, type)
{
	if(SessionState.Debug)
		Msg("Replacing zombie " + zombie + " with " + type.population + "\n");

	local spawner = SessionState.UncommonEntity;
	local zombieOrigin = zombie.GetOrigin();	
	if(zombie.GetEntityIndex() in SessionState.CommonInfectedList)
		delete SessionState.CommonInfectedList[zombie.GetEntityIndex()];
		
	zombie.Kill();
	
	spawner.SetOrigin(zombieOrigin);
	spawner.__KeyValueFromString("population", type.population);
	DoEntFire("!self", "SpawnZombie", "", 0.01, null, spawner);
	DoEntFire("!self", "StartleZombie", "", 0.02, null, spawner);
}


function AttackGnome()
{	
	
	local bot = null
	
	while (bot = Entities.FindByClassname(bot, "infected"))
	{		
		if(SessionState.GnomeEntity)
		{
			local attackTarget = SessionState.GnomeEntity;
			
			// Attack a barricade if close to one.
			local closestBarricade = Entities.FindByClassnameNearest("prop_wall_breakable", bot.GetOrigin(), 40);
			if(closestBarricade)
			{
				attackTarget = closestBarricade;
			}
		
			CommandTable <-
			{
				bot = bot
				target = attackTarget
				cmd = BOT_CMD_ATTACK
			}
			CommandABot(CommandTable);
		}
		
	}	
}


function IsValidBuildLocation(origin, allowNearTurrets)
{
	if(SessionState.State == STATE_END)
	{
		return false;
	}

	foreach(zone, params in SessionState.ExclusionZoneList)
	{
		if("zLevel" in params)
		{
			// Checks the distance vectors projection in the z axis.
			if(abs( (zone.GetOrigin() - origin).Dot(Vector(0, 0, 1)) ) > params.zLevel)
				{ continue; }
		}
	
		switch(params.type)
		{
			case EXCLUSION_RADIAL:		
			{
				if((zone.GetOrigin() - origin).Length2D() < params.radius)
					return false;
				
				break;
			}
			case EXCLUSION_RECTANGLE:
			{
				// Check if the origin is on a rectangle with ordered vertices a, b and d.
				local ao = origin - params.a;
				local ab = params.b - params.a;
				local ad = params.d - params.a;
				
				if(ao.Dot(ab) > 0 && ab.Dot(ab) > ao.Dot(ab) && ao.Dot(ad) > 0 && ad.Dot(ad) > ao.Dot(ad))
					return false;
			}
		}
	}
	if(allowNearTurrets)
	{
		return true;
	}
	
	foreach(zone, params in SessionState.TurretExclusionZoneList)
	{
		if("zLevel" in params)
		{
			// Checks the distance vectors projection in the z axis.
			if(abs( (zone.GetOrigin() - origin).Dot(Vector(0, 0, 1)) ) > params.zLevel)
				{ continue; }
		}
	
		switch(params.type)
		{
			case EXCLUSION_RADIAL:		
			{
				if((zone.GetOrigin() - origin).Length2D() < params.radius)
					return false;
				
				break;
			}
			case EXCLUSION_RECTANGLE:
			{
				// Check if the origin is on a rectangle with ordered vertices a, b and d.
				local ao = origin - params.a;
				local ab = params.b - params.a;
				local ad = params.d - params.a;
				
				if(ao.Dot(ab) > 0 && ab.Dot(ab) > ao.Dot(ab) && ao.Dot(ad) > 0 && ad.Dot(ad) > ao.Dot(ad))
					return false;
			}
		}
	}
	return true;
}


function UserConsoleCommand(playerScript, arg)
{
	switch(arg)
	{
		case "cashmoney":
		{
			g_ModeScript.Resources.AddResources(10000);
			break;
		}
		case "debug_turrets":
		{
			SessionState.Debug = true;
		
			foreach(turret in SessionState.TurretList)
			{
				turret.dbg = true;
			}
			break;
		}
		case "debug_off":
		{
			SessionState.Debug = false;
		
			foreach(turret in SessionState.TurretList)
			{
				turret.dbg = false;
			}
			break;
		}
		case "force_start":
		{
			g_ModeScript.StartAssault();
			break;
		}
		case "toggle_effects":
		{
			OPTIMIZE_NETCODE = !OPTIMIZE_NETCODE;
			
			if(!OPTIMIZE_NETCODE)
			{
				optimizationLevel = 0
				trackIntervalMultiplier = 1
			}
			else if(SessionState.NumTurrets >= 45)
			{
				optimizationLevel = 2
				trackIntervalMultiplier = 2
			}
			else if(SessionState.NumTurrets >= 35)
			{
				optimizationLevel = 2
				trackIntervalMultiplier = 1
			}
			else if(SessionState.NumTurrets >= 20)
			{
				optimizationLevel = 1
				trackIntervalMultiplier = 1
			}
			else
			{
				optimizationLevel = 0
				trackIntervalMultiplier = 1
			}	
			
			break;
		}
		case "iddqd":
		{
			SessionState.GnomeHealth = 100000;
			break;
		}
	}

}

// function OnGameEvent_player_death(params)
// {
	// DeepPrintTable(params);
// }

// function OnGameEvent_infected_hurt(params)
// {
	// DeepPrintTable(params);
// }

function OnGameEvent_infected_death(params)
{
	// "attacker"	"short"	 	// user ID who killed
	// "infected_id" "short"	// ID of the infected that died
	// "gender"		"short"		// gender (type) of the infected
	// "weapon_id"	"short"		// ID of the weapon used
	// "headshot"	"bool"		// singals a headshot
	// "minigun"	"bool"		// singals a minigun kill
	// "blast"		"bool"		// singals a death from blast damage
	// "submerged"	"bool"		// indicates the infected was submerged
	
}

function OnGameEvent_zombie_death(params)
{
	//DeepPrintTable(params);
	
	g_ModeScript.SessionState.ZombiesKilled++;
	
	if(g_ModeScript.SessionState.ZombiesLeft > 0)
		g_ModeScript.SessionState.ZombiesLeft--;
	
	local infectedList = g_ModeScript.SessionState.CommonInfectedList;
	//DeepPrintTable(infectedList);
	if(params.victim in infectedList)
	{
		local type = infectedList[params.victim];

		delete infectedList[params.victim];
	
		if(type)
		{
			g_ModeScript.Resources.AddResources(type.money);		
		}
		else
		{
			g_ModeScript.Resources.AddResources(COMMON_REWARD);
		}
	}
	else
	{
		g_ModeScript.Resources.AddResources(COMMON_REWARD);		
	}
	
	if(RandomFloat(0, 1) <= MONEY_WAD_DROP_CHANCE)
	{
		local origin = EntIndexToHScript(params.victim).GetOrigin();
		SpawnMoneyWad(origin + Vector(0, 0, 32));
	}
	
	g_ModeScript.HUDUpdateZombiesLeftString();
}


function AllowTakeDamage(damageTable)
{
	if(damageTable.Victim.GetClassname() == "infected" && damageTable.Attacker.GetName().find("turret") >= 0)
	{
		local population = "";
		if(damageTable.Victim.GetEntityIndex() in SessionState.CommonInfectedList
			&& SessionState.CommonInfectedList[damageTable.Victim.GetEntityIndex()] != null)
		{
			population = SessionState.CommonInfectedList[damageTable.Victim.GetEntityIndex()].population;
		}
		// Reduce flame turret damage on CEDA zombies.
		if(population == "gdef_ceda" && damageTable.Attacker.GetName().find("flame_turret") >= 0)
		{
			damageTable.DamageDone *= 0.25;
		}
		// Reduce flak damage on riot cops.
		if(population == "gdef_riot" && damageTable.Attacker.GetName().find("flak_turret") >= 0)
		{
			damageTable.DamageDone *= 0.50;
		}
		// Reduce laser turret damage on jimmy.
		else if(population == "gdef_jimmy" && damageTable.Attacker.GetName().find("laser_turret") >= 0)
		{
			damageTable.Victim.SetHealth(damageTable.Victim.GetHealth() - damageTable.DamageDone * 0.25);
			return false;
		}
	
		// Disable instakilling damage effects on commons (doesn't work in all cases).
		if(damageTable.Victim.GetHealth() > damageTable.DamageDone)
		{
			damageTable.Victim.SetHealth(damageTable.Victim.GetHealth() - damageTable.DamageDone)
			return false;
		}
	}
	else if(SessionState.GnomeEntity &&
		(damageTable.Victim == SessionState.GnomeEntity) &&
		(damageTable.Attacker.GetClassname() == "infected"))
		
	{
		SessionState.GnomeHealth -= damageTable.DamageDone * GNOME_DAMAGE_MODIFIER;

		UpdateHUDGnomeHealth();

		if(SessionState.GnomeHealth <= 0)
		{
			SessionState.GnomeHealth = 0;
			DoEntFire("!self", "Break", "", 0 , SessionState.GnomeEntity, SessionState.GnomeEntity);
			if(SessionState.State != STATE_END)
			{
				SessionState.State = STATE_END;
				Director.ForceNextStage();
			}
		}
			
	}
	else if(damageTable.Victim.GetClassname() == "player"
		&& (damageTable.Victim.IsSurvivor()))
	{
		return false;
	}
	else if((damageTable.Attacker.GetClassname() == "infected")
		&& damageTable.Victim.GetName().find("barricade_break") != null)
	{
		// Increase damage toward barricades.
		damageTable.DamageDone *= 2.0;
	}
	
	return true;
}

function UpdateHUDGnomeHealth()
{
	local gnomeHealthInt = (SessionState.GnomeHealth - SessionState.GnomeHealth % 1);
	
	if(SessionState.GnomeHealth < 1 && SessionState.GnomeHealth > 0)
		gnomeHealthInt = 1;
	
	gdefHUD.Fields.gnome.dataval = "Gnome health: " + gnomeHealthInt + "%";

	if(SessionState.GnomeHealth < GNOME_LOWHEALTH)
		gdefHUD.Fields.gnome.flags = gdefHUD.Fields.gnome.flags | HUD_FLAG_BLINK;
}

function CanPickupObject( object )
{
	if(SessionState.Debug)
		printl("CanPickupObject ran on: " + object);


	if(object.GetName().find("turret_crate") != null || object.GetName().find("barricade_materials") != null)
	{
		if(object in SessionState.CrateList)
		{
			if(SessionState.CrateList[object] == false)
			{
				SessionState.CrateList[object] = true;
				return true;
			}
			else
			{
				CrateDropped();
				return false;
			}
		}
		else
		{
			SessionState.CrateList[object] <- true;
			return false;
		}
	}
	else if(object.GetName().find("money_wad") != null)
	{
		return true;
	}
	else if(object.GetName().find("ammo_pack") != null)
	{
		return true;
	}
	
	// check the map script for a PickupObject function for extra qualified items

	local canPickup = false
	if( "PickupObject" in g_MapScript )
	{
		canPickup = g_MapScript.PickupObject( object )
	}
	
	return canPickup
}
