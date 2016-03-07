/* 
 * Custom weapon template script. 
 * A magic staff that shoots fireballs.
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
 */

viewmodel <- null 		// Viewmodel entity
currentPlayer <- null 	// The player using the weapon

FIREBALL_INTERVAL <- 7 		// How many frammes before the fireball can be fired again.
TRACE_MAX_DISTANCE <- 2048 	// How far the attack ray trace goes.

fireballDelay <- 0			// Counter for the refire delay.
fireballEntity <- null		// Persistant entity for the fireball explosion.
fireballFired <- false		// Tracks if the fireball has been fired in the for the duration of the keypress.

// Called after the script has loaded.
function OnInitialize()
{
	printl("New custom weapon script on ent: " + self)
	
	// Registers a function to run every frame.
	AddThinkToEnt(self, "Think")
	
	// Precaches the sounds needed.
	self.PrecacheScriptSound("Player.HeartbeatLoop")
	self.PrecacheScriptSound("BaseGrenade.Explode")
	
	// Spawns the explosion entity
	fireballEntity = g_ModeScript.CreateSingleSimpleEntityFromTable(FIREBALL_ENTITY)
}

// Called when a player swithces to the the weapon.
function OnEquipped(player, _viewmodel)
{
	viewmodel = _viewmodel
	currentPlayer = player
	
	// Plays a looping heartbeat sound as long as the player has the weapon out.
	EmitSoundOn("Player.HeartbeatLoop", currentPlayer)
}

// Called when a player switches away from the weapon.
function OnUnEquipped()
{
	StopSoundOn("Player.HeartbeatLoop", currentPlayer)
	
	currentPlayer = null
	viewmodel = null
}

// Called when the player stats firing.
function OnStartFiring()
{

}

// A think function to decrement the delay timer.
function Think()
{
	if(fireballDelay > 0)
	{
		fireballDelay--
	}
}

// Called every frame the player the player holds down the fire button.
function OnFireTick(playerButtonMask)
{	
	if(fireballDelay < 1)
	{
		if(!fireballFired)
		{
			fireballDelay = FIREBALL_INTERVAL
			ShootFireBall()
			fireballFired = true
		}
	}
}

// Called when te plaeyr ends firing.
function OnEndFiring()
{
	fireballFired = false
}

// Do a ray reace where the player is looing and spawn an explosion there.
function ShootFireBall()
{
	local traceStartPoint = currentPlayer.EyePosition()	
	local traceEndpoint = currentPlayer.EyePosition() + VectorFromQAngle(currentPlayer.EyeAngles(), TRACE_MAX_DISTANCE)
		
	local traceTable =
	{
		start = currentPlayer.EyePosition()
		end = traceEndpoint
		ignore = currentPlayer
	}
	TraceLine(traceTable) // Performs the trace.
	
	// If we hit an entity, color it red (if it suports the Color input).
	if("enthit" in traceTable)
	{
		DoEntFire("!self", "Color", "240 32 32", 0, self, traceTable.enthit)			
	}
	
	if(traceTable.hit) // If we hit something along the trace.
	{
		// Draw a green line to the hit position (move to see it).
		DebugDrawLine(traceStartPoint, traceTable.pos, 0, 255, 0, true, 2.0)
		
		// Move the explosion entity to the right position.
		fireballEntity.SetOrigin(traceTable.pos)
	}
	else
	{
		// Draw a red line to the end of the trace.
		DebugDrawLine(traceStartPoint, traceEndpoint, 255, 0, 0, true, 2.0)
		
		fireballEntity.SetOrigin(traceEndpoint)
	}
	
	// BOOM!
	DoEntFire("!self", "Explode", "" 0, currentPlayer, fireballEntity)
	EmitSoundOn("BaseGrenade.Explode", fireballEntity)
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

// Entity keyvalue table for spawning the explosion entity.
FIREBALL_ENTITY <-
{
	classname = "env_explosion"
	targetname = "fireball"
	iRadiusOverride = 0
	fireballsprite = "sprites/zerogxplode.spr"
	ignoredClass = 0
	iMagnitude = 100
	rendermode = 5
	spawnflags = 2 | 64 // Repeatable | No Sound
	origin = Vector(0, 0, 0)
}
