// Speedrun mutation base script
// By: Rectus

local HEALTH_CAP = 100;  // Max amount of health the players can regenerate.
local INCAP_TIME = 2; // Number of update cycles before incapped players are revived.
local BOT_ATTACK_RANGE = 256;

IncludeScript("VSLib");

MutationOptions <-
{
	ActiveChallenge = 1 
	cm_AutoReviveFromSpecialIncap = 1
	cm_AllowPillConversion = 0
	cm_DominatorLimit = 4
	cm_MaxSpecials = 6

	cm_ShouldHurry = 1
	cm_FirstManOut = 1
	cm_WitchLimit = 10
	TankLimit = 0
	SpitterLimit = 0
	SurvivorMaxIncapacitatedCount = 99
	SpecialInitialSpawnDelayMin = 5
	SpecialInitialSpawnDelayMax = 30
	cm_ShouldEscortHumanPlayers = 0
	
	PreferredMobDirection = SPAWN_IN_FRONT_OF_SURVIVORS
	referredSpecialDirection = SPAWN_SPECIALS_IN_FRONT_OF_SURVIVORS
	
	// convert items to better ones
	weaponsToConvert =
	{
		weapon_pipe_bomb = 	"weapon_molotov_spawn"
		weapon_vomitjar = 	"weapon_molotov_spawn"
		weapon_pain_pills = "weapon_adrenaline"
		weapon_rifle_m60  = "weapon_rifle_spawn"
		weapon_autoshotgun  = "weapon_rifle_spawn"
		weapon_shotgun_spas  = "weapon_rifle_spawn"
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}	
	
	weaponsToRemove =
	{
		weapon_first_aid_kit = 0
		weapon_defibrillator = 0
		weapon_grenade_launcher = 0
	}

	function AllowWeaponSpawn( classname )
	{
		if ( classname in weaponsToRemove )
		{
			return false;
		}
		return true;
	}
}

MutationState <-
{
	BotCommand = 0,
	InSaferoom = false,
	Winner = null,
	BotMoveTarget = null,
	SpeedrunStarted = false,
	InFinale = false,
	PuntTable = {},
	AllowPunt = false
}

function OnGameplayStart()
{
	// Add the punt think funtion
	if(!("PuntTimer" in g_ModeScript))
		PuntTimer <- Timers.AddTimer(0.1, true, ApplyPunt);
			
	SessionState.Winner = null;
	SessionState.InSaferoom = false;
	Scoring_LoadTable( SessionState.MapName, SessionState.ModeName );
	if("MapGameplayStart" in g_MapScript)
		MapGameplayStart();
}

function OnShutdown()
{
	ScriptedMode_RemoveSlowPoll(PeriodicalUpdate);
	EntFire("speedrun_punt", "Kill"); // Remove the punt think function
}


function AddSurvivorHealth( amount )
{
	survivorEntity <- null;
	health <- 0;
	while((survivorEntity <- Entities.FindByClassname(survivorEntity, "player")))
	{
		if(survivorEntity.IsSurvivor() && !survivorEntity.IsIncapacitated())
		{
			health = survivorEntity.GetHealth() + survivorEntity.GetHealthBuffer() + amount;
			if(health <= HEALTH_CAP)
			{
				survivorEntity.SetHealth(health);
				survivorEntity.SetHealthBuffer(0);
			}
			else if(health < 1)
			{
				survivorEntity.SetHealth(1);
				survivorEntity.SetHealthBuffer(0);
			}
			else
			{
				survivorEntity.SetHealth(HEALTH_CAP);
				survivorEntity.SetHealthBuffer(0);
			}
		}
	}	
}

function AllowBash(attacker, victim)
{
	if ((victim.GetClassname() == "player")
		&& (attacker.GetClassname() == "player")
		&& attacker.IsSurvivor())
	{
		if(SessionState.AllowPunt)
		{
			local PUNT_FORCE = 550;
			local CORRECTION_ANGLE = QAngle(-45, 0, 0);
			local puntDir = VectorfromQAngle(attacker.EyeAngles() + CORRECTION_ANGLE);
			local impulse = Vector(puntDir.x, puntDir.y, fabs(puntDir.z)) * PUNT_FORCE;
			
			
			// Since applying force to other players seems to be disallowed
			// during a bash event, we store the impulses,
			// and apply them with a think function.
			SessionState.PuntTable[victim] <- impulse; 

		}
		else
			victim.Stagger(attacker.GetOrigin());
	}
		
	return ALLOW_BASH_ALL;
}

