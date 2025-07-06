// ================================
// about_me Player Tools - about_me_tools.dm
// ================================
// Tools for player-controlled creation and editing of:
// - Memories
// - Relationships
// - Chronicle stories
// - Groups (Coteries, Sects, Clans)
// ================================
// -----------------------
// Memory Tools
// -----------------------
/proc/CreateMemory(var/mob/living/carbon/human/owner, var/title, var/details, var/list/tags = list(), var/status = "active")
	if (!owner || !owner.GetComponent(/datum/component/about_me))
		return null

	var/datum/component/about_me/comp = owner.GetComponent(/datum/component/about_me)

	var/datum/memory/M = new()
	M.title = title
	M.details = details
	M.tags = tags.Copy()
	M.created_time = world.time
	M.status = status
	M.id = rand(10000, 99999)
	M.time = world.time

	comp.memories_all += M
	return M

/proc/EditMemory(var/datum/memory/M, var/new_title = null, var/new_details = null, var/list/new_tags = null, var/new_status = null)
	if (!M) return
	if (new_title) M.title = new_title
	if (new_details) M.details = new_details
	if (islist(new_tags)) M.tags = new_tags.Copy()
	if (new_status) M.status = new_status

/proc/DeleteMemory(var/mob/living/carbon/human/owner, var/datum/memory/M)
	if (!owner || !M) return

	var/datum/component/about_me/comp = owner.GetComponent(/datum/component/about_me)
	if (!comp) return

	// Remove from all memory pools
	comp.memories_all -= M
	// Remove from chronicle list if it was tagged to be tracked there
	comp.chronicle_events -= M

/proc/TagMemory(var/datum/memory/M, var/tag)
	if (!M || !tag) return
	if (!islist(M.tags)) M.tags = list()
	if (!(tag in M.tags))
		M.tags += tag

/proc/AttachMemoryToRelationship(var/datum/relationships/R, var/datum/memory/M)
	if (!R || !M) return
	if (!islist(R.rel_memories)) R.rel_memories = list()
	if (!(M in R.rel_memories))
		R.rel_memories += M

/proc/AttachMemoryToGroup(var/datum/groups/G, var/datum/memory/M)
	if (!G || !M) return
	if (!islist(G.memories))
		G.memories = list()
	if (!(M in G.memories))
		G.memories += M

// -----------------------
// Relationship Tools
// -----------------------
/proc/CreateRelationship(
	var/source_ckey,
	var/target_ckey,
	var/relationship_type = REL_TYPE_ACQUAINTANCE,
	var/strength = 0,
	var/name = null,
	var/desc = null,
	var/mutual = FALSE,
	var/list/tags = list(),
	var/list/memories = list(),
	var/flags = 0
)
	if (!source_ckey || !target_ckey)
		return null

	var/datum/relationships/R = new()
	R.source_ckey = source_ckey
	R.target_ckey = target_ckey
	R.relationship_type = relationship_type
	R.strength = clamp(strength, -100, 100)
	R.name = name || "[relationship_type] with [target_ckey]"
	R.desc = desc || "A [relationship_type] between [source_ckey] and [target_ckey]."
	R.mutual = mutual
	R.tags = tags.Copy()
	R.rel_memories = list()
	R.flags = flags

	return R


/proc/EditRelationship(var/datum/relationships/R, var/name = null, var/desc = null, var/gtype = null)
	if (!R) return
	if (name) R.name = name
	if (desc) R.desc = desc
	if (gtype) R.relationship_type = gtype


/proc/DeleteRelationship(var/list/relationship_list, var/datum/relationships/R)
	if (!R || !islist(relationship_list)) return
	relationship_list -= R


/proc/ChangeRelationshipStrength(var/datum/relationships/R, var/new_strength)
	if (!R) return
	R.strength = clamp(new_strength, -100, 100)


/proc/ToggleRelationshipVisibility(var/datum/relationships/R)
	if (!R) return
	R.visible = !R.visible


/proc/AddRelationshipTag(var/datum/relationships/R, var/tag)
	if (!R || !tag) return
	if (!islist(R.tags)) R.tags = list()
	if (!(tag in R.tags))
		R.tags += tag

// -----------------------
// Chronicle Tools
// -----------------------

/// Creates a new story entry and appends it to a given list (usually chronicle_events)
/proc/CreateChronicleStory(var/list/chronicle_list, var/title, var/desc, var/time = null)
	if (!islist(chronicle_list)) return null
	if (!title) return null
	var/datum/chronicle_entry/E = new()
	E.title = title
	E.details = desc || "No details provided."
	E.created_time = time || time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	E.id = rand(10000, 99999)
	E.time = world.time
	chronicle_list += E
	return E

/// Edits the fields of an existing chronicle entry
/proc/EditChronicleEntry(var/datum/chronicle_entry/E, var/title = null, var/details = null, var/time = null)
	if (!E) return
	if (title) E.title = title
	if (details) E.details = details
	if (time) E.created_time = time

/// Deletes a chronicle entry from a list (chronicle_events, etc)
/proc/DeleteChronicleEntry(var/list/chronicle_list, var/datum/chronicle_entry/E)
	if (!islist(chronicle_list) || !E) return
	chronicle_list -= E

