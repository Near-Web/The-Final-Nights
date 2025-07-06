// ----------
// RELATIONSHIP TOOLS (Component Procs w/ TGUI Prompts)
// ----------

/datum/component/about_me/proc/prompt_create_relationship(mob/user)
	// Prompt user for target ckey and details
	var/target_ckey = tgui_input_text(user, "Create Relationship", "Target player's ckey?")
	if (!target_ckey) return
	var/relationship_type = tgui_input_list(user, "Relationship Type", "Select type", list("Acquaintance", "Friend", "Rival", "Enemy", "Ally"))
	if (!relationship_type) relationship_type = "Acquaintance"
	var/strength = text2num(tgui_input_text(user, "Relationship Strength", "Enter strength (-100 to 100, 0 = neutral)", "0"))
	if (isnull(strength)) strength = 0
	var/name = tgui_input_text(user, "Relationship Name", "Custom relationship name (optional)")
	var/desc = tgui_input_text(user, "Relationship Description", "Description (optional)")
	var/mutual = tgui_input_list(user, "Mutual?", "Should this be mutual?", list("No", "Yes")) == "Yes"

	var/list/tags = list()
	var/tags_string = tgui_input_text(user, "Tags", "Comma-separated tags? (Optional)")
	if (tags_string && length(tags_string))
		tags = splittext(tags_string, ",")

	var/datum/relationships/R = src.create_relationship(src.owner.ckey, target_ckey, relationship_type, strength, name, desc, mutual, tags)
	if (R)
		src.group_relationships += R
		save_to_file()
		to_chat(user, "<span class='notice'>Relationship created: [R?.name]</span>")
	else
		to_chat(user, "<span class='warning'>Failed to create relationship.</span>")

/datum/component/about_me/proc/create_relationship(
	var/source_ckey,
	var/target_ckey,
	var/relationship_type = "Acquaintance",
	var/strength = 0,
	var/name = null,
	var/desc = null,
	var/mutual = FALSE,
	var/list/tags = list(),
	var/list/memories = list(),
	var/flags = 0
)
	if (!source_ckey || !target_ckey)
		return null
	var/datum/relationships/R = new()
	R.source_ckey = source_ckey
	R.target_ckey = target_ckey
	R.relationship_type = relationship_type
	R.strength = clamp(strength, -100, 100)
	R.name = name || "[relationship_type] with [target_ckey]"
	R.desc = desc || "A [relationship_type] between [source_ckey] and [target_ckey]."
	R.mutual = mutual
	R.tags = tags.Copy()
	R.rel_memories = list()
	R.flags = flags
	return R

/datum/component/about_me/proc/prompt_edit_relationship(mob/user)
	// Prompt user to select and edit a relationship
	var/list/options = list()
	for (var/datum/relationships/R in src.group_relationships)
		options["[R.id]: [R.name] ([R.relationship_type])"] = R
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No relationships to edit.</span>")
		return
	}
	var/choice = tgui_input_list(user, "Edit Relationship", "Select a relationship to edit", options)
	var/datum/relationships/R = options[choice]
	if (!R) return

	var/name = tgui_input_text(user, "Edit Relationship", "New name? (leave blank to keep)", R.name)
	var/desc = tgui_input_text(user, "Edit Relationship", "New description? (leave blank to keep)", R.desc)
	var/type = tgui_input_text(user, "Edit Relationship", "Type? (leave blank to keep)", R.relationship_type)
	var/strength = text2num(tgui_input_text(user, "Edit Relationship", "Strength (-100 to 100)? (leave blank to keep)", "[R.strength]"))

	src.edit_relationship(R, name, desc, type, strength)
	to_chat(user, "<span class='notice'>Relationship edited: [R?.name]</span>")

/datum/component/about_me/proc/edit_relationship(var/datum/relationships/R, var/name = null, var/desc = null, var/type = null, var/strength = null)
	if (!R) return
	if (name) R.name = name
	if (desc) R.desc = desc
	if (type) R.relationship_type = type
	if (!isnull(strength)) R.strength = clamp(strength, -100, 100)
	save_to_file()

/datum/component/about_me/proc/prompt_delete_relationship(mob/user)
	// Prompt user to select a relationship to delete
	var/list/options = list()
	for (var/datum/relationships/R in src.group_relationships)
		options["[R.id]: [R.name]"] = R
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No relationships to delete.")
		return
	}
	var/choice = tgui_input_list(user, "Delete Relationship", "Select a relationship to delete", options)
	var/datum/relationships/R = options[choice]
	if (!R) return
	src.delete_relationship(R)
	to_chat(user, "<span class='notice'>Relationship deleted.")

/datum/component/about_me/proc/delete_relationship(var/datum/relationships/R)
	if (!R) return
	src.group_relationships -= R
	save_to_file()

/datum/component/about_me/proc/prompt_toggle_relationship_visibility(mob/user)
	// Prompt user to toggle visibility
	var/list/options = list()
	for (var/datum/relationships/R in src.group_relationships)
		options["[R.id]: [R.name]"] = R
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No relationships to toggle.")
		return
	}
	var/choice = tgui_input_list(user, "Toggle Visibility", "Select a relationship", options)
	var/datum/relationships/R = options[choice]
	if (!R) return
	src.toggle_relationship_visibility(R)
	to_chat(user, "<span class='notice'>Visibility toggled for relationship.")

/datum/component/about_me/proc/toggle_relationship_visibility(var/datum/relationships/R)
	if (!R) return
	R.visible = !R.visible
	save_to_file()

/datum/component/about_me/proc/prompt_add_relationship_tag(mob/user)
	// Prompt user to select relationship and tag
	var/list/options = list()
	for (var/datum/relationships/R in src.group_relationships)
		options["[R.id]: [R.name]"] = R
	if (!length(options)) {
		to_chat(user, "<span class='warning'>No relationships to tag.")
		return
	}
	var/choice = tgui_input_list(user, "Tag Relationship", "Select a relationship to tag", options)
	var/datum/relationships/R = options[choice]
	if (!R) return
	var/tag = tgui_input_text(user, "Tag Relationship", "Enter tag")
	if (!tag) return
	src.add_relationship_tag(R, tag)
	to_chat(user, "<span class='notice'>Tag added to relationship.")

/datum/component/about_me/proc/add_relationship_tag(var/datum/relationships/R, var/tag)
	if (!R || !tag) return
	if (!islist(R.tags)) R.tags = list()
	if (!(tag in R.tags))
		R.tags += tag
	save_to_file()
