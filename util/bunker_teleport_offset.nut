// Teleports entities in a radius around the source, relative to the source and destination markers.

TeleSource <- Entities.FindByName(null, "tele_source");
TeleDest <- Entities.FindByName(null, "tele_dest");

function Teleport(radius)
{
	local source = TeleSource.GetOrigin();
	local destination = TeleDest.GetOrigin();
	local teleportSet = [];
	local entity = null;
	
	// Doing all the work before we actually teleport anyone.
	while( entity = Entities.FindInSphere(entity, source, radius))
		if((entity.GetClassname() == "player") || (entity.GetClassname() == "infected"))
			teleportSet.append(entity);

	
	foreach(object in teleportSet)
		object.SetOrigin(destination + (object.GetOrigin() - source));
}

