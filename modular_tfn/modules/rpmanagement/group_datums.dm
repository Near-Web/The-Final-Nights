// ---------------------------------------------
// Premade Groups!
// ---------------------------------------------
//These are objects for in-game, management and generation of groups.
//These are the initial groups that exist in the world, and their types.
//They will be created on server start if they do not already exist, and managed by the subsystem.
//These are NOT the only groups that can exist. And should be expanded with new roles.
//These are the ONLY MAJOR groups that are guaranteed to exist, and should be used for faction/sect/clan/tribe/squads/etc checks.

	//This uses component data to assign groups. Be careful with this, god knows it took me long enough to put it together. It will be optimized!
	//This is so that players can organicly and dynamically change their clan/sect/organization/parties/etc, or plop into one.
	//This also allows for custom groups to be made and assigned, outside of the hardcoded ones.
	//This also allows for saved xp created parties/coteries to be loaded in.
	//This is why the about me component is so complicated, its a really fancy key.

/datum/component/about_me/proc/assign_groups()
    var/list/new_groups = list()

    // City: Everyone is in the city
    if (GLOB.groups && GLOB.groups[GROUP_KEY_CITY])
        new_groups += GLOB.groups[GROUP_KEY_CITY]

    // Faction (Kindred, Fera, or Unknowing)
    if (src.species == "Kindred")
        if (GLOB.groups[GROUP_KEY_FACTION_KINDRED])
            new_groups += GLOB.groups[GROUP_KEY_FACTION_KINDRED]
    else if (src.species == "Fera" || src.species == "Werewolf")
        if (GLOB.groups[GROUP_KEY_FACTION_FERA])
            new_groups += GLOB.groups[GROUP_KEY_FACTION_FERA]
    else if (src.species == "Human" || !src.species)
        if (GLOB.groups[GROUP_KEY_FACTION_UNKNOWING])
            new_groups += GLOB.groups[GROUP_KEY_FACTION_UNKNOWING]

    // Sect ()
    if (src.sect)
        var/sect_key = GROUP_KEY_SECT(src.sect)
        if (GLOB.groups && GLOB.groups[sect_key])
            new_groups += GLOB.groups[sect_key]

    // Clan (Kindred only, "Membership", RoundStart.)
    if (src.clan)
        var/clan_key = GROUP_KEY_CLAN(src.clan)
        if (GLOB.groups && GLOB.groups[clan_key])
            new_groups += GLOB.groups[clan_key]

	// Tribe (Fera/Garou only, "Membership", RoundStart)
    if (src.tribe)
        var/tribe_key = GROUP_KEY_TRIBE(src.tribe)
        if (GLOB.groups && GLOB.groups[tribe_key])
            new_groups += GLOB.groups[tribe_key]

    // Organization (optional)
    if (src.organization)
        var/org_key = GROUP_KEY_ORG(src.organization)
        if (GLOB.groups && GLOB.groups[org_key])
            new_groups += GLOB.groups[org_key]

    // Saved parties/coteries (optional, list of group datums)
    if (islist(src.saved_parties))
        new_groups += src.saved_parties

    src.groups = new_groups



/datum/component/about_me/proc/update_group_texts()
    sect_text = ""
    organization_text = ""
    party_text = ""

    if (!islist(src.groups)) return

    for (var/datum/groups/G in src.groups)
        switch (G.group_type)
            if (GROUP_TYPE_SECT)
                sect_text = G.name
            if (GROUP_TYPE_ORGANIZATION)
                organization_text = G.name
            if (GROUP_TYPE_PARTY)
                party_text = G.name

/datum/component/about_me/proc/sync_group_relationships()
    group_relationships = list()
    if (islist(src.groups))
        for (var/datum/groups/G in src.groups)
            group_relationships += G



/datum/groups/city
    group_type = GROUP_TYPE_CITY
    xp_cost_to_create = 500000

/datum/groups/faction
    group_type = GROUP_TYPE_FACTION
    xp_cost_to_create = 50000
/datum/groups/sect
    group_type = GROUP_TYPE_SECT
    xp_cost_to_create = 50000
/datum/groups/clan
    group_type = GROUP_TYPE_CLAN
    xp_cost_to_create = 50000
/datum/groups/tribe
    group_type = GROUP_TYPE_TRIBE
    xp_cost_to_create = 50000
/datum/groups/organization
    group_type = GROUP_TYPE_ORGANIZATION
    xp_cost_to_create = 1000
/datum/groups/party
    group_type = GROUP_TYPE_PARTY
    xp_cost_to_create = 500

//The big city
/datum/groups/city/SanFrancisco
	//members += GLOB.player_list if not already in members
	id = GROUP_KEY_CITY
	name = "San Francisco"
	desc = "The city of San Francisco, home to many kindred and unknowing alike."
	icon = ""
	tags = list("city", "sanfrancisco", "sf", "thecity", "metropolis", "urban")
	members = list() //Everyone is a member of the city, but this is blank until assigned.
	memories = list() //City memories, events, etc. All groups will have their stuff saved somehow.

//Factions
//Basically the city's government, police, and it's people. Citizen membership! Only one city so should be easy.
/datum/groups/faction/unknowing
//Good bad or the ugly, you're unknowing.

//Good bad or the ugly, you're a kindred.
/datum/groups/faction/kindred
    id = "kindred" // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Kindred of San Francisco"
    desc = "The Kindred of San Francisco, the vampires who rule the city from the shadows."
    icon = ""
    tags = list("kindred", "vampire", "vampires")
    members = list() //Members are assigned via component data.
    memories = list() //Faction memories, events, etc. All groups will have their stuff saved somehow.

//Good bad or the ugly, you're a fera.

/datum/groups/clan/ventrue
    id = "ventrue"
    name = "Clan Ventrue"
    desc = "Clan Ventrue, the blue bloods and aristocrats of the Kindred"
    icon = ""
    tags = list("ventrue", "clan", "bluebloods", "aristocrats")
    members = list() //Members are assigned via component data.
    memories = list() //Clan memories, events, etc.


/datum/groups/clan/brujah
/datum/groups/clan/toreador




/datum/groups/faction/fera

/datum/groups/tribe/silverfangs



//You've seen some things, you know the truth, and you hunt it. You're a hunter.

/datum/groups/faction/hunters

//Sects
/datum/groups/sect/camarilla
/datum/groups/sect/anarchs
/datum/groups/sect/sabbat

//Organizations
/datum/groups/organization/government
/datum/groups/organization/military
/datum/groups/organization/policedepartment
/datum/groups/organization/hospital
/datum/groups/organization/gang
/datum/groups/organization/cult
/datum/groups/organization/corporation

//Squads/parties are coteries, small groups of like-minded friends or associates.
/datum/groups/party/coterie
/datum/groups/party/squad

