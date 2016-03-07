
IncludeScript("sm_resources", g_MapScript)
IncludeScript("usetargets/base_buildable_target")

BuildableType	<- "Barricade Materials"
ResourceCost	<- 0

// button options
BuildTime		<- g_ModeScript.BARRICADE_BUY_TIME;
BuildText		<- "Pick up materials"
BuildSubText	<- ""

GLOW_RANGE <- 150

function OnPostSpawn()
{
	SetGlowRange(GLOW_RANGE);
}
