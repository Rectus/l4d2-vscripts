// Football use script
// Attach to a point_script_use_target

KICK_FORCE <- 1000;
KICK_OFFSET <- Vector(0, 0, 4);
ball <- null;
allowKick <- true;

function Precache()
{
	ball = Entities.FindByName(null, self.GetUseModelName());
	if(ball == null)
	{
		self.Kill();
		return;
	}	
		
	ball.PrecacheScriptSound("physics/rubber/rubber_tire_impact_soft3.wav");
	self.CanShowBuildPanel(false);
}

function OnUseStart()
{	
	if(!allowKick)
		return false;

	local kickVector = ball.GetOrigin() - GetUsingPlayer().GetOrigin() + KICK_OFFSET;
	kickVector = kickVector * (1 / kickVector.Length()) * KICK_FORCE;
	ball.ApplyAbsVelocityImpulse(kickVector);
	EmitSoundOn("physics/rubber/rubber_tire_impact_soft3.wav", ball);
	allowKick = false;
	DoEntFire("!self", "RunScriptCode", "allowKick = true", 0.2, self, self); // Ghetto timer
	return false;
}

function GetUsingPlayer()
{
	local player = null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(player.GetEntityHandle() == PlayerUsingMe)
		{
			return player;
		}
	}
 
	return null;
}