function ApplyPunt(__none)
{
	foreach(victim, impulse in g_ModeScript.SessionState.PuntTable)
		victim.ApplyAbsVelocityImpulse(impulse);
		
	g_ModeScript.SessionState.PuntTable <- {};
}

function VectorfromQAngle(angles, radius = 1.0)
{
	local function ToRad(angle)
	{
		return (angle * PI) / 180;
	}
	
	local yaw = ToRad(angles.Yaw());
	local pitch = ToRad(-angles.Pitch());
	
	local x = radius * cos(yaw) * cos(pitch);
	local y = radius * sin(yaw) * cos(pitch);
	local z = radius * sin(pitch);
	
	return Vector(x, y, z);
}

function AllowTakeDamage(damageTable)
{
	//DeepPrintTable(damageTable);
	
	if(!SessionState.SpeedrunStarted 
		&& (damageTable.Victim.GetClassname() == "player")
		&&	damageTable.Victim.IsSurvivor())
		
		return false;
	
	// Autorevive when incapped
	if ((!SessionState.InSaferoom)
		&& (damageTable.Victim.GetClassname() == "player")
		&& damageTable.Victim.IsSurvivor()
		&& (damageTable.Victim.IsIncapacitated()
		||	damageTable.Victim.IsHangingFromLedge()))
	{
		Timers.AddTimer(5.0, false, RevivePlayer, damageTable.Victim);
		return true;

	}
	
	return true;
}

function RevivePlayer(player)
{
	player.ReviveFromIncap();
}

// When we transition to a new map
function OnGameEvent_map_transition(params)
{
	SessionState.SpeedrunStarted = false;
}

function OnGameEvent_player_left_start_area(params)
{
	if(!SessionState.SpeedrunStarted)
		SpeedrunStart();
}

function OnGameEvent_door_open(params)
{
	if(!SessionState.SpeedrunStarted && params.checkpoint)
		SpeedrunStart();
}

function OnGameEvent_gauntlet_finale_start(params)
{
	SessionState.InFinale = true;
	ClearBotCommands();
	SessionState.BotMoveTarget = FindBotFinaleTarget();
}


function OnGameEvent_finale_start(params)
{
	SessionState.InFinale = true;
	
	if(SessionState.FinaleStages)
		FinaleStages <- SessionState.FinaleStages
	else
		FinaleStages <- 8;
		
	for(i <- 0; i < (FinaleStages + 1); i++)
		EntFire("trigger_finale", "AdvanceFinalestate")
	
	ClearBotCommands();
	SessionState.BotMoveTarget = FindBotFinaleTarget();
}


// When a survivor reaches the safe room
function OnGameEvent_player_entered_checkpoint(params)
{
	if((Director.GetFurthestSurvivorFlow()  >= GetMaxFlowDistance()) && !SessionState.InSaferoom 
		&& ("userid" in params)
		&& GetPlayerFromUserID(params.userid).IsSurvivor())

		SpeedrunEnd(GetPlayerFromUserID(params.userid));
}

// Starts the round
function SpeedrunStart()
{
	printl("Bot target: " + SessionState.BotMoveTarget);
	GiveBotMoveCommands(null);
	
	if(!("PuntTimer" in g_ModeScript))
		PuntTimer <- Timers.AddTimer(0.1, true, ApplyPunt);
			
	PeriodicalTimer <- Timers.AddTimer(2.0, true, PeriodicalUpdate);
	BotAttackTimer <- Timers.AddTimer(3.0, true, GiveBotAttackCommands);
	
	SessionState.SpeedrunStarted = true;
	HUDManageTimers(1, TIMER_COUNTUP, 0);
	Ticker_AddToHud( SpeedrunHUD, "Start running!" );
	DisableLedgehang();
}

