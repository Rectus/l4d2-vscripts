//Script for using the CEDA trailer doors.

model <- null;

function Precache()
{
	self.SetProgressBarFinishTime( 0 );
	self.SetProgressBarCurrentProgress( 0.0 );
	self.CanShowBuildPanel(false);
	model = Entities.FindByName(null, self.GetUseModelName());
}

function OnUseStart()
{
	local user = null;

	if(model && (user = Entities.FindByClassnameNearest("player", model.GetOrigin(), 128)))
		model.ApplyAbsVelocityImpulse(user.GetForwardVector() * -20);
	
	return false;
}
