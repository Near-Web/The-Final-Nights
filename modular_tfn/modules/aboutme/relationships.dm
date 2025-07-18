// ================================
// Relationships System - relationships.dm
// ================================

/datum/relationships
	var/id
	var/name = "Unnamed Relationship"
	var/relationship_type = REL_TYPE_ACQUAINTANCE
	var/desc = "No description yet."
	var/strength = 0 // -100 to +100
	var/visible = TRUE
	var/mutual = FALSE

	var/source_ckey
	var/target_ckey

	var/list/tags = list()
	var/list/rel_memories = list()
	var/flags = 0

// -----------------------
// Flag Utilities
// -----------------------

/datum/relationships/proc/HasFlag(flag)
	return (flags & flag) != 0

/datum/relationships/proc/AddFlag(flag)
	flags |= flag

/datum/relationships/proc/RemoveFlag(flag)
	flags &= ~flag

/datum/relationships/proc/ClearFlags()
	flags = 0

// -----------------------
// UI Packaging
// -----------------------

/datum/relationships/proc/GetFormattedUI()
	. = list(
		"id" = id,
		"name" = name,
		"type" = relationship_type,
		"strength" = strength,
		"desc" = desc,
		"visible" = visible,
		"mutual" = mutual,
		"source" = source_ckey,
		"target" = target_ckey,
		"flags" = flags,
		"tags" = tags.Copy(),
		"rel_memories" = list()
	)

	for (var/datum/memory/M in rel_memories)
		.["rel_memories"] += list(M.GetFormattedUI())


// -----------------------
// Relationship Generator
// -----------------------
/proc/GenerateRelationship(
	source_ckey,
	target_ckey,
	relationship_type = REL_TYPE_ACQUAINTANCE,
	strength = 0,
	name = null,
	desc = null,
	mutual = FALSE,
	var/list/tags = list(),
	var/list/rel_memories = list(),
	flags = 0
)
	if (!source_ckey || !target_ckey)
		return null

	var/id = "[world.time]-[rand(1000, 9999)]"

	var/datum/relationships/R = new()
	R.id = id
	R.source_ckey = source_ckey
	R.target_ckey = target_ckey
	R.relationship_type = relationship_type
	R.strength = strength
	R.name = name || "[relationship_type] with [target_ckey]"
	R.desc = desc || "A [relationship_type] relationship between [source_ckey] and [target_ckey]."
	R.mutual = mutual
	R.tags = tags.Copy()
	R.rel_memories = rel_memories.Copy()
	R.flags = flags

	// Return both relationships if mutual
	if (mutual)
		var/datum/relationships/R2 = new()
		R2.id = "[world.time]-[rand(1000, 9999)]"
		R2.source_ckey = target_ckey
		R2.target_ckey = source_ckey
		R2.relationship_type = relationship_type
		R2.strength = strength
		R2.name = name || "[relationship_type] with [source_ckey]"
		R2.desc = desc || "A [relationship_type] relationship between [target_ckey] and [source_ckey]."
		R2.mutual = TRUE
		R2.tags = tags.Copy()
		R2.rel_memories = rel_memories.Copy()
		R2.flags = flags
		return list(R, R2)

	return R

/datum/relationships/proc/IsVisibleTo(ckey)
	return visible || source_ckey == ckey || (mutual && target_ckey == ckey)

/datum/relationships/proc/AddMemory(var/datum/memory/M)
	if (M && !(M in rel_memories))
		rel_memories += M

/datum/relationships/proc/RemoveMemory(var/datum/memory/M)
	if (M in rel_memories)
		rel_memories -= M

