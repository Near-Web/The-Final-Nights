// ----------
// MEMORY TOOLS (Component Procs w/ TGUI Prompts)
// ----------
/datum/component/about_me/proc/prompt_create_memory(mob/user)
    // Prompt for memory details
    var/title = tgui_input_text(user, "Create Memory", "Title for this memory?")
    if (!title) return

    var/details = tgui_input_text(user, "Create Memory", "Details for this memory?")
    if (!details) return

    // Tag selection (single choice)
    var/tag = tgui_input_list(user, "Memory Tag", "Select a tag for this memory", MEMORY_TAGS)
    if (!tag)
        to_chat(user, "<span class='warning'>You must pick a tag!</span>")
        return
    var/list/tags = list(tag)

    var/status = tgui_input_list(user, "Status", "Select status", list("active", "hidden", "archived"))
    if (!status) status = "active"

    var/datum/memory/M = src.create_memory(title, details, tags, status)
    to_chat(user, "<span class='notice'>Memory created: [M?.title]</span>")


/datum/component/about_me/proc/create_memory(title, details, list/tags = list(), status = "active")
	// Core logic for memory creation, called by prompt proc
	var/datum/memory/M = new()
	M.title = title
	M.details = details
	M.tags = tags.Copy()
	M.created_time = world.time
	M.status = status
	M.id = rand(10000, 99999)
	M.time = world.time
	src.memories_all += M
	save_to_file()
	return M

/datum/component/about_me/proc/prompt_edit_memory(mob/user)
	// Prompt user to select a memory to edit and new values
	var/list/options = list()
	for (var/datum/memory/M in src.memories_all)
		options["[M.id]: [M.title]"] = M
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No memories to edit.</span>")
		return
	}
	var/choice = tgui_input_list(user, "Edit Memory", "Select a memory to edit", options)
	var/datum/memory/M = options[choice]
	if (!M) return

	var/new_title = tgui_input_text(user, "Edit Memory", "New title? (leave blank to keep)", M.title)
	var/new_details = tgui_input_text(user, "Edit Memory", "New details? (leave blank to keep)", M.details)

	// Only allow a single tag, preselect current or first if missing
	var/current_tag = (islist(M.tags) && M.tags.len) ? M.tags[1] : (MEMORY_TAGS[1] || "")
	var/new_tag = tgui_input_list(user, "Edit Tag", "Select a tag", MEMORY_TAGS, current_tag)
	var/list/new_tags = new_tag ? list(new_tag) : M.tags

	var/new_status = tgui_input_list(user, "Status", "Select status", list("active", "hidden", "archived"), M.status)

	src.edit_memory(M, new_title, new_details, new_tags, new_status)
	to_chat(user, "<span class='notice'>Memory edited: [M?.title]</span>")

/datum/component/about_me/proc/edit_memory(var/datum/memory/M, var/new_title = null, var/new_details = null, var/list/new_tags = null, var/new_status = null)
	if (!M) return
	if (new_title) M.title = new_title
	if (new_details) M.details = new_details
	if (islist(new_tags)) M.tags = new_tags.Copy()
	if (new_status) M.status = new_status
	save_to_file()

/datum/component/about_me/proc/prompt_delete_memory(mob/user)
	// Prompt user to select a memory to delete
	var/list/options = list()
	for (var/datum/memory/M in src.memories_all)
		options["[M.id]: [M.title]"] = M
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No memories to delete.</span>")
		return
	}
	var/choice = tgui_input_list(user, "Delete Memory", "Select a memory to delete", options)
	var/datum/memory/M = options[choice]
	if (!M) return
	src.delete_memory(M)
	to_chat(user, "<span class='notice'>Memory deleted.")

/datum/component/about_me/proc/delete_memory(var/datum/memory/M)
	if (!M) return
	src.memories_all -= M
	src.chronicles_all -= M
	save_to_file()

/datum/component/about_me/proc/prompt_tag_memory(mob/user)
	// Prompt user to select memory and tag
	var/list/options = list()
	for (var/datum/memory/M in src.memories_all)
		options["[M.id]: [M.title]"] = M
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No memories to tag.</span>")
		return
	}
	var/choice = tgui_input_list(user, "Tag Memory", "Select a memory to tag", options)
	var/datum/memory/M = options[choice]
	if (!M) return
	var/tag = tgui_input_text(user, "Tag Memory", "Enter tag")
	if (!tag) return
	src.tag_memory(M, tag)
	to_chat(user, "<span class='notice'>Tag added to memory.")

/datum/component/about_me/proc/tag_memory(var/datum/memory/M, var/tag)
	if (!M || !tag) return
	if (!islist(M.tags)) M.tags = list()
	if (!(tag in M.tags))
		M.tags += tag
	save_to_file()

/datum/component/about_me/proc/prompt_attach_memory_to_relationship(mob/user)
	// Prompt user for memory and relationship
	var/list/mem_opts = list()
	for (var/datum/memory/M in src.memories_all)
		mem_opts["[M.id]: [M.title]"] = M
	if (!length(mem_opts)) {
		to_chat(user, "<span class='warning'>No memories found.</span>")
		return
	}
	var/mem_choice = tgui_input_list(user, "Attach Memory", "Select a memory", mem_opts)
	var/datum/memory/M = mem_opts[mem_choice]
	if (!M) return

	var/list/rel_opts = list()
	for (var/datum/relationships/R in src.group_relationships)
		rel_opts["[R.id]: [R.name]"] = R
	if (!length(rel_opts)) {
		to_chat(user, "<span class='warning'>No relationships found.</span>")
		return
	}
	var/rel_choice = tgui_input_list(user, "Attach Memory", "Select a relationship", rel_opts)
	var/datum/relationships/R = rel_opts[rel_choice]
	if (!R) return

	src.attach_memory_to_relationship(R, M)
	to_chat(user, "<span class='notice'>Memory attached to relationship.</span>")

/datum/component/about_me/proc/attach_memory_to_relationship(var/datum/relationships/R, var/datum/memory/M)
	if (!R || !M) return
	if (!islist(R.rel_memories)) R.rel_memories = list()
	if (!(M in R.rel_memories))
		R.rel_memories += M
	save_to_file()

/datum/component/about_me/proc/prompt_attach_memory_to_group(mob/user)
	// Prompt user for memory and group
	var/list/mem_opts = list()
	for (var/datum/memory/M in src.memories_all)
		mem_opts["[M.id]: [M.title]"] = M
	if (!length(mem_opts)) {
		to_chat(user, "<span class='warning'>No memories found.")
		return
	}
	var/mem_choice = tgui_input_list(user, "Attach Memory", "Select a memory", mem_opts)
	var/datum/memory/M = mem_opts[mem_choice]
	if (!M) return

	var/list/group_opts = list()
	for (var/datum/groups/G in GLOB.groups)
		group_opts["[G.id]: [G.name]"] = G
	if (!length(group_opts)) {
		to_chat(user, "<span class='warning'>No groups found.")
		return
	}
	var/group_choice = tgui_input_list(user, "Attach Memory", "Select a group", group_opts)
	var/datum/groups/G = group_opts[group_choice]
	if (!G) return

	src.attach_memory_to_group(G, M)
	to_chat(user, "<span class='notice'>Memory attached to group.</span>")

/datum/component/about_me/proc/attach_memory_to_group(var/datum/groups/G, var/datum/memory/M)
	if (!G || !M) return
	if (!islist(G.memories))
		G.memories = list()
	if (!(M in G.memories))
		G.memories += M
	save_to_file()
