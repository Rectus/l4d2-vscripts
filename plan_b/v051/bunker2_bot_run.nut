// Commands the survivor bots to move to a target.

MoveDest <- Vector(1952, 48, -1824);



function CommandBotRun()
{
	local BOT_CMD_ATTACK = 0
	local BOT_CMD_MOVE = 1
	local BOT_CMD_RETREAT = 2
	
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