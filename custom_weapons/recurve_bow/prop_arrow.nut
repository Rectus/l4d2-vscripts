
AddThinkToEnt(self, "Think")
damageActive <- true
stillCounter <- 0
TRACE_DISTANCE <- 64
entitiesHit <- {}
TRACE_INTERVAL <- 0.1
GLANCING_HIT_DISTANCE <- 32
INFECTED_HIT_VELOCITY_FACTOR <- 0.8
usingPlayer <- null
color <- null

SURVIVOR_DAMAGE <- 15
INFECTED_DAMAGE <- 500
WITCH_DAMAGE_MULTIPLIER <- 0.7

DoEntFire("!self", "CallScriptFunction", "Think", 0.0, self, self)
DoEntFire("!self", "CallScriptFunction", "Think", 0.05, self, self)

function SetColor(colorString)
{
	color = colorString
	DoEntFire("!self", "Color", colorString, 0, self, self)
}

function Think()
{
	DoEntFire("!self", "CallScriptFunction", "Think", TRACE_INTERVAL / 2, self, self)

	if(!("bowScript" in this))
	{
		return TRACE_INTERVAL
	}
	
	if(!damageActive)
	{
		if(CheckStillArrow())
		{
			return TRACE_INTERVAL
		}
	
		return TRACE_INTERVAL
	}
	
	if(TraceDirectHit(true))
	{
		return TRACE_INTERVAL
	}
	else if(damageActive)
	{
		CheckGlancingHits()
	}
	
	if(CheckStillArrow())
	{
		return TRACE_INTERVAL
	}
}

// Hack to damage nearby commons since their positions are not always synched between players and server.
function CheckGlancingHits()
{
	local target = null
	local survivorHit = false
	//DebugDrawCircle(self.GetOrigin(), Vector(0, 0, 255), 200, GLANCING_HIT_DISTANCE, false, 5.0)
	while(target = Entities.FindInSphere(target, self.GetOrigin(), 64))
	{
		if((target.GetOrigin() + Vector(0, 0, 48) - self.GetOrigin()).Length() < GLANCING_HIT_DISTANCE 
			&& target.GetClassname() == "infected")
		{
			//DebugDrawLine(target.GetOrigin() + Vector(0, 0, 48), self.GetOrigin(), 0, 0, 255, true, 5)
		
			if(target in entitiesHit)
			{
				continue
			}
			entitiesHit[target] <- null
		
			local targetPos = target.GetOrigin()
			local damagePos = Vector(targetPos.x, targetPos.y, self.GetOrigin().z)			
			
			//printl("Glancing hit on infected: " + target)
			EmitSoundOn("Zombie.BulletImpact", self)
			EmitSoundOnClient("Zombie.BulletImpact", usingPlayer)
			target.TakeDamage(INFECTED_DAMAGE, (1 << 1), usingPlayer)
			self.SetVelocity(GetPhysVelocity(self) * INFECTED_HIT_VELOCITY_FACTOR)
			//return
			
		}
	}
}

function TraceDirectHit(hitUsingPlayer)
{

	local traceDistance = GetPhysVelocity(self).Length() * TRACE_INTERVAL * 0.5
	
	if(traceDistance < TRACE_DISTANCE)
	{
		traceDistance = TRACE_DISTANCE
	}

	local traceTable =
	{
		start = self.GetOrigin()
		end = self.GetOrigin() + VectorFromQAngle(self.GetAngles(), traceDistance)
		ignore = self
		mask =  0x1 | 0x2 | 0x4 | 0x8 | 0x2000 | 0x4000 | 0x2000000 | 0x40000000
		//mask = DirectorScript.TRACE_MASK_ALL
	}
	//DebugDrawLine(traceTable.start, traceTable.end, 0, 255, 0, true, 5)
	TraceLine(traceTable)
	
	if(traceTable.hit)
	{
		if("enthit" in traceTable && traceTable.enthit.GetEntityIndex() != 0)
		{
			//printl("Arrow hit entity: " + traceTable.enthit)
		
			if(traceTable.enthit.GetClassname() == "player")
			{
				if(!hitUsingPlayer && traceTable.enthit == usingPlayer)
				{
					return false
				}
			
				if(traceTable.enthit.IsSurvivor())
				{
					traceTable.enthit.TakeDamage(SURVIVOR_DAMAGE * GetFriendlyFireFactor(), (1 << 1), usingPlayer)
					
					SpawnEffect(bowScript.ARROW_HIT_EFFECT_BLOOD, traceTable.pos)
					SpawnStaticArrow(traceDistance * traceTable.fraction, traceTable.enthit, "Zombie.BulletImpact")
				}
				else
				{
					if(traceTable.enthit.GetHealth() > INFECTED_DAMAGE)
					{
						SpawnEffect(bowScript.ARROW_HIT_EFFECT_BLOOD, traceTable.pos)
						SpawnStaticArrow(traceDistance * traceTable.fraction, traceTable.enthit, "Zombie.BulletImpact")
					}
					else
					{					
						EmitSoundOn("Zombie.BulletImpact", self)
						EmitSoundOnClient("Zombie.BulletImpact", usingPlayer)
					}
					traceTable.enthit.TakeDamage(INFECTED_DAMAGE, (1 << 1), usingPlayer)
					
				}
				damageActive = false
				
				return true
			}
			else if(traceTable.enthit.GetClassname() == "infected")
			{
				traceTable.enthit.TakeDamage(INFECTED_DAMAGE, (1 << 1), usingPlayer)
				EmitSoundOn("Zombie.BulletImpact", self)
				EmitSoundOnClient("Zombie.BulletImpact", usingPlayer)
				self.SetVelocity(GetPhysVelocity(self) * INFECTED_HIT_VELOCITY_FACTOR)
				SpawnEffect(bowScript.ARROW_HIT_EFFECT_BLOOD, traceTable.pos)
				return false
			}
			else if(traceTable.enthit.GetClassname() == "witch")
			{
				damageActive = false
				local hitDamage = INFECTED_DAMAGE * WITCH_DAMAGE_MULTIPLIER
				if(traceTable.enthit.GetHealth() > hitDamage)
				{
					SpawnEffect(bowScript.ARROW_HIT_EFFECT_BLOOD, traceTable.pos)
					SpawnStaticArrow(traceDistance * traceTable.fraction, traceTable.enthit, "Zombie.BulletImpact")
				}
				else
				{					
					EmitSoundOn("Zombie.BulletImpact", self)
					EmitSoundOnClient("Zombie.BulletImpact", usingPlayer)
				}
				traceTable.enthit.TakeDamage(hitDamage, (1 << 1), usingPlayer)
				return true
			}
			else
			{
				damageActive = false
				traceTable.enthit.TakeDamage(INFECTED_DAMAGE, (1 << 1), usingPlayer)
				
				SpawnEffect(bowScript.ARROW_HIT_EFFECT, traceTable.pos)
				SpawnStaticArrow(traceDistance * traceTable.fraction, null, "weapons/bow/arrow_impact.wav")
				return true
			}

		}
		else
		{
			damageActive = false
			SpawnEffect(bowScript.ARROW_HIT_EFFECT, traceTable.pos)
			SpawnStaticArrow(traceDistance * traceTable.fraction null, "weapons/bow/arrow_impact.wav")
			return true
		}
	}
	return false
}

function GetFriendlyFireFactor()
{
	switch(Convars.GetStr("z_difficulty").tolower())
	{
	case "easy":
		return Convars.GetFloat("survivor_friendly_fire_factor_easy")
		
	case "normal":
		return Convars.GetFloat("survivor_friendly_fire_factor_normal")
		
	case "hard":
		return Convars.GetFloat("survivor_friendly_fire_factor_hard")
		
	case "impossible":
		return Convars.GetFloat("survivor_friendly_fire_factor_expert")
	
	default:
		return 1.0
	}
}


function SpawnEffect(keyvals, origin)
{
	local keyvalues = clone keyvals
	keyvalues.origin = origin
	keyvalues.angles = self.GetAngles()
	local effect = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)
	DoEntFire("!self", "Kill", "", 1.0, effect, effect)
}

function CheckStillArrow()
{
	if(GetPhysVelocity(self).Length() < 5)
	{
		damageActive = false
	
		if(stillCounter++ > 10)
		{
			SpawnStaticArrow(0)
			return true
		}
	}
	else
	{
		stillCounter = 0
	}
	return false
}


function SpawnStaticArrow(penetration, entity = null, sound = null)
{
	local keyvalues = clone bowScript.ARROW_STATIC
	if(penetration > 32)
	{
		keyvalues.origin = self.GetOrigin() + VectorFromQAngle(self.GetAngles(), penetration - 28)
	}
	else
	{
		keyvalues.origin = self.GetOrigin()
	}
	keyvalues.angles = self.GetAngles()
	keyvalues.rendercolor <- color
	local statArrow = g_ModeScript.CreateSingleSimpleEntityFromTable(keyvalues)

	DoEntFire("!self", "Kill", "", 150, statArrow, statArrow)
	
	if(entity)
	{
		DoEntFire("!self", "SetParent", "!activator", 0 , entity, statArrow)	
		if(entity.GetClassname() == "player" && entity.IsSurvivor())
		{
			DoEntFire("!self", "SetParentAttachmentMaintainOffset", "spine", 0.1 , statArrow, statArrow)
		}
	}
	if(sound)
	{
		EmitSoundOn(sound, statArrow)
		EmitSoundOnClient(sound, usingPlayer)
	}
	
	self.Kill()
}


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

