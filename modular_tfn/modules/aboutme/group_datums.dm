//This dynamicly updates and assigns groups as effeciently as I could think of for now.
/datum/component/about_me/proc/assign_groups()
    var/list/new_groups = list()
    // City: Everyone is in the city
    if (GLOB.groups && GLOB.groups[GROUP_KEY_CITY])
        new_groups += GLOB.groups[GROUP_KEY_CITY]
    // Faction
    if (src.species == "Kindred")
        if (GLOB.groups[GROUP_KEY_FACTION_KINDRED])
            new_groups += GLOB.groups[GROUP_KEY_FACTION_KINDRED]
    else if (src.species == "Fera")
        if (GLOB.groups[GROUP_KEY_FACTION_FERA])
            new_groups += GLOB.groups[GROUP_KEY_FACTION_FERA]
    else if (src.species == "Human" || !src.species)
        if (GLOB.groups[GROUP_KEY_FACTION_UNKNOWING])
            new_groups += GLOB.groups[GROUP_KEY_FACTION_UNKNOWING]
    // Sect
    if (!src.sect || src.sect == "")
        var/sect_key = GROUP_KEY_SECT_INDEPENDENT
        if (GLOB.groups && GLOB.groups[sect_key])
            new_groups += GLOB.groups[sect_key]
    else
        var/sect_key = GROUP_KEY_SECT(src.sect)
        if (GLOB.groups && GLOB.groups[sect_key])
            new_groups += GLOB.groups[sect_key]
    // Clan
    if (src.clan)
        var/clan_key = GROUP_KEY_CLAN(src.clan)
        if (GLOB.groups && GLOB.groups[clan_key])
            new_groups += GLOB.groups[clan_key]
    // Tribe
    if (src.tribe)
        var/tribe_key = GROUP_KEY_TRIBE(src.tribe)
        if (GLOB.groups && GLOB.groups[tribe_key])
            new_groups += GLOB.groups[tribe_key]
            message_admins("DEBUG: Added tribe group: [tribe_key] ([GLOB.groups[tribe_key]])")
        else
            message_admins("DEBUG: Tribe key missing: [tribe_key] (src.tribe=[src.tribe])")

    // Organization
    if (src.organization)
        var/org_key = GROUP_KEY_ORG(src.organization)
        if (GLOB.groups && GLOB.groups[org_key])
            new_groups += GLOB.groups[org_key]
    // Parties/coteries (future expansion)
    // if (islist(src.parties))
    //     new_groups += src.parties
    src.groups = new_groups
//for overview display, just a basic rake of information.
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
//will be used to populate co-workers, clan-mates, etc.
/datum/component/about_me/proc/sync_group_relationships()
    group_relationships = list()
    if (islist(src.groups))
        for (var/datum/groups/G in src.groups)
            group_relationships += G

// ---------------------------------------------
// Premade Groups!
// ---------------------------------------------
//CITY/FACTIONS/SECTS/CLANS/TRIBES/ORGANIZATIONS/PARTIES!!!
//These are the base group datums, which can be extended for fully premade groups below, or can begenerated in round, as needed.
//City is just the whole city.
/datum/groups/city
    group_type = GROUP_TYPE_CITY
    tags = list(GROUP_TAG_CITY)
/datum/groups/faction
    group_type = GROUP_TYPE_FACTION
    tags = list(GROUP_TAG_FACTION)
/datum/groups/sect
    group_type = GROUP_TYPE_SECT
    tags = list(GROUP_TAG_SECT)
/datum/groups/clan
    group_type = GROUP_TYPE_CLAN
    tags = list(GROUP_TAG_CLAN)
/datum/groups/tribe
    group_type = GROUP_TYPE_TRIBE
    tags = list(GROUP_TAG_TRIBE)
// Catch-all organizations (PD, hospital, etc)
/datum/groups/organization
    group_type = GROUP_TYPE_ORGANIZATION
    tags = list(GROUP_TAG_ORG)
