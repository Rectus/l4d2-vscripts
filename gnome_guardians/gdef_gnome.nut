/* Gnome guardians gnome entity script.
 *
 * Copyright (c) Rectus 2015
 */

printl("Gnome entity script.")

closePlayers <- {};
colaCounter <- {};
COLA_DELAY <- 100;
DISTANCE <- 110;
DISTANCE_SQUARED <- 110 * 110;
LEEWAY_BEFORE_SHOVE <- 170;
CORRECTION_VECTOR <- Vector(0, 0, 80);
IMPULSE_MAGNITUDE <- 700;

function Precache()
{
	self.PrecacheScriptSound("Strongman.ImpactAdrenaline");
	self.PrecacheScriptSound("Event.BleedingOutEnd_L4D1");
	self.PrecacheScriptSound("Event.ScavengeOvertimeEnd");
	self.PrecacheScriptSound("Event.ScavengeRoundStart");
	self.PrecacheModel("models/infected/common_male_riot.mdl");
	self.PrecacheModel("models/infected/common_male_clown.mdl");
	self.PrecacheModel("models/infected/common_male_ceda.mdl");
	self.PrecacheModel("models/infected/common_male_jimmy.mdl");
}

function OnPostSpawn()
{
	g_ModeScript.SessionState.GnomeEntity <- self;	
	g_ModeScript.SessionState.GnomeEntity.ValidateScriptScope();
	
	g_ModeScript.SessionState.ExclusionZoneList[g_ModeScript.SessionState.GnomeEntity] <- 
		{ type = g_ModeScript.EXCLUSION_RADIAL, radius = 128 };
}	

function Think()
{
	g_ModeScript.CollectInfected();
	
	local player = null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(player.IsSurvivor() && (player.GetOrigin() - self.GetOrigin()).LengthSqr() < DISTANCE_SQUARED)
		{
			if(player in closePlayers)
			{
				if((closePlayers[player] += DISTANCE - (player.GetOrigin() - self.GetOrigin()).Length()) >= LEEWAY_BEFORE_SHOVE)
				{
					local direction = player.GetOrigin() - self.GetOrigin() + CORRECTION_VECTOR;
					local impulse = direction.Scale(IMPULSE_MAGNITUDE / direction.Length());
					player.ApplyAbsVelocityImpulse(impulse);
					
					EmitSoundOn("Strongman.ImpactAdrenaline", player);
					
					delete closePlayers[player];
				}
			}
			else
			{
				closePlayers[player] <- 1;
			}
		}
		else if(player in closePlayers)
		{
			delete closePlayers[player];
		}
	}
	
	local cola = null;
	while(cola = Entities.FindByModel(cola, "models/w_models/weapons/w_cola.mdl"))
	{
		if((cola.GetOrigin() - self.GetOrigin()).LengthSqr() < DISTANCE_SQUARED)
		{
			if(cola in colaCounter)
			{
				if(--colaCounter[cola] <= 0)
				{
					cola.Kill();
					EmitSoundOn("Christmas.GiftDrop", self);
					g_ModeScript.SessionState.GnomeHealth += 1;
					if(g_ModeScript.SessionState.GnomeHealth > 100.0) {g_ModeScript.SessionState.GnomeHealth = 100.0;}
					g_ModeScript.UpdateHUDGnomeHealth();
					delete colaCounter[cola];
				}
			}
			else
			{
				colaCounter[cola] <- COLA_DELAY;
			}
		}
		else if(cola in colaCounter)
		{
			delete colaCounter[cola];
		}
	}
}