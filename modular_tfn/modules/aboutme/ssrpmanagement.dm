// ================================
// RP Management Subsystem - ssrpmanagement.dm (CLEAN)
// ================================
// Centralizes all group and persistence logic under the RP Management subsystem.
// ================================
GLOBAL_LIST_EMPTY(groups)
GLOBAL_LIST_EMPTY(canonical_groups) // <-- Only one declaration!
//For Initializing all cannon groups in the subsystem.
/// Canonical groups: Key => Type path (as string or path)
var/global/list/canonical_groups = list(
    // --- City
    GROUP_KEY_CITY = /datum/groups/city/SanFrancisco,

    // --- Factions
    GROUP_KEY_FACTION_UNKNOWING = /datum/groups/faction/citizen,
    GROUP_KEY_FACTION_KINDRED   = /datum/groups/faction/kindred,
    GROUP_KEY_FACTION_FERA      = /datum/groups/faction/fera,
    GROUP_KEY_FACTION_HUNTERS   = /datum/groups/faction/hunter,

    // --- Sects
    GROUP_KEY_SECT_CAMARILLA    = /datum/groups/sect/camarilla,
    GROUP_KEY_SECT_ANARCHS      = /datum/groups/sect/anarchs,
    GROUP_KEY_SECT_SABBAT       = /datum/groups/sect/sabbat,
    GROUP_KEY_SECT_INDEPENDENT  = /datum/groups/sect/independent,
    GROUP_KEY_SECT_PAINTEDCITY  = /datum/groups/sect/paintedcity,
    GROUP_KEY_SECT_AMBERGLADE   = /datum/groups/sect/amberglade,
    GROUP_KEY_SECT_POISONEDSHORE = /datum/groups/sect/poisonedshore,

    // --- Clans (add all you want here)
    GROUP_KEY_CLAN_VENTRUE                = /datum/groups/clan/ventrue,
    GROUP_KEY_CLAN_BRUJAH                 = /datum/groups/clan/brujah,
    GROUP_KEY_CLAN_TOREADOR               = /datum/groups/clan/toreador,
    GROUP_KEY_CLAN_MALKAVIAN              = /datum/groups/clan/malkavian,
    GROUP_KEY_CLAN_NOSFERATU              = /datum/groups/clan/nosferatu,
    GROUP_KEY_CLAN_GANGREL                = /datum/groups/clan/gangrel,
    GROUP_KEY_CLAN_TREMERE                = /datum/groups/clan/tremere,
    GROUP_KEY_CLAN_LASOMBRA               = /datum/groups/clan/lasombra,
    GROUP_KEY_CLAN_TZIMISCE               = /datum/groups/clan/tzimisce,
    GROUP_KEY_CLAN_MINISTRY               = /datum/groups/clan/ministry,
    GROUP_KEY_CLAN_GIOVANNI               = /datum/groups/clan/giovanni,
    GROUP_KEY_CLAN_SALUBRI                = /datum/groups/clan/salubri,
    GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY = /datum/groups/clan/daughters_of_cacophony,
    GROUP_KEY_CLAN_BAALI                  = /datum/groups/clan/baali,

    // --- Tribes
    GROUP_KEY_TRIBE_RONIN               = /datum/groups/tribe/ronin,
    GROUP_KEY_TRIBE_BLACKFURIES         = /datum/groups/tribe/blackfuries,
    GROUP_KEY_TRIBE_BLACKSPIRALDANCERS  = /datum/groups/tribe/blackspiraldancers,
    GROUP_KEY_TRIBE_BONEGNAWERS         = /datum/groups/tribe/bonegnawers,
    GROUP_KEY_TRIBE_CHILDRENOFGAIA      = /datum/groups/tribe/childrenofgaia,
    GROUP_KEY_TRIBE_CORAX               = /datum/groups/tribe/corax,
    GROUP_KEY_TRIBE_GALESTALKERS        = /datum/groups/tribe/galestalkers,
    GROUP_KEY_TRIBE_GETOFFENRIS         = /datum/groups/tribe/getoffenris,
    GROUP_KEY_TRIBE_GHOSTCOUNCIL        = /datum/groups/tribe/ghostcouncil,
    GROUP_KEY_TRIBE_GLASSWALKERS        = /datum/groups/tribe/glasswalkers,
    GROUP_KEY_TRIBE_HARTWARDENS         = /datum/groups/tribe/hartwardens,
    GROUP_KEY_TRIBE_REDTALONS           = /datum/groups/tribe/redtalons,
    GROUP_KEY_TRIBE_SHADOWLORDS         = /datum/groups/tribe/shadowlords,
    GROUP_KEY_TRIBE_SILENTSTRIDERS      = /datum/groups/tribe/silentstriders,
    GROUP_KEY_TRIBE_SILVERFANGS         = /datum/groups/tribe/silverfangs,
    GROUP_KEY_TRIBE_STARGAZERS          = /datum/groups/tribe/stargazers,

    // --- Organizations
    GROUP_KEY_ORG_GOVERNMENT        = /datum/groups/organization/government,
    GROUP_KEY_ORG_MILITARY          = /datum/groups/organization/military,
    GROUP_KEY_ORG_POLICEDEPARTMENT  = /datum/groups/organization/policedepartment,
    GROUP_KEY_ORG_HOSPITAL          = /datum/groups/organization/hospital,
    GROUP_KEY_ORG_PRIMOGENCOUNCIL   = /datum/groups/organization/primogencouncil,

    // --- Parties
    GROUP_KEY_PARTY_COTERIE = /datum/groups/party/coterie,
    GROUP_KEY_PARTY_SQUAD   = /datum/groups/party/squad
)


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

/// Called on server init, this just starts them up, if there are no players related to them, they shouldn't get messed with again.
/datum/controller/subsystem/rpmanagement/proc/InitAllGroups()
    load_all_groups() // Loads saved storyteller data

    // Loop through all canonical group keys, and instantiate if missing
    for (var/group_key in canonical_groups)
        if (!(group_key in GLOB.groups))
            var/typepath = canonical_groups[group_key]
            GLOB.groups[group_key] = new typepath()

    // Optional: List each group for admin verification
    message_admins("[length(GLOB.groups)] core groups initialized!")
    for (var/key in GLOB.groups)
        var/datum/groups/G = GLOB.groups[key]
        world.log << "Group: [key] ([G.group_type])"


/***********************************************
 * Group Instance Save Utility
 ***********************************************/

/datum/groups/proc/save_to_file()
    save_all_groups() // Just calls the global saver
