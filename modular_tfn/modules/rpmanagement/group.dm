// ================================
// Groups System - groups.dm
// ================================
// Tracks factions, sects, clans, tribes, and player-created groups.
// Supports dynamic creation, memory sharing, and member management.
// ================================

// Group DEFINES are here

/datum/groups
	var/id
	var/name = "Unnamed Group"
	var/desc = "No description provided."
	var/icon = null                   // Optional UI icon (e.g. .png file path)
	var/group_type = "generic"       // Used to sort into tabs
	var/leader_ckey = null           // Group leader (player or NPC)
	var/list/tags = list()
	var/list/member_roles = list() // key = ckey, value = "role"
	var/list/members = list()        // List of ckeys
	var/list/memories = list()       // List of /datum/memory
	var/created_timestamp = 0
	var/xp_cost_to_create = 0

// ---------------------------------------------
// Core Functionality
// ---------------------------------------------

/datum/groups/New()
	..()
	id = "[world.time]_[rand(1000,9999)]"

/datum/groups/proc/AddMember(var/ckey)
	if (!ckey || members.Find(ckey))
		return
	members += ckey
	save_to_file()

/datum/groups/proc/RemoveMember(var/ckey)
	if (ckey in members)
		members -= ckey
		save_to_file()

/datum/groups/proc/IsMember(var/ckey)
	return (ckey in members)

/datum/groups/proc/GetMembers()
	return members.Copy()

/datum/groups/proc/AddMemory(var/memory)
	if (!memory)
		return
	memories += memory
	save_to_file()

/datum/groups/proc/GetMemories()
	return memories.Copy()

/datum/groups/proc/SetLeader(var/ckey)
	leader_ckey = ckey
	save_to_file()

/datum/groups/proc/GetLeader()
	return leader_ckey

// Display
/datum/groups/proc/GetName()
	return name

/datum/groups/proc/GetDescription()
	return desc

// TGUI data for rendering
/datum/groups/proc/GetFormattedUI()
	var/list/ui = list()
	ui["id"] = id
	ui["name"] = name
	ui["desc"] = desc
	ui["type"] = group_type
	ui["icon"] = icon
	ui["leader"] = leader_ckey
	ui["member_roles"] = member_roles.Copy()
	ui["members"] = GetMembers()
	ui["memories"] = list()
	for (var/datum/memory/M in memories)
		ui["memories"] += M.GetFormattedUI()
	return ui

// ---------------------------------------------
// Group Subtypes
// ---------------------------------------------

/datum/groups/faction
	group_type = "faction"
	xp_cost_to_create = 0

/datum/groups/sect
	group_type = "sect"
	xp_cost_to_create = 0

/datum/groups/clan
	group_type = "clan"
	xp_cost_to_create = 0

/datum/groups/tribe
	group_type = "tribe"
	xp_cost_to_create = 0

/datum/groups/organization
	group_type = "organization"
	xp_cost_to_create = 0

/datum/groups/player_created
	group_type = "coterie"
	xp_cost_to_create = 500

//member editting
/datum/groups/proc/CanEditGroup(var/ckey)
	var/role = GetMemberRole(ckey)
	return (ckey == leader_ckey) || (role in list("officer", "admin"))

/datum/groups/proc/GetMemberRole(var/ckey)
	// If you have a member roles assoc list, use it; otherwise, leader is "leader"
	if (ckey == src.leader_ckey)
		return "leader"
	// If you later add officer/admin, check here:
	// if (src.officers && ckey in src.officers) return "officer"
	// if (src.admins && ckey in src.admins) return "admin"
	return "member"


//Group Relationships
/datum/groups/proc/CreateGroupRelationship(var/ckey)
	if (!ckey) return null

	var/datum/relationships/R = new()
	R.name = "[name] Affiliation"
	R.relationship_type = REL_TYPE_ALLY
	R.strength = IsMember(ckey) ? 50 : 10
	R.source_ckey = ckey
	R.target_ckey = "group_[name]"
	R.desc = "This is your connection to the group '[name]', a [group_type]."
	R.visible = TRUE
	R.mutual = FALSE
	R.AddFlag(REL_FLAG_POLITICAL)

	return R

// ---------------------------------------------
// Saving and Loading
// ---------------------------------------------

/datum/groups/proc/get_save_path()
	return "data/groups_storyteller_saves.json"

/datum/groups/proc/save_to_file()
	var/path = get_save_path()
	var/savefile/F = new(path)
	if (!F) return

	F["version"] << 1
	F["groups"] << global_groups


//Tags
/datum/groups/proc/AddTag(var/tag)
	tag = lowertext(trim(tag))
	if (!(tag in tags)) tags += tag

/datum/groups/proc/RemoveTag(var/tag)
	tag = lowertext(trim(tag))
	tags -= tag

//share memories
/datum/groups/proc/ShareMemoryWithMembers()
	for (var/ckey in members)
		var/mob/Mob = GLOB.player_list[ckey]
		if (Mob)
			var/datum/component/about_me/A = Mob.GetComponent(/datum/component/about_me)
			if (A)
				for (var/datum/memory/M in memories)
					if (!(M in A.memories_all))
						A.memories_all += M
