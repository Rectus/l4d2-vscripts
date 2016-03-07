
prop <- null;
enabled <-false;
turret <- null;
TURRET_NAME <- "mg_turret_gun";
NAME <- "mg_turret_base_use";
buttonReuseCounter <- 20;
REFUND_PRICE <- 17;

function Precache()
{
	self.PrecacheScriptSound("Hint.LittleReward");
	
	// UseModelEntity doesn't exsist here yet.
	prop = Entities.FindByName(null, self.GetUseModelName());
	local prefix = self.GetName().slice(0, self.GetName().find(NAME));
	turret = Entities.FindByName(null, self.GetName().slice(0, self.GetName().find(NAME)) + 
		TURRET_NAME + self.GetName().slice(prefix.len() + NAME.len()));
	Assert(turret, "Turret not found:" + self);
	Assert(prop, "Invalid use target:" + self);
	self.SetProgressBarText( "Sell turret" );
	self.SetProgressBarSubText( "Refund: " + REFUND_PRICE );
	self.SetProgressBarFinishTime( 3 );
	self.SetProgressBarCurrentProgress( 0.0 );
	self.CanShowBuildPanel( true );
}


function OnUseFinished()
{
	EmitSoundOn("Hint.LittleReward", prop);
	delete g_ModeScript.SessionState.TurretExclusionZoneList[turret.GetScriptScope().exclusionZoneEnt];
	local idx = g_ModeScript.SessionState.TurretList.find(turret.GetScriptScope());
	g_ModeScript.SessionState.TurretList.remove(idx);
		
	g_ModeScript.SessionState.NumTurrets--;
	g_ResourceManager.AddResources(REFUND_PRICE);
	StopSoundOn("Minigun.Fire", turret);
	DoEntFire("!self", "FireUser1", "", 0, null, turret);
}
