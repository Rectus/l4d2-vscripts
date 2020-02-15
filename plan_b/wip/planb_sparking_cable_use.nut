
enabled <- false;
prop <- null;
door <- null;
secondExplosion <- false;
inUse <- false;
explosionHalted <- false;
totalUseTime <- 0.0;

function OnPostSpawn()
{
	self.SetProgressBarText("Repair the cable");
	self.SetProgressBarSubText("");
	self.SetProgressBarFinishTime(18);
	enabled = false;
	prop = Entities.FindByName(null, self.GetUseModelName());
	Assert(prop);
	
	door = Entities.FindByName(null, "door_explosive_2");
	Assert(door);
	
	self.CanShowBuildPanel(false);
}

function Explode()
{
	Enable();
}

function ExplodeAgain()
{
	if(inUse || explosionHalted)
	{
		EntFire("cable_sparking_relay1", "Trigger");
		self.StopUse();
		Disable();
		DoEntFire("!self", "runscriptcode", "Enable()", 5, self, self);
		secondExplosion = true;
	}
	else
	{
		explosionHalted = true;
	}
}

function Enable()
{
	enabled = true;
	self.CanShowBuildPanel(true);
	DoEntFire("!self", "startglowing", "", 0, "", prop);
}

function Disable()
{
	enabled = false;
	self.CanShowBuildPanel(false);
	DoEntFire("!self", "stopglowing", "", 0, "", prop);
}

function OnUseStart()
{
	if(enabled)
	{
		if(!secondExplosion)
		{
			if(!explosionHalted)
			{
				DoEntFire("!self", "runscriptcode", "ExplodeAgain()", RandomFloat(2, 3.5), self, self);
			}
			else
			{
				DoEntFire("!self", "runscriptcode", "ExplodeAgain()", 0.1, self, self);
			}
		}
	
		inUse = true;
		EntFire("door_explosive_2", "Close", "", 0.0);
		EntFire("door_explosive_2", "SetSpeed", "3", 0.01);
		EntFire("door_explosive_2", "Open", "", 0.02);
		DoEntFire("!self", "SetAnimation", "repair", 0.0, prop, prop);
		EntFire("door_spark", "StartSpark", "", 0.7);
		return true;
	}
	return false;
}

function OnUseStop(useTime)
{
	inUse = false;
	self.SetProgressBarCurrentProgress(useTime);
	EntFire("door_explosive_2", "SetSpeed", "0.001");
	EntFire("door_explosive_2", "Close", "", 0.01);
	DoEntFire("!self", "SetAnimation", "fall", 0.0, prop, prop);
	EntFire("door_spark", "StopSpark");
}

function OnUseFinished()
{
	inUse = false;
	Disable();
	EntFire("cable_sparking_relay2", "Trigger");
	EntFire("door_explosive_2", "SetSpeed", "0.001");
}