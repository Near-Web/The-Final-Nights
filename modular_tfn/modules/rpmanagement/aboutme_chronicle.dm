// -----------------------
// Chronicle Tools (Component Procs w/ TGUI Prompts)
// -----------------------

/datum/component/about_me/proc/prompt_create_chronicle_entry(mob/user)
	// Prompt user for new chronicle entry details
	var/title = tgui_input_text(user, "Create Chronicle Entry", "Title?")
	if (!title) return
	var/details = tgui_input_text(user, "Create Chronicle Entry", "Details?")
	if (!details) details = "No details provided."
	var/time = tgui_input_text(user, "Date (optional)", "YYYY-MM-DD hh:mm:ss", time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"))
	var/datum/chronicle_entry/E = src.create_chronicle_entry(title, details, time)
	if (E) {
		src.chronicle_events += E
		save_to_file()
		to_chat(user, "<span class='notice'>Chronicle entry created: [E?.title]</span>")
	}
	else {
		to_chat(user, "<span class='warning'>Failed to create chronicle entry.</span>")
	}

/datum/component/about_me/proc/create_chronicle_entry(title, details, time = null)
	if (!title) return null
	var/datum/chronicle_entry/E = new()
	E.title = title
	E.details = details
	E.created_time = time || time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	E.id = rand(10000, 99999)
	E.time = world.time
	return E

/datum/component/about_me/proc/prompt_edit_chronicle_entry(mob/user)
	// Prompt user to select a chronicle entry to edit
	var/list/options = list()
	for (var/datum/chronicle_entry/E in src.chronicle_events)
		options["[E.id]: [E.title]"] = E
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No chronicle entries to edit.</span>")
		return
	}
	var/choice = tgui_input_list(user, "Edit Chronicle Entry", "Select an entry to edit", options)
	var/datum/chronicle_entry/E = options[choice]
	if (!E) return
	var/title = tgui_input_text(user, "Edit Title", "New title? (leave blank to keep)", E.title)
	var/details = tgui_input_text(user, "Edit Details", "New details? (leave blank to keep)", E.details)
	var/time = tgui_input_text(user, "Edit Date", "New date? (leave blank to keep)", E.created_time)
	src.edit_chronicle_entry(E, title, details, time)
	save_to_file()
	to_chat(user, "<span class='notice'>Chronicle entry edited.")

/datum/component/about_me/proc/edit_chronicle_entry(var/datum/chronicle_entry/E, var/title = null, var/details = null, var/time = null)
	if (!E) return
	if (title) E.title = title
	if (details) E.details = details
	if (time) E.created_time = time

/datum/component/about_me/proc/prompt_delete_chronicle_entry(mob/user)
	// Prompt user to select a chronicle entry to delete
	var/list/options = list()
	for (var/datum/chronicle_entry/E in src.chronicle_events)
		options["[E.id]: [E.title]"] = E
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No chronicle entries to delete.")
		return
	}
	var/choice = tgui_input_list(user, "Delete Chronicle Entry", "Select an entry to delete", options)
	var/datum/chronicle_entry/E = options[choice]
	if (!E) return
	src.delete_chronicle_entry(E)
	save_to_file()
	to_chat(user, "<span class='notice'>Chronicle entry deleted.")

/datum/component/about_me/proc/delete_chronicle_entry(var/datum/chronicle_entry/E)
	if (!E) return
	src.chronicle_events -= E

/datum/component/about_me/proc/prompt_attach_memory_to_chronicle(mob/user)
	// Prompt user to select chronicle entry and memory to link
	var/list/chron_opts = list()
	for (var/datum/chronicle_entry/E in src.chronicle_events)
		chron_opts["[E.id]: [E.title]"] = E
	if (!length(chron_opts)) {
		to_chat(user, "<span class='warning'>No chronicle entries.")
		return
	}
	var/chron_choice = tgui_input_list(user, "Attach Memory", "Select a chronicle entry", chron_opts)
	var/datum/chronicle_entry/E = chron_opts[chron_choice]
	if (!E) return

	var/list/mem_opts = list()
	for (var/datum/memory/M in src.memories_all)
		mem_opts["[M.id]: [M.title]"] = M
	if (!length(mem_opts)) {
		to_chat(user, "<span class='warning'>No memories available.")
		return
	}
	var/mem_choice = tgui_input_list(user, "Attach Memory", "Select a memory to attach", mem_opts)
	var/datum/memory/M = mem_opts[mem_choice]
	if (!M) return
	src.attach_memory_to_chronicle(E, M)
	save_to_file()
	to_chat(user, "<span class='notice'>Memory attached to chronicle entry.")

/datum/component/about_me/proc/attach_memory_to_chronicle(var/datum/chronicle_entry/E, var/datum/memory/M)
	if (!E || !M) return
	if (!islist(E.attached_memories))
		E.attached_memories = list()
	if (!(M in E.attached_memories))
		E.attached_memories += M
