/* Gnome guardians mingun turret computer script.
 *
 * Copyright (c) Rectus 2015
 */

prop <- null;
enabled <-false;
turret <- null;
TURRET_NAME <- "mg_turret_gun";
NAME <- "mg_turret_comp_use";
buttonReuseCounter <- 20;

lastStatusMode <- -1;
lastStatusOverheated <- true;

function Precache()
{
	self.PrecacheScriptSound("Buttons.snd37");
	
	// UseModelEntity doesn't exsist here yet.
	prop = Entities.FindByName(null, self.GetUseModelName());
	local prefix = self.GetName().slice(0, self.GetName().find(NAME));
	turret = Entities.FindByName(null, self.GetName().slice(0, self.GetName().find(NAME)) + 
		TURRET_NAME + self.GetName().slice(prefix.len() + NAME.len()));
	Assert(turret, "Turret not found:" + self);
	Assert(prop, "Invalid use target:" + self);
	
	AddThinkToEnt(self, "Think");
	
	self.SetProgressBarFinishTime(1);
}

function Think()
{
	UpdateState();

	if(!enabled)
	{
		if(--buttonReuseCounter < 1)
		{
			enabled = true;
			buttonReuseCounter = 5;
		}
	}
}


function UpdateState()
{
	local status = "";
	local turretScope = turret.GetScriptScope();
	if(turretScope.targetingMode != lastStatusMode)
	{
		switch(turretScope.targetingMode)
		{
			case turretScope.TGT_MODE_RANDOM:
			{
				self.SetProgressBarSubText("Targeting mode: Random");
				break;
			}
			case turretScope.TGT_MODE_CLOSEST:
			{
				self.SetProgressBarSubText("Targeting mode: Closest");
				break;
			}
			case turretScope.TGT_MODE_FURTHEST:
			{
				self.SetProgressBarSubText("Targeting mode: Furthest");
				break;
			}
		}
		lastStatusMode = turretScope.targetingMode;
	}
	
	if(g_ModeScript.OPTIMIZE_NETCODE)
	{
		if(turretScope.overheated != lastStatusOverheated)
		{
			if(turretScope.overheated)
			{
				self.SetProgressBarCurrentProgress(1);
				status = "OVERHEAT!";
			}
			else
			{
				self.SetProgressBarCurrentProgress(0);
				status = "Operational";
			}
			
			lastStatusOverheated = turretScope.overheated;
			self.SetProgressBarText("STATUS: " + status);
		}
	}
	else
	{	
		self.SetProgressBarFinishTime(turret.GetScriptScope().MAX_HEAT);
		
		if(turretScope.overheated)
		{
			self.SetProgressBarCurrentProgress(turretScope.heat);
			status = "OVERHEAT!";
		}
		else if(turretScope.targetAimedAt)
		{
			self.SetProgressBarCurrentProgress(turretScope.heat);
			status = "Firing";
		}
		else if(turretScope.target)
		{
			self.SetProgressBarCurrentProgress(turretScope.heat);
			status = "Tracking";
		}
		else
		{
			self.SetProgressBarCurrentProgress(turretScope.heat);
			status = "Scanning";
		}
		
		self.SetProgressBarText("STATUS: " + status);
	}
}

function OnUseStart()
{
	if(enabled)
	{
		EmitSoundOn("Buttons.snd37", prop);
		turret.GetScriptScope().targetingMode = (turret.GetScriptScope().targetingMode + 1) % 3;
		turret.GetScriptScope().target = null;
		enabled = false;
	}
	
	return false;
}