/datum/groups/party
    group_type = GROUP_TYPE_PARTY
    tags = list(GROUP_TAG_PARTY)

//PREMADE GROUPS!
//ALL OF THESE MUST HAVE A KEY FOR THEIR ID. Found in group.dm.
//The WHOLE City.
/datum/groups/city/SanFrancisco
	id = GROUP_KEY_CITY
	name = "San Francisco"
	desc = "The city of San Francisco. No matter your story, citizen or visitor, your choices brought you here this night."
	leader_name = "Government/Mayor/City Council of San Francisco"
	members = list("(Everyone within the city.)") // Everyone is a member of the city, by default.
//Factions: These represent mob mentality, for example kindred whispers of sabbat can be updated here. Very Generalized
//Citizens, all city services fall under this.
/datum/groups/faction/citizen
    id = GROUP_KEY_FACTION_UNKNOWING // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Citizen of San Francisco"
    desc = "You are a just a regular citizen of San Francisco."
    leader_name = "Elected Mayor."
    members = list("(The Masses.)")
//Kindred
/datum/groups/faction/kindred
    id = GROUP_KEY_FACTION_KINDRED // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Kindred of San Francisco"
    desc = "You are a Kindred of San Francisco."
    leader_name = "Varies, between sects."
//Fera
/datum/groups/faction/fera
	id = GROUP_KEY_FACTION_FERA // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Fera of San Francisco"
	desc = "You are a Fera of San Francisco."
	leader_name = "Varies, between sects."
//Hunters
/datum/groups/faction/hunter
	id = GROUP_KEY_FACTION_HUNTERS // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Hunter of San Francisco"
	desc = "You are a hunter of San Francisco, with all that entails."
	leader_name = "Varies"
//Sects: Unlike generalized factions, sects are driven largly by player choices!
//Independent, Catch all for everyone.
/datum/groups/sect/independent
	id = GROUP_KEY_SECT_INDEPENDENT
	name = "Independent"
	desc = "You are independent, and not aligned with any major sect, for now."
	leader_name = "You lead your own life, as you will."
	members = list("(Anyone not aligned with a sect.)")
//Kindred Sects, set from role
/datum/groups/sect/camarilla
	id = GROUP_KEY_SECT_CAMARILLA
	name = "Camarilla"
	desc = "You are a member of the Camarilla, the largest and most influential sect of Kindred, dedicated to preserving the Traditions, and namely, the Masquerade. You maintain order among kindred."
	leader_name = "Prince"
	members = list("(All Camarilla Members.)")
/datum/groups/sect/anarchs
	id = GROUP_KEY_SECT_ANARCHS
	name = "Anarch"
	desc = "You are an Anarch, a member of the Anarch Movement, which opposes the rigid hierarchy of the Camarilla and seeks greater freedom and equality among Kindred."
	leader_name = "Baron"
	members = list("(All Anarch Members.)")
/datum/groups/sect/sabbat
	id = GROUP_KEY_SECT_SABBAT
	name = "Sabbat"
	desc = "You are a member of the Sabbat, a sect of Kindred that rejects human morality and embraces their predatory nature, often engaging in violent and ruthless behavior."
	leader_name = "Ductus"
	members = list("(All Sabbat Members.)")
//Fera Sects, set from role
/datum/groups/sect/paintedcity
	id = GROUP_KEY_SECT_PAINTEDCITY
	name = "painted city"
	desc = "You are a member of the painted city."
	leader_name = "The Spirits?"
	members = list("(All Fera Kind, whispers between spirits.)")
/datum/groups/sect/amberglade
	id = GROUP_KEY_SECT_AMBERGLADE
	name = "amber glade"
	desc = "You are a member of the amber glade."
	leader_name = "The Spirits?"
	members = list("(All Fera Kind, whispers between spirits.)")
