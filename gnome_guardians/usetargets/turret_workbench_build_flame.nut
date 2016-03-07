
IncludeScript("sm_resources", g_MapScript)
IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "Turret crate"
ResourceCost	<- 50

// button options
BuildTime		<- 1
BuildText		<- "Buy Flame Turret"

if( ResourceCost )
{
	BuildSubText	<- "Cost: $" + ResourceCost
}
else
{
	BuildSubText	<- "Cost: FREE"
}

// Overrides function in base_buildable_target
function UpdateCostString()
{
	BuildSubText <- "Cost: $" + ResourceCost;
	self.SetProgressBarSubText(BuildSubText);
}