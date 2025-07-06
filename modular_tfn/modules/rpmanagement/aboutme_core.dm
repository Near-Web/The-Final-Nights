// about_me Component: stripped down to essentials
/datum/component/about_me
	var/name
	var/species
	var/role
	var/special_role
	var/clan
	var/generation
	var/masquerade
	var/humanity
	var/regnant_name
	var/regnant_clan_name
	var/physique
	var/dexterity
	var/social
	var/mentality
	var/cruelty
	var/lockpicking
	var/athletics
	var/list/disciplines = list()
	var/mob/living/carbon/human/owner
	var/list/memories_all = list()
	var/list/chronicle_events = list()
	var/list/group_relationships = list()
	var/sect_text = ""
	var/organization_text = ""
	var/party_text = ""
	var/current_status = ""
	var/faction_alignment = ""

/datum/component/about_me/Initialize()
	. = ..()
	if (ismob(parent) && istype(parent, /mob/living/carbon/human))
		owner = parent
		var/datum/action/about_me/about_me = new(parent)
		about_me.Grant(parent)

/datum/component/about_me/proc/generate_overview()
	if (!ismob(owner)) return
	var/mob/living/carbon/human/H = owner
	if (!H) return
	name = H.real_name
	species = iskindred(H) ? "Kindred" : ishuman(H) ? "Human" : "Unknown"
	role = H.mind?.assigned_role
	special_role = H.mind?.special_role
	if (H.mind?.enslaved_to)
		regnant_name = "[H.mind.enslaved_to]"
	physique = H.physique + H.additional_physique
	dexterity = H.dexterity + H.additional_dexterity
	social = H.social + H.additional_social
	mentality = H:mentality + H.additional_mentality
	cruelty = H:blood + H.additional_blood
	lockpicking = H:lockpicking + H.additional_lockpicking
	athletics = H:athletics + H.additional_athletics

	var/datum/species/kindred/K = H.dna?.species
	if (iskindred(H) && istype(K, /datum/species/kindred))
		clan = K.clane?.name || "Caitiff"
		generation = H.generation > 0 ? H.generation : "Unknown"
		masquerade = H.masquerade
		humanity = H.morality_path?.score
		disciplines = list()

		if (islist(K?.disciplines))
			for (var/datum/discipline/D in K.disciplines)
				disciplines += D

/datum/component/about_me/proc/get_stats_dict()
	return list(
		"Physique" = physique,
		"Dexterity" = dexterity,
		"Social" = social,
		"Mentality" = mentality,
		"Cruelty" = cruelty,
		"Lockpicking" = lockpicking,
		"Athletics" = athletics
	)

/datum/component/about_me/proc/get_disciplines_list()
	var/list/out = list()
	for (var/datum/discipline/D in disciplines)
		out += list(list("name" = D.name, "level" = D.level, "desc" = D.desc))
	return out

/datum/component/about_me/proc/get_overview_data()
	generate_overview()
	return list(
		"name" = name,
		"species" = species,
		"role" = role,
		"special_role" = special_role,
		"clan" = clan,
		"generation" = generation,
		"masquerade" = masquerade,
		"humanity" = humanity,
		"regnant" = regnant_name,
		"regnant_clan" = regnant_clan_name,
		"stats" = get_stats_dict(),
		"disciplines" = get_disciplines_list()
	)

/datum/component/about_me/proc/filter_memories_by_tag(list/mems, tag)
	var/list/result = list()
	for (var/memory in mems)
		if (!islist(memory["tags"]))
			continue
		if (tag in memory["tags"])
			result += memory
	return result


/datum/component/about_me/proc/get_full_payload()
	var/list/mem_export = islist(memories_all) ? export_memory() : list()
	var/list/chron_export = islist(chronicle_events) ? export_chronicle() : list()
	var/list/rel_export = islist(group_relationships) ? export_relationships() : list()
	message_admins("[src.type]: get_full_payload() — overview.name: [get_overview_data()["name"]]")
	return list(
		"overview" = get_overview_data(),
		"memories_all" = mem_export,
		"background" = filter_memories_by_tag(mem_export, "background") || list(),
		"current" = filter_memories_by_tag(mem_export, "current") || list(),
		"recent" = filter_memories_by_tag(mem_export, "recent") || list(),
		"goal" = filter_memories_by_tag(mem_export, "goal") || list(),
		"secret" = filter_memories_by_tag(mem_export, "secret") || list(),
		"reputation" = filter_memories_by_tag(mem_export, "reputation") || list(),
		"chronicle" = list("events" = chron_export),
		"groups" = list(
			"sect_text" = sect_text || "",
			"organization_text" = organization_text || "",
			"party_text" = party_text || ""
		),
		"relationships" = list("group_affiliations" = rel_export),
		"status" = current_status || "",
		"alignment" = faction_alignment || ""
	)

/client/verb/Debugabout_mePayload()
	set name = "About Me Debug Payload"
	set category = "IC"
	if (!istype(mob, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = mob
	var/datum/component/about_me/C = H.GetComponent(/datum/component/about_me)
	if (!C)
		return
	to_chat(src, "<span class='notice'>[json_encode(C.get_full_payload(), TRUE)]</span>")
