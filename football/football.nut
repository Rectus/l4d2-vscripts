
MutationState <-
{
	GameStarted = false
	RedScore = 0
	BlueScore = 0
	Ball = null
	
	AttackerRatio = 3
	MoveRadiusMax = 512
	MoveRadiusMin = 32
	MoveLimit = 512
	CurrentCycle = 0
	CyclePos = 0
	Cycles = 50
	CommandInterval = 2
	MoveInterval = 20
}

MutationOptions <-
{	
	cm_NoSurvivorBots = true
	
	SpawnSetRule = SPAWN_FINALE
	SpecialInfectedAssault = 0
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
	CommonLimit  = 22
	TankLimit    = 0
	PanicWavePauseMax = 0
	PanicWavePauseMin = 0
	AddToSpawnTimer = 0
	ZombieSpawnRange = 7000
	BileMobSize = 0
	ZombieDontClear = 1
	MegaMobSize = 500	
}

footballHUD <-
{
	Fields =
	{
		blue =
		{
			slot = HUD_RIGHT_TOP
			staticstring = "Blue: "
			datafunc = @() g_ModeScript.SessionState.BlueScore
			flags = HUD_FLAG_NOBG
			name = "Blue"
		}
	
		red = 
		{
			slot = HUD_LEFT_TOP
			staticstring = "Red: "
			datafunc = @() g_ModeScript.SessionState.RedScore
			flags = HUD_FLAG_NOBG
			name = "Red"
		}
				
		timer =
		{
			slot = HUD_MID_TOP
			//staticstring = ""
			special = HUD_SPECIAL_TIMER0 
			flags = HUD_FLAG_NOBG
			name = "Timer"
		}
	}
}

function OnGameplayStart()
{
	HUDSetLayout(footballHUD);
	EntFire("chase_football", "EnableMotion", "", 5);
	EntFire("chase_football", "Sleep", "", 5.01);
}

function StartGame()
{
	SessionState.Ball <- Entities.FindByName(null, "chase_football");
	SessionState.Ball.GetScriptScope()["BallThink"] <- @() g_ModeScript.PlayBall();
	AddThinkToEnt(SessionState.Ball, "BallThink");

	SessionState.GameStarted = true;
	Director.ForceNextStage();
	HUDManageTimers(0, TIMER_COUNTUP, 0);
}

function GetNextStage()
{
	if(SessionState.GameStarted)
	{
		DirectorOptions.ScriptedStageType <- STAGE_PANIC;
		DirectorOptions.ScriptedStageValue <- 1;
	}
	else
	{
		DirectorOptions.ScriptedStageType <- STAGE_SETUP;
		DirectorOptions.ScriptedStageValue <- 0;
	}
}

function PlayGoalEffects()
{
	local player = null;
	
	while (player = Entities.FindByClassname(player, "player"))
	{	
		EmitSoundOnClient("Scavenge.point_scored", player);
		DoEntFire("!self", "speakresponseconcept", "PlayerNiceJob", 0, null, player);
	}
}

function PlayBall()
{	
	if(SessionState.CurrentCycle % SessionState.CommandInterval == 0)
	{
		local num = SessionState.CyclePos;
		local bot = null;
		local CommandTable = {};
		
		while (bot = Entities.FindByClassname(bot, "infected"))
		{		
			if((num++ % SessionState.AttackerRatio) == 0)
			{
				if(SessionState.CurrentCycle % SessionState.MoveInterval == 0)
				{
					if((bot.GetOrigin() - SessionState.Ball.GetOrigin()).Length() > SessionState.MoveLimit)
					{
						ClearBotCommands(bot);
						//DebugDrawLine(SessionState.Ball.GetOrigin(), bot.GetOrigin(), 0, 0, 127, true, 0.5);
					}
					else 
					{
						local movePos = SessionState.Ball.GetOrigin()
							+ VectorFromQAngle(QAngle(0, RandomInt(0, 359), 0)
								, RandomInt(SessionState.MoveRadiusMin , SessionState.MoveRadiusMax));
					
						//DebugDrawLine(movePos, bot.GetOrigin(), 0, 192, 0, true, 0.5);
						//DebugDrawCircle(movePos, Vector(0, 128, 0), 192, 8, true, 0.5);
					
						CommandTable =
						{
							bot = bot
							pos = movePos
							cmd = BOT_CMD_MOVE
						}
						CommandABot(CommandTable);
						continue;
					}
				}
			}
		
			CommandTable =
			{
				bot = bot
				target = SessionState.Ball
				cmd = BOT_CMD_ATTACK
			}
			CommandABot(CommandTable);
			//DebugDrawLine(SessionState.Ball.GetOrigin(), bot.GetOrigin(), 192, 0, 0, true, 0.5);	
		}
		
	}	
	
	SessionState.CurrentCycle++;
	if(SessionState.CurrentCycle >= SessionState.Cycles)
	{
		SessionState.CurrentCycle = 0;
		SessionState.CyclePos = (SessionState.CyclePos + 1) % SessionState.AttackerRatio;
	}
}

function ClearBotCommands(bot)
{

	local CommandTable =
	{
		bot = bot
		cmd = BOT_CMD_RESET
	}
	
	CommandABot(CommandTable);
}

function VectorFromQAngle(angles, radius = 1.0)
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