
prop <- null;
enabled <-false;
turret <- null;
TURRET_NAME <- "turret_gun";
NAME <- "turret_comp_use";
buttonReuseCounter <- 20;

function Precache()
{
	self.PrecacheScriptSound("Buttons.snd37");
	
	// UseModelEntity doesn't exsist here yet.
	prop = Entities.FindByName(null, self.GetUseModelName());
	turret = Entities.FindByName(null, TURRET_NAME + self.GetName().slice(NAME.len()));
	Assert(turret, "Turret not found:" + self);
	Assert(prop, "Invalid use target:" + self);
	self.SetProgressBarFinishTime(10);
	self.SetProgressBarText("Reprogram turret");
	enabled = true;
}




function OnUseStart()
{
	self.SetProgressBarText("Reprogramming turret...");

	return enabled;
}

function OnUseStop(timeUsed)
{
	self.SetProgressBarText("Reprogram turret");
}

function OnUseFinished()
{
	EmitSoundOn("Buttons.snd37", prop);
	DoEntFire("!self", "Skin", "3", 0, prop, prop);

	turret.GetScriptScope().TARGET_PRIORITY <-
	[
		{
			tgtClass = ["player"],
			zombieType = 8
		},
		{
			tgtClass = ["player"],
			isSurvivor = false
		},
		{
			tgtClass = ["infected"]
		}
	]
	
	turret.GetScriptScope().target = null;
	self.CanShowBuildPanel(false);
	enabled = false;
}