/datum/groups/sect/poisonedshore
	id = GROUP_KEY_SECT_POISONEDSHORE
	name = "poisoned shore"
	desc = "You are a member of the poisoned shore."
	leader_name = "The Spirits?"
	members = list("(All Fera Kind, whispers between spirits.)")
//Kindred Clans, set from character
/datum/groups/clan/caitif
    id = GROUP_KEY_CLAN_CAITIF
    name = "Clanless"
    desc = "You are without clan."
/datum/groups/clan/ventrue
    id = GROUP_KEY_CLAN_VENTRUE
    name = "Clan Ventrue"
    desc = "Clan Ventrue, the blue bloods and aristocrats of the Kindred."
/datum/groups/clan/brujah
    id = GROUP_KEY_CLAN_BRUJAH
    name = "Clan Brujah"
    desc = "Clan Brujah, the rabble, rebels, and iconoclasts of the Kindred."
/datum/groups/clan/toreador
    id = GROUP_KEY_CLAN_TOREADOR
    name = "Clan Toreador"
    desc = "Clan Toreador, the artistes, socialites, and patrons of the Kindred."
/datum/groups/clan/malkavian
    id = GROUP_KEY_CLAN_MALKAVIAN
    name = "Clan Malkavian"
    desc = "Clan Malkavian, the seers, lunatics, and visionaries of the Kindred."
/datum/groups/clan/nosferatu
    id = GROUP_KEY_CLAN_NOSFERATU
    name = "Clan Nosferatu"
    desc = "Clan Nosferatu, the outcasts, spies, and information brokers of the Kindred."
/datum/groups/clan/gangrel
    id = GROUP_KEY_CLAN_GANGREL
    name = "Clan Gangrel"
    desc = "Clan Gangrel, the wanderers and shapeshifters of the Kindred."
/datum/groups/clan/tremere
    id = GROUP_KEY_CLAN_TREMERE
    name = "Clan Tremere"
    desc = "Clan Tremere, the warlocks, scholars, and blood mages of the Kindred."
/datum/groups/clan/lasombra
    id = GROUP_KEY_CLAN_LASOMBRA
    name = "Clan Lasombra"
    desc = "Clan Lasombra, the shadow manipulators and rulers of the Kindred."
/datum/groups/clan/tzimisce
    id = GROUP_KEY_CLAN_TZIMISCE
    name = "Clan Tzimisce"
    desc = "Clan Tzimisce, the flesh-shapers and lords of horror among the Kindred."
/datum/groups/clan/ministry
    id = GROUP_KEY_CLAN_MINISTRY
    name = "Clan Ministry"
    desc = "The Ministry (formerly Setites), the corrupters, tempters, and cultists of the Kindred."
/datum/groups/clan/giovanni
    id = GROUP_KEY_CLAN_GIOVANNI
    name = "Clan Giovanni"
    desc = "Clan Giovanni, the necromancers and merchant princes of the Kindred."
/datum/groups/clan/salubri
    id = GROUP_KEY_CLAN_SALUBRI
    name = "Clan Salubri"
    desc = "Clan Salubri, the healers, sages, and outcasts among the Kindred."
/datum/groups/clan/daughters_of_cacophony
    id = GROUP_KEY_CLAN_DAUGHTERS_OF_CACOPHONY
    name = "Daughters of Cacophony"
    desc = "The Daughters of Cacophony, enigmatic sirens and masters of supernatural song."
/datum/groups/clan/baali
    id = GROUP_KEY_CLAN_BAALI
    name = "Clan Baali"
    desc = "The Baali, infernalists, corrupters, and worshippers of dark powers among the Kindred."
//Fera Tribes, ronin default, set from character.
/datum/groups/tribe/ronin
    id = GROUP_KEY_TRIBE_RONIN
    name = "Ronin"
    desc = "Ronin, those Garou and Fera who walk alone without tribe or allegiance."
/datum/groups/tribe/blackfuries
    id = GROUP_KEY_TRIBE_BLACKFURIES
    name = "Black Furies"
    desc = "The Black Furies, protectors of the sacred and avengers of the oppressed."
