
KICK_FORCE <- 1000000;
KICK_OFFSET <- Vector(0, 0, 16);

function Precache()
{
	self.PrecacheScriptSound("physics/rubber/rubber_tire_impact_soft3.wav");
}

function Kick(player)
{
	local kickVector = self.GetOrigin() - player.GetOrigin() + KICK_OFFSET;
	kickVector = kickVector * (1 / kickVector.Length()) * KICK_FORCE;
	self.ApplyAbsVelocityImpulse(kickVector);
	EmitSoundOn("physics/rubber/rubber_tire_impact_soft3.wav", self);
}

function OnGameEvent_player_use(params)
{
	local item = null;
	if(("targetid" in params))
	{
		if((item = EntIndexToHScript(params.targetid)))
		{
			if(item.GetName().find("football") >= 0)
			{
				item.GetScriptScope().Kick(GetPlayerFromUserID(params.userid));
			}
		}
	}
}

if(!"FootballUseRegistered" in getroottable())
{
	__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
	::FootballUseRegistered <- true;
}
