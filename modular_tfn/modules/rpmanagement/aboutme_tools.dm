/datum/component/about_me/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	// ------ Memory Actions ------
	if (action == "create_memory")
		src.prompt_create_memory(ui.user)
		return TRUE

	if (action == "edit_memory")
		src.prompt_edit_memory(ui.user)
		return TRUE

	if (action == "delete_memory")
		src.prompt_delete_memory(ui.user)
		return TRUE

	if (action == "tag_memory")
		src.prompt_tag_memory(ui.user)
		return TRUE

	if (action == "attach_memory_to_relationship")
		src.prompt_attach_memory_to_relationship(ui.user)
		return TRUE

	if (action == "attach_memory_to_group")
		src.prompt_attach_memory_to_group(ui.user)
		return TRUE

	// ------ Group Actions ------
	if (action == "create_group")
		src.prompt_create_group(ui.user)
		return TRUE

	if (action == "edit_group")
		src.prompt_edit_group(ui.user)
		return TRUE

	if (action == "delete_group")
		src.prompt_delete_group(ui.user)
		return TRUE

	if (action == "add_member_to_group")
		src.prompt_add_member_to_group(ui.user)
		return TRUE

	if (action == "remove_member_from_group")
		src.prompt_remove_member_from_group(ui.user)
		return TRUE

	if (action == "make_group_leader")
		src.prompt_make_group_leader(ui.user)
		return TRUE

	if (action == "add_group_tag")
		src.prompt_add_group_tag(ui.user)
		return TRUE

	if (action == "remove_group_tag")
		src.prompt_remove_group_tag(ui.user)
		return TRUE

	// ------ Relationship Actions ------
	if (action == "create_relationship")
		src.prompt_create_relationship(ui.user)
		return TRUE

	if (action == "edit_relationship")
		src.prompt_edit_relationship(ui.user)
		return TRUE

	if (action == "delete_relationship")
		src.prompt_delete_relationship(ui.user)
		return TRUE

	if (action == "toggle_relationship_visibility")
		src.prompt_toggle_relationship_visibility(ui.user)
		return TRUE

	if (action == "add_relationship_tag")
		src.prompt_add_relationship_tag(ui.user)
		return TRUE

	// ------ Chronicle Actions ------
	if (action == "create_chronicle_entry")
		src.prompt_create_chronicle_entry(ui.user)
		return TRUE

	if (action == "edit_chronicle_entry")
		src.prompt_edit_chronicle_entry(ui.user)
		return TRUE

	if (action == "delete_chronicle_entry")
		src.prompt_delete_chronicle_entry(ui.user)
		return TRUE

	if (action == "attach_memory_to_chronicle")
		src.prompt_attach_memory_to_chronicle(ui.user)
		return TRUE


