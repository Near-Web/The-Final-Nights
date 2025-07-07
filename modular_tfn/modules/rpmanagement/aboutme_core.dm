// about_me Component: stripped down to essentials
/datum/component/about_me
	var/mob/living/carbon/human/owner
	var/name
	var/species
	var/role
	var/special_role
	var/physique
	var/dexterity
	var/social
	var/mentality
	var/cruelty
	var/lockpicking
	var/athletics


	var/list/memories_all = list()
	var/list/relationships_all = list()
	var/list/chronicles_all = list()
	var/list/group_relationships = list()

	var/sect_text = ""
	var/organization_text = ""
	var/party_text = ""
	var/current_status = ""
	var/faction_alignment = ""
	var/list/groups = list()
	var/sect = ""

	var/list/disciplines = list()
	var/clan
	var/generation
	var/masquerade
	var/humanity
	var/regnant_name
	var/regnant_clan_name

	var/tribe = ""

	var/organization = ""
	var/list/saved_parties = list()
	//can be in multiple parties. Parties only appear when their owner or officers are around.


/datum/component/about_me/Initialize()
	. = ..()
	if (ismob(parent) && istype(parent, /mob/living/carbon/human))
		owner = parent
		var/datum/action/about_me/about_me = new(parent)
		about_me.Grant(parent)
		load_from_file() // <-- Load saved data after setup

//This Generates, only the overview data
/datum/component/about_me/proc/generate_overview()
	if (!ismob(owner)) return
	//GroupStuff
	assign_groups()
	update_group_texts()
	sync_group_relationships()

	//Basic Info
	var/mob/living/carbon/human/H = owner
	if (!H) return
	name = H.real_name
	species = iskindred(H) ? "Kindred" : ishuman(H) ? "Human" : "Unknown"
	role = H.mind?.assigned_role
	special_role = H.mind?.special_role
	if (H.mind?.enslaved_to)
		regnant_name = "[H.mind.enslaved_to]"

	//Stats
	physique = H.physique + H.additional_physique
	dexterity = H.dexterity + H.additional_dexterity
	social = H.social + H.additional_social
	mentality = H:mentality + H.additional_mentality
	cruelty = H:blood + H.additional_blood
	lockpicking = H:lockpicking + H.additional_lockpicking
	athletics = H:athletics + H.additional_athletics

	if (iskindred(H))
		var/datum/species/kindred/K = H.dna?.species
		// --- CLAN
		var/datum/vampire_clan/C = H.clan
		clan = C.name

		// --- GENERATION
		generation = (H.generation && H.generation > 0) ? H.generation : "Unknown"

		// --- MASQUERADE
		masquerade = (H.masquerade != null) ? H.masquerade : 0

		// --- HUMANITY or PATH SCORE
		humanity = (H.morality_path && H.morality_path.score != null) ? H.morality_path.score : "Unknown"

		// --- DISCIPLINES (detailed list)
		disciplines = list()
		if (islist(K?.disciplines))
			for (var/datum/discipline/D in K.disciplines)
				if (!D) continue
				var/discipline_entry = list(
					"name" = D.name,
					"level" = D.level,
					"desc" = D.desc || ""
				)
				disciplines += list(discipline_entry)

		// --- REGNANT (if blood bonded)
		//var/regnant = null
		//var/regnant_clan = null

//Gets overview data for UI
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
		"disciplines" = disciplines
	)

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


//Get FINAL data for UI!
/datum/component/about_me/proc/get_full_payload()
	// Ensure the overview data is up to date
	generate_overview()

	// --- Export/Serialize all data types for UI ---
	var/list/mem_export = islist(memories_all) ? export_memory() : list()           // All memories
	var/list/chron_export = islist(chronicles_all) ? export_chronicle() : list()    // Chronicle entries
	var/list/rel_export = islist(group_relationships) ? export_relationships() : list()// Relationships

	// Exports groups into structured dict for UI
	var/list/group_objects = export_group_objects()

	// Debug message for admins, optional but useful
	message_admins("[src.type]: get_full_payload() - comp.name: [name], memories: [length(mem_export)], chronicle: [length(chron_export)], relationships: [length(rel_export)], groups: [length(group_objects)]")

	return list(
		// 1. Character Overview
		"overview" = get_overview_data(), // Basic bio, stats, disciplines, etc.

		// 2. Character Only Memories (full export and by type for UI filters)
		"memories_all" = mem_export,                        // All memories (raw export)
		"background" = filter_memories_by_tag(mem_export, "background") || list(),
		"current" = filter_memories_by_tag(mem_export, "current") || list(),
		"recent" = filter_memories_by_tag(mem_export, "recent") || list(),
		"goal" = filter_memories_by_tag(mem_export, "goal") || list(),
		"secret" = filter_memories_by_tag(mem_export, "secret") || list(),
		"reputation" = filter_memories_by_tag(mem_export, "reputation") || list(),

		// 3. Chronicle (events list)
		"chronicle" = list(
			"events" = chron_export // Each is a dict: id, title, details, etc.
		),

		// 4. Groups
		"groups" = list(
			// Legacy/quick text fields, if needed for display
			"sect_text" = sect_text || "",
			"organization_text" = organization_text || "",
			"party_text" = party_text || "",
			// NEW: full structured export of groups for the UI GroupsSection
			"group_objects" = group_objects // Dict: type => list of group dicts
		),

		// 5. Relationships
		"relationships" = list(
			"group_affiliations" = rel_export // List of dicts: id, name, relationship_type, etc.
		),

		// 6. Miscellaneous (status, alignment)
		"status" = current_status || "",
		"alignment" = faction_alignment || ""
	)


/datum/component/about_me/proc/filter_memories_by_tag(list/mems, tag)
	var/list/result = list()
	for (var/memory in mems)
		if (!islist(memory["tags"]))
			continue
		if (tag in memory["tags"])
			result += memory
	return result

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
