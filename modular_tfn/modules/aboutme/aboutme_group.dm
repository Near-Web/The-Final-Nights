// -----------------------
// Group Tools (Component Procs w/ TGUI Prompts)
//BUTTONS
// -----------------------

/datum/component/about_me/proc/prompt_create_group(mob/user)
	// Prompt user for group creation details
	var/name = tgui_input_text(user, "Create Group", "Group name?")
	if (!name) return
	var/gtype = tgui_input_list(user, "Group Type", "Select type", list("Coterie", "Sect", "Clan", "Party", "Organization"))
	if (!gtype) gtype = "Coterie"
	var/desc = tgui_input_text(user, "Description", "Description? (Optional)")
	var/icon = tgui_input_text(user, "Icon", "Icon state? (Optional)")
	var/list/tags = list()
	var/tags_string = tgui_input_text(user, "Tags", "Comma-separated tags? (Optional)")
	if (tags_string && length(tags_string))
		tags = splittext(tags_string, ",")
	var/leader_ckey = src.owner?.ckey
	var/datum/groups/G = src.create_group(name, gtype, desc, icon, leader_ckey, tags)
	if (G) {
		to_chat(user, "<span class='notice'>Group created: [G?.name]</span>")
	}
	else {
		to_chat(user, "<span class='warning'>Failed to create group.</span>")
	}

/datum/component/about_me/proc/create_group(var/name, var/gtype, var/desc, var/icon, var/leader_ckey, var/list/tags)
	if (!name) return null
	var/datum/groups/G = new()
	G.name = name
	G.group_type = gtype
	G.desc = desc
	G.icon = icon
	G.leader_ckey = leader_ckey
	G.tags = tags.Copy()
	G.members = list()
	G.memories = list()
	if (leader_ckey)
		G.members += leader_ckey
	GLOB.groups += G
	save_all_groups()
	return G

/datum/component/about_me/proc/prompt_edit_group(mob/user)
	var/list/options = list()
	for (var/datum/groups/G in GLOB.groups)
		options["[G.id]: [G.name]"] = G
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No groups to edit.</span>")
		return
	}
	var/choice = tgui_input_list(user, "Edit Group", "Select a group to edit", options)
	var/datum/groups/G = options[choice]
	if (!G) return
	var/name = tgui_input_text(user, "Edit Name", "New name? (leave blank to keep)", G.name)
	var/desc = tgui_input_text(user, "Edit Description", "New description? (leave blank to keep)", G.desc)
	var/icon = tgui_input_text(user, "Edit Icon", "New icon? (leave blank to keep)", G.icon)
	var/gtype = tgui_input_text(user, "Edit Type", "New type? (leave blank to keep)", G.group_type)
	src.edit_group(G, name, desc, icon, gtype)
	save_all_groups()
	to_chat(user, "<span class='notice'>Group edited: [G?.name]</span>")

/datum/component/about_me/proc/edit_group(var/datum/groups/G, var/name = null, var/desc = null, var/icon = null, var/gtype = null)
	if (!G) return
	if (name) G.name = name
	if (desc) G.desc = desc
	if (icon) G.icon = icon
	if (gtype) G.group_type = gtype

/datum/component/about_me/proc/prompt_delete_group(mob/user)
	var/list/options = list()
	for (var/datum/groups/G in GLOB.groups)
		options["[G.id]: [G.name]"] = G
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No groups to delete.")
		return
	}
	var/choice = tgui_input_list(user, "Delete Group", "Select a group to delete", options)
	var/datum/groups/G = options[choice]
	if (!G) return
	src.delete_group(G)
	save_all_groups()
	to_chat(user, "<span class='notice'>Group deleted.")

/datum/component/about_me/proc/delete_group(var/datum/groups/G)
	if (!G || !(G in GLOB.groups)) return
	GLOB.groups -= G

/datum/component/about_me/proc/prompt_add_member_to_group(mob/user)
	// Prompt user to select group and add member
	var/list/group_opts = list()
	for (var/datum/groups/G in GLOB.groups)
		group_opts["[G.id]: [G.name]"] = G
	if (!length(group_opts)) {
		to_chat(user, "<span class='warning'>No groups found.")
		return
	}
	var/group_choice = tgui_input_list(user, "Add Member", "Select a group", group_opts)
	var/datum/groups/G = group_opts[group_choice]
	if (!G) return
	var/ckey = tgui_input_text(user, "Add Member", "Enter member ckey?")
	if (!ckey) return
	src.add_member_to_group(G, ckey)
	save_all_groups()
	to_chat(user, "<span class='notice'>Member added to group.")

