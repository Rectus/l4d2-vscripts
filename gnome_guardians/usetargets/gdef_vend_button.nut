
IncludeScript("usetargets/base_buildable_target");

//ResourceCost <- 0;
ControllerScope <- null;
Item <- null;

// Called by the vending machine controller to set up the button.
function Initialize(controller, item)
{
	ControllerScope = controller;
	Item = item;
	
	if(!("empty" in item))
	{
		ResourceCost = item.price;
		BuildSubText <- "Cost: $" + ResourceCost;
		
		self.CanShowBuildPanel(true);
		self.SetProgressBarText("Buy " + item.displayTitle);
		self.SetProgressBarSubText("Cost: $" + item.price);
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
		EnableUse();
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