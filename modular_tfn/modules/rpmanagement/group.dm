// ================================
// Groups System - groups.dm
// ================================
// Tracks factions, sects, clans, tribes, and player-created groups.
// Supports dynamic creation, memory sharing, and member management.
// ================================

// Group DEFINES are here for now
// ================================
// Group Types
// ================================
#define GROUP_TYPE_CITY          "city"
#define GROUP_TYPE_FACTION       "faction"
#define GROUP_TYPE_SECT          "sect"
#define GROUP_TYPE_CLAN          "clan"
#define GROUP_TYPE_TRIBE         "tribe"
#define GROUP_TYPE_ORGANIZATION  "organization"
#define GROUP_TYPE_PARTY         "party"

/// List of valid group types
#define GROUP_TYPES list(\
	GROUP_TYPE_CITY, \
	GROUP_TYPE_FACTION, \
	GROUP_TYPE_SECT, \
	GROUP_TYPE_CLAN, \
	GROUP_TYPE_TRIBE, \
	GROUP_TYPE_ORGANIZATION, \
	GROUP_TYPE_PARTY \
)

// --- Group Key Defines ---
// City
#define GROUP_KEY_CITY "city"
// Factions
#define GROUP_KEY_FACTION_UNKNOWING "faction_unknowing"
#define GROUP_KEY_FACTION_KINDRED   "faction_kindred"
#define GROUP_KEY_FACTION_FERA      "faction_fera"
#define GROUP_KEY_FACTION_HUNTERS   "faction_hunters"
// Sects
#define GROUP_KEY_SECT_CAMARILLA    "sect_camarilla"
#define GROUP_KEY_SECT_ANARCHS      "sect_anarchs"
#define GROUP_KEY_SECT_SABBAT       "sect_sabbat"
// Clans
#define GROUP_KEY_CLAN_VENTRUE      "clan_ventrue"
#define GROUP_KEY_CLAN_BRUJAH       "clan_brujah"
#define GROUP_KEY_CLAN_TOREADOR     "clan_toreador"
// Tribes
#define GROUP_KEY_TRIBE_SILVERFANGS "tribe_silverfangs"
// Organizations
#define GROUP_KEY_ORG_GOVERNMENT        "org_government"
#define GROUP_KEY_ORG_MILITARY          "org_military"
#define GROUP_KEY_ORG_POLICEDEPARTMENT  "org_policedepartment"
#define GROUP_KEY_ORG_HOSPITAL          "org_hospital"
// Parties
#define GROUP_KEY_PARTY_COTERIE     "party_coterie"
#define GROUP_KEY_PARTY_SQUAD       "party_squad"


// ================================
// Group Dynamic Key Construction Macros
// ================================
/// These help with dynamic lookups, e.g. for player- or event-generated groups.
#define GROUP_KEY_FACTION(_id)      "faction_[lowertext(_id)]"
#define GROUP_KEY_SECT(_id)         "sect_[lowertext(_id)]"
#define GROUP_KEY_CLAN(_id)         "clan_[lowertext(_id)]"
#define GROUP_KEY_TRIBE(_id)        "tribe_[lowertext(_id)]"
#define GROUP_KEY_ORG(_id)          "org_[lowertext(_id)]"
#define GROUP_KEY_PARTY(_id)        "party_[lowertext(_id)]"

// ================================
// Group Tags
// ================================
#define GROUP_TAG_POLITICAL    "political"
#define GROUP_TAG_SOCIAL       "social"
#define GROUP_TAG_HISTORICAL   "historical"
#define GROUP_TAG_SECRET       "secret"
#define GROUP_TAG_FACTION      "faction"
#define GROUP_TAG_CLAN         "clan"
#define GROUP_TAG_SECT         "sect"
#define GROUP_TAG_COTERIE      "coterie"
#define GROUP_TAG_TRIBE        "tribe"
#define GROUP_TAG_ORG          "organization"
#define GROUP_TAG_PARTY        "party"

#define GROUP_TAGS list(\
	GROUP_TAG_POLITICAL, \
	GROUP_TAG_SOCIAL, \
	GROUP_TAG_HISTORICAL, \
	GROUP_TAG_SECRET, \
	GROUP_TAG_FACTION, \
	GROUP_TAG_CLAN, \
	GROUP_TAG_SECT, \
	GROUP_TAG_COTERIE, \
	GROUP_TAG_TRIBE, \
	GROUP_TAG_ORG, \
	GROUP_TAG_PARTY \
)

