IncludeScript("planb_pickupable_prop", this);

minefield <- null;
DETECTION_OFFSET <- Vector(0, -64, 0);
DETECTION_RADIUS_OUTER <- 48;
DETECTION_RADIUS_OUTER_SQUARE <- DETECTION_RADIUS_OUTER * DETECTION_RADIUS_OUTER;
DETECTION_RADIUS_BEEP <- 24;
BEEP_INTERVAL <- 3;
beepCounter <- 0;
LIGHT_OFFSET <- Vector(0, 2.6, 6.36);
lightEffectEnt <- null;
soundStaticEnt <- null;
enabled <- false;

DEBUG <- false;

lightEffectTable <-
{
	classname = "env_sprite"
	model = "sprites/redglow3.vmt"
	spawnflags = 0
	scale = 0.025
	rendermode = 9
	renderamt = 160
	parentname = "mine_detector"
	
}

soundStaticTable <-
{
	classname = "ambient_generic"
	SourceEntityName = "mine_detector"
	health = 0
	message = "Objects.TV_Static"
	spawnflags = 0
	pitch = 80
}

function Precache()
{
	PrecacheEntityFromTable(lightEffectTable);
	PrecacheEntityFromTable(soundStaticTable);
	self.PrecacheScriptSound("Respawn.CountdownBeep");
	self.PrecacheScriptSound("Objects.TV_Static");
}

function OnPostSpawn()
{
	self.ConnectOutput("OnPlayerPickup", "OnPickup");
	self.ConnectOutput("OnPhysGunDrop", "OnDrop");
	lightEffectEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(lightEffectTable, self);
	lightEffectEnt.SetOrigin(LIGHT_OFFSET);
	soundStaticEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(soundStaticTable, self);
}

function OnPickup()
{
	if(minefield == null)
	{
		minefield = Entities.FindByName(null, "minefield_script").GetScriptScope();
		
		if(minefield == null)
			throw("Mine detector: Could not find minefield script!")
			
		AddThinkToEnt(self, "Think");
	}
	DoEntFire("!self", "StopGlowing", "", 0, self, self);
	DoEntFire("!self", "HideSprite", "", 0, self, lightEffectEnt);
	enabled = true;
}

function OnDrop()
{
	DoEntFire("!self", "StartGlowing", "", 0, self, self);
	DoEntFire("!self", "SetGlowRange", "256", 0, self, self);
	DoEntFire("!self", "Volume", "0", 0, self, soundStaticEnt);
	enabled = false;
}


function Think()
{
	if(enabled)
	{
		local detectionPoint = LocalToGlobalCoords(DETECTION_OFFSET, self.GetOrigin(), self.GetAngles());
		local detected = false;
		local minePos = null;

		if(DEBUG)
		{
			DebugDrawCircle(detectionPoint, Vector(0, 64, 0), 192, DETECTION_RADIUS_OUTER, true, 0.1);
		}
		
		foreach(mine in minefield.mines)
		{
			if((mine - detectionPoint).LengthSqr() < DETECTION_RADIUS_OUTER_SQUARE)
			{
				if(DEBUG)
				{
					DebugDrawCircle(mine, Vector(64, 0, 0), 192, 16, true, 0.1);
				}
				detected = true;
				
				if(!minePos || minePos.LengthSqr() > (mine - detectionPoint).LengthSqr())
					minePos = mine;
			}
		}
		
		if(detected)
		{
			local distance = (minePos - detectionPoint).Length();
		
			if(distance < DETECTION_RADIUS_BEEP)
			{
				if((beepCounter = (beepCounter + 1) % BEEP_INTERVAL) == 0)
				{
					EmitSoundOn("Respawn.CountdownBeep", self);
					DoEntFire("!self", "ShowSprite", "", 0, self, lightEffectEnt);
					DoEntFire("!self", "HideSprite", "", BEEP_INTERVAL / 20.0, self, lightEffectEnt);
				}
			}
			
			DoEntFire("!self", "Volume", "10", 0, self, soundStaticEnt);
			DoEntFire("!self", "Pitch", "" + (148 - distance), 0, self, soundStaticEnt);
		}
		else
		{
			//beepCounter = BEEP_INTERVAL - 1;
			DoEntFire("!self", "Volume", "5", 0, self, soundStaticEnt);
		}
	}
}

function LocalToGlobalCoords(coordinates, origin, angles)
{
	return origin + RotatePosition(origin, angles, coordinates);
}