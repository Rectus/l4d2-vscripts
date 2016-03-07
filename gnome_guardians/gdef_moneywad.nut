
function PickupCash()
{
	g_ModeScript.OnMoneyPickup();
	EmitSoundOnClient("Hint.LittleReward", activator); // scripted_item_drop sets activator correctly
	self.Kill();
}


self.ConnectOutput("OnPlayerTouch", "PickupCash");
self.ConnectOutput("OnPlayerPickup", "PickupCash");

DoEntFire("!self", "Kill", "", 30, self, self);	// Remove the pickup after 30 seconds.