/datum/component/about_me/proc/export_group_objects()
	// 1. Prepare map for each canonical group type.
	var/list/group_map = list()
	// Optionally, define group types you want to expose in UI
	var/list/canonical_types = list("city", "faction", "sect", "clan", "tribe", "organization", "party", "player_created")
	for (var/type in canonical_types)
		group_map[type] = list()

	// 2. Add each actual group datum from src.groups, sorted into type buckets.
	if (islist(src.groups))
		for (var/datum/groups/G in src.groups)
			if (!istype(G, /datum/groups)) continue
			var/list/dict = G.GetFormattedUI()
			var/type = dict["type"] || "player_created"
			if (!(type in group_map))
				type = "player_created"
			group_map[type] += list(dict)

	// 3. Remove empty buckets for clean UI
	for (var/type in group_map.Copy())
		if (!length(group_map[type]))
			group_map -= type

	return group_map



//Base Group Datum
/datum/groups
    var/id                             // Unique string key for the group (matches the key in GLOB.groups)
    var/name = "Unnamed Group"
    var/desc = "No description provided."
    var/icon = null                   // Optional UI icon (e.g. .png file path)
    var/group_type = GROUP_TYPE_ORGANIZATION   // Use macro, default as needed
    var/leader_ckey = null            // Group leader (player or NPC ckey)
    var/list/tags = list()
    var/list/member_roles = list()    // key = ckey, value = "role"
    var/list/members = list()         // List of ckeys (or ref to member objects)
    var/list/memories = list()        // List of /datum/memory
    var/list/chronicles = list()      // List of /datum/chronicle (major group events)
    var/list/relationships = list()   // List of /datum/relationship (to other groups or major NPCs)
    var/list/subgroups = list()       // List of group IDs or /datum/groups (nested groups, e.g. clan holds coteries)
    var/created_timestamp = 0
    var/xp_cost_to_create = 0

    // Utility: Check if this group can store subgroups (overridden by subtypes if needed)
/datum/groups/proc/has_subgroups()
        // By default, only cities, factions, clans, organizations, etc. can have subgroups.
        // Override as needed in child types.
        return group_type in list(GROUP_TYPE_CITY, GROUP_TYPE_FACTION, GROUP_TYPE_CLAN, GROUP_TYPE_ORGANIZATION, GROUP_TYPE_SECT, GROUP_TYPE_TRIBE)


//For displaying player relationship types in UI
/datum/groups/proc/get_relationship_type(owner)
    // Use the macro for display if desired, or map as needed
    switch(src.group_type)
        if (GROUP_TYPE_CLAN)         return "Clan"
        if (GROUP_TYPE_SECT)         return "Sect"
        if (GROUP_TYPE_CITY)         return "City"
        if (GROUP_TYPE_FACTION)      return "Faction"
        if (GROUP_TYPE_TRIBE)        return "Tribe"
        if (GROUP_TYPE_ORGANIZATION) return "Organization"
        if (GROUP_TYPE_PARTY)        return "Party"
        // add other cases as you add more types
    return initial(src.group_type) // fallback to the raw group_type or "Group"

// ---------------------------------------------
// Core Functionality
// ---------------------------------------------

/datum/groups/New()
	..()
	id = "[world.time]_[rand(1000,9999)]"
	// Ensure lists are initialized
	if (!islist(members)) members = list()
	if (!islist(memories)) memories = list()
	if (!islist(chronicles)) chronicles = list()
	if (!islist(relationships)) relationships = list()
	if (!islist(subgroups)) subgroups = list()
	if (!islist(tags)) tags = list()
	if (!islist(member_roles)) member_roles = list()

// ------------ Membership ------------

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

/// Returns a copy so the caller can't modify the real list
/datum/groups/proc/GetMembers()
	return members.Copy()

// ------------ Memories ------------

/datum/groups/proc/AddMemory(var/memory)
	if (!memory)
		return
	memories += memory
	save_to_file()

/datum/groups/proc/GetMemories()
	return memories.Copy()

// ------------ Chronicles ------------

/datum/groups/proc/AddChronicle(var/chronicle)
	if (!chronicle)
		return
	chronicles += chronicle
	save_to_file()

/datum/groups/proc/RemoveChronicle(var/chronicle)
	if (chronicle in chronicles)
		chronicles -= chronicle
		save_to_file()

/datum/groups/proc/GetChronicles()
	return chronicles.Copy()

// ------------ Relationships ------------

/datum/groups/proc/AddRelationship(var/rel)
	if (!rel)
		return
	relationships += rel
	save_to_file()

