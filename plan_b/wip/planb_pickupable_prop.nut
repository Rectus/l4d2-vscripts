CAN_PICK_UP <- true;


function OnGameEvent_player_use(params)
{
	// Hooks the CanPickupObject function if it exists, otherwise it may disallow pickups.
	if(("CanPickupObject" in g_ModeScript || "CanPickupObject" in DirectorScript)
		&& g_ModeScript.CanPickupObject != getroottable().PlanBPickupOverride)
	{
		g_ModeScript.OverriddenCanPickupObject <- g_ModeScript.CanPickupObject;
		g_ModeScript.CanPickupObject <- getroottable().PlanBPickupOverride;
	
		printl("planb_pickupable_prop: Hooked CanPickupObject()!");
	}
	
	else
	{
		g_ModeScript.CanPickupObject <- getroottable().PlanBPickupOverride;
	}
	
	// Lets CanPickupObject handle the pickup.
	if("CanPickupObject" in g_ModeScript)
	{
		return;
	}
	/*
	local player = null;
	if(params.userid == 0 || !(player = GetPlayerFromUserID(params.userid)))
	{
		return;
	}

	local item = null;
	if(("targetid" in params))
	{
		if((item = EntIndexToHScript(params.targetid)))
		{
			if("CAN_PICK_UP" in item.GetScriptScope() && item.GetScriptScope().CAN_PICK_UP)
			{
				printl("Player " + player + " picked up " + item);
				PickupObject(player, item);
			}
		}
	}
	*/
}

// Function to override CanPickupObject with. Calls the overridden one for other objects.
::PlanBPickupOverride <- function(object)
{
	if("CAN_PICK_UP" in object.GetScriptScope() && object.GetScriptScope().CAN_PICK_UP)
	{
		return true;
	}
	
	if("OverriddenCanPickupObject" in g_ModeScript)
	{
		return OverriddenCanPickupObject(object);
	}
	
	return false;
}



if(!("PlanBItemPickupRegistered" in getroottable()))
{
	__CollectEventCallbacks(this, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
	::PlanBItemPickupRegistered <- true;
}