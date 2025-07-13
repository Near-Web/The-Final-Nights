// ---------------------------------------------
// Premade Groups!
// ---------------------------------------------
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
    else if (src.species == "Garou")
        if (GLOB.groups[GROUP_KEY_FACTION_FERA])
            new_groups += GLOB.groups[GROUP_KEY_FACTION_FERA]
    else if (src.species == "Human" || !src.species)
        if (GLOB.groups[GROUP_KEY_FACTION_UNKNOWING])
            new_groups += GLOB.groups[GROUP_KEY_FACTION_UNKNOWING]

    // Sect
    if (src.sect == "")
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

    // Organization
    if (src.organization)
        var/org_key = GROUP_KEY_ORG(src.organization)
        if (GLOB.groups && GLOB.groups[org_key])
            new_groups += GLOB.groups[org_key]

    //parties/coteries, needs work.
    //if (islist(src.parties))
    //    new_groups += src.parties

    src.groups = new_groups

//for overview.
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

//FACTIONS/SECTS/CLANS/TRIBES/ORGANIZATIONS/PARTIES!!!
//These are the base group datums, which can be extended for fully premade groups below, or can begenerated in round, as needed.

//Getting smaller each step.
//City is just the whole city.
/datum/groups/city
    group_type = GROUP_TYPE_CITY

//Factions are large generalized groups, like all Kindred, Fera, or Unknowing humans respectively.
//You can only be in ONE faction at a time.
/datum/groups/faction
    group_type = GROUP_TYPE_FACTION

//Sects are more focused groups, like Camarilla, Anarchs, or Sabbat for Kindred.
//This allows for a camarilla to have decent feelings about the anarchs or vise versa. Or conflicted feelings at the least.
//Maybe look out for them to a point, maybe to their own peril.
//You can only have direct membership in one sect at a time, but can have relationships with other sects.
/datum/groups/sect
    group_type = GROUP_TYPE_SECT

//These are actual "races", species detail specific groups that creatures of the night are BORN into.
//That does not mean they have a good relationship with their clan, or even like them.
//But they are born into it, and cannot change it. (Except Caitiff, who are clanless, and don't get one.)
//You can only be in ONE clan at a time, but can have relationships with other clans.
/datum/groups/clan
    group_type = GROUP_TYPE_CLAN
/datum/groups/tribe
    group_type = GROUP_TYPE_TRIBE
//Clanlike group for humans AND hunters, MOB mentality.
//This will be unknown by creatures, and is a bit of a catch-all for humans and informs them like clan leadership will inform clans.
/datum/groups/human
    group_type = GROUP_TYPE_ORGANIZATION
    leader_name = "The Masses."

	//***WARNING***
//This is where control is handed to the players. Will be densely logged for strong actions.
//This is a broad term for any large organization, these are KNOWN to the public.
//Leadership is handled by in game roles.
//Like the police department, Biker Gang, or the Tower Corp, or other business fronts.
//These are the actual jobs.
//All of these are known to the city in some way, but even a secret club has a public face.
/datum/groups/organization
    group_type = GROUP_TYPE_ORGANIZATION

//Coteries, Squads, Parties, Salons, etc. Smaller sub-groups.
//Primogen Council, City Leadership, SWAT, National Guard, etc.
/datum/groups/party
    group_type = GROUP_TYPE_PARTY

//PREMADE GROUPS!
//ALL of this, or as much as possible, should be set and handled by the aboutmecomp.assign_groups(), ^ above.
//
	//The WHOLE City, and Everyone Online gets this. Doesn't display names or information about others, only city-wide information.
//(Admin level communications. Like a city-wide alert of national guard, riots, etc. News broadcasts, etc. Mayor updates. Narrative Focused.)
//With a Mayor Role, this could be very interesting.
/datum/groups/city/SanFrancisco
	//members += GLOB.player_list if not already in members
	id = GROUP_KEY_CITY
	name = "San Francisco"
	desc = "The city of San Francisco. No matter your story, citizen or visitor, your choices brought you here this night."
	leader_name = "Mayor/City Council of San Francisco"
	icon = ""
	tags = list("city", "sanfrancisco")
	members = list("(Everyone.)") // Everyone is a member of the city, by default.

	//Factions: Where do you work? You gotta be one of these.
