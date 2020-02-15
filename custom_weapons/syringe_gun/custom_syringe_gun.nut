/* 
 * Syringe gun script.
 *
 * Copyright (c) 2017 Rectus
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

viewmodel <- null 		// Viewmodel entity
currentPlayer <- null 	// The player using the weapon

syringeCount <- 5

hurtEnt <- null
hurtSurvivorEnt <- null
explosionEnt <- null
fireFrame <- 0
fireHoldCounter <- 0
infiniteAmmo <- false
throwVector <- null
rechargeHint <- null
hitZombie <- null
hitPos <- null

TRACE_MAX_DISTANCE <- 48

FIRE_HOLD_TIME <- 0
FIRE_ANIM_FRAMES <- 14
FIRE_ANIM_RELEASE <- 0
FIRE_ANIM_SKIN_CYCLE <- 7

SYRINGE_HEAL_AMOUNT <- 20
SYRINGE_RECHARGE_TIME <- 30

syringeRecharge <- 0.0



// Called after the script has loaded.
function OnInitialize()
{
	PrecacheEntityFromTable(SYRINGE_TRAIL)
	PrecacheEntityFromTable(SYRINGE_HIT_EFFECT)
	PrecacheEntityFromTable(SPIT_PARTICLE)
	PrecacheEntityFromTable(TRANSFORM_PARTICLE)
	self.PrecacheScriptSound("Default.ClipEmpty_Pistol")
	self.PrecacheScriptSound("Christmas.GiftDrop")
	self.PrecacheScriptSound("SMG_Silenced.FireIncendiary")
	self.PrecacheScriptSound("Player.PickupWeapon")
	self.PrecacheScriptSound("Adrenaline.NeedleIn")
	self.PrecacheScriptSound("BaseGrenade.Explode")
	self.PrecacheScriptSound("SpitProjectile.Bounce")
	self.PrecacheModel("models/weapons/melee/syringe_gun/syringe.mdl")
	self.PrecacheModel("models/weapons/melee/syringe_gun/syringe_extended.mdl")

	printl("New custom syringe gun script on ent: " + self)

	rechargeHint = g_ModeScript.CreateSingleSimpleEntityFromTable(RECHARGE_HINT)
	weaponController.RegisterTrackedEntity(rechargeHint, self)
	
	// Registers a function to run every frame.
	AddThinkToEnt(self, "Think")

}


// Called when a player swithces to the the weapon.
function OnEquipped(player, _viewmodel)
{
	viewmodel = _viewmodel
	currentPlayer = player
	fireHoldCounter = 0
	fireFrame = -1
}


// Called when a player switches away from the weapon.
function OnUnEquipped()
{
	currentPlayer = null
	viewmodel = null
	fireHoldCounter = 0
	fireFrame = -1
}


// Called when the player stats firing.
function OnStartFiring()
{
	local infAmmoCvar = Convars.GetFloat("sv_infinite_ammo")
	if(infAmmoCvar)
	{
		infiniteAmmo = (infAmmoCvar > 0)
	}
	
}


// A think function to decrement the delay timer.
function Think()
{
	if(viewmodel)
	{
		if(fireFrame > -1)
		{
			if(fireFrame == FIRE_ANIM_RELEASE)
			{
				
				FireSyringe()
				fireFrame++
			}
			else if(fireFrame == FIRE_ANIM_FRAMES)
			{
				if(fireHoldCounter > 0)
				{
					fireFrame = 0
				}
				else
				{
					fireFrame = -1
				}
			}
			else
			{
				fireFrame++
			}
		}
	
	}
	
	if(syringeRecharge > 0)
	{
		syringeRecharge -= 0.1
		
		if(syringeRecharge <= 0)
		{
			syringeRecharge = 0
			syringeCount = 1
			if(currentPlayer)
			{
				EmitSoundOnClient("Christmas.GiftDrop", currentPlayer) 
			}
		}
	}
}


// Called every frame the player the player holds down the fire button.
function OnFireTick(playerButtonMask)
{	
	if(fireHoldCounter++ == FIRE_HOLD_TIME)
	{
		if(fireFrame < 0)
		{
			fireFrame = FIRE_HOLD_TIME
		}
	}
}


// Called when the player ends firing.
function OnEndFiring()
{
	fireHoldCounter = 0
}


function FireSyringe()
{

	if(!infiniteAmmo)
	{
		if(syringeCount < 1)
		{
			EmitSoundOn("Default.ClipEmpty_Pistol", currentPlayer)
			local percentage = ((1 - syringeRecharge / SYRINGE_RECHARGE_TIME) * 100).tointeger().tostring() + "%%"
			rechargeHint.__KeyValueFromString("hint_caption", "Syringe recharging: " + percentage)
			DoEntFire("!self", "ShowHint", "!activator", 0.01, currentPlayer, rechargeHint)
			return
		}
		else if(syringeCount == 1)
		{
			if(syringeRecharge == 0)
			{
				syringeRecharge = SYRINGE_RECHARGE_TIME
			}
		}
		syringeCount--
	}
	
	EmitSoundOn("SMG_Silenced.FireIncendiary", currentPlayer) //"GrenadeLauncher.Fire"
	
	
	if(!TracePointBlankSyringe())
	{
		local eyeVec = VectorFromQAngle(currentPlayer.EyeAngles(), 1)
		local spawnPoint = currentPlayer.EyePosition() + eyeVec * 24 + eyeVec.Cross(Vector(0, 0, 1)) * 6 + Vector(0, 0, -8)
		local keyvalues = clone SYRINGE_ENTITY	
		keyvalues.origin = spawnPoint
		keyvalues.angles = currentPlayer.EyeAngles() + QAngle(-5, 1, 0)
		local syringe = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
		
		keyvalues = clone SYRINGE_TRAIL
		keyvalues.origin = spawnPoint + eyeVec * 40
		local trail = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
		DoEntFire("!self", "SetParent", "!activator", 0, syringe, trail)
		DoEntFire("!self", "Kill", "", 10, trail, trail)
		
		syringe.ValidateScriptScope()
		syringe.GetScriptScope().gunScript <- this
		syringe.GetScriptScope().usingPlayer <- currentPlayer
		syringe.GetScriptScope().Think()
		syringe.ApplyAbsVelocityImpulse(VectorFromQAngle(currentPlayer.EyeAngles() + QAngle(-5, 1, 0), 1500))
		
		
	}
}


function TracePointBlankSyringe()
{
	local traceStartPoint = currentPlayer.EyePosition()	
	local traceEndpoint = currentPlayer.EyePosition() + VectorFromQAngle(currentPlayer.EyeAngles(), TRACE_MAX_DISTANCE)
		
	local traceTable =
	{
		start = currentPlayer.EyePosition()
		end = traceEndpoint
		mask = DirectorScript.TRACE_MASK_SHOT
		ignore = currentPlayer
	}
	TraceLine(traceTable)

	if(traceTable.hit)
	{
		//DebugDrawLine(traceStartPoint, traceTable.pos, 0, 255, 0, true, 2.0)	
		
		if(("enthit" in traceTable) && traceTable.enthit.GetEntityIndex() > 0)
		{
			local entityHit = traceTable.enthit
		
			entityHit.TakeDamage(0, (1 << 1), currentPlayer)
		
			if(entityHit.GetClassname() == "player")
			{
				EmitSoundOnClient("Adrenaline.NeedleIn", currentPlayer)
				if(entityHit.IsSurvivor())
				{
					EmitSoundOnClient("Adrenaline.NeedleIn", entityHit)
					
					if(entityHit.IsIncapacitated())
					{
						entityHit.ReviveFromIncap()
					}
				
					entityHit.UseAdrenaline(5)
					DoEntFire("!self", "SpeakResponseConcept", "UseAdrenaline", 0.5, entityHit, entityHit)
					local newHealthBuffer = entityHit.GetHealthBuffer() + SYRINGE_HEAL_AMOUNT
					
					local maxHealth = Convars.GetFloat("first_aid_kit_max_heal")//pain_pills_health_threshold
					if(maxHealth && newHealthBuffer + entityHit.GetHealth() > maxHealth)
					{
						local healPercentage = Convars.GetFloat("first_aid_heal_percent")
						local bufferHealAmount = maxHealth - entityHit.GetHealthBuffer() - entityHit.GetHealth()
						local newHealth = entityHit.GetHealth() + (SYRINGE_HEAL_AMOUNT - bufferHealAmount) * healPercentage
						newHealthBuffer = maxHealth - newHealth
						
						if(newHealth > maxHealth * healPercentage)
						{
							newHealth = maxHealth * healPercentage
							newHealthBuffer = maxHealth * (1 - healPercentage)
						}
						
						entityHit.SetHealth(newHealth)
					}
					
					entityHit.SetHealthBuffer(newHealthBuffer)
					SpawnStaticSyringe(traceTable.pos, currentPlayer.EyeAngles(), entityHit, true)
				}
				else
				{
					DoEntFire("!self", "color", "0 64 0", 0.0, entityHit, entityHit)
					entityHit.SetHealth(entityHit.GetHealth() * 2)
					SpawnStaticSyringe(traceTable.pos, currentPlayer.EyeAngles(), entityHit, false)
				}
				
				return true
			}
			else if(entityHit.GetClassname() == "infected")
			{
				InfectedHit(entityHit, traceTable.pos)
				return true
			}
			else if(entityHit.GetClassname() == "witch")
			{
				EmitSoundOnClient("Adrenaline.NeedleIn", currentPlayer)
				local keyvalues = clone TRANSFORM_PARTICLE
				keyvalues.origin = entityHit.GetOrigin()
				local particle = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
				DoEntFire("!self", "Kill", "", 5, particle, particle)
				
				local spawnTable = {type = 7, pos = entityHit.GetOrigin() + Vector(8, 8, 0), ang = entityHit.GetAngles()}
				ZSpawn(spawnTable)
				return true
			}
			else
			{
				SpawnSyringeStuck(traceTable.pos, currentPlayer.EyeAngles(), entityHit)
				return true
			}
		}
		else
		{
			SpawnSyringeStuck(traceTable.pos, currentPlayer.EyeAngles(), bull)
			return true
		}
	}
	
	return false
}


function InfectedHit(entity, pos)
{
	local random = RandomInt(0, 25)
	
	if(random < 8) // Spawn SI
	{
		EmitSoundOn("BoomerZombie.Fall", entity)
		local keyvalues = clone TRANSFORM_PARTICLE
		keyvalues.origin = entity.GetOrigin()
		local particle = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
		DoEntFire("!self", "Kill", "", 5, particle, particle)
		
		local spawnTable = {type = random + 1, pos = entity.GetOrigin(), ang = entity.GetAngles()}
		entity.SetOrigin(entity.GetOrigin() + Vector(32, 32, 0))
		entity.Kill()
		ZSpawn(spawnTable)
	}
	else if(random < 15) // Explode
	{
		CommandABot({ cmd = 1, pos = entity.GetOrigin(), bot = entity}) // BOT_CMD_MOVE
		EmitSoundOn("BoomerZombie.Fall", entity)
		EmitSoundOnClient("Adrenaline.NeedleIn", currentPlayer)
		
		if (!explosionEnt || !explosionEnt.IsValid())
		{
			explosionEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(EXPLOSION_ENTITY)
			weaponController.RegisterTrackedEntity(explosionEnt, self)
		}
		
		hitZombie = entity
		hitPos = pos - entity.GetOrigin()
		explosionEnt.SetOrigin(pos)
		DoEntFire("!self", "CallScriptFunction", "DoExplosion" 2.0, self, self)
		//SpawnStaticSyringe(pos, currentPlayer.EyeAngles(), entity)
	}
	else // Leak spit
	{
		CommandABot({ cmd = 1, pos = entity.GetOrigin(), bot = entity}) // BOT_CMD_MOVE
		EmitSoundOn("BoomerZombie.Fall", entity)
		EmitSoundOnClient("Adrenaline.NeedleIn", currentPlayer)
		hitZombie = entity
		hitPos = pos - entity.GetOrigin()
		
		DoEntFire("!self", "CallScriptFunction", "DoSpit" 1.0, self, self)	
	}
}

function DoExplosion()
{
	if(hitZombie && explosionEnt && explosionEnt.IsValid())
	{
		explosionEnt.SetOrigin(hitPos + hitZombie.GetOrigin())
	}
	DoEntFire("!self", "Explode", "" 0, currentPlayer, explosionEnt)
	EmitSoundOn("BoomerZombie.Detonate", explosionEnt)
}


function DoSpit()
{
	if(hitZombie)
	{
		local keyvalues = clone SPIT_PARTICLE
		keyvalues.origin = hitPos + hitZombie.GetOrigin()
		local particle = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
		DoEntFire("!self", "Kill", "", 5, particle, particle)
		EmitSoundOn("SpitProjectile.Bounce", particle)
		
		DropSpit(hitPos + hitZombie.GetOrigin() + Vector(4, 4, 64))
		hitZombie.TakeDamage(10000, 1, currentPlayer)
	}
}


function SpawnSyringeStuck(origin, angles, entity = null)
{
	local keyvalues = clone SYRINGE_PICKUP_STUCK
	keyvalues.origin = origin + VectorFromQAngle(angles, -2)
	keyvalues.angles = angles
	local syringe = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)

	if(entity)
	{
		DoEntFire("!self", "SetParent", "!activator", 0.05 , entity, syringe)
	}
	
	keyvalues = clone SYRINGE_HIT_EFFECT
	keyvalues.origin = origin
	local effect = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
	DoEntFire("!self", "Kill", "", 0.5, effect, effect)
	
	DoEntFire("!self", "Kill", "", 300, syringe, syringe)
}


function SpawnStaticSyringe(origin, angles, entity = null, isPlayer = false)
{
	local keyvalues = clone SYRINGE_STATIC
	keyvalues.origin = origin + VectorFromQAngle(angles, 1)
	keyvalues.angles = angles
	local syringe = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)

	if(entity)
	{
		DoEntFire("!self", "SetParent", "!activator", 0.05 , entity, syringe)
		if(isPlayer)
		{
			DoEntFire("!self", "SetParentAttachmentMaintainOffset", "spine", 0.1 , syringe, syringe)
		}
	}
	
	keyvalues = clone SYRINGE_HIT_EFFECT
	keyvalues.origin = origin
	local effect = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
	DoEntFire("!self", "Kill", "", 0.5, effect, effect)
	
	DoEntFire("!self", "Kill", "", 30, syringe, syringe)
}


// Converts a QAngle to a vector, with a optional length.
function VectorFromQAngle(angles, radius = 1.0)
{
	local function ToRad(angle)
	{
		return (angle * PI) / 180;
	}
   
	local yaw = ToRad(angles.Yaw());
	local pitch = ToRad(-angles.Pitch());
   
	local x = radius * cos(yaw) * cos(pitch);
	local y = radius * sin(yaw) * cos(pitch);
	local z = radius * sin(pitch);
   
	return Vector(x, y, z);
}


function Clamp(val, min, max)
{
	if(val > max)
	{
		return max
	}
	else if(val > min)
	{
		return val
	}

	return min
}

SYRINGE_ENTITY <-
{
	classname = "prop_physics_override"
	targetname = "arrow"
	vscripts = "prop_syringe"
	//vscripts = "prop_rocket"
	model = "models/weapons/melee/syringe_gun/syringe.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	fadescale = 0
	//solid = 0
	//glowstate = 3
	//glowrange = 128
	//glowcolor = Vector(255, 0, 0)
}

SYRINGE_PICKUP <-
{
	classname = "prop_dynamic_override"
	targetname = "arrow"
	vscripts = "prop_syringe_static"
	model = "models/weapons/melee/syringe_gun/syringe.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	solid = 0
	glowstate = 3
	glowrange = 128
	glowcolor = Vector(128, 128, 255)
	fadescale = 0
}

SYRINGE_PICKUP_STUCK <-
{
	classname = "prop_dynamic_override"
	targetname = "arrow"
	vscripts = "prop_syringe_static"
	model = "models/weapons/melee/syringe_gun/syringe_extended.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	solid = 0
	glowstate = 3
	glowrange = 128
	glowcolor = Vector(128, 128, 255)
	fadescale = 0
}

SYRINGE_STATIC <-
{
	classname = "prop_dynamic_override"
	targetname = "arrow"
	model = "models/weapons/melee/syringe_gun/syringe_extended.mdl"
	origin = Vector(0, 0, 0)
	angles = Vector(0, 0, 0)
	solid = 0
	fadescale = 0.1
}

SYRINGE_TRAIL <-
{
	classname = "info_particle_system"
	effect_name = "extinguisher_mist"// "spitter_projectile_trail_2" //"weapon_grenadelauncher_trail"//  "weapon_tracers_incendiary_smoke"   
	render_in_front = "0"
	start_active = "1"
	targetname = "syringe_trail"
	origin = Vector(0, 0, 0)
}

TRANSFORM_PARTICLE <-
{
	classname = "info_particle_system"
	effect_name = "small_smoke"  
	render_in_front = "0"
	start_active = "1"
	targetname = "smoke"
	origin = Vector(0, 0, 0)
}

SPIT_PARTICLE <-
{
	classname = "info_particle_system"
	effect_name = "spitter_areaofdenial"  
	render_in_front = "0"
	start_active = "1"
	targetname = "spit"
	origin = Vector(0, 0, 0)
}


SYRINGE_HIT_EFFECT <-
{
	classname = "info_particle_system"
	effect_name = "spitter_projectile_trail_2" //"steam_child_base"
	render_in_front = "0"
	start_active = "1"
	targetname = "syringe_trail"
	origin = Vector(0, 0, 0)
}


EXPLOSION_ENTITY <-
{
	classname = "env_explosion"
	targetname = "syringe_explosion"
	iRadiusOverride = 0
	fireballsprite = "sprites/zerogxplode.spr"
	ignoredClass = 0
	iMagnitude = 100
	rendermode = 5
	spawnflags = 2 | 64 // Repeatable | No Sound
	origin = Vector(0, 0, 0)
}

RECHARGE_HINT <- 
{
	classname = "env_instructor_hint"
	hint_name = "recharge_hint"
	hint_caption = "Syringe recharging"
	hint_auto_start = 0
	hint_target = ""
	hint_timeout = 2
	hint_static = 1
	hint_forcecaption = 1
	hint_icon_onscreen = "icon_no"
	hint_instance_type = 2
	hint_color = "255 255 255"
}
