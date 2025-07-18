// ================================
// chronicles.dm
// Chronicle Events & Shared History System
// ================================
// Tracks important IC events across characters and groups.
// Designed for use with the AboutMe component.
// ================================

/datum/chronicle
	var/id
	var/title = "Untitled Chronicle"
	var/details = ""
	var/timestamp = 0

	var/list/related_memories = list()         // /datum/memory
	var/list/related_relationships = list()     // /datum/relationship
	var/list/related_characters = list()       // list of ckeys
	var/list/related_groups = list()           // /datum/groups

/datum/chronicle/New(var/_title, var/_details)
	..()
	timestamp = world.realtime
	id = "[timestamp]_[rand(1000,9999)]"
	title = _title
	details = _details

/datum/chronicle_entry
	var/id
	var/time
	var/title
	var/details
	var/created_time
	var/list/attached_memories = list()
	var/list/tags = list()

/datum/chronicle_entry/New(var/_title, var/_details)
	..()
	title = _title
	details = _details
	created_time = world.time
	id = "[created_time]_[rand(1000,9999)]"


// ========== Linking Procs ==========

/datum/chronicle/proc/AddMemory(var/datum/memory/M)
	if (M && !related_memories.Find(M))
		related_memories += M

/datum/chronicle/proc/AddRelationship(var/datum/relationship/R)
	if (R && !related_relationships.Find(R))
		related_relationships += R

/datum/chronicle/proc/AddCharacter(var/ckey)
	if (ckey && istext(ckey) && !related_characters.Find(ckey))
		related_characters += ckey

/datum/chronicle/proc/AddGroup(var/datum/groups/G)
	if (G && !related_groups.Find(G))
		related_groups += G

// ========== UI Display Formatting ==========

/datum/chronicle/proc/GetFormattedUI()
	var/list/output = list()
	output["id"] = id
	output["title"] = title
	output["details"] = details
	output["timestamp"] = timestamp

	output["memories"] = list()
	for (var/datum/memory/M in related_memories)
		output["memories"] += M.GetFormattedUI()

	output["relationships"] = list()
	for (var/datum/relationships/R in related_relationships)
		output["relationships"] += R.GetFormattedUI()

	output["characters"] = related_characters.Copy()

	output["groups"] = list()
	for (var/datum/groups/G in related_groups)
		output["groups"] += G.GetFormattedUI()

	return output

// ========== Save/Load Support ==========
// These are automatically handled in the save/load of aboutme.dm
// assuming `chronicle_events` contains only /datum/chronicle entries

