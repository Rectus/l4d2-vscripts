
damageActive <- true
armCounter <- 0
ARM_DELAY <- 0 
TRACE_DISTANCE <- 256
inititalized <- false
prevAngles <- null
ANGLE_TOLERANCE <- 0.1
ROCKETJUMP_RADIUS <- 64
ROCKETJUMP_FORCE <- 600
DIRECT_DAMAGE <- 7000
DAMAGE_RADIUS <- 512
STUMBLE_RADIUS <- 600
MAX_DAMAGE <- 1500
SELF_DAMAGE_CAP <- 33
EXPLOSION_FORCE <- 8000
SURVIVOR_DAMAGE_FACTOR <- 0.33

usingPlayer <- null
exploded <- false

pushEntities <- 
[
	"prop_physics",
	"prop_car_alarm",
	"scripted_item_drop",
	"prop_physics_multiplayer",
	"prop_ragdoll",
	"func_physbox"
]

excludeDamage <-
[
	"prop_door_rotating_checkpoint"
]

function OnPostSpawn()
{
	AddThinkToEnt(self, "Think")
	DoEntFire("!self", "CallScriptFunction", "Think", 0.01, self, self)
}

function Think()
{	
	if(!inititalized)
	{
		inititalized = true
		self.ApplyAbsVelocityImpulse(VectorFromQAngle(self.GetAngles(), 6000))
		self.ApplyLocalAngularVelocityImpulse(VectorFromQAngle(QAngle(0, 0, 0), 5000))
	}

	self.ApplyAbsVelocityImpulse(VectorFromQAngle(self.GetAngles(), 1000))
	
	
	if(armCounter++ < ARM_DELAY)
	{
		return
	}
	
	if(TraceDirectHit())
	{
		return
	}
	
	if(prevAngles && VectorFromQAngle(prevAngles).Dot(VectorFromQAngle(self.GetAngles())) < (1 - ANGLE_TOLERANCE))
	{
		//printl(VectorFromQAngle(prevAngles).Dot(VectorFromQAngle(self.GetAngles())))
		Explode()
	}
	prevAngles = self.GetAngles()
	
	if(GetPhysVelocity(self).Length() < 5)
	{
		Explode()
	}
}

function TraceDirectHit()
{
	local traceTable =
	{
		start = self.GetOrigin()
		end = self.GetOrigin() + VectorFromQAngle(self.GetAngles(), TRACE_DISTANCE)
		ignore = self
		mask =  0x1 | 0x2 | 0x4 | 0x8 | 0x2000 | 0x4000 | 0x2000000 | 0x40000000
		//mask = DirectorScript.TRACE_MASK_ALL
	}
	//DebugDrawLine(traceTable.start, traceTable.end, 0, 255, 0, false, 0.11)
	TraceLine(traceTable)
	
	if(traceTable.hit)
	{
		if(traceTable.enthit && traceTable.enthit.IsValid() && traceTable.enthit.GetEntityIndex() > 0
			&& excludeDamage.find(traceTable.enthit.GetClassname()) == null)
		{
			traceTable.enthit.TakeDamage(DIRECT_DAMAGE, (1 << 6) | (1 << 25), usingPlayer)
		}
		self.SetOrigin(traceTable.pos)
		Explode()
	}
	return false
}

