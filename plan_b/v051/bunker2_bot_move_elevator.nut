// Commands the survivor bots to move to a target.

MoveDest <- Entities.FindByName(null, "vent_elevator_bot_target").GetOrigin();



function CommandBotMove()
{
	local BOT_CMD_ATTACK = 0
	local BOT_CMD_MOVE = 1
	local BOT_CMD_RETREAT = 2
	local BOT_CMD_RESET = 3
	
	local bot = null;
	
	while (bot = Entities.FindByClassname(bot, "player"))
	{		
		if(bot.IsSurvivor() && IsPlayerABot(bot))
		{
			CommandTable <-
			{
				bot = bot
				cmd = BOT_CMD_MOVE
				pos = MoveDest
			}	
			
			CommandABot(CommandTable);
		}
	}
}

function ClearBotCommands()
{
	local BOT_CMD_RESET = 3

	local currentPlayer = null;
	while((currentPlayer = Entities.FindByClassname(currentPlayer, "player")))
	{
		if(currentPlayer.IsSurvivor() && IsPlayerABot(currentPlayer))
		{
			CommandTable <-
			{
				bot = currentPlayer
				cmd = BOT_CMD_RESET
			}
			
			CommandABot(CommandTable);
		}
	}
}