//This exports specific data for the about me tgui, to avoid sending everything.
/datum/component/about_me/proc/export_memory()
	var/list/exported = list()
	for (var/datum/memory/M in src.memories_all)
		exported += list(M.export_data())
	return exported

/datum/component/about_me/proc/export_chronicle()
	var/list/events = list()
	for (var/event in chronicles_all)
		if (islist(event))
			events += list(event)
		else if (istype(event, /datum/chronicle))
			var/datum/chronicle/E = event
			events += list(E.GetFormattedUI())
	return events

/datum/component/about_me/proc/export_relationships()
    var/list/exported = list()
    for (var/G in group_relationships)
        if (!istype(G, /datum/groups)) continue
        var/datum/groups/group = G
        exported += list(list(
            "id" = group.id,
            "name" = group.name,
            "relationship_type" = group.get_relationship_type(owner), // e.g. "Clan", "Sect", "Coterie"
            "strength" = "Member", // Or whatever logic you want
            "icon" = group.icon, // if you support icons
        ))
    // In the future, merge relationships_all as well!
    return exported


