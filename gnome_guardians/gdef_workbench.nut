/* Gnome guardians workbench entity script.
 *
 * Copyright (c) Rectus 2015
 */
 
// Adds an build exclusion zone to the the workbench.
if("g_ModeScript" in getroottable() && "ExclusionZoneList" in g_ModeScript.SessionState)
{
	local A = RotatePosition(self.GetOrigin(), self.GetAngles(), Vector(-36, 72, 0)) + self.GetOrigin();
	local B = RotatePosition(self.GetOrigin(), self.GetAngles(), Vector(36, 72, 0)) + self.GetOrigin();
	local D = RotatePosition(self.GetOrigin(), self.GetAngles(), Vector(-36, -72, 0)) + self.GetOrigin();

	g_ModeScript.SessionState.ExclusionZoneList[self] <- 
		{ type = g_ModeScript.EXCLUSION_RECTANGLE, 
			a = A, b = B, d = D };
}