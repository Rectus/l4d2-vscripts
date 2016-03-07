// Script for spawning the entity group versions of the turrets in the demo map.


// Adds the EMS spawning helpers.
function smDbgPrint(_) {}
function smDbgLoud(_) {}
IncludeScript("sm_utilities");
IncludeScript("sm_spawn");

// Includes the entity groups for the turrets.
IncludeScript("entitygroups/turretsystem_mg_turret_group");
IncludeScript("entitygroups/turretsystem_flame_turret_group");
IncludeScript("entitygroups/turretsystem_laser_turret_group");
IncludeScript("entitygroups/turretsystem_flak_turret_group");

// Spawns the turrets on all info_item_position entities with the name <turret name>_spawn.
SpawnMultiple(TurretsystemMgTurret.GetEntityGroup(), {filter = @(group) group.GetName() == "turretsystem_mg_turret_spawn"});
SpawnMultiple(TurretsystemFlameTurret.GetEntityGroup(), {filter = @(group) group.GetName() == "turretsystem_flame_turret_spawn"});
SpawnMultiple(TurretsystemLaserTurret.GetEntityGroup(), {filter = @(group) group.GetName() == "turretsystem_laser_turret_spawn"});
SpawnMultiple(TurretsystemFlakTurret.GetEntityGroup(), {filter = @(group) group.GetName() == "turretsystem_flak_turret_spawn"});