/datum/groups/proc/RemoveRelationship(var/rel)
	if (rel in relationships)
		relationships -= rel
		save_to_file()

/datum/groups/proc/GetRelationships()
	return relationships.Copy()

// ------------ Subgroups (hierarchy) ------------

/datum/groups/proc/AddSubgroup(var/group_id)
	if (!group_id || subgroups.Find(group_id))
		return
	subgroups += group_id
	save_to_file()

/datum/groups/proc/RemoveSubgroup(var/group_id)
	if (group_id in subgroups)
		subgroups -= group_id
		save_to_file()

/datum/groups/proc/GetSubgroups()
	return subgroups.Copy()

// ------------ Leadership ------------

/datum/groups/proc/SetLeader(var/ckey)
	leader_ckey = ckey
	save_to_file()

/datum/groups/proc/GetLeader()
	return leader_ckey

// ------------ Display ------------

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
	ui["tags"] = tags.Copy()
	ui["leader"] = leader_ckey
	ui["member_roles"] = member_roles.Copy()
	ui["members"] = GetMembers()

	// Memories
	ui["memories"] = list()
	for (var/datum/memory/M in memories)
		ui["memories"] += M.GetFormattedUI()

	// Chronicles
	ui["chronicles"] = list()
	for (var/datum/chronicle/C in chronicles)
		ui["chronicles"] += C.GetFormattedUI()

	// Relationships
	ui["relationships"] = list()
	for (var/datum/relationships/R in relationships)
		ui["relationships"] += R.GetFormattedUI()

	// Subgroups (just include ids and names for summary)
	ui["subgroups"] = list()
	for (var/group_id in subgroups)
		var/datum/groups/G = GLOB.groups[group_id]
		if (G)
			ui["subgroups"] += list(list("id"=G.id, "name"=G.name, "type"=G.group_type))
	return ui


// --- Membership editing ---

/datum/groups/proc/CanEditGroup(var/ckey)
	var/role = GetMemberRole(ckey)
	return (ckey == leader_ckey) || (role in list("officer", "admin"))

/datum/groups/proc/GetMemberRole(var/ckey)
	if (ckey == src.leader_ckey)
		return "leader"
	if (member_roles && (ckey in member_roles))
		return member_roles[ckey]
	return "member"

// --- Group Relationships ---

/datum/groups/proc/CreateGroupRelationship(var/ckey)
	if (!ckey) return null
	var/datum/relationships/R = new()
	R.name = "[name] Affiliation"
	R.relationship_type = REL_TYPE_ALLY
	R.strength = IsMember(ckey) ? 50 : 10
	R.source_ckey = ckey
	R.target_ckey = "group_[id]"
	R.desc = "This is your connection to the group '[name]', a [group_type]."
	R.visible = TRUE
	R.mutual = FALSE
	R.AddFlag(REL_FLAG_POLITICAL)
	return R

// --- Tag editing ---

/datum/groups/proc/AddTag(var/tag)
	tag = lowertext(trim(tag))
	if (!(tag in tags))
		tags += tag

/datum/groups/proc/RemoveTag(var/tag)
	tag = lowertext(trim(tag))
	tags -= tag


//ONLY GROUPS can share memories/chronicles/relationships to members.

// --- Memory sharing ---

/datum/groups/proc/ShareMemoryWithMembers()
	for (var/ckey in members)
		var/mob/Mob = GLOB.player_list[ckey]
		if (Mob)
			var/datum/component/about_me/A = Mob.GetComponent(/datum/component/about_me)
			if (A)
				for (var/datum/memory/M in memories)
					if (!(M in A.memories_all))
						A.memories_all += M

// --- Chronicle sharing ---

/datum/groups/proc/ShareChronicleWithMembers()
	for (var/ckey in members)
		var/mob/Mob = GLOB.player_list[ckey]
		if (Mob)
			var/datum/component/about_me/A = Mob.GetComponent(/datum/component/about_me)
			if (A)
				for (var/datum/chronicle/C in chronicles)
					if (!(C in A.chronicles_all))
						A.chronicles_all += C

// --- Relationship sharing ---

/datum/groups/proc/ShareRelationshipWithMembers()
	for (var/ckey in members)
		var/mob/Mob = GLOB.player_list[ckey]
		if (Mob)
			var/datum/component/about_me/A = Mob.GetComponent(/datum/component/about_me)
			if (A)
				for (var/datum/relationship/R in relationships)
					if (!(R in A.relationships_all))
						A.relationships_all += R
