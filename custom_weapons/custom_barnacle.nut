/* 
 * Barnacle gun control script. 
 * 
 *
 * Copyright (c) 2016 Rectus
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
 
TONGUE_MAX_DISTANCE <- 1024
TONGUE_SPEED <- 128
TONGUE_PULL_FORCE <- 200
TONGUE_PULL_FIXUP <- Vector(0, 0, 180)
TONGUE_PULL_FORCE_RAMPDOWN_FACTOR <- 10
TONGUE_PULL_FORCE_RAMPDOWN_MAX <- 50
REEL_SOUND_INTERVAL <- 10
PLAYER_CLAMP_VELOCITY_H <- 1000
PLAYER_CLAMP_VELOCITY_VMIN <- -300
PLAYER_CLAMP_VELOCITY_VMAX <- 1000

// The entity classes to track the position of when pulling. The values factor how much to pull the player versus the object.
DYNAMIC_ENTITIES <-
{
	prop_dynamic = 1.0
	func_physbox = 0.8
	prop_ragdoll = 0.0
	prop_car_alarm = 0.0
	prop_physics = 0.0
	prop_physics = 0.0
	player = 0.5
	infected = 1.0
	witch = 1.0
	weapon_ = 0.0
}

viewmodel <- null // Viewmodel entity
currentPlayer <- null // The player using the weapon
firing <- false // True while the weapon is firing
activeFiring <- false // True while the player holds the fire button
newPickup <- true

tongueEndpoint <- null
tongueDistance <- 0
tongueFrac <- 0
tonguePull <- false
tongueHit <- false
tongueHitDynamic <- false
tongueVictim <- null
tongueVictimLocPos <- null
tongueForceRampdown <- 0
useTongueFixup <- 1
reelSoundTimer <- 0



function OnInitialize()
{
	self.PrecacheScriptSound("SmokerZombie.TongueAttack")
	self.PrecacheScriptSound("player/smoker/hit/tongue_hit_1.wav")
	self.PrecacheScriptSound("SmokerZombie.TongueFly")
	self.PrecacheScriptSound("SmokerZombie.TongueStrain")
	self.PrecacheScriptSound("SmokerZombie.TongueRetract")
	
	printl("New barnacle on ent: " + self)
	
	// Entities
	rope1 <- SpawnEntityOn(barnacle_rope1)
	rope2 <- SpawnEntityOn(barnacle_rope_cpoint)
	ropeFall <- null
	ropeFallEnd <- null

	rope1.__KeyValueFromString("cpoint1", rope2.GetName())
	DoEntFire("!self", "Start", "", 0.01, self, rope1)
	
	ropeFall = SpawnEntityOn(barnacle_rope_fall)
	ropeFall.__KeyValueFromString("cpoint1", rope2.GetName())
}

function OnEquipped(player, _viewmodel)
{
	viewmodel = _viewmodel
	currentPlayer = player
	
	if(newPickup)
	{
		DoEntFire("!self", "SpeakResponseConcept", "PlayerLaugh", 0, currentPlayer, currentPlayer)
		newPickup = false
	}
	EndedFiring()
}

function OnUnEquipped()
{
	EndedFiring()
	
	currentPlayer = null
	viewmodel = null
}

function OnStartFiring()
{
	activeFiring = true

	if(!firing && currentPlayer)
	{		
		DoEntFire("!self", "SetParent", "!activator", 0, viewmodel, rope1)
		DoEntFire("!self", "SetParentAttachment", "attach_nozzle", 0.01, rope1, rope1)	

		if(!rope2 || !rope2.IsValid())
		{
			rope2 = SpawnEntityOn(barnacle_rope_cpoint)
			rope1.__KeyValueFromString("cpoint1", rope2.GetName())
			ropeFall.__KeyValueFromString("cpoint1", rope2.GetName())
		}
	
		firing = true
		tongueDistance = 0
		useTongueFixup = 1
		tongueForceRampdown = 0
		tonguePull = false
		
		EmitSoundOn("SmokerZombie.TongueAttack", currentPlayer)
		EmitSoundOn("SmokerZombie.TongueFly", currentPlayer)
		
		local nozzlePos = currentPlayer.EyePosition() + RotatePosition(currentPlayer.EyePosition(), currentPlayer.EyeAngles(), Vector(72, 3, -13))
			
		local traceEndpoint = currentPlayer.EyePosition() + VectorFromQAngle(currentPlayer.EyeAngles(),TONGUE_MAX_DISTANCE)
		if(g_WeaponController.weaponDebug)
		{
			DebugDrawLine(nozzlePos, traceEndpoint, 64, 64, 255, true, 1.0)
		}
		local tongueTrace =
		{
			start = currentPlayer.EyePosition()
			end = traceEndpoint
			ignore = currentPlayer
		}
		TraceLine(tongueTrace)
		tongueHit = tongueTrace.hit
		
		
		
		tongueEndpoint = (tongueTrace.end - tongueTrace.start) * tongueTrace.fraction + tongueTrace.start
		if("enthit" in tongueTrace)
		{
			tongueVictim = tongueTrace.enthit
			tongueHitDynamic = false
			foreach(entClass, _ in DYNAMIC_ENTITIES)
			{
				if(tongueVictim.GetClassname().find(entClass) != null)
				{
					tongueHitDynamic = true
					if(g_WeaponController.weaponDebug)
					{
						printl(tongueVictim.GetClassname())	
					}
					rope2.SetOrigin(tongueEndpoint)
					DoEntFire("!self", "SetParent", "!activator", 0.01, tongueVictim, rope2)
					break;
				}				
			}
		}
		tongueFrac = tongueTrace.fraction
		if(g_WeaponController.weaponDebug)
		{
			DebugDrawLine(tongueTrace.start, tongueEndpoint, 64, 64, 255, true, 1.0)
		}
		rope1.SetOrigin(nozzlePos)
		if(!tongueHitDynamic)
		{
			rope2.SetOrigin(nozzlePos)
		}
	}
}

function OnFireTick(playerButtonMask)
{
	if(!firing)
	{
		return
	}
	
	local attack2Pressed = (playerButtonMask & (DirectorScript.IN_RELOAD | DirectorScript.IN_ATTACK2)) != 0
	
	if(tongueHitDynamic && (!tongueVictim || !tongueVictim.IsValid()))
	{
		EndedFiring()
		return
	}

	if(currentPlayer)
	{
		local tonguePosition = null
		local nozzlePos = currentPlayer.EyePosition() + RotatePosition(currentPlayer.EyePosition(), currentPlayer.EyeAngles(), Vector(72, 3, -13))
		if(g_WeaponController.weaponDebug)
		{
			DebugDrawCircle(nozzlePos, Vector(0, 0, 255), 200, 2, false, 0.11)
		}
						 
		local tongueVector = tongueEndpoint - nozzlePos

		
		if(!tonguePull)
		{
			tongueDistance += TONGUE_SPEED
			// Instantly latch on to dynamic entities.
			if(tongueHitDynamic)
			{
				tonguePull = true
				DoEntFire("!self", "DisableLedgeHang", "", 0.0, self, currentPlayer)
				DoEntFire("!self", "DisableLedgeHang", "", 0.499, self, currentPlayer)
				tonguePosition = tongueVictim.GetOrigin()
				StopSoundOn("SmokerZombie.TongueFly", currentPlayer)
				EmitSoundOn("player/smoker/hit/tongue_hit_1.wav", rope2)
				EmitSoundOn("player/smoker/hit/tongue_hit_1.wav", currentPlayer)
				reelSoundTimer = REEL_SOUND_INTERVAL
			}
			else if(tongueDistance >= TONGUE_MAX_DISTANCE * tongueFrac)
			{
				tongueDistance = TONGUE_MAX_DISTANCE * tongueFrac							
				tonguePosition = (tongueVector * (1 / tongueVector.Length()) * tongueDistance) + nozzlePos				
				
				if(tongueHit)
				{
					tonguePull = true
					DoEntFire("!self", "DisableLedgeHang", "", 0, self, currentPlayer)
					DoEntFire("!self", "DisableLedgeHang", "", 0.499, self, currentPlayer)
					StopSoundOn("SmokerZombie.TongueFly", currentPlayer)
					EmitSoundOn("player/smoker/hit/tongue_hit_1.wav", rope2)
					EmitSoundOn("player/smoker/hit/tongue_hit_1.wav", currentPlayer)
					reelSoundTimer = REEL_SOUND_INTERVAL
				}
				else
				{
					StopSoundOn("SmokerZombie.TongueFly", currentPlayer)
					EmitSoundOn("SmokerZombie.TongueHit", currentPlayer)
					EndedFiring()
				}
			}
			else
			{
				tonguePosition = tongueVector + nozzlePos
			}
		}
		else
		{		
			if(--reelSoundTimer < 1)
			{
				EmitSoundOn("SmokerZombie.TongueRetract", currentPlayer)
				reelSoundTimer = REEL_SOUND_INTERVAL
			}
		
			if(tongueHitDynamic)
			{
				tonguePosition = tongueVictim.GetOrigin()
			}
			else
			{
				tonguePosition = tongueVector + nozzlePos
			}
			
			if(!attack2Pressed)
			{	
				local playerPullFactor = 1.0
				if(tongueHitDynamic)
				{
					foreach(entClass, pullFactor in DYNAMIC_ENTITIES)
					{
						if(tongueVictim.GetClassname().find(entClass) != null)
						{
							playerPullFactor = pullFactor
							break
						}
					}
				}
				local pullVector = tonguePosition - currentPlayer.EyePosition()
				if(playerPullFactor > 0.0001)
				{
					currentPlayer.ApplyAbsVelocityImpulse((pullVector * (1 / pullVector.Length()) * (TONGUE_PULL_FORCE - tongueForceRampdown) + TONGUE_PULL_FIXUP * useTongueFixup) * playerPullFactor)
				}
				if(playerPullFactor < 0.9999)
				{
					tongueVictim.ApplyAbsVelocityImpulse((pullVector * (-1 / pullVector.Length()) * (TONGUE_PULL_FORCE - tongueForceRampdown)) * (1.0 - playerPullFactor))
				}
				
				tongueForceRampdown += TONGUE_PULL_FORCE_RAMPDOWN_FACTOR
				if(tongueForceRampdown > TONGUE_PULL_FORCE_RAMPDOWN_MAX)
				{
					tongueForceRampdown = TONGUE_PULL_FORCE_RAMPDOWN_MAX
				}
				useTongueFixup = 0
			}
			else
			{
				tongueForceRampdown = 0
				useTongueFixup = 1
			}
			
			ClampPlayerVelocity()
		}
		
		if(!tongueHitDynamic)
		{
			if(!rope2 || !rope2.IsValid())
			{
				rope2 = SpawnEntityOn(barnacle_rope_cpoint)
				rope1.__KeyValueFromString("cpoint1", rope2.GetName())
				ropeFall.__KeyValueFromString("cpoint1", rope2.GetName())
			}
			rope2.SetOrigin(tonguePosition)	
		}
		
		if(g_WeaponController.weaponDebug)
		{
			if(tongueHit)
			{
				DebugDrawLine(nozzlePos, tonguePosition, 0, 255, 0, true, 0.11)
			}
			else
			{
				DebugDrawLine(nozzlePos, tonguePosition, 255, 0, 0, true, 0.11)
			}
		}
	}
	
	
	if(!activeFiring)
	{
		EndedFiring()
	}	
}

function ClampPlayerVelocity()
{
	local inVelocity = currentPlayer.GetVelocity()
	
	local zVelocity = inVelocity.z
	local hVelocity = Vector(inVelocity.x, inVelocity.y, 0)
	
	if(zVelocity > PLAYER_CLAMP_VELOCITY_VMAX)
	{
		zVelocity = PLAYER_CLAMP_VELOCITY_VMAX
	}
	else if (zVelocity < PLAYER_CLAMP_VELOCITY_VMIN)
	{
		zVelocity = PLAYER_CLAMP_VELOCITY_VMIN
	}
	
	if(hVelocity.LengthSqr() > PLAYER_CLAMP_VELOCITY_H * PLAYER_CLAMP_VELOCITY_H)
	{
		hVelocity = hVelocity * (1 / hVelocity.Length()) * PLAYER_CLAMP_VELOCITY_H 
	}
	
	currentPlayer.SetVelocity(hVelocity + Vector(0, 0, zVelocity))
}

function OnEndFiring()
{
	activeFiring = false
}

function EndedFiring()
{
	if(firing)
	{			
		StopSoundOn("SmokerZombie.TongueFly", currentPlayer)
		EmitSoundOn("SmokerZombie.TongueStrain", currentPlayer)

		DoEntFire("!self", "EnableLedgeHang", "", 0.5, self, currentPlayer)
		
		ropeFall.SetOrigin(rope1.GetOrigin())
		DoEntFire("!self", "Start", "", 0, self, ropeFall)
		DoEntFire("!self", "Stop", "", 1, self, ropeFall)
		
		DoEntFire("!self", "ClearParent", "", 0, self, rope1)
		DoEntFire("!self", "ClearParent", "", 0, self, rope2)
		DoEntFire("!self", "RunScriptCode", "self.SetOrigin(Vector(0,0,0))", 0.01, rope1, rope1)
		DoEntFire("!self", "RunScriptCode", "self.SetOrigin(Vector(0,0,0))", 0.01, rope2, rope2)
		tongueVictimLocPos = null
		tongueVictim = null
		tongueHitDynamic = null
		firing = false
	}
}

function SpawnEntityOn(keyValues)
{
	local spawnEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(keyValues)
	spawnEnt.SetOrigin(RotatePosition(self.GetOrigin(), self.GetAngles(), spawnEnt.GetOrigin()) + self.GetOrigin())
	spawnEnt.SetAngles(self.GetAngles())
	
	return spawnEnt
}

barnacle_rope1 <-
{
	classname = "info_particle_system"
	targetname = "barnacle_rope1"
	effect_name = "smoker_tongue"
	start_active = "0"
	render_in_front = "0"
	cpoint1 = ""
	origin = Vector(0, 0, 0)
}

barnacle_rope_cpoint <-
{
	classname = "info_particle_target"
	targetname = "barnacle_rope_cpoint"
	origin = Vector(0, 0, 0)
}

barnacle_rope_fall<-
{
	classname = "info_particle_system"
	targetname = "barnacle_rope_fall"
	effect_name = "smoker_tongue_fall"
	start_active = "0"
	render_in_front = "0"
	cpoint1 = ""
	origin = Vector(0, 0, 0)
}