/// Attaches a memory to a chronicle entry (used for links, references, etc)
/proc/AttachMemoryToChronicle(var/datum/chronicle_entry/E, var/datum/memory/M)
	if (!E || !M) return
	if (!islist(E.attached_memories))
		E.attached_memories = list()
	if (!(M in E.attached_memories))
		E.attached_memories += M


// -----------------------
// Group Tools
// -----------------------

/// Creates a new group and adds it to the global list
/proc/CreateGroup(var/name, var/gtype = GROUP_TYPE_COTERIE, var/desc = "", var/icon = "", var/leader_ckey = "", var/list/tags = list())
	if (!name) return null

	var/datum/groups/G = new()
	G.name = name
	G.group_type = gtype
	G.desc = desc
	G.icon = icon
	G.leader_ckey = leader_ckey
	G.tags = tags.Copy()
	G.members = list()
	G.memories = list()

	if (leader_ckey)
		G.members += leader_ckey

	global_groups += G
	SaveGlobalGroups()

	return G

/// Edits metadata for an existing group
/proc/EditGroup(var/datum/groups/G, var/name = null, var/desc = null, var/icon = null, var/gtype = null)
	if (!G) return
	if (name) G.name = name
	if (desc) G.desc = desc
	if (icon) G.icon = icon
	if (gtype) G.group_type = gtype

/// Deletes a group from the global list
/proc/DeleteGroup(var/datum/groups/G)
	if (!G || !(G in global_groups)) return
	global_groups -= G
	SaveGlobalGroups()

/// Adds a member to the group
/proc/AddMemberToGroup(var/datum/groups/G, var/ckey)
	if (!G || !ckey) return
	if (!(ckey in G.members))
		G.members += ckey

/// Removes a member from the group
/proc/RemoveMemberFromGroup(var/datum/groups/G, var/ckey)
	if (!G || !ckey) return
	G.members -= ckey

/// Promotes a member to leader
/proc/MakeGroupLeader(var/datum/groups/G, var/ckey)
	if (!G || !ckey) return
	if (!(ckey in G.members))
		G.members += ckey
	G.leader_ckey = ckey

/// Tags a group with new label(s)
/proc/AddGroupTag(var/datum/groups/G, var/tag)
	if (!G || !tag) return
	if (!islist(G.tags)) G.tags = list()
	if (!(tag in G.tags)) G.tags += tag

/// Removes a tag from the group
/proc/RemoveGroupTag(var/datum/groups/G, var/tag)
	if (!G || !tag) return
	if (tag in G.tags)
		G.tags -= tag

// -----------------------
// ADDITIONALFUNCTIONS
// -----------------------

/datum/component/about_me/proc/tag_memory(mob/user)
	var/id = tgui_input_text(user, "Tag Memory", "Enter memory ID")
	if (!id) return
	var/datum/memory/M = locate(text2num(id)) in src.memories_all
	if (!M) return
	var/tag = tgui_input_text(user, "Tag Memory", "Enter tag")
	if (!tag) return
	TagMemory(M, tag)
	save_to_file()

/datum/component/about_me/proc/add_relationship_tag(mob/user)
	var/id = tgui_input_text(user, "Tag Relationship", "Enter relationship ID")
	if (!id) return
	for (var/datum/relationships/R in src.group_relationships)
		if (R.id == text2num(id))
			var/tag = tgui_input_text(user, "Tag", "Enter tag")
			if (tag) AddRelationshipTag(R, tag)
			save_to_file()
			break

/datum/component/about_me/proc/attach_memory_to_relationship(mob/user)
	var/mem_id = tgui_input_text(user, "Attach Memory", "Memory ID")
	var/rel_id = tgui_input_text(user, "To Relationship", "Relationship ID")
	if (!mem_id || !rel_id) return
	var/datum/memory/M = locate(text2num(mem_id)) in src.memories_all
	for (var/datum/relationships/R in src.group_relationships)
		if (R.id == text2num(rel_id))
			AttachMemoryToRelationship(R, M)
			save_to_file()
			break

/datum/component/about_me/proc/attach_memory_to_chronicle(mob/user)
	var/mem_id = tgui_input_text(user, "Attach Memory", "Memory ID")
	var/chron_id = tgui_input_text(user, "To Chronicle", "Chronicle ID")
	if (!mem_id || !chron_id) return
	var/datum/memory/M = locate(text2num(mem_id)) in src.memories_all
	for (var/datum/chronicle_entry/E in src.chronicle_events)
		if (E.id == text2num(chron_id))
			AttachMemoryToChronicle(E, M)
			save_to_file()
			break

/datum/component/about_me/proc/attach_memory_to_group(mob/user)
	var/mem_id = tgui_input_text(user, "Attach Memory", "Memory ID")
	var/group_id = tgui_input_text(user, "To Group", "Group ID")
	if (!mem_id || !group_id) return
	var/datum/memory/M = locate(text2num(mem_id)) in src.memories_all
	for (var/datum/groups/G in global_groups)
		if (G.id == text2num(group_id))
			AttachMemoryToGroup(G, M)
			save_to_file()
			break