//These are overall general consensus of various groups, keeping information seperated if needed.
//Default, just citizens
//Everyone gets this, and if they are apart of another faction, they get this and that.
/datum/groups/faction/citizen
    id = GROUP_KEY_FACTION_UNKNOWING // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Citizen of San Francisco"
    desc = "You are a just a regular citizen of San Francisco, with all that entails."
    leader_name = "You are free to live as a citizen in San Fran."
    icon = ""
    tags = list("citizen")

//Good bad or the ugly, you're a kindred.
/datum/groups/faction/kindred
    id = GROUP_KEY_FACTION_KINDRED // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
    name = "Kindred of San Francisco"
    desc = "You are a Kindred of San Francisco, with all that entails."
    leader_name = "Varies, between sects."
    icon = ""
    tags = list("kindred", "vampire", "vampires")

/datum/groups/faction/fera
	id = GROUP_KEY_FACTION_FERA // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Fera of San Francisco"
	desc = "You are a Fera of San Francisco, with all that entails."
	leader_name = "Varies, between sects."
	icon = ""
	tags = list("fera", "werewolf", "garou")

/datum/groups/faction/hunter
	id = GROUP_KEY_FACTION_HUNTERS // Replace with the appropriate key or define GROUP_KEY_FACTION macro elsewhere
	name = "Hunter of San Francisco"
	desc = "You are a hunter of San Francisco, with all that entails."
	leader_name = "Varies"
	icon = ""
	tags = list("hunter")

	//Sects: Unlike generalized factions, sects are driven largly by player choices!
//Default Sect is Independent, for any race, if none is found or appropriate by their role or species, etc.
/datum/groups/sect/independent
	id = GROUP_KEY_SECT_INDEPENDENT
	name = "Independent Citizens"
	desc = "You are independent, and not aligned with any major sect. "
	leader_name = "None"
	icon = ""
	tags = list("independent")
	members = list("(All Independent Citizens.)")

//Kindred Sects
/datum/groups/sect/camarilla
	id = GROUP_KEY_SECT_CAMARILLA
	name = "Camarilla"
	desc = "You are a member of the Camarilla, the largest and most influential sect of Kindred, dedicated to preserving the Masquerade and maintaining order among vampires."
	leader_name = "Prince"
	icon = ""
	tags = list("camarilla")
	members = list("(All Camarilla Members.)")

/datum/groups/sect/anarchs
	id = GROUP_KEY_SECT_ANARCHS
	name = "Anarch"
	desc = "You are an Anarch, a member of the Anarch Movement, which opposes the rigid hierarchy of the Camarilla and seeks greater freedom and equality among Kindred."
	leader_name = "Baron"
	icon = ""
	tags = list("anarchs")
	members = list("(All Anarch Members.)")

/datum/groups/sect/sabbat
	id = GROUP_KEY_SECT_SABBAT
	name = "Sabbat"
	desc = "You are a member of the Sabbat, a sect of Kindred that rejects human morality and embraces their predatory nature, often engaging in violent and ruthless behavior."
	leader_name = "Ductus"
	icon = ""
	tags = list("sabbat")
	members = list("(All Sabbat Members.)")

//Fera Sects

/datum/groups/sect/paintedcity
	id = "paintedcity"
	name = "painted city"
	desc = "You are a member of the painted city."
	leader_name = "The Spirits?"
	icon = ""
	tags = list("fera", "werewolf", "garou")
	members = list("(All Fera Kind, whispers between spirits.)")

/datum/groups/sect/amberglade
	id = "amberglade"
	name = "amber glade"
	desc = "You are a member of the amber glade."
	leader_name = "The Spirits?"
	icon = ""
	tags = list("fera", "werewolf", "garou")
	members = list("(All Fera Kind, whispers between spirits.)")

/datum/groups/sect/poisonedshore
	id = "poisonedshore"
	name = "poisoned shore"
	desc = "You are a member of the poisoned shore."
	leader_name = "The Spirits?"
	icon = ""
	tags = list("fera", "werewolf", "garou")
	members = list("(All Fera Kind, whispers between spirits.)")


