/* Gnome guardians turret crate build script.
 *
 * Copyright (c) Rectus 2015
 */

printl("Turret crate use script!")

BUILD_TEXT <- "Assemble Turret";
BUILD_TIME <- 2;

CHECK_TURRET_CAP <- true;
ALLOW_BUILD_NEAR_TURRETS <- false;

prop <- null;
dropped <- false;
validBuildSite <- true;
buildDelayed <- true;
usingPlayer <- null;
built <-false;

function Precache()
{
	self.PrecacheScriptSound("Player.AwardUpgrade");

	self.SetProgressBarText(BUILD_TEXT);
	self.SetProgressBarSubText("");
	self.SetProgressBarFinishTime(BUILD_TIME);
	self.SetProgressBarCurrentProgress(0.0);
}

function OnPostSpawn()
{
	Assert((prop = Entities.FindByName(null, self.GetUseModelName())) != null);
	
	EntFire("!self", "RunScriptCode", "buildDelayed = false", 0.5);
}

function Think()
{	
	if(dropped)
	{
		//printl("Think() dropped")
		dropped = false;
		PickupProp();
	}
}

function OnUseStart()
{
	//printl("OnUseStart: " + self.GetName())
	local crateList = g_ModeScript.SessionState.CrateList;
	local player = null;
	local invTable = {};
	validBuildSite = true;
	
	if(dropped || buildDelayed || built)
	{
		//printl("prop dropped!")
		self.StopUse();
		return false;
	}
	
	// Don't allow build if anyone is carrying the crate.
	while(player = Entities.FindByClassname(player, "player"))
	{
		GetInvTable(player, invTable);
		//g_ModeScript.DeepPrintTable(invTable);
		
		if("Held" in invTable && invTable.Held == prop)
		{		
			//printl("prop held!")
			self.StopUse();
			return false;
		}
	}
	
	if(CHECK_TURRET_CAP && g_ModeScript.SessionState.NumTurrets >= g_ModeScript.TURRET_CAP)
	{
		self.SetProgressBarText("Turret limit reached!");
		validBuildSite <- false;
	}
	else 
	{
		if(CheckBuildLocation())
		{
			self.SetProgressBarText(BUILD_TEXT);
		}
		DoEntFire("!self", "RunScriptCode", "CheckBuildLocation()", BUILD_TIME / 4.0, self, self);
	}

	crateList[prop] <- true;
	self.SetProgressBarSubText("Release to pick up");
	usingPlayer = GetUsingPlayer();
	
	return true;
}

function CheckBuildLocation()
{
	if(!g_ModeScript.IsValidBuildLocation(prop.GetOrigin(), ALLOW_BUILD_NEAR_TURRETS))
	{
		self.SetProgressBarText("Can not build here!");
		validBuildSite <- false;
	}
	
	return validBuildSite;
}

function OnUseStop( timeUsed )
{
	//printl("OnUseStop( " + timeUsed+ " ): " + self.GetName())

	self.SetProgressBarSubText("");
	
	dropped = true;
	
}

function PickupProp()
{
	local player = null;
	
	g_ModeScript.SessionState.CrateList[prop] = false;
	
	if((player = Entities.FindByClassnameNearest("player", prop.GetOrigin(), 512)))
	{
		PickupObject(player, prop);
		g_ModeScript.CratePickedUp();
		//printl("Pickup: player = " + player + " prop = " + prop);
	}
	
	buildDelayed = true;
	EntFire("!self", "RunScriptCode", "buildDelayed = false", 0.5);
	self.SetProgressBarText(BUILD_TEXT);
}

function OnUseFinished()
{
	//printl("OnUseFinished(): " + self.GetName() + usingPlayer)
	
	dropped = false;
	
	if(CheckBuildLocation())
	{
		built = true;
		prop.SetVelocity(Vector(0, 0, 0));
		delete g_ModeScript.SessionState.CrateList[prop];
		EntFire(self.GetUseModelName(), "FireUser2" 0, 0.02);
		DoEntFire("!self", "RunScriptCode" "SetCrateAngles()", 0.02, self, self);
		EntFire(self.GetUseModelName(), "FireUser1" 0, 0.25);
		EmitSoundOnClient("Player.AwardUpgrade", usingPlayer);
	}
	else
	{
		buildDelayed = true;
		EntFire("!self", "RunScriptCode", "buildDelayed = false", 0.5);
	}
} 

function SetCrateAngles()
{
	prop.SetAngles(QAngle(0, prop.GetAngles().Yaw(), 0));
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

