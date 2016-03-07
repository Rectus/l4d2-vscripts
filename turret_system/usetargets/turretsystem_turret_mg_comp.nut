/* Mingun turret computer script.
 * 
 * Add this to the Entity Scripts keyvalue of an entiyt to make it behave like a turret.
 * It needs some support entitties to find the hit location and show graphical effects, 
 * as well as for hurting the target.
 * 
 *
 * Copyright (c) 2015 Rectus
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */

prop <- null;
enabled <-false;
turret <- null;
TURRET_NAME <- "mg_turret_gun";
NAME <- "mg_turret_comp_use";
buttonReuseCounter <- 20;

function Precache()
{
	self.PrecacheScriptSound("Buttons.snd37");
	
	// UseModelEntity doesn't exsist here yet.
	prop = Entities.FindByName(null, self.GetUseModelName());
	local prefix = self.GetName().slice(0, self.GetName().find(NAME));
	turret = Entities.FindByName(null, self.GetName().slice(0, self.GetName().find(NAME)) + 
		TURRET_NAME + self.GetName().slice(prefix.len() + NAME.len()));
	Assert(turret, "Turret not found:" + self);
	Assert(prop, "Invalid use target:" + self);
	AddThinkToEnt(self, "Think");
}

function Think()
{
	UpdateState();

	if(!enabled)
	{
		if(--buttonReuseCounter < 1)
		{
			enabled = true;
			buttonReuseCounter = 5;
		}
	}
}


function UpdateState()
{
	self.SetProgressBarFinishTime(turret.GetScriptScope().MAX_HEAT);
	
	switch(turret.GetScriptScope().targetingMode)
	{
		case turret.GetScriptScope().TGT_MODE_RANDOM:
		{
			self.SetProgressBarSubText("Targeting mode: Random");
			break;
		}
		case turret.GetScriptScope().TGT_MODE_CLOSEST:
		{
			self.SetProgressBarSubText("Targeting mode: Closest");
			break;
		}
		case turret.GetScriptScope().TGT_MODE_FURTHEST:
		{
			self.SetProgressBarSubText("Targeting mode: Furthest");
			break;
		}
	
	}
	
	local status = "";
	
	if(turret.GetScriptScope().overheated)
	{
		self.SetProgressBarCurrentProgress(turret.GetScriptScope().heat);
		status = "OVERHEAT!";
	}
	else if(turret.GetScriptScope().targetAimedAt)
	{
		self.SetProgressBarCurrentProgress(turret.GetScriptScope().heat);
		status = "Firing";
	}
	else if(turret.GetScriptScope().target)
	{
		self.SetProgressBarCurrentProgress(turret.GetScriptScope().heat);
		status = "Tracking";
	}
	else
	{
		self.SetProgressBarCurrentProgress(turret.GetScriptScope().heat);
		status = "Scanning";
	}
	
	self.SetProgressBarText("STATUS: " + status);
}

function OnUseStart()
{
	if(enabled)
	{
		EmitSoundOn("Buttons.snd37", prop);
		turret.GetScriptScope().targetingMode = (turret.GetScriptScope().targetingMode + 1) % 3;
		turret.GetScriptScope().target = null;
		enabled = false;
	}
	
	return false;
}

function OnUseStop(timeUsed)
{

}

function OnUseFinished()
{

}
