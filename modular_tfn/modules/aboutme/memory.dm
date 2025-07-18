// ================================
// Memory System - memories.dm
// ================================
// Individual memory entries + memory container component
// ================================

/// Individual memory datum
/datum/memory
	var/id // Unique memory ID (e.g. "672342-1234")
	var/time
	var/title = ""
	var/details = ""
	var/tier = null                // E.g., MEMORY_BACKGROUND, MEMORY_RECENT, etc.
	var/list/tags = list()         // Arbitrary labels (e.g. ["secret", "sect", "event"])
	var/source_ckey = null         // Who created the memory
	var/status = "active"          // Optional: draft, verified, redacted, etc.
	var/created_time = null        // Timestamp of creation

	// Expanded metadata
	var/is_public = TRUE           // Whether this memory is visible to others
	var/edited_time = null         // Last time it was edited (if ever)
	var/editor_ckey = null         // Who last edited it
	var/list/related_groups = list()  // Group names, e.g. ["Camarilla", "Clan Tremere"]
	var/memory_type = null         // Optional enum or identifier (e.g. "event", "relationship", "rumor")

/datum/memory/New(title = "", details = "", source = null, taglist = list(), tier = null)
		..()
		src.title = title
		src.details = details
		src.source_ckey = source
		src.tags = taglist
		src.tier = tier
		src.created_time = world.time
		src.status = "active"
		src.is_public = TRUE

/datum/memory/proc/export_data()
    return list(
        "id" = src.id,
        "title" = src.title,
        "details" = src.details,
        "tags" = src.tags,
        "status" = src.status,
        "time" = src.time,
        // ...any other properties for the UI
    )
/// Stores memories about a specific character
/datum/memory_set
	var/target_ckey = ""
	var/list/memories = list()

// ================================
// Memory Generator Utility
// ================================
/proc/GenerateMemory(
	var/title = "Untitled Memory",
	var/details = "",
	var/source_ckey = null,
	var/tier = null,
	var/list/tags = list(),
	var/status = "active",
	var/is_public = TRUE,
	var/editor_ckey = null,
	var/edited_time = null,
	var/list/related_groups = list(),
	var/memory_type = null
)
	var/datum/memory/M = new()
	M.id = "[world.time]-[rand(1000, 9999)]"
	M.title = title
	M.details = details
	M.source_ckey = source_ckey
	M.tier = tier
	var/list/final_tags = list()
	for (var/tag in tags)
		if (istext(tag))
			final_tags += lowertext(trim(tag))
	M.tags = final_tags
	M.status = status
	M.is_public = is_public
	M.editor_ckey = editor_ckey
	M.edited_time = edited_time
	M.related_groups = related_groups.Copy()
	M.memory_type = memory_type
	M.created_time = world.time
	return M


/datum/memory/proc/GetFormattedUI()
	. = list(
		"title" = title,
		"details" = details,
		"tags" = tags.Copy(),
		"time" = created_time,
		"status" = status
	)


// ================================
// Tag Handlers
// ================================

/datum/memory/proc/AddTag(var/tag)
	if (!istext(tag)) return
	tag = lowertext(trim(tag))
	if (!(tag in tags))
		tags += tag

/datum/memory/proc/RemoveTag(var/tag)
	if (!istext(tag)) return
	tag = lowertext(trim(tag))
	tags -= tag

/datum/memory/proc/HasTag(var/tag)
	if (!istext(tag)) return FALSE
	tag = lowertext(trim(tag))
	return tag in tags

/datum/memory/proc/ClearTags()
	tags = list()
