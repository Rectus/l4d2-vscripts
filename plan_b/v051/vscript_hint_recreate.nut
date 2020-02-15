Msg("Instructor hint workaround initialized.\n");

// Workaround for hints only displaying for the activator.

vscriptHintRemove <- true; // State to prevent newly spawned hints from being removed.

function OnGameEvent_instructor_server_hint_create(params)
{
	if((params.hint_name.find("vscript_recreated_hint_") != null) //Prevents infinite loops.
		|| (params.userid == 0) //If the hint was triggered for all players already.
		|| (params.hint_target == "")
		|| (params.hint_name.find("noremove"))) // Add this to hints to excempt them.
	{
		return;
	}
	
	if(developer)
		Msg("Replacing instructor hint: " + params.hint_name + "\n");
	
	// Removes commas from the color value.
	local color = split(params.hint_color, "(),");
	params.hint_color = color.reduce(@(prevval, curval) prevval + " " + curval);
	
	params.hint_auto_start <- 1;
	
	local hintTarget = EntIndexToHScript(params.hint_target);
	
	if(!hintTarget)
	{
		return;
	}
	params.hint_target <- hintTarget.GetName();

	local hintBaseName = params.hint_name;
	params.hint_name <- "vscript_recreated_hint_" + hintBaseName;
	params.targetname <- params.hint_name;
	delete params.hint_entindex;
	 
	// Wheter the hint is static is determined by flag 256 in the game event data.
	params.hint_static <- ((params.hint_flags & 256) != 0) ? 1 : 0;
	
	vscriptHintRemove <- false;
	EntFire(hintBaseName, "EndHint" ,0);
	
	local triggeringPlayer = GetPlayerFromID(params.userid);
	delete params.userid;
	local player = null;
	
	infoTargetTable <-
	{
		classname = "info_target_instructor_hint"
		targetname = params.targetname + "_target"
	}
	
	local infoTarget = CreateSingleSimpleEntityFromTable(infoTargetTable, triggeringPlayer);
	
	CreateHintOn(infoTarget.GetName(), null, null, [params]);
	
	while((player = Entities.FindByClassname(player, "player")))
	{
		if(player != triggeringPlayer)
			infoTarget.SetOrigin(player.GetOrigin());
	}
	infoTarget.SetOrigin(hintTarget.GetOrigin());	
}

// Needed to propagate EndHint to the spawned hints.
function OnGameEvent_instructor_server_hint_stop(params)
{
	if(!vscriptHintRemove)
	{
		vscriptHintRemove <- true;
		return;
	}	
		
	if(!params.hint_name.find("vscript_recreated_hint_"))
	{
		if(developer)
			Msg("Ending instructor hint: " + params.hint_name + "\n");

		EntFire("vscript_recreated_hint_" + params.hint_name, "EndHint");
	}
}

// Needed unless in Scripted Mode.
//__CollectGameEventCallbacks(this);

function GetPlayerFromID(playerid)
{
	local player = null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(player.GetPlayerUserId() == playerid)
		{
			return player;
		}
	}
	return null;
}