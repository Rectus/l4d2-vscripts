


MutationState <-
{
	PickupList = {}
	PlayerList = []
}

function OnGameplayStart()
{
	// TODO: Needs checks for when players change
	local player = null;
	while (player = Entities.FindByClassname(player, "player"))
	{
		if(player.IsSurvivor())
			SessionState.PlayerList.append(player);		
	}
	ScriptedMode_AddUpdate(@() g_ModeScript.PlayerUseTest());	
	
	CreateSingleSimpleEntityFromTable({classname="logic_script" targetname="telekinesis_throw"
			vscripts="telekinesis_throw" thinkfunction="ThrowPoll"});
}

// Checks if the use key is held, and picks up the pointed at object.
function PlayerUseTest()
{
	foreach(player in SessionState.PlayerList)
	{
		if(player.GetButtonMask() & IN_USE)
		{
			local traceTable =
			{
				start = player.EyePosition()
				end = player.EyePosition() + VectorfromQAngle(player.EyeAngles(), 1000)
				ignore = player
				mask = TRACE_MASK_SHOT	
			}
			local result = TraceLine(traceTable);
			DeepPrintTable(traceTable);
			
			if(result && ("enthit" in traceTable) && (traceTable.enthit.GetClassname() == "prop_physics"))
			{
				SessionState.PickupList[player] <- traceTable.enthit;
				PickupObject(player, traceTable.enthit);
				EmitSoundOnClient("Defibrillator.Use", player);
			}

		}
	
	}	
}

// If a player has picked up an item, and presses secondary attack, add an impulse to the object.
// TODO: Might need a way of knowing if a player has dropped an object.
function ThrowPoll()
{
	foreach(player in SessionState.PlayerList)
	{
		
		if((player.GetButtonMask() & IN_ATTACK2) && (player in SessionState.PickupList))
		{
			DeepPrintTable(SessionState);
			try
			{
				SessionState.PickupList[player].ApplyAbsVelocityImpulse(VectorfromQAngle(player.EyeAngles(), 5000));
			}
			catch(id)
			{
				printl("Impulse failed! " + id);
			}
			delete SessionState.PickupList[player];
		}
	}
}

// Converts QAngles into vectors, with an optional vector length.
function VectorfromQAngle(angles, radius = 1.0)
{
	local function ToRad(angle)
	{
		return (angle * PI) / 180;
	}
	
	local yaw = ToRad(angles.Yaw());
	local pitch = ToRad(-angles.Pitch());
	
	local x = radius * cos(yaw) * cos(pitch);
	local y = radius * sin(yaw) * cos(pitch);
	local z = radius * sin(pitch);
	
	return Vector(x, y, z);
}



function CanPickupObject(object)
{
	DeepPrintTable(SessionState);

	foreach(player, currentObject in SessionState.PickupList)
		if(currentObject == object)
		{
			printl("CanPickupObject: " + object);
			return true;
		}
		
	return false;
}