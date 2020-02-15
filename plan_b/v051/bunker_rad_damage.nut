

function LightRadDamage(amount)
{
	if(!Convars.GetFloat("god"))
	{
		ConvertHealthToBuffer(activator, amount);	
	}
}

function HeavyRadDamage(amount)
{
	if(!Convars.GetFloat("god"))
	{
		ConvertHealthToBuffer(activator, amount * 5);
		
		if(activator.GetHealthBuffer() > amount)
		{
			activator.SetHealthBuffer(activator.GetHealthBuffer() - amount);
		}
		else
		{
			activator.SetHealthBuffer(0);
		}
	}
}

function ConvertHealthToBuffer(player, amount)
{	
	if(player.GetHealth() > amount)
	{
		player.SetHealth(player.GetHealth() - amount);
		player.SetHealthBuffer(player.GetHealthBuffer() + amount);
		
	}
	else
	{
		player.SetHealthBuffer(player.GetHealthBuffer() + player.GetHealth());
		player.SetHealth(0);
	}
}