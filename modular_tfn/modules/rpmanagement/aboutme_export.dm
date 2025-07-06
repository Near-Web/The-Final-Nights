//This exports specific data for the about me tgui, to avoid sending everything.

/datum/component/about_me/proc/export_memory()
	var/list/exported = list()
	for (var/datum/memory/M in src.memories_all)
		exported += list(M.export_data())
	return exported

/datum/component/about_me/proc/export_relationships()
	var/list/output = list()
	for (var/datum/relationships/R in group_relationships)
		if (ispath(R.type) && istype(R))
			output += list(R.GetFormattedUI())
	return output

/datum/component/about_me/proc/export_chronicle()
	var/list/events = list()
	for (var/event in chronicle_events)
		if (islist(event))
			events += list(event)
		else if (istype(event, /datum/chronicle))
			var/datum/chronicle/E = event
			events += list(E.GetFormattedUI())
	return events
