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
// Group Keys
// City
#define GROUP_KEY_CITY "city"
// Factions
#define GROUP_KEY_FACTION_UNKNOWING      "faction_unknowing"
#define GROUP_KEY_FACTION_KINDRED        "faction_kindred"
#define GROUP_KEY_FACTION_FERA           "faction_fera"
#define GROUP_KEY_FACTION_HUNTERS        "faction_hunters"
// Sects
#define GROUP_KEY_SECT_INDEPENDENT       "sect_independent"
#define GROUP_KEY_SECT_CAMARILLA         "sect_camarilla"
#define GROUP_KEY_SECT_ANARCHS           "sect_anarchs"
#define GROUP_KEY_SECT_SABBAT            "sect_sabbat"
#define GROUP_KEY_SECT_PAINTEDCITY       "sect_paintedcity"
#define GROUP_KEY_SECT_AMBERGLADE        "sect_amberglade"
#define GROUP_KEY_SECT_POISONEDSHORE     "sect_poisonedshore"
// Clans
#define GROUP_KEY_CLAN_CAITIF                 "clan_caitif"
#define GROUP_KEY_CLAN_VENTRUE                "clan_ventrue"
#define GROUP_KEY_CLAN_BRUJAH                 "clan_brujah"
#define GROUP_KEY_CLAN_TOREADOR               "clan_toreador"
#define GROUP_KEY_CLAN_MALKAVIAN              "clan_malkavian"
#define GROUP_KEY_CLAN_NOSFERATU              "clan_nosferatu"
#define GROUP_KEY_CLAN_GANGREL                "clan_gangrel"
#define GROUP_KEY_CLAN_TREMERE                "clan_tremere"
#define GROUP_KEY_CLAN_LASOMBRA               "clan_lasombra"
#define GROUP_KEY_CLAN_TZIMISCE               "clan_tzimisce"
#define GROUP_KEY_CLAN_MINISTRY               "clan_ministry"
#define GROUP_KEY_CLAN_GIOVANNI               "clan_giovanni"
#define GROUP_KEY_CLAN_SALUBRI                "clan_salubri"
#define GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY "clan_daughters_of_cacophony"
#define GROUP_KEY_CLAN_BAALI                  "clan_baali"
// Tribes
#define GROUP_KEY_TRIBE_RONIN               "tribe_ronin"
#define GROUP_KEY_TRIBE_BLACKFURIES         "tribe_blackfuries"
#define GROUP_KEY_TRIBE_BLACKSPIRALDANCERS  "tribe_blackspiraldancers"
#define GROUP_KEY_TRIBE_BONEGNAWERS         "tribe_bonegnawers"
#define GROUP_KEY_TRIBE_CHILDRENOFGAIA      "tribe_childrenofgaia"
#define GROUP_KEY_TRIBE_CORAX               "tribe_corax"
#define GROUP_KEY_TRIBE_GALESTALKERS        "tribe_galestalkers"
#define GROUP_KEY_TRIBE_GETOFFENRIS         "tribe_getoffenris"
#define GROUP_KEY_TRIBE_GHOSTCOUNCIL        "tribe_ghostcouncil"
#define GROUP_KEY_TRIBE_GLASSWALKERS        "tribe_glasswalkers"
#define GROUP_KEY_TRIBE_HARTWARDENS         "tribe_hartwardens"
#define GROUP_KEY_TRIBE_REDTALONS           "tribe_redtalons"
#define GROUP_KEY_TRIBE_SHADOWLORDS         "tribe_shadowlords"
#define GROUP_KEY_TRIBE_SILENTSTRIDERS      "tribe_silentstriders"
#define GROUP_KEY_TRIBE_SILVERFANGS         "tribe_silverfangs"
#define GROUP_KEY_TRIBE_STARGAZERS          "tribe_stargazers"
// Organizations
#define GROUP_KEY_ORG_GOVERNMENT        "org_government"
#define GROUP_KEY_ORG_MILITARY          "org_military"
#define GROUP_KEY_ORG_POLICEDEPARTMENT  "org_policedepartment"
#define GROUP_KEY_ORG_HOSPITAL          "org_hospital"
#define GROUP_KEY_ORG_PRIMOGENCOUNCIL   "org_primogencouncil"
// Parties
#define GROUP_KEY_PARTY_COTERIE         "party_coterie"
#define GROUP_KEY_PARTY_SQUAD           "party_squad"
// ================================
// Group Dynamic Key Construction Macros
// ================================
/// These help with dynamic lookups using keys, and the ssrpmanagement subsystem.
#define GROUP_KEY_FACTION(_id)      "faction_[lowertext(_id)]"
#define GROUP_KEY_SECT(_id)         "sect_[lowertext(_id)]"
#define GROUP_KEY_CLAN(_id)         "clan_[lowertext(_id)]"
#define GROUP_KEY_TRIBE(_id) "tribe_[lowertext(trim(replacetext(_id, " ", "")))]"
#define GROUP_KEY_ORG(_id)          "org_[lowertext(_id)]"
#define GROUP_KEY_PARTY(_id)        "party_[lowertext(_id)]"
// Group Tags, these get stacked on, Core, are all the main group types, the rest is to help define those groups, and what they can do, how they appear etc.
// --- Core/Political Structure ---
#define GROUP_TAG_CITY          "city"          // Any city or metropolitan group
#define GROUP_TAG_FACTION       "faction"       // Broad supernatural or mortal faction (Kindred, Fera, Hunter, etc)
#define GROUP_TAG_SECT          "sect"          // Sects like Camarilla, Sabbat, Anarchs, Independent, etc
#define GROUP_TAG_CLAN          "clan"          // Vampire clans, bloodlines, etc
#define GROUP_TAG_TRIBE         "tribe"         // Garou or Fera tribe
#define GROUP_TAG_ORG           "organization"  // Hospital, PD, gangs, corporations, etc
#define GROUP_TAG_PARTY         "party"         // Coteries, squads, units, etc
// --- Social/Role/Relationship ---
#define GROUP_TAG_COTERIE       "coterie"       // Small groups of player-selected associates
#define GROUP_TAG_SOCIAL        "social"        // Social clubs, events, salons, gatherings
#define GROUP_TAG_POLITICAL     "political"     // Councils, ruling bodies, governing roles
#define GROUP_TAG_HIERARCHY     "hierarchy"     // Explicitly hierarchical (e.g., Primogen, Inner Circle, Packs)
#define GROUP_TAG_WORK          "work"          // Job/Profession-based (Doctors, Police, Bartenders, etc)
#define GROUP_TAG_FAMILY        "family"        // Mortal or supernatural "family" (e.g. Giovanni family, mortal mafias)
#define GROUP_TAG_CREW          "crew"          // Heist crews, organized crime, street gangs
// --- Supernatural/Thematic ---
#define GROUP_TAG_VAMPIRE       "vampire"
#define GROUP_TAG_GAROU         "garou"
#define GROUP_TAG_FERA          "fera"
#define GROUP_TAG_WRAITH        "wraith"
#define GROUP_TAG_MAGE          "mage"
#define GROUP_TAG_HUNTER        "hunter"
#define GROUP_TAG_MORTAL        "mortal"
// --- Secret/Special Access ---
#define GROUP_TAG_SECRET        "secret"        // Hidden/secret societies, cults, conspiracies
#define GROUP_TAG_CULT          "cult"          // Any cult, religious or esoteric group
#define GROUP_TAG_UNDERGROUND   "underground"   // Criminal, black market, or secret undergrounds
// --- Regional/Setting-Specific ---
#define GROUP_TAG_SANFRANCISCO  "sanfrancisco"
#define GROUP_TAG_SETTING       "setting"
#define GROUP_TAG_REGIONAL      "regional"
// --- Law/Crime/Enforcement ---
#define GROUP_TAG_LAW           "law"           // Law enforcement
#define GROUP_TAG_CRIME         "crime"         // Criminal organizations
#define GROUP_TAG_GOVERNMENT    "government"
#define GROUP_TAG_MILITARY      "military"
// --- Story/Legacy ---
#define GROUP_TAG_HISTORICAL    "historical"    // Legacy/old organizations, historical societies
// --- Miscellaneous/Custom ---
#define GROUP_TAG_PLAYER        "player"        // Player-created
#define GROUP_TAG_EVENT         "event"         // Temporary/event-based
#define GROUP_TAG_TEMPORARY     "temporary"
#define GROUP_TAG_SPECIAL       "special"
#define GROUP_TAG_CUSTOM        "custom"
// --- Complete group tag list for lookup/assignment ---
#define GROUP_TAGS list(\
    GROUP_TAG_CITY, \
    GROUP_TAG_FACTION, \
    GROUP_TAG_SECT, \
    GROUP_TAG_CLAN, \
    GROUP_TAG_TRIBE, \
    GROUP_TAG_ORG, \
    GROUP_TAG_PARTY, \
    GROUP_TAG_COTERIE, \
    GROUP_TAG_SOCIAL, \
    GROUP_TAG_POLITICAL, \
    GROUP_TAG_HIERARCHY, \
    GROUP_TAG_WORK, \
    GROUP_TAG_FAMILY, \
    GROUP_TAG_CREW, \
    GROUP_TAG_VAMPIRE, \
    GROUP_TAG_GAROU, \
    GROUP_TAG_FERA, \
    GROUP_TAG_WRAITH, \
    GROUP_TAG_MAGE, \
    GROUP_TAG_HUNTER, \
    GROUP_TAG_MORTAL, \
    GROUP_TAG_SECRET, \
    GROUP_TAG_CULT, \
    GROUP_TAG_UNDERGROUND, \
    GROUP_TAG_SANFRANCISCO, \
    GROUP_TAG_SETTING, \
    GROUP_TAG_REGIONAL, \
    GROUP_TAG_LAW, \
    GROUP_TAG_CRIME, \
    GROUP_TAG_GOVERNMENT, \
    GROUP_TAG_MILITARY, \
    GROUP_TAG_HISTORICAL, \
    GROUP_TAG_PLAYER, \
    GROUP_TAG_EVENT, \
    GROUP_TAG_TEMPORARY, \
    GROUP_TAG_SPECIAL, \
    GROUP_TAG_CUSTOM \
)
/datum/component/about_me/proc/export_group_objects()
	// 1. Prepare map for each canonical group type.
	var/list/group_map = list()
	var/list/canonical_types = list("city", "faction", "sect", "clan", "tribe", "organization", "party", "player_created")
	for (var/type in canonical_types)
		group_map[type] = list()

	// 2. Add each actual group datum from src.groups, sorted into type buckets.
	if (islist(src.groups))
		for (var/datum/groups/G in src.groups)
			if (!istype(G, /datum/groups)) continue
			var/list/dict = G.GetFormattedUI()
			var/type = lowertext(dict["type"] || "player_created")
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
    var/leader_name = "None"
    var/list/tags = list()
    var/list/member_roles = list()    // key = ckey, value = "role"
    var/list/members = list()         // List of ckeys (or ref to member objects)
    var/list/memories = list()        // List of /datum/memory
    var/list/chronicles = list()      // List of /datum/chronicle (major group events)
    var/list/relationships = list()   // List of /datum/relationship (to other groups or major NPCs)
    var/list/subgroups = list()       // List of group IDs or /datum/groups (nested groups, e.g. clan holds coteries)
    var/created_timestamp = 0
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
	if (ckey)
		var/mob/Mob = GLOB.player_list[ckey]
		if (Mob)
			leader_name = Mob.real_name || Mob.name
		else
			leader_name = ckey
	else
		leader_name = "None"
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
	ui["leader"] = leader_name
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
