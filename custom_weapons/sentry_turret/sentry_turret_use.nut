
/* 
 * Sentry turret use target script
 *
 * Copyright (c) 2019 Rectus
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
 */


prop <- null
enabled <-false
turretEnt <- null
usingPlayer <- null
ammoLeftFrac <- 1.0
isUsed <- false

timeUseStart <- 0
USETIME_BEFORE_BAR <- 0.3

USE_TIME <- 2.0

function Precache()
{
	self.PrecacheScriptSound("Hint.LittleReward")
	self.PrecacheScriptSound("Player.AmmoPackUse")
	self.PrecacheScriptSound("BaseCombatCharacter.AmmoPickup")
}

function OnPostSpawn()
{
	
	self.CanShowBuildPanel(false)
}

function Initialize(turret)
{
	turretEnt = turret.weakref()
	
	self.SetProgressBarText("Use to rearm. Hold to pick up")
	self.SetProgressBarSubText("Ammo left")
	self.SetProgressBarFinishTime(USE_TIME)
	self.SetProgressBarCurrentProgress(USE_TIME)
	self.CanShowBuildPanel(true)
	enabled = true
	
	AddThinkToEnt(self, "Think")
}


function Think()
{
	if(!turretEnt || !turretEnt.IsValid())
	{
		self.Kill()
		return 
	}
	
	ammoLeftFrac = turretEnt.GetScriptScope().GetAmmoFraction()
	if(!isUsed) {self.SetProgressBarCurrentProgress(ammoLeftFrac * USE_TIME)}
	return 0.2
}

function ResetUse()
{
	timeUseStart = 0
	
	if(!isUsed && turretEnt && turretEnt.IsValid())
	{
		local prevAmmo = turretEnt.GetScriptScope().GetAmmoFraction()
		ammoLeftFrac = turretEnt.GetScriptScope().Rearm(usingPlayer)
				
		if(ammoLeftFrac > prevAmmo)
		{
			EmitSoundOn("BaseCombatCharacter.AmmoPickup", prop)
			EmitSoundOnClient("BaseCombatCharacter.AmmoPickup", usingPlayer)
			self.SetProgressBarCurrentProgress(ammoLeftFrac)
		}
	}
}

function OnUseStart()
{

	if(!turretEnt || !turretEnt.IsValid())
	{
		self.Kill()
		return 
	}

	if(enabled)
	{
		if(timeUseStart == 0)
		{
			timeUseStart = Time()
			prop = GetUseProp()
			usingPlayer = GetUsingPlayer()
			
			DoEntFire("!self", "CallScriptFunction", "ResetUse", USETIME_BEFORE_BAR, self, self)
			
			return false
		}
		else if (Time() < USETIME_BEFORE_BAR + timeUseStart)
		{
		
			return false
		}
	
	
		self.SetProgressBarText("Recovering...")
		self.SetProgressBarSubText("")
		isUsed = true
		
		prop = GetUseProp()
		usingPlayer = GetUsingPlayer()
		self.SetProgressBarCurrentProgress(0.0)

		EmitSoundOn("Player.AmmoPackUse", prop)
		
		return true
	}
	
	return false	
	
}

function OnUseStop(timeUsed)
{
	isUsed = false
	StopSoundOn("Player.AmmoPackUse", prop)
	self.SetProgressBarText("Use to rearm. Hold to pick up")
	self.SetProgressBarSubText("Ammo left")
	self.SetProgressBarCurrentProgress(ammoLeftFrac * USE_TIME)
}


function OnUseFinished()
{
	EmitSoundOnClient("Player.PickupWeapon", usingPlayer)
	self.StopUse()
	self.CanShowBuildPanel(false)
	
	local ammoLeft = turretEnt.GetScriptScope().GetAmmoFraction()
	
	local equippedWep = GetPlayerSecondaryWeapon(usingPlayer)
	
	if(equippedWep.GetClassname() == "weapon_pistol")
	{
		equippedWep.Kill()
	}
	
	if(Convars.GetFloat("sv_infinite_ammo") <= 0 || equippedWep.GetClassname() != "weapon_melee")
	{
		usingPlayer.GiveItem("sentry")
		
		local newSentry = GetPlayerSecondaryWeapon(usingPlayer)
		
		newSentry.ValidateScriptScope()
		newSentry.GetScriptScope().ammoFrac = ammoLeft
	}
	
	if(turretEnt) {turretEnt.Kill()}
	if(prop) {prop.Kill()}
	self.Kill()
}


function GetUsingPlayer()
{
	local player = null
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(player.GetEntityHandle() == PlayerUsingMe)
		{
			usingPlayer = player
			break
		}
	}
	return player
}

function GetPlayerSecondaryWeapon(player)
{
	local invTable = {};
	GetInvTable(player, invTable);

	if(!("slot1" in invTable))
		return null;
		
	local weapon = invTable.slot1;
	
	if(weapon)
		return weapon;
		
	return null;
}


// Returns the handle of the use model entity.
function GetUseProp()
{
	if(!("UseModelEntity" in this))
		return null

	local model = null
	while(model = Entities.FindByName(model, self.GetUseModelName()))
	{
		if(model.GetEntityHandle() == UseModelEntity)
		{
			return model
		}
	}
 
	return null
}