// Ends the round
function SpeedrunEnd(winner)
{
		Timers.RemoveTimer(PeriodicalTimer);
		Timers.RemoveTimer(BotAttackTimer);
		ClearBotCommands();
		
		HUDManageTimers(1, TIMER_STOP, 0);
		SessionState.Winner = winner;
		SessionState.InSaferoom = true;
		// quick and dirty, sets all the survivors health to 0
		AddSurvivorHealth(0 - HEALTH_CAP * 2);
		winner.SetHealth(HEALTH_CAP);
		SpeedrunDisplayScores();
			
		if(SessionState.BotMoveTarget != null)
		{
			Timers.AddTimer(7.0, false, EndTeleport, winner);
			EntFire("prop_door_rotating_checkpoint", "Close", 0, 7); // Closes the saferoom door 
		}
}

// Teleport losing survivors to the winner
function EndTeleport(winner)
{
	player <- null;
	while( (player <- Entities.FindByClassname(player, "player")))
		if(player.IsSurvivor() && (player != winner))
			player.SetOrigin(SessionState.BotMoveTarget);
}

// Changed from Update() to slowpoll
function PeriodicalUpdate(__args)
{
	g_ModeScript.SpeedrunHUD.Fields.distance.dataval = "Leader distance: " 
		+ abs(Director.GetFurthestSurvivorFlow() / GetMaxFlowDistance() * 100) + "%";
		
	if(("MapGameplayStart" in g_MapScript) && !SessionState.InFinale)
		EntFire("info_director", "EndScript"); // Make sure no director scripts interfere
	
	
	if(!SessionState.InSaferoom)
	{
		// Regenerates survivor health
		g_ModeScript.AddSurvivorHealth(1);
		
	// Checks if suvivors have reached the safe room.

		if((Director.GetFurthestSurvivorFlow() / GetMaxFlowDistance()) > 0.995)
		{
			local winner = null;
			local topDistance = 0;
			local player = null;
			while( (player = Entities.FindByClassname(player, "player")))
			{
				if(player.IsSurvivor() && (GetCurrentFlowPercentForPlayer(player) > topDistance))
				{
					winner = player;
					topDistance = GetCurrentFlowPercentForPlayer(player);
				}
			}
			g_ModeScript.SpeedrunEnd(winner);
		}
	}
}

// Find the end of the level
function FindBotFinaleTarget()
{
	
	if("BotFinaleTarget" in SessionState)
		if(SessionState.InFinale)
			return SessionState.BotFinaleTarget;

		
	printl("Error: Couldn't find finale bot target!");
	return null;
	
}

function DisableLedgehang()
{
	local player = null;
	while( (player = Entities.FindByClassname(player, "player")))
		if(player.IsSurvivor())
			DoEntFire("!self", "disableledgehang", "", 0, player, null);
}

// Gives the bots attack commands
function GiveBotAttackCommands(__args)
{	
	BOT_CMD_ATTACK <- 0
	BOT_CMD_MOVE <- 1
	BOT_CMD_RETREAT <- 2
	
	local bot = null
	
	while (bot = Entities.FindByClassname(bot, "player"))
	{
		if(bot.IsSurvivor() && IsPlayerABot(bot))
		{
			local noTarget = false;

			if(g_ModeScript.SessionState.BotCommand == 0)
			{
				// Attack nearest common
				CommandTable <-
				{
					bot = bot
					target =  Entities.FindByClassnameNearest("infected", bot.GetOrigin(), BOT_ATTACK_RANGE) 
					cmd = BOT_CMD_ATTACK
				}
				if(CommandTable.target)
				{	
					g_ModeScript.ClearBotCommand(bot);
					CommandABot(CommandTable);
				}
				else 
					noTarget = true;
			}
			
			if(noTarget || (g_ModeScript.SessionState.BotCommand == 1))
			{
				// Attack neraest other survivor or SI
				local target = null;
				while(target = Entities.FindByClassnameWithin(target, "player", bot.GetOrigin(), BOT_ATTACK_RANGE))
				{
					if(!target.IsSurvivor())
						break;
				}

				if(target) 
				{
					CommandTable <-
					{
						bot = bot
						target = target
						cmd = BOT_CMD_ATTACK
					}
					g_ModeScript.ClearBotCommand(bot);
					CommandABot(CommandTable);
				}
				else 
					noTarget = true;
				
			}
		}
	}
	g_ModeScript.SessionState.BotCommand = (g_ModeScript.SessionState.BotCommand + 1) % 2;
	Timers.AddTimer(2.0, false, g_ModeScript.GiveBotMoveCommands);
}

