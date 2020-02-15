
enabled <- false;
codebook <- false;
prop <- null;

function Precache()
{
	self.SetProgressBarText("Use door console");
	self.SetProgressBarSubText("");
	self.SetProgressBarFinishTime(7);
	enabled = true;
	prop = Entities.FindByName(null, self.GetUseModelName());
	Assert(prop);
}

function UseCodebook()
{
	codebook = true;
	self.SetProgressBarFinishTime(6);
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
		if(codebook)
			self.SetProgressBarSubText("Using codebook");
		else
			self.SetProgressBarSubText("");
			
			
		self.SetProgressBarText("Figuring out door code...");
		return true;
	}
	return false;
}

function OnUseStop(useTime)
{
	self.SetProgressBarText("Use door console");
}

function OnUseFinished()
{
	Disable();
}