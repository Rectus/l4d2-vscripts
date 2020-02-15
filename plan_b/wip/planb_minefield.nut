

MINE_AVG_DISTANCE <- 128;
MINE_DISTANCE_VARIATION <- 96;
MINE_Z_RANGE <- 128;
MINE_DETONATION_RADIUS <- 24;
MINE_DETONATION_RADIUS_SQUARE <- MINE_DETONATION_RADIUS * MINE_DETONATION_RADIUS;
MINE_DETONATION_RADIUS_PLAYER <- 20;
MINE_DETONATION_RADIUS_PLAYER_SQUARE <- MINE_DETONATION_RADIUS_PLAYER * MINE_DETONATION_RADIUS_PLAYER;
ENTITY_CENTER_RANGE <- 1500;
ENTITY_CLASSES <- ["player", "infected", "prop_physics", "prop_physics_multiplayer", "weapon_gascan", 
	"grenade_launcher_projectile", "pipe_bomb_projectile", "molotov_projectile", "vomitjar_projectile"]
DIFFICULTY_DENSITY_FACTOR <- [0.5, 0.8, 1.0, 1.25]
mines <- [];
detEntites <- [];
DEBUG <- false;
thinkPeriod <- 0;
mineSpawner <- null;


function GetDifficultyLevel()
{
	local diffStrings = 
	{
		easy = 0
		normal = 1
		hard = 2
		impossible = 3
	}
	local difficulty = Convars.GetStr("z_difficulty").tolower();
	
	return diffStrings[difficulty];
}

function GenerateMineField()
{
	local baseHeight = 0;
	local boundaryNorth = 0;
	local boundarySouth = 0;
	local boundaryWest = 0;
	local boundaryEast = 0;

	try
	{
		mineSpawner = Entities.FindByName(null, "mine_spawner");

		baseHeight = self.GetOrigin().z;
		boundaryNorth = Entities.FindByName(null, "minefield_boundary_n").GetOrigin().y;
		boundarySouth = Entities.FindByName(null, "minefield_boundary_s").GetOrigin().y;
		boundaryWest = Entities.FindByName(null, "minefield_boundary_w").GetOrigin().x;
		boundaryEast = Entities.FindByName(null, "minefield_boundary_e").GetOrigin().x;
	}
	catch(exception)
	{
		throw("Minefield script: Failed to find all nessecary entities: " + exception);
	}

	if(DEBUG)
	{
		printl("Minefield bounds " + boundaryNorth + " to " + boundarySouth + " and " + boundaryWest + " to " + boundaryEast + "\nHeight " + baseHeight);
	}
	
	mines = [];
	
	local diffFactor = DIFFICULTY_DENSITY_FACTOR[GetDifficultyLevel()];
	
	local numMinesNS = (boundaryNorth - boundarySouth) * diffFactor / MINE_AVG_DISTANCE;
	numMinesNS = numMinesNS - numMinesNS % 1;
	
	local numMinesWE = (boundaryEast - boundaryWest) * diffFactor / MINE_AVG_DISTANCE;
	numMinesWE = numMinesWE - numMinesWE % 1;
	
	printl("Number of mines: x " + numMinesWE + " y " + numMinesNS);
	
	local distVariation = MINE_DISTANCE_VARIATION / diffFactor;
	
	for(local i = 0; i < numMinesWE; i++)
	{
		local baseX = boundaryWest + MINE_AVG_DISTANCE * i / diffFactor;
	
		for(local j = 0; j < numMinesNS; j++)
		{
			local baseY = boundarySouth + MINE_AVG_DISTANCE * j / diffFactor;
			
			local posX = RandomFloat(-distVariation, distVariation) + baseX;
			local posY = RandomFloat(-distVariation, distVariation) + baseY;
			
			mines.append(TraceToGround(Vector(posX, posY, baseHeight)));
			
		}
	}
	if(DEBUG)
		printl("Number of mines generated: " + mines.len());
		
	AddThinkToEnt(self, "Think");
	RecalculateEntities();
}

function TraceToGround(basePos)
{
	local traceTable =
	{
		start = basePos
		end = basePos + Vector(0, 0, -512)
		mask = DirectorScript.TRACE_MASK_NPC_SOLID
	}
	
	if(TraceLine(traceTable))
	{
		return traceTable.pos;
	}
	else
	{
		return basePos;
	}
}

function RecalculateEntities()
{
	local tempEntities = [];
	
	foreach(entityClass in ENTITY_CLASSES)
	{
		local entity = null;
		while(entity = Entities.FindByClassnameWithin(entity, entityClass, self.GetOrigin(), ENTITY_CENTER_RANGE))
		{
			if(entityClass == "player" && entity.IsDead())
				continue;
				
			tempEntities.append(entity);
		}
	}
	
	detEntites = [];
	detEntites.extend(tempEntities);
	
	if(DEBUG)
		printl(detEntites.len() + " entities found near minefield.");
}

function Think()
{
	if((thinkPeriod = (thinkPeriod + 1) % 10) == 0)
	{
		//RecalculateEntities();
	
		if(DEBUG)
			foreach(minePos in mines)
			{
				DebugDrawLine(minePos, minePos + Vector(0, 0, 32), 0, 255, 0, true, 1.0);
				DebugDrawCircle(minePos, Vector(0, 128, 0), 192, MINE_DETONATION_RADIUS, true, 1.0);
			}
	}
	
	foreach(entity in detEntites)
	{
		if(entity && entity.IsValid())
		{
			local entOrigin = entity.GetOrigin();
			local isPlayer = entity.GetClassname() == "player";
		
			if(DEBUG)
			{
				if(thinkPeriod == 0)
					DebugDrawCircle(entOrigin, Vector(0, 0, 192), 192, 32, true, 1.0);
			}
			
			foreach(minePos in mines)
			{
				local distanceSqr = (minePos - entOrigin).LengthSqr();
			
				if((!isPlayer && distanceSqr < MINE_DETONATION_RADIUS_SQUARE)
					|| distanceSqr < MINE_DETONATION_RADIUS_PLAYER_SQUARE)
				{
					mines.remove(mines.find(minePos));
					
					if(DEBUG)
						DebugDrawLine(minePos, minePos + Vector(0, 0, 48), 255, 0, 0, true, 10.0);
						
					DetonateMine(minePos, entity);
				}
			}
		}
	}
}


function DetonateMine(position, triggeringEntity)
{
	mineSpawner.SpawnEntityAtLocation(position, Vector(0, 0, 0));
	
	if(triggeringEntity.GetClassname() == "player")
		triggeringEntity.Stagger(position);
}