//Kindred Clans, Caitif are clanless... They don't get one, don't ask for it.
/datum/groups/clan/ventrue
    id = "ventrue"
    name = "Clan Ventrue"
    desc = "Clan Ventrue, the blue bloods and aristocrats of the Kindred."
    icon = ""
    tags = list("ventrue", "clan")

/datum/groups/clan/brujah
    id = "brujah"
    name = "Clan Brujah"
    desc = "Clan Brujah, the rabble, rebels, and iconoclasts of the Kindred."
    icon = ""
    tags = list("brujah", "clan")

/datum/groups/clan/toreador
    id = "toreador"
    name = "Clan Toreador"
    desc = "Clan Toreador, the artistes, socialites, and patrons of the Kindred."
    icon = ""
    tags = list("toreador", "clan")

/datum/groups/clan/malkavian
    id = "malkavian"
    name = "Clan Malkavian"
    desc = "Clan Malkavian, the seers, lunatics, and visionaries of the Kindred."
    icon = ""
    tags = list("malkavian", "clan")

/datum/groups/clan/nosferatu
    id = "nosferatu"
    name = "Clan Nosferatu"
    desc = "Clan Nosferatu, the outcasts, spies, and information brokers of the Kindred."
    icon = ""
    tags = list("nosferatu", "clan")

/datum/groups/clan/gangrel
    id = "gangrel"
    name = "Clan Gangrel"
    desc = "Clan Gangrel, the wanderers and shapeshifters of the Kindred."
    icon = ""
    tags = list("gangrel", "clan")

/datum/groups/clan/tremere
    id = "tremere"
    name = "Clan Tremere"
    desc = "Clan Tremere, the warlocks, scholars, and blood mages of the Kindred."
    icon = ""
    tags = list("tremere", "clan")

/datum/groups/clan/lasombra
    id = "lasombra"
    name = "Clan Lasombra"
    desc = "Clan Lasombra, the shadow manipulators and rulers of the Kindred."
    icon = ""
    tags = list("lasombra", "clan")

/datum/groups/clan/tzimisce
    id = "tzimisce"
    name = "Clan Tzimisce"
    desc = "Clan Tzimisce, the flesh-shapers and lords of horror among the Kindred."
    icon = ""
    tags = list("tzimisce", "clan")

/datum/groups/clan/ministry
    id = "ministry"
    name = "Clan Ministry"
    desc = "The Ministry (formerly Setites), the corrupters, tempters, and cultists of the Kindred."
    icon = ""
    tags = list("ministry", "setite", "clan")

/datum/groups/clan/giovanni
    id = "giovanni"
    name = "Clan Giovanni"
    desc = "Clan Giovanni, the necromancers and merchant princes of the Kindred."
    icon = ""
    tags = list("giovanni", "clan")

/datum/groups/clan/salubri
    id = "salubri"
    name = "Clan Salubri"
    desc = "Clan Salubri, the healers, sages, and outcasts among the Kindred."
    icon = ""
    tags = list("salubri", "clan")

/datum/groups/clan/daughters_of_cacophony
    id = "daughters_of_cacophony"
    name = "Daughters of Cacophony"
    desc = "The Daughters of Cacophony, enigmatic sirens and masters of supernatural song."
    icon = ""
    tags = list("daughters_of_cacophony", "clan")
/datum/groups/clan/baali
    id = "baali"
    name = "Clan Baali"
    desc = "The Baali, infernalists, corrupters, and worshippers of dark powers among the Kindred."
    icon = ""
    tags = list("baali", "clan")




//Fera Tribes
/datum/groups/tribe/silverfangs

//Hunter Groups
/datum/groups/party/hunters_squad

//Organizations
/datum/groups/organization/government
/datum/groups/organization/military
/datum/groups/organization/policedepartment
/datum/groups/organization/hospital
/datum/groups/organization/gang
/datum/groups/organization/corporation

//Squads/parties are coteries, small groups of like-minded friends or associates.
/datum/groups/party/coterie
/datum/groups/party/squad