// Gives the bots movement commands
function GiveBotMoveCommands(__args)
{	
	BOT_CMD_ATTACK <- 0
	BOT_CMD_MOVE <- 1
	BOT_CMD_RETREAT <- 2
	
	local bot = null
	
	while (bot = Entities.FindByClassname(bot, "player"))
	{		
		// Move to level end
		if(bot.IsSurvivor() && IsPlayerABot(bot) && g_ModeScript.SessionState.BotMoveTarget)
		{
			CommandTable <-
			{
				bot = bot
				pos = g_ModeScript.SessionState.BotMoveTarget
				cmd = BOT_CMD_MOVE
			}
			CommandABot(CommandTable);
		}
	}	
}

function ClearBotCommands()
{
	local currentPlayer = null;
	while((currentPlayer = Entities.FindByClassname(currentPlayer, "player")))
	{
		if(currentPlayer.IsSurvivor() && IsPlayerABot(currentPlayer))
		{
			CommandTable <-
			{
				bot = currentPlayer
				cmd = BOT_CMD_RESET
			}
			
			//DeepPrintTable(CommandTable);
			CommandABot(CommandTable);
		}
	}
}

function ClearBotCommand(bot)
{
	CommandTable <-
	{
		bot = bot
		cmd = BOT_CMD_RESET
	}
	CommandABot(CommandTable);
}

function FindWinnerName()
{
	local currentPlayer = null;
	while( (currentPlayer = Entities.FindByClassname(currentPlayer, "player")))
	{
		if(currentPlayer == SessionState.Winner)
			return currentPlayer.GetPlayerName();
	}
	return "Unknown Winner";
}

function SetupModeHUD( )
{
	SpeedrunHUD <-
	{
		Fields =
		{
			distance = 
			{
				slot = HUD_LEFT_TOP,
				dataval = "Leader distance: 0%",
				name = "distance",
				//flags = HUD_FLAG_ALIGN_RIGHT
			}
			
			timer = 
			{
				slot = HUD_RIGHT_TOP,
				staticstring = "Time: ",
				name = "timer",
				special = HUD_SPECIAL_TIMER1
			}
			
			scoretable =
			{
				slot = HUD_MID_BOX,
				dataval = "",
				name = "scoretable"
				flags = HUD_FLAG_NOTVISIBLE | HUD_FLAG_ALIGN_CENTER
			}
		}
	}
	
	HUDSetLayout(SpeedrunHUD);
	HUDPlace(HUD_LEFT_TOP, 0.12, 0.025, 0.20, 0.04)
}


function SpeedrunDisplayScores()
{
	local winnerName = FindWinnerName();
	
	local finalTime = HUDReadTimer(1);
	local scoreStrings = Scoring_AddScoreAndBuildStrings(winnerName, finalTime)
	HUDPlace(HUD_MID_BOX, 0.30, 0.15, 0.50, 0.70)

	local scoretableContents = winnerName + ", " + scoreStrings.yourtime + "\n\n\n\n"
		+ "Top Scores:\n";

	foreach(idx, value in scoreStrings.topscores)
		scoretableContents = scoretableContents + "\n" + value;
		
	SpeedrunHUD.Fields.scoretable.dataval = scoretableContents;
	SpeedrunHUD.Fields.scoretable.flags = SpeedrunHUD.Fields.scoretable.flags & ~HUD_FLAG_NOTVISIBLE;
	Scoring_SaveTable(SessionState.MapName, SessionState.ModeName);
}

// Prints out useful information when you say debug_print
function InterceptChat(str, SrcEnt)
{
	if(str.find("debug_print") != null)
	{
		printl("DirectorOptions:");
		DeepPrintTable(DirectorOptions);
		printl("SessionOptions:");
		DeepPrintTable(SessionOptions);
		printl("SessionState:");
		DeepPrintTable(SessionState);
	}
	else if(str.find("!punt") != null)
	{
		if(!SessionState.AllowPunt)
		{
			SessionState.AllowPunt <- true;
			Say(SrcEnt, "Speedrun: Player punting enabled!", false);
		}
		else
		{
			SessionState.AllowPunt <- false;
			Say(SrcEnt, "Speedrun: Player punting disabled!", false);
		}
	}
}