// ================================
// RP Management Subsystem - ssrpmanagement.dm (CLEAN)
// ================================
// Centralizes all group and persistence logic under the RP Management subsystem.
// ================================
GLOBAL_LIST_EMPTY(groups)

SUBSYSTEM_DEF(rpmanagement)
    name = "RP Management"
    init_order = INIT_ORDER_DEFAULT
    wait = 10

/***********************************************
 * Group Persistence Utilities (Under Subsystem)
 ***********************************************/

/// Returns the group save path (single file for all, easy for admin editing)
/proc/get_group_save_path()
    return "data/storyteller_saves.json"

/// Save all groups to file
/proc/save_all_groups()
    var/path = get_group_save_path()
    var/savefile/F = new(path)
    if (!F)
        world.log << "❌ Failed to open [path] for group save."
        return
    F["version"] << 1
    F["group_count"] << length(GLOB.groups)
    // Save each group by its key
    for (var/key in GLOB.groups)
        F["groups/[key]"] << GLOB.groups[key]
    world.log << "✅ All groups saved to [path]"

/// Load all groups from file
/proc/load_all_groups()
    var/path = get_group_save_path()
    if (!fexists(path))
        world.log << "⚠️ No group save found at [path], using defaults."
        return
    var/savefile/F = new(path)
    if (!F)
        world.log << "❌ Failed to open [path] for group load."
        return
    var/version, group_count
    F["version"] >> version
    F["group_count"] >> group_count
    // Rebuild GLOB.groups from file
    for (var/key in F.dir["groups"])
        var/datum/groups/G
        F["groups/[key]"] >> G
        if (G)
            GLOB.groups[key] = G
    world.log << "✅ Loaded [length(GLOB.groups)] groups from [path]"

// Main subsystem class
/datum/controller/subsystem/rpmanagement

/datum/controller/subsystem/rpmanagement/Initialize()
    load_all_groups()
    ..() // Call parent
    InitAllGroups()
	//Load group informations()
	//bleh, the rest of the init stuff
    return

/// Called on server init
/datum/controller/subsystem/rpmanagement/proc/InitAllGroups()
    load_all_groups() // Loads saved storyteller data

    // Initialize hardcoded groups if not already present (safe for persistence)
    // -------- City (universal) --------
    if (!(GROUP_KEY_CITY in GLOB.groups))
        GLOB.groups[GROUP_KEY_CITY] = new /datum/groups/city/SanFrancisco

    // -------- Factions --------
    if (!(GROUP_KEY_FACTION_UNKNOWING in GLOB.groups))
        GLOB.groups[GROUP_KEY_FACTION_UNKNOWING] = new /datum/groups/faction/unknowing
    if (!(GROUP_KEY_FACTION_KINDRED in GLOB.groups))
        GLOB.groups[GROUP_KEY_FACTION_KINDRED] = new /datum/groups/faction/kindred
    if (!(GROUP_KEY_FACTION_FERA in GLOB.groups))
        GLOB.groups[GROUP_KEY_FACTION_FERA] = new /datum/groups/faction/fera
    if (!(GROUP_KEY_FACTION_HUNTERS in GLOB.groups))
        GLOB.groups[GROUP_KEY_FACTION_HUNTERS] = new /datum/groups/faction/hunters

    // -------- Sects --------
    if (!(GROUP_KEY_SECT_CAMARILLA in GLOB.groups))
        GLOB.groups[GROUP_KEY_SECT_CAMARILLA] = new /datum/groups/sect/camarilla
    if (!(GROUP_KEY_SECT_ANARCHS in GLOB.groups))
        GLOB.groups[GROUP_KEY_SECT_ANARCHS] = new /datum/groups/sect/anarchs
    if (!(GROUP_KEY_SECT_SABBAT in GLOB.groups))
        GLOB.groups[GROUP_KEY_SECT_SABBAT] = new /datum/groups/sect/sabbat

    // -------- Clans --------
    if (!(GROUP_KEY_CLAN_VENTRUE in GLOB.groups))
        GLOB.groups[GROUP_KEY_CLAN_VENTRUE] = new /datum/groups/clan/ventrue
    if (!(GROUP_KEY_CLAN_BRUJAH in GLOB.groups))
        GLOB.groups[GROUP_KEY_CLAN_BRUJAH] = new /datum/groups/clan/brujah
    if (!(GROUP_KEY_CLAN_TOREADOR in GLOB.groups))
        GLOB.groups[GROUP_KEY_CLAN_TOREADOR] = new /datum/groups/clan/toreador

    // -------- Tribes --------
    if (!(GROUP_KEY_TRIBE_SILVERFANGS in GLOB.groups))
        GLOB.groups[GROUP_KEY_TRIBE_SILVERFANGS] = new /datum/groups/tribe/silverfangs

    // -------- Organizations --------
    if (!(GROUP_KEY_ORG_GOVERNMENT in GLOB.groups))
        GLOB.groups[GROUP_KEY_ORG_GOVERNMENT] = new /datum/groups/organization/government
    if (!(GROUP_KEY_ORG_MILITARY in GLOB.groups))
        GLOB.groups[GROUP_KEY_ORG_MILITARY] = new /datum/groups/organization/military
    if (!(GROUP_KEY_ORG_POLICEDEPARTMENT in GLOB.groups))
        GLOB.groups[GROUP_KEY_ORG_POLICEDEPARTMENT] = new /datum/groups/organization/policedepartment
    if (!(GROUP_KEY_ORG_HOSPITAL in GLOB.groups))
        GLOB.groups[GROUP_KEY_ORG_HOSPITAL] = new /datum/groups/organization/hospital

    // -------- Parties/Squads/Coteries --------
    if (!(GROUP_KEY_PARTY_COTERIE in GLOB.groups))
        GLOB.groups[GROUP_KEY_PARTY_COTERIE] = new /datum/groups/party/coterie
    if (!(GROUP_KEY_PARTY_SQUAD in GLOB.groups))
        GLOB.groups[GROUP_KEY_PARTY_SQUAD] = new /datum/groups/party/squad

    // Optional: List each group for admin verification
    world.log << "[length(GLOB.groups)] core groups initialized!"
    for (var/key in GLOB.groups)
        var/datum/groups/G = GLOB.groups[key]
        world.log << "Group: [key] ([G.type])"


/***********************************************
 * Group Instance Save Utility
 ***********************************************/

/datum/groups/proc/save_to_file()
    save_all_groups() // Just calls the global saver
