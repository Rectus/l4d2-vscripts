/* Vending machine button script. Automatically spawned by the controller.
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
 
 
IncludeScript("usetargets/base_buildable_target");

//ResourceCost <- 0;
ControllerScope <- null;
Item <- null;
Amount <- -1;

UseStateDependencies <- {canAfford = false, buttonOn = true, inStock = true}

// Called by the vending machine controller to set up the button.
function Initialize(controller, item)
{
	ControllerScope = controller;
	Item = item;
	
	if(!("empty" in Item) && (!("amount" in Item) || Item.amount > 0))
	{

		ResourceCost = item.price;
		BuildSubText <- "Cost: $" + ResourceCost;

		
		if("amount" in Item)
		{
			Amount = Item.amount;
			
			UseStateDependencies.inStock = (Amount >= 1);
		}
		
		self.CanShowBuildPanel(true);
		self.SetProgressBarText("Buy " + item.displayTitle);
		self.SetProgressBarSubText(BuildSubText);
		self.SetProgressBarFinishTime(1.5);		
	}
	else
	{
		BuildSubText <- "";
		self.SetProgressBarText("");
		self.SetProgressBarSubText("");
		self.CanShowBuildPanel(false);
		
	}
	TurnOff();
}

// Called from base_buildable_target when the use finishes.
function BuildCompleted()
{
	if(Amount != -1)
	{
		Amount--;
		
		if(Amount < 1)
		{
			UseStateDependencies.inStock = false;
			DoEntFire("!self", "Skin", "0", 0, self, GetUseModel());
			self.CanShowBuildPanel(false);
			UpdateButtonState();
		}
	}
	ControllerScope.SpawnItem(Item);
}

// Overrides function in base_buildable_target
function TurnOff()
{
	if(!UseStateDependencies.buttonOn)
		return;

	UseStateDependencies.buttonOn = false;
	DoEntFire("!self", "Skin", "1", 0, self, GetUseModel());
	DoEntFire("!self", "SetGlowOverride", "255 0 0", 0, self, GetUseModel());
	
	DisableBuildPanel();
	StopButtonUse();
	UpdateButtonState();
}

// Overrides function in base_buildable_target
function TurnOn()
{
	if(UseStateDependencies.buttonOn)
		return;

	if(!("empty" in Item))
	{
		DoEntFire("!self", "Skin", (Item.buttonSkin - 1).tostring(), 0, self, GetUseModel());
		UseStateDependencies.buttonOn = true;
		UseStateDependencies.canAfford = g_ResourceManager.CanAfford(ResourceCost);
		if(Amount != -1)
		{
			UseStateDependencies.inStock = (Amount >= 1);
			if(Amount < -1)
			{
				DoEntFire("!self", "Skin", "0", 0, self, GetUseModel());
				self.CanShowBuildPanel(false);
			}
		}
	}
	else
	{
		DoEntFire("!self", "Skin", "0", 0, self, GetUseModel());		
	}
	
	EnableBuildPanel();
	UpdateButtonState();
}

// Overrides function in base_buildable_target
function EnableUse()
{
	if(Enabled)
		return;

	Enabled = true;
	
	DoEntFire("!self", "SetGlowOverride", "0 255 0", 0, self, GetUseModel());
	self.CanShowBuildPanel(true);
}

// Overrides function in base_buildable_target
function DisableUse()
{
	if(!Enabled)
		return;

	Enabled = false;
	self.StopUse();
	
	DoEntFire("!self", "SetGlowOverride", "255 0 0", 0, self, GetUseModel());
}

// Overrides function in base_buildable_target
function UpdateCostString()
{
	BuildSubText <- "Cost: $" + ResourceCost;

	self.SetProgressBarSubText(BuildSubText);
}

// Returns the handle of the use model entity.
function GetUseModel()
{
	if(!("UseModelEntity" in this))
		return null;

	local model = null;
	while(model = Entities.FindByName(model, self.GetUseModelName()))
	{
		if(model.GetEntityHandle() == UseModelEntity)
		{
			return model;
		}
	}
 
	return null;
}