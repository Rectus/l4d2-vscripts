

survivormodels <-
{
	bill = "models/survivors/survivor_namvet.mdl",
	francis = "models/survivors/survivor_biker.mdl",
	louis = "models/survivors/survivor_manager.mdl",
	zoey = "models/survivors/survivor_teenangst.mdl"
}

waterPushOrigin <- Entities.FindByName(null, "push_origin").GetOrigin();

printl(waterPushOrigin);

function BunkerWaterPush()
{
	

	foreach (i, model in survivormodels)
	{
		survivor <- Entities.FindByModel(null, model)
		
		if (survivor != null)
		{
			survOrigin <- survivor.GetOrigin()
			distance <- (survivor.GetOrigin() - waterPushOrigin).Length()
			//distance <- sqrt( pow(waterPushOrigin.x - survOrigin.x, 2) + pow(waterPushOrigin.y - survOrigin.y, 2) + pow(waterPushOrigin.z - survOrigin.z, 2))
			if  (distance < 180)
			{
				//DebugDrawLine( survivor.GetOrigin(), waterPushOrigin, 0, 255, 0, true, 5.0 );
				
				survivor.SetVelocity(survivor.GetVelocity() + Vector(0,0,RandomInt((150 - (distance * 2.5)),(200 - distance * 1))));
				
			}
			else
			{
				//DebugDrawLine( survivor.GetOrigin(), waterPushOrigin, 255, 0, 0, true, 5.0 );
			}
		}
	}
}

//::BunkerwaterPush <- BunkerwaterPush;