function Explode()
{
	if(exploded) {return}
	exploded = true

	local player = null
	
	if(usingPlayer && (usingPlayer.GetOrigin() - self.GetOrigin()).Length() <= ROCKETJUMP_RADIUS)
	{
		local playerVec = usingPlayer.GetOrigin() + Vector(0, 0, 32) - self.GetOrigin()
		usingPlayer.ApplyAbsVelocityImpulse(playerVec  * (ROCKETJUMP_FORCE / playerVec.Length()))
	}

	DoRadialDamage(self.GetOrigin(), DAMAGE_RADIUS, MAX_DAMAGE, (1 << 6) | (1 << 25))

	DoRadialDamage(self.GetOrigin(), STUMBLE_RADIUS, 1, (1 << 25))
	
	local physExplosionEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(PHYSEXPLOSION_ENTITY)
	physExplosionEnt.SetOrigin(self.GetOrigin())
	
	local explosionEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(EXPLOSION_ENTITY)
	explosionEnt.SetOrigin(self.GetOrigin())
	
	ROCKET_FIREBALL.origin = self.GetOrigin()
	local fireballEnt = g_ModeScript.CreateSingleSimpleEntityFromTable(ROCKET_FIREBALL)
	
	DoEntFire("!self", "Explode", "" 0, self, physExplosionEnt)
	DoEntFire("!self", "Explode", "" 0, self, explosionEnt)
	
	DoEntFire("!self", "Kill", "" 0.1, self, physExplosionEnt)
	DoEntFire("!self", "Kill", "" 0.1, self, explosionEnt)
	DoEntFire("!self", "Kill", "" 15, self, fireballEnt)
	EmitSoundOn("GrenadeLauncher.Explode", fireballEnt)
	
	self.Kill()
}


function DoRadialDamage(position, radius, maxDamage, dmgType)
{
	local entity = null
	local ffFactor = GetFriendlyFireFactor()

	while(entity = Entities.FindInSphere(entity, position, radius))
	{
		if(entity.GetClassname() == "player" && entity.IsSurvivor())
		{	
			local damage = maxDamage * (1 - (entity.GetOrigin() - position).Length() / radius) * ffFactor * SURVIVOR_DAMAGE_FACTOR
			
			if(entity == usingPlayer && damage > SELF_DAMAGE_CAP)
			{
				damage = SELF_DAMAGE_CAP
			}
			
			if(damage > 0 && damage < 1) {damage = 1}
			
			entity.TakeDamage(damage, dmgType, usingPlayer)
		}
		else if(entity.GetEntityIndex() > 0 && excludeDamage.find(entity.GetClassname()) == null)
		{
			local distanceFactor = (1 - (entity.GetOrigin() - position).Length() / radius)
			local damage = maxDamage * distanceFactor
			
			if(damage > 0 && damage < 1) {damage = 1}
			
			entity.TakeDamage(damage, dmgType, usingPlayer)
			
			if(pushEntities.find(entity.GetClassname()) != null)
			{
				local direction = (entity.GetOrigin() - position)
				entity.ApplyAbsVelocityImpulse(direction * (1 / direction.Length()) * EXPLOSION_FORCE * distanceFactor)
			}
		}
	}
}


function GetFriendlyFireFactor()
{
	switch(Convars.GetStr("z_difficulty"))
	{
	case "Easy":
	case "easy":
		return Convars.GetFloat("survivor_friendly_fire_factor_easy")
		
	case "Normal":
	case "normal":
		return Convars.GetFloat("survivor_friendly_fire_factor_normal")
		
	case "Hard":
	case "hard":
		return Convars.GetFloat("survivor_friendly_fire_factor_hard")
		
	case "Impossible":
	case "impossible":
		return Convars.GetFloat("survivor_friendly_fire_factor_expert")
	
	default:
		return 1.0
	}
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


PHYSEXPLOSION_ENTITY <-
{
	classname = "env_physexplosion"
	targetname = "rocket_push"
	radius = 1000
	//fireballsprite = "sprites/zerogxplode.spr"

	magnitude = EXPLOSION_FORCE * 10
	spawnflags = 1 // No damage
	origin = Vector(0, 0, 0)
}

EXPLOSION_ENTITY <-
{
	classname = "env_explosion"
	targetname = "fireball"
	iRadiusOverride = 500
	fireballsprite = "sprites/zerogxplode.spr"
	ignoredClass = 0
	iMagnitude = 1
	rendermode = 5
	spawnflags = 4 | 8 | 64 // No explosion | No Smoke | No Sound
	origin = Vector(0, 0, 0)
}


ROCKET_FIREBALL <-
{
	classname = "info_particle_system"
	angles = Vector(0, 0, 0)
	effect_name = "weapon_grenadelauncher"
	//effect_name = "missile_hit1"
	render_in_front = "0"
	start_active = "1"
	targetname = "rocket_fireball"
	origin = Vector(0, 0, 0)
}

