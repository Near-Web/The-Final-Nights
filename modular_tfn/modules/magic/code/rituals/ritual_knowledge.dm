#define VV_HK_GIVE_RITUAL "give_ritual"
#define VV_HK_REMOVE_RITUAL "remove_ritual"

/**
 * # Ritual Knowledge
 *
 * The datums that allow magic users to progress and learn new rituals.
 *
 * Ritual Knowledge datums are not singletons - they are instantiated as they
 * are given to magic users, and deleted if the discipline is removed.
 *
 */
/datum/ritual_knowledge
	/// Name of the knowledge, shown to the magic user.
	var/name = "Basic knowledge"
	/// Description of the knowledge, shown to the magic user. Describes what it unlocks / does.
	var/desc = "Basic knowledge of forbidden arts."
	/// What's shown to the magic user when the knowledge is acquired
	var/gain_text
	/// The abstract parent type of the knowledge, used in determine mutual exclusivity in some cases
	var/datum/ritual_knowledge/abstract_parent_type = /datum/ritual_knowledge
	/// Assoc list of [typepaths we need] to [amount needed].
	/// If set, this knowledge allows the magic user to do a ritual on a transmutation rune with the components set.
	/// If one of the items in the list is a list, it's treated as 'any of these items will work'
	var/list/required_atoms
	/// Paired with above. If set, the resulting spawned atoms upon ritual completion.
	var/list/result_atoms = list()
	/// If set, required_atoms checks for these *exact* types and doesn't allow them to be ingredients.
	var/list/banned_atom_types = list()
	///If this is considered starting knowledge, TRUE if yes
	var/is_starting_knowledge = FALSE

/datum/ritual_knowledge/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_RITUAL, "Give Ritual")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_RITUAL, "Remove Ritual")

/datum/ritual_knowledge/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_GIVE_RITUAL])
		if(!check_rights(R_ADMIN))
			return
		CALLBACK(src, PROC_REF(admin_ritual_to_give), usr)
	if(href_list[VV_HK_REMOVE_RITUAL])
		if(!check_rights(R_ADMIN))
			return
		CALLBACK(src, PROC_REF(admin_ritual_to_remove), usr)

/datum/ritual_knowledge/proc/admin_ritual_to_give()
	return

/datum/ritual_knowledge/proc/admin_ritual_to_remove()
	return

/**
 * Get a list of all rituals this magic user can invoke on a rune.
 * Iterates over all of our knowledge and, if we can invoke it, adds it to our list.
 *
 * Returns an associated list of [knowledge name] to [knowledge datum] sorted by knowledge priority.
 */
/mob/living/carbon/human/proc/get_rituals()
	var/list/rituals = list()

	for(var/knowledge_index in researched_knowledge)
		var/datum/ritual_knowledge/knowledge = researched_knowledge[knowledge_index]
		if(!knowledge.can_be_invoked(src))
			continue
		rituals[knowledge.name] = knowledge

	return sortTim(rituals, GLOBAL_PROC_REF(cmp_typepaths_asc), associative = TRUE)


/** Called when the knowledge is first researched.
 * This is only ever called once per magic user.
 *
 * Arguments
 * * user - The magic user who researched something
 */
/datum/ritual_knowledge/proc/on_research(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(gain_text)
		to_chat(user, span_warning("[gain_text]"))
	on_gain(user)

/**
 * Called when the knowledge is applied to a mob.
 * This can be called multiple times per magic user,
 * in the case of bodyswap shenanigans.
 *
 * Arguments
 * * user - the magic user which we're applying things to
 */
/datum/ritual_knowledge/proc/on_gain(mob/user)
	return

/**
 * Called when the knowledge is removed from a mob,
 * either due to a magic user being de-magic user'd or bodyswap memery.
 *
 * Arguments
 * * user - the magic user which we're removing things from
 */
/datum/ritual_knowledge/proc/on_lose(mob/user)
	return

/**
 * Determines if a magic user can actually attempt to invoke the knowledge as a ritual.
 * By default, we can only invoke knowledge with rituals associated.
 *
 * Return TRUE to have the ritual show up in the rituals list, FALSE otherwise.
 */
/datum/ritual_knowledge/proc/can_be_invoked(mob/living/carbon/human)
	return !!LAZYLEN(required_atoms)

/**
 * Special check for rituals.
 * Called before any of the required atoms are checked.
 *
 * If you are adding a more complex summoning,
 * or something that requires a special check
 * that parses through all the atoms,
 * you should override this.
 *
 * Arguments
 * * user - the mob doing the ritual
 * * atoms - a list of all atoms being checked in the ritual.
 * * selected_atoms - an empty list(!) instance passed in by the ritual. You can add atoms to it in this proc.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual will continue, or FALSE, if the ritual is skipped / cancelled
 */
/datum/ritual_knowledge/proc/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return TRUE

/**
 * Parses specific items into a more readble form.
 * Can be overriden by knoweldge subtypes.
 */
/datum/ritual_knowledge/proc/parse_required_item(atom/item_path, number_of_things)
	// If we need a human, there is a high likelihood we actually need a (dead) body
	if(ispath(item_path, /mob/living/carbon/human))
		return "bod[number_of_things > 1 ? "ies" : "y"]"
	if(ispath(item_path, /mob/living))
		return "carcass[number_of_things > 1 ? "es" : ""] of any kind"
	return "[initial(item_path.name)]\s"
/**
 * Called whenever the knowledge's associated ritual is completed successfully.
 *
 * Creates atoms from types in result_atoms.
 * Override this if you want something else to happen.
 * This CAN sleep, such as for summoning rituals which poll for ghosts.
 *
 * Arguments
 * * user - the mob who did the ritual
 * * selected_atoms - an list of atoms chosen as a part of this ritual.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual should cleanup afterwards, or FALSE, to avoid calling cleanup after.
 */
/datum/ritual_knowledge/proc/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	if(!length(result_atoms))
		return FALSE
	return TRUE

/**
 * Called after on_finished_recipe returns TRUE
 * and a ritual was successfully completed.
 *
 * Goes through and cleans up (deletes)
 * all atoms in the selected_atoms list.
 *
 * Remove atoms from the selected_atoms
 * (either in this proc or in on_finished_recipe)
 * to NOT have certain atoms deleted on cleanup.
 *
 * Arguments
 * * selected_atoms - a list of all atoms we intend on destroying.
 */
/datum/ritual_knowledge/proc/cleanup_atoms(list/selected_atoms)
	SHOULD_CALL_PARENT(TRUE)

	for(var/atom/sacrificed as anything in selected_atoms)
		if(isliving(sacrificed))
			continue

		selected_atoms -= sacrificed
		qdel(sacrificed)


#undef VV_HK_GIVE_RITUAL
#undef VV_HK_REMOVE_RITUAL
