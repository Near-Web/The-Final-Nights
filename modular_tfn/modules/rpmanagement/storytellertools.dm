
// -----------------------
// Admin Verb for Creation
// -----------------------
//input for creating a memory in game
/mob/verb/create_memory()
	set name = "Create Memory"
	set category = "Storyteller Tools"
	set desc = "Create a memory for a player or group."

	var/ckey_or_group = input("Target ckey or group name:") as text
	var/title = input("Memory title:") as text
	var/details = input("Memory details:") as message
	var/raw_tags = input("Comma-separated tags (e.g. 'sect,war,secret'):") as text
	var/timestamp = input("In-game time or date (optional):") as null|text
	var/status = input("Status (public/private/hidden):") as null|anything in list("public", "private", "hidden")

	var/list/tags = splittext(raw_tags, ",")
	for (var/i in 1 to tags.len)
		tags[i] = trim(tags[i])

	var/id = "[world.time]-[rand(1000, 9999)]"

	var/datum/memory/M = GenerateMemory(
		title = title,
		details = details,
		source_ckey = usr.ckey,
		tags = tags,
		status = status,
		is_public = (status == "public"),
		editor_ckey = null,
		edited_time = null,
		related_groups = list(),
		memory_type = null
	)
	M.id = id
	M.created_time = timestamp || "[time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]"

	// Try assigning to a player
	for (var/mob/Mob in GLOB.player_list)
		if (Mob.ckey == ckey_or_group)
			if (!Mob.GetComponent(/datum/component/about_me))
				Mob.AddComponent(/datum/component/about_me)

			var/datum/component/about_me/A = Mob.GetComponent(/datum/component/about_me)
			A.memories_all += M
			A.save_to_file()
			to_chat(Mob, "<span class='notice'>You received a new memory: <b>[title]</b></span>")
			world.log << "[usr] created a memory for [Mob.real_name || Mob.ckey]: [title]"
			return

	// Fallback: unassigned or future group support
	world.log << "[usr] created memory '[title]' for [ckey_or_group] (no matching player found)"

/mob/verb/CreateRelationship()
	set name = "Create Relationship"
	set category = "Storyteller Tools"
	set desc = "Create a relationship between two players."

	var/source_ckey = input("Source ckey:") as text
	var/target_ckey = input("Target ckey:") as text
	var/type = input("Type of relationship:") as null|anything in list("Acquaintance", "Friend", "Foe", "Lover", "Enemy")
	var/strength = input("Strength (-100 to 100):") as num
	var/name = input("Name:") as null|text
	var/desc = input("Description:") as null|text
	var/mutual = alert("Should this be a mutual relationship?", "Mutual?", "Yes", "No") == "Yes"

	var/rel_data = GenerateRelationship(source_ckey, target_ckey, type, strength, name, desc, mutual)

	if (islist(rel_data))
		for (var/datum/relationship/R in rel_data)
			assign_relationship_to_player(R)
	else
		assign_relationship_to_player(rel_data)

/// Assigns a relationship to the appropriate about_me component
/proc/assign_relationship_to_player(var/datum/relationships/R)
	if (!R || !R.source_ckey) return

	for (var/mob/Mob in GLOB.player_list)
		if (Mob.ckey == R.source_ckey)
			var/datum/component/about_me/A = Mob.GetComponent(/datum/component/about_me)
			A.group_relationships += R
			A.save_to_file()
			to_chat(Mob, "<span class='notice'>You now have a new relationship: <b>[R.name]</b></span>")
			break

	world.log << "[usr] created relationship: [R.name] ([R.source_ckey] → [R.target_ckey])"


/mob/verb/CreateChronicle()
	set name = "Create Chronicle"
	set category = "Storyteller Tools"
	set desc = "Create a new chronicle entry. Optionally link it to a group."
	var/title = input("Chronicle Title:") as text
	var/details = input("Chronicle Details:") as message
	var/mode = input("Do you want to associate this with a group?") in list("Yes", "No")
	var/datum/chronicle/C
	if (mode == "Yes")
		// Build a list of existing groups to choose from
		var/list/group_names = list()
		var/list/name_to_group = list()
		for (var/datum/groups/G in global_groups)
			var/display = "[G.name] ([G.group_type])"
			group_names += display
			name_to_group[display] = G
		if (!group_names.len)
			to_chat(src, "<span class='warning'>No groups found to associate with.</span>")
			return
		var/selected = input("Select a group to associate:") in group_names
		var/datum/groups/G = name_to_group[selected]
		C = new(title, details)
		C.AddGroup(G)
		for (var/ckey in G.members)
			C.AddCharacter(ckey)
		to_chat(src, "<span class='notice'>Chronicle '<b>[title]</b>' created and linked to group '<b>[G.name]</b>'.</span>")
	else
		to_chat(src, "<span class='notice'>Chronicle '<b>[title]</b>' null.</span>")