/datum/groups/tribe/blackspiraldancers
    id = GROUP_KEY_TRIBE_BLACKSPIRALDANCERS
    name = "Black Spiral Dancers"
    desc = "The Black Spiral Dancers, lost to the Wyrm and bringers of chaos and corruption."
/datum/groups/tribe/bonegnawers
    id = GROUP_KEY_TRIBE_BONEGNAWERS
    name = "Bone Gnawers"
    desc = "The Bone Gnawers, survivors of the streets and scavengers among the Garou."
/datum/groups/tribe/childrenofgaia
    id = GROUP_KEY_TRIBE_CHILDRENOFGAIA
    name = "Children of Gaia"
    desc = "The Children of Gaia, peacemakers, healers, and seekers of unity among the Garou."
/datum/groups/tribe/corax
    id = GROUP_KEY_TRIBE_CORAX
    name = "Corax"
    desc = "The Corax, raven-shifters, messengers, and keepers of secrets."
/datum/groups/tribe/galestalkers
    id = GROUP_KEY_TRIBE_GALESTALKERS
    name = "Gale Stalkers"
    desc = "The Gale Stalkers, elusive and wild Garou, attuned to the storm."
/datum/groups/tribe/getoffenris
    id = GROUP_KEY_TRIBE_GETOFFENRIS
    name = "Get of Fenris"
    desc = "The Get of Fenris, warriors, berserkers, and defenders of Garou honor."
/datum/groups/tribe/ghostcouncil
    id = GROUP_KEY_TRIBE_GHOSTCOUNCIL
    name = "Ghost Council"
    desc = "The Ghost Council, mysterious spirit-guided Garou or the wise of the Umbra."
/datum/groups/tribe/glasswalkers
    id = GROUP_KEY_TRIBE_GLASSWALKERS
    name = "Glass Walkers"
    desc = "The Glass Walkers, masters of technology and urban Garou society."
/datum/groups/tribe/hartwardens
    id = GROUP_KEY_TRIBE_HARTWARDENS
    name = "Hart Wardens"
    desc = "The Hart Wardens, guardians of nature and sacred lands."
/datum/groups/tribe/redtalons
    id = GROUP_KEY_TRIBE_REDTALONS
    name = "Red Talons"
    desc = "The Red Talons, savage Garou, fierce protectors of the wild."
/datum/groups/tribe/shadowlords
    id = GROUP_KEY_TRIBE_SHADOWLORDS
    name = "Shadow Lords"
    desc = "The Shadow Lords, cunning politicians, manipulators, and seekers of power."
/datum/groups/tribe/silentstriders
    id = GROUP_KEY_TRIBE_SILENTSTRIDERS
    name = "Silent Striders"
    desc = "The Silent Striders, wanderers and messengers of the restless dead."
/datum/groups/tribe/silverfangs
    id = GROUP_KEY_TRIBE_SILVERFANGS
    name = "Silver Fangs"
    desc = "The Silver Fangs, noble rulers and ancient leaders of the Garou Nation."
/datum/groups/tribe/stargazers
    id = GROUP_KEY_TRIBE_STARGAZERS
    name = "Stargazers"
    desc = "The Stargazers, mystics, philosophers, and seekers of cosmic truth."
//Organizations, these are the catch all for smaller groups. Like the PD, Hospital Staff, etc.
//Set from role, or joining them in round from leaders/officers.
/datum/groups/organization/primogencouncil
/datum/groups/organization/government
/datum/groups/organization/military
/datum/groups/organization/policedepartment
/datum/groups/organization/hospital
/datum/groups/organization/gang
/datum/groups/organization/corporation
//Squads/parties are coteries, small groups of like-minded friends or associates.
//Hunter/Swat/National Guard
/datum/groups/party/hunters_squad
/datum/groups/party/coterie
/datum/groups/party/squad
