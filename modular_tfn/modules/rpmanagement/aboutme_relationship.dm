// ================================
// about_me Component - Relationship Tools
// ================================

// Create a personal relationship
/datum/component/about_me/proc/create_relationship()
	set name = "Create Relationship"
	set desc = "Create a relationship with another character."

	var/target_ckey = input(owner, "Enter target ckey:", "Create Relationship") as text
	if (!target_ckey) return

	var/type = input(owner, "Relationship type:", "Create Relationship") as null|anything in list("friend", "enemy", "acquaintance", "rival")
	if (!type) return

	var/strength = input(owner, "Strength (-100 to 100):", "Create Relationship") as num
	var/name = input(owner, "Optional name:", "Create Relationship") as null|text
	var/desc = input(owner, "Optional description:", "Create Relationship") as null|text

	var/datum/relationships/R = GenerateRelationship(
		source_ckey = owner.ckey,
		target_ckey = target_ckey,
		relationship_type = type,
		strength = clamp(strength, -100, 100),
		name = name,
		desc = desc,
		mutual = FALSE
	)

	if (R)
		group_relationships += R
		save_to_file()
		to_chat(owner, "<span class='notice'>You created a relationship with [target_ckey]: [R.name]</span>")


// Edit an existing personal relationship
/datum/component/about_me/proc/edit_relationship(var/id)
	if (!id || !length(group_relationships)) return

	for (var/datum/relationships/R in group_relationships)
		if (R.id == id)
			var/name = input(owner, "Edit name:", "", R.name) as null|text
			var/desc = input(owner, "Edit description:", "", R.desc) as null|text
			var/type = input(owner, "Edit type:", "", R.relationship_type) as null|anything in list("friend", "enemy", "acquaintance", "rival")
			var/strength = input(owner, "Edit strength:", "", R.strength) as num

			if (name) R.name = name
			if (desc) R.desc = desc
			if (type) R.relationship_type = type
			R.strength = clamp(strength, -100, 100)

			save_to_file()
			to_chat(owner, "<span class='notice'>Relationship '[R.name]' updated.</span>")
			return


// Delete a personal relationship
/datum/component/about_me/proc/delete_relationship(var/id)
	if (!id || !length(group_relationships)) return

	for (var/datum/relationships/R in group_relationships)
		if (R.id == id)
			group_relationships -= R
			save_to_file()
			to_chat(owner, "<span class='notice'>Relationship '[R.name]' deleted.</span>")
			return


// Get formatted data for UI use
/datum/component/about_me/proc/get_group_relationships()
	var/list/result = list()
	for (var/datum/relationships/R in group_relationships)
		result += list(list(
			"id" = R.id,
			"name" = R.name,
			"relationship_type" = R.relationship_type,
			"strength" = R.strength,
			"desc" = R.desc,
			"tags" = R.tags.Copy(),
			"visible" = R.visible,
			"mutual" = R.mutual,
			"source_ckey" = R.source_ckey,
			"target_ckey" = R.target_ckey,
			"flags" = R.flags
		))
	return result

/datum/component/about_me/proc/FindRelationshipByTarget(target_ckey)
	for (var/datum/relationships/R in group_relationships)
		if (R.target_ckey == target_ckey)
			return R
	return null