/datum/component/about_me/proc/add_member_to_group(var/datum/groups/G, var/ckey)
	if (!G || !ckey) return
	if (!(ckey in G.members))
		G.members += ckey

/datum/component/about_me/proc/prompt_remove_member_from_group(mob/user)
	var/list/group_opts = list()
	for (var/datum/groups/G in GLOB.groups)
		group_opts["[G.id]: [G.name]"] = G
	if (!length(group_opts)) {
		to_chat(user, "<span class='warning'>No groups found.")
		return
	}
	var/group_choice = tgui_input_list(user, "Remove Member", "Select a group", group_opts)
	var/datum/groups/G = group_opts[group_choice]
	if (!G) return
	var/ckey = tgui_input_text(user, "Remove Member", "Enter member ckey?")
	if (!ckey) return
	src.remove_member_from_group(G, ckey)
	save_all_groups()
	to_chat(user, "<span class='notice'>Member removed from group.")

/datum/component/about_me/proc/remove_member_from_group(var/datum/groups/G, var/ckey)
	if (!G || !ckey) return
	G.members -= ckey

/datum/component/about_me/proc/prompt_make_group_leader(mob/user)
	var/list/group_opts = list()
	for (var/datum/groups/G in GLOB.groups)
		group_opts["[G.id]: [G.name]"] = G
	if (!length(group_opts)) {
		to_chat(user, "<span class='warning'>No groups found.")
		return
	}
	var/group_choice = tgui_input_list(user, "Make Leader", "Select a group", group_opts)
	var/datum/groups/G = group_opts[group_choice]
	if (!G) return
	var/ckey = tgui_input_text(user, "Make Leader", "Enter leader ckey?")
	if (!ckey) return
	src.make_group_leader(G, ckey)
	save_all_groups()
	to_chat(user, "<span class='notice'>New leader set for group.")

/datum/component/about_me/proc/make_group_leader(var/datum/groups/G, var/ckey)
	if (!G || !ckey) return
	if (!(ckey in G.members))
		G.members += ckey
	G.leader_ckey = ckey

/datum/component/about_me/proc/prompt_add_group_tag(mob/user)
	var/list/group_opts = list()
	for (var/datum/groups/G in GLOB.groups)
		group_opts["[G.id]: [G.name]"] = G
	if (!length(group_opts)) {
		to_chat(user, "<span class='warning'>No groups found.")
		return
	}
	var/group_choice = tgui_input_list(user, "Add Tag", "Select a group", group_opts)
	var/datum/groups/G = group_opts[group_choice]
	if (!G) return
	var/tag = tgui_input_text(user, "Add Tag", "Enter tag?")
	if (!tag) return
	src.add_group_tag(G, tag)
	save_all_groups()
	to_chat(user, "<span class='notice'>Tag added to group.")

/datum/component/about_me/proc/add_group_tag(var/datum/groups/G, var/tag)
	if (!G || !tag) return
	if (!islist(G.tags)) G.tags = list()
	if (!(tag in G.tags))
		G.tags += tag

/datum/component/about_me/proc/prompt_remove_group_tag(mob/user)
	var/list/group_opts = list()
	for (var/datum/groups/G in GLOB.groups)
		group_opts["[G.id]: [G.name]"] = G
	if (!length(group_opts)) {
		to_chat(user, "<span class='warning'>No groups found.")
		return
	}
	var/group_choice = tgui_input_list(user, "Remove Tag", "Select a group", group_opts)
	var/datum/groups/G = group_opts[group_choice]
	if (!G) return
	var/tag = tgui_input_text(user, "Remove Tag", "Enter tag to remove?")
	if (!tag) return
	src.remove_group_tag(G, tag)
	save_all_groups()
	to_chat(user, "<span class='notice'>Tag removed from group.")

/datum/component/about_me/proc/remove_group_tag(var/datum/groups/G, var/tag)
	if (!G || !tag) return
	if (tag in G.tags)
		G.tags -= tag


