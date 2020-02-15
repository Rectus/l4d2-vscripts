MethHeads <-{};

function UseMethlab()
{
	if(!(activator in MethHeads))
		MethHeads[activator] <- 1;
	else
		MethHeads[activator] += 0.5;
			
	if(!Convars.GetFloat("god"))
	{
		activator.SetHealthBuffer(100 / MethHeads[activator] + activator.GetHealth());
		activator.SetHealth(0);
	}
	activator.UseAdrenaline(30 / MethHeads[activator]);
}