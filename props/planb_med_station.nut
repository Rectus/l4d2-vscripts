// Attatch to a point_script_use_target for a usable prop that can heal players.


MAX_HEALTH <- 99;
HEAL_FRAC <- 0.80;
HEAL_MAX <- 100;

uses <- 3;
prop <- null;
usingPlayer <- null;
enabled <-false;
updateCounter <- 0;
hint <- null;

FullHealthHint <-
{
	classname = "env_instructor_hint"
	hint_allow_nodraw_target = "1"
	hint_name = "full_health_hint"
	hint_color = "255 255 255"
	hint_caption = "You don't need to heal", 
	hint_timeout = "3", 
	hint_static = "1",
	hint_icon_onscreen = "icon_info",
	hint_instance_type = "2",
	hint_range = "128" 
	hint_auto_start = "0"
}


function OnPostSpawn()
{
	self.SetProgressBarFinishTime(5);
	MAX_HEALTH = Convars.GetFloat("pain_pills_health_threshold");
	HEAL_MAX = Convars.GetFloat("first_aid_kit_max_heal");
	hint = g_ModeScript.CreateSingleSimpleEntityFromTable(FullHealthHint, self);
	
	AddThinkToEnt(self, "Think");
	
}

function SetUses(new)
{
	uses = new;
	UpdateState();
}

function Think()
{
	if(updateCounter)
	{
		updateCounter--;
		if(!updateCounter)
			UpdateState();
	}
}

function OnUseStart()
{
	if(enabled)
	{	
		local player = null;
		while(player = Entities.FindByClassname(player, "player"))
		{
			if(player.GetEntityHandle() == PlayerUsingMe)
			{
				usingPlayer = player;
				break;
			}
		}
		
		if(usingPlayer.GetHealth() >= MAX_HEALTH)
		{
			DoEntFire("!self", "ShowHint", "", 0, usingPlayer, hint);
			enabled =false;
			updateCounter = 10;
			return false;
		}
			
		self.SetProgressBarText("Healing...");
		DoEntFire("!self", "speakresponseconcept", "CoverMeHeal", 0, "", usingPlayer);
		EmitSoundOn("Player.BandagingWounds", usingPlayer);
		return true;
	}
		
	return false;
}

function OnUseStop(timeUsed)
{
	StopSoundOn("Player.BandagingWounds", usingPlayer);
	
	updateCounter = 10;
}

function OnUseFinished()
{
	enabled = false;
	self.StopUse();
	self.CanShowBuildPanel(false);
	uses--;
	
	if(usingPlayer && usingPlayer.GetHealth() < MAX_HEALTH)
	{
		local newHealth = (MAX_HEALTH - usingPlayer.GetHealth()) * HEAL_FRAC + 1 + usingPlayer.GetHealth();

		usingPlayer.SetHealthBuffer(0);
		DoEntFire("!self", "sethealth", "" + newHealth, 0, "", usingPlayer);
		DoEntFire("!self", "speakresponseconcept", "RelaxedSigh", 0, "", usingPlayer);
	}
	usingPlayer = null;
	
}

function UpdateState()
{
	if(prop == null)
	{
		prop = GetUseModel();
	}
	
	Assert(prop, "planb_med_station: Invalid use target");


	//prop.__KeyValueFromInt("SetBodyGroup", uses);
	DoEntFire("!self", "SetBodyGroup", uses.tostring(), 0, prop, prop);

	if(uses > 0)
	{
		enabled = true;
		self.CanShowBuildPanel(true);
		self.SetProgressBarText("Heal at first aid station");
		DoEntFire("!self", "startglowing", "", 0, "", prop);
	}
	else
	{
		enabled = false;
		self.CanShowBuildPanel(false);
		DoEntFire("!self", "stopglowing", "", 0, "", prop);
	}
}

// Returns the handle of the use model entity.
function GetUseModel()
{
	if(!("UseModelEntity" in this))
		return null;

	local model = null;
	while(model = Entities.FindByName(model, self.GetUseModelName()))
	{
		if(model.GetEntityHandle() == UseModelEntity)
		{
			return model;
		}
	}
 
	return null;
}