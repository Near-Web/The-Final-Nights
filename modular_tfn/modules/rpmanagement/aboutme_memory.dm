/datum/component/about_me/proc/get_memories_with_tags(var/list/search_tags)
	if (!length(memories_all) || !length(search_tags)) return list()
	var/list/results = list()
	for (var/datum/memory/M in memories_all)
		if (!islist(M.tags)) continue
		for (var/T in search_tags)
			if (T in M.tags)
				results += export_memory(M)
				break
	return results

/datum/component/about_me/proc/search_memories(var/query)
	var/list/matches = list()
	for (var/datum/memory/M in memories_all)
		if (findtext(lowertext(M.title), lowertext(query)) || findtext(lowertext(M.details), lowertext(query)))
			matches += export_memory(M)
	return matches

/datum/component/about_me/proc/export_all_memories()
	var/list/output = list()
	for (var/datum/memory/M in memories_all)
		output += export_memory(M)
	return output

/datum/component/about_me/proc/create_memory()
	set name = "Create Memory"
	set desc = "Add a personal memory to your character."

	var/title = input(owner, "Memory title:", "Create Memory") as text
	if (!title) return

	var/details = input(owner, "Memory details:", "Create Memory") as message
	if (!details) return

	var/raw_tags = input(owner, "Tags (comma-separated):", "Create Memory") as null|text
	var/list/tags = raw_tags ? splittext(raw_tags, ",") : list()
	for (var/i in 1 to tags.len)
		tags[i] = trim(tags[i])

	var/status = input(owner, "Status of memory:", "Create Memory") as null|anything in list("active", "goal", "secret", "archived")
	if (!status) status = "active"

	var/id = "[world.time]-[rand(1000, 9999)]"

	var/datum/memory/M = GenerateMemory(
		title = title,
		details = details,
		tags = tags,
		status = status,
		is_public = (status == "public"),
		source_ckey = owner.ckey,
		editor_ckey = null,
		edited_time = null,
		related_groups = list(),
		memory_type = null
	)
	M.id = id
	M.created_time = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")

	memories_all += M
	save_to_file()
	to_chat(owner, "<span class='notice'>You created a new memory: <b>[title]</b></span>")

/datum/component/about_me/proc/edit_memory(var/id)
	if (!id || !length(memories_all)) return

	var/datum/memory/M = locate(id) in src.memories_all
	if (!M) return

	var/title = input("New title:", "", M.title) as null|text
	var/details = input("New details:", "", M.details) as null|message
	var/raw_tags = input("Tags (comma-separated):", "", jointext(M.tags, ", ")) as null|text
	var/status = input("Status:", "", M.status) as null|anything in list("public", "private", "hidden")

	if (title) M.title = title
	if (details) M.details = details
	if (status) {
		M.status = status
		M.is_public = (status == "public")
	}
	if (raw_tags) {
		M.tags = list()
		for (var/T in splittext(raw_tags, ","))
			M.tags += trim(T)
	}

	M.edited_time = time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")
	M.editor_ckey = src.owner?.ckey
	src.save_to_file()

/datum/component/about_me/proc/delete_memory(var/id)
	if (!id || !length(memories_all)) return

	var/datum/memory/M = locate(id) in src.memories_all
	if (!M) return

	memories_all -= M
	src.save_to_file()
