
IncludeScript("sm_resources", g_MapScript)
IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "Turret crate"
ResourceCost	<- 1

// button options
BuildTime		<- 2
BuildText		<- "Buy Test Turret"

if( ResourceCost )
{
	BuildSubText	<- "Cost: " + ResourceCost
}
else
{
	BuildSubText	<- "Cost: FREE"
}
