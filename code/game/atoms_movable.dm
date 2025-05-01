/atom/movable
	layer = OBJ_LAYER
	glide_size = 8
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE

	var/last_move = null
	var/last_move_time = 0
	var/anchored = FALSE
	var/move_resist = MOVE_RESIST_DEFAULT
	var/move_force = MOVE_FORCE_DEFAULT
	var/pull_force = PULL_FORCE_DEFAULT
	var/datum/thrownthing/throwing = null
	var/throw_speed = 2 //How many tiles to move per ds when being thrown. Float values are fully supported
	var/throw_range = 7
	///Max range this atom can be thrown via telekinesis
	var/tk_throw_range = 1
	var/mob/pulledby = null
	var/initial_language_holder = /datum/language_holder
	var/datum/language_holder/language_holder	// Mindless mobs and objects need language too, some times. Mind holder takes prescedence.
	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_whisper = "whispers"
	var/verb_sing = "sings"
	var/verb_yell = "yells"
	var/speech_span
	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5
	/// Things we can pass through while moving. If any of this matches the thing we're trying to pass's [pass_flags_self], then we can pass through.
	var/pass_flags = NONE
	/// If false makes [CanPass][/atom/proc/CanPass] call [CanPassThrough][/atom/movable/proc/CanPassThrough] on this type instead of using default behaviour
	var/generic_canpass = TRUE
	///0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move
	var/moving_diagonally = 0
	///attempt to resume grab after moving instead of before.
	var/atom/movable/moving_from_pull
	///Holds information about any movement loops currently running/waiting to run on the movable. Lazy, will be null if nothing's going on
	var/datum/movement_packet/move_packet
	var/datum/forced_movement/force_moving = null //handled soley by forced_movement.dm
	/**
	 * an associative lazylist of relevant nested contents by "channel", the list is of the form: list(channel = list(important nested contents of that type))
	 * each channel has a specific purpose and is meant to replace potentially expensive nested contents iteration.
	 * do NOT add channels to this for little reason as it can add considerable memory usage.
	 */
	var/list/important_recursive_contents
	///contains every client mob corresponding to every client eye in this container. lazily updated by SSparallax and is sparse:
	///only the last container of a client eye has this list assuming no movement since SSparallax's last fire
	var/list/client_mobs_in_contents

	/// String representing the spatial grid groups we want to be held in.
	/// acts as a key to the list of spatial grid contents types we exist in via SSspatial_grid.spatial_grid_categories.
	/// We do it like this to prevent people trying to mutate them and to save memory on holding the lists ourselves
	var/spatial_grid_key

	/**
	  * In case you have multiple types, you automatically use the most useful one.
	  * IE: Skating on ice, flippers on water, flying over chasm/space, etc.
	  * I reccomend you use the movetype_handler system and not modify this directly, especially for living mobs.
	  */
	var/movement_type = GROUND

	var/atom/movable/pulling
	var/grab_state = 0
	var/throwforce = 0
	var/datum/component/orbiter/orbiting

	///is the mob currently ascending or descending through z levels?
	var/currently_z_moving

	///Last location of the atom for demo recording purposes
	var/atom/demo_last_loc

	/// Either FALSE, [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = FALSE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/emissive_blocker/em_block

	///Used for the calculate_adjacencies proc for icon smoothing.
	var/can_be_unanchored = FALSE

	///Lazylist to keep track on the sources of illumination.
	var/list/affected_dynamic_lights
	///Highest-intensity light affecting us, which determines our visibility.
	var/affecting_dynamic_lumi = 0

	/// Whether this atom should have its dir automatically changed when it moves. Setting this to FALSE allows for things such as directional windows to retain dir on moving without snowflake code all of the place.
	var/set_dir_on_move = TRUE


/atom/movable/Initialize(mapload)
	. = ..()
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			var/mutable_appearance/gen_emissive_blocker = mutable_appearance(icon, icon_state, EMISSIVE_BLOCKER_LAYER, EMISSIVE_BLOCKER_PLANE)
			gen_emissive_blocker.dir = dir
			gen_emissive_blocker.alpha = alpha
			gen_emissive_blocker.appearance_flags |= appearance_flags
			add_overlay(list(gen_emissive_blocker))
		if(EMISSIVE_BLOCK_UNIQUE)
			render_target = ref(src)
			em_block = new(src, render_target)
			add_overlay(list(em_block))
	if(opacity)
		AddElement(/datum/element/light_blocking)
	switch(light_system)
		if(MOVABLE_LIGHT)
			AddComponent(/datum/component/overlay_lighting)
		if(MOVABLE_LIGHT_DIRECTIONAL)
			AddComponent(/datum/component/overlay_lighting, is_directional = TRUE)


/atom/movable/Destroy(force)
	QDEL_NULL(proximity_monitor)
	QDEL_NULL(language_holder)
	QDEL_NULL(em_block)

	unbuckle_all_mobs(force = TRUE)

	if(loc)
		//Restore air flow if we were blocking it (movables with ATMOS_PASS_PROC will need to do this manually if necessary)
		loc.handle_atom_del(src)

	if(opacity)
		RemoveElement(/datum/element/light_blocking)

	invisibility = INVISIBILITY_ABSTRACT

	if(pulledby)
		pulledby.stop_pulling()

	if(orbiting)
		orbiting.end_orbit(src)
		orbiting = null

	. = ..()

	for(var/movable_content in contents)
		qdel(movable_content)

	LAZYCLEARLIST(client_mobs_in_contents)

	moveToNullspace()

	vis_contents.Cut()

/atom/movable/proc/update_emissive_block()
	if(!blocks_emissive)
		return
	else if (blocks_emissive == EMISSIVE_BLOCK_GENERIC)
		var/mutable_appearance/gen_emissive_blocker = mutable_appearance(icon, icon_state, EMISSIVE_BLOCKER_LAYER, EMISSIVE_BLOCKER_PLANE)
		gen_emissive_blocker.dir = dir
		gen_emissive_blocker.alpha = alpha
		gen_emissive_blocker.appearance_flags |= appearance_flags
		return gen_emissive_blocker
	else if(blocks_emissive == EMISSIVE_BLOCK_UNIQUE)
		if(!em_block)
			render_target = ref(src)
			em_block = new(src, render_target)
		return em_block

/atom/movable/update_overlays()
	. = ..()
	. += update_emissive_block()

/atom/movable/proc/onZImpact(turf/impacted_turf, levels, message = TRUE)
	if(message)
		visible_message("<span class='danger'>[src] crashes into [impacted_turf]!</span>")
	var/atom/highest = impacted_turf
	for(var/atom/hurt_atom as anything in impacted_turf.contents)
		if(!hurt_atom.density)
			continue
		if(isobj(A) || ismob(A))
			if(A.layer > highest.layer)
				highest = A
	INVOKE_ASYNC(src, PROC_REF(SpinAnimation), 5, 2)
	return TRUE

/*
 * The core multi-z movement proc. Used to move a movable through z levels.
 * If target is null, it'll be determined by the can_z_move proc, which can potentially return null if
 * conditions aren't met (see z_move_flags defines in __DEFINES/movement.dm for info) or if dir isn't set.
 * Bear in mind you don't need to set both target and dir when calling this proc, but at least one or two.
 * This will set the currently_z_moving to CURRENTLY_Z_MOVING_GENERIC if unset, and then clear it after
 * Forcemove().
 *
 *
 * Args:
 * * dir: the direction to go, UP or DOWN, only relevant if target is null.
 * * target: The target turf to move the src to. Set by can_z_move() if null.
 * * z_move_flags: bitflags used for various checks in both this proc and can_z_move(). See __DEFINES/movement.dm.
 */
/atom/movable/proc/zMove(dir, turf/target, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(!target)
		target = can_z_move(dir, get_turf(src), null, z_move_flags)
		if(!target)
			set_currently_z_moving(FALSE, TRUE)
			return FALSE
	var/list/moving_movs = get_z_move_affected(z_move_flags)

	for(var/atom/movable/movable as anything in moving_movs)
		movable.currently_z_moving = currently_z_moving || CURRENTLY_Z_MOVING_GENERIC
		movable.forceMove(target)
		movable.set_currently_z_moving(FALSE, TRUE)
	// This is run after ALL movables have been moved, so pulls don't get broken unless they are actually out of range.
	if(z_move_flags & ZMOVE_CHECK_PULLS)
		for(var/atom/movable/moved_mov as anything in moving_movs)
			if(z_move_flags & ZMOVE_CHECK_PULLEDBY && moved_mov.pulledby && (moved_mov.z != moved_mov.pulledby.z || get_dist(moved_mov, moved_mov.pulledby) > 1))
				moved_mov.pulledby.stop_pulling()
			if(z_move_flags & ZMOVE_CHECK_PULLING)
				moved_mov.check_pulling(TRUE)
	return TRUE

/// Returns a list of movables that should also be affected when src moves through zlevels, and src.
/atom/movable/proc/get_z_move_affected(z_move_flags)
	. = list(src)
	if(buckled_mobs)
		. |= buckled_mobs
	if(!(z_move_flags & ZMOVE_INCLUDE_PULLED))
		return
	for(var/mob/living/buckled as anything in buckled_mobs)
		if(buckled.pulling)
			. |= buckled.pulling
	if(pulling)
		. |= pulling

/**
 * Checks if the destination turf is elegible for z movement from the start turf to a given direction and returns it if so.
 * Args:
 * * direction: the direction to go, UP or DOWN, only relevant if target is null.
 * * start: Each destination has a starting point on the other end. This is it. Most of the times the location of the source.
 * * z_move_flags: bitflags used for various checks. See __DEFINES/movement.dm.
 * * rider: A living mob in control of the movable. Only non-null when a mob is riding a vehicle through z-levels.
 */
/atom/movable/proc/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS, mob/living/rider)
	if(!start)
		start = get_turf(src)
		if(!start)
			return FALSE
	if(!direction)
		if(!destination)
			return FALSE
		direction = get_dir_multiz(start, destination)
	if(direction != UP && direction != DOWN)
		return FALSE
	if(!destination)
		destination = get_step_multiz(start, direction)
		if(!destination)
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(rider || src, "<span class='warning'>There's nowhere to go in that direction!</span>")
			return FALSE
	if(z_move_flags & ZMOVE_FALL_CHECKS && (throwing || (movement_type & (FLYING|FLOATING)) || !has_gravity(start)))
		return FALSE
	if(z_move_flags & ZMOVE_CAN_FLY_CHECKS && !(movement_type & (FLYING|FLOATING)) && has_gravity(start))
		if(z_move_flags & ZMOVE_FEEDBACK)
			if(rider)
				to_chat(rider, "<span class='notice'>[src] is is not capable of flight.<span>")
			else
				to_chat(src, "<span class='notice'>You are not Superman.<span>")
	if(!(z_move_flags & ZMOVE_IGNORE_OBSTACLES) && !(start.zPassOut(src, direction, destination) && destination.zPassIn(src, direction, start)))
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider || src, "<span class='warning'>You couldn't move there!</span>")
		return FALSE
	return destination //used by some child types checks and zMove()

/atom/movable/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("step_x" = TRUE, "step_y" = TRUE, "step_size" = TRUE, "bounds" = TRUE)
	var/static/list/careful_edits = list("bound_x" = TRUE, "bound_y" = TRUE, "bound_width" = TRUE, "bound_height" = TRUE)
	if(banned_edits[var_name])
		return FALSE	//PLEASE no.
	if((careful_edits[var_name]) && (var_value % world.icon_size) != 0)
		return FALSE

	switch(var_name)
		if(NAMEOF(src, x))
			var/turf/T = locate(var_value, y, z)
			if(T)
				admin_teleport(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, y))
			var/turf/T = locate(x, var_value, z)
			if(T)
				admin_teleport(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, z))
			var/turf/T = locate(x, y, var_value)
			if(T)
				admin_teleport(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, loc))
			if(isatom(var_value) || isnull(var_value))
				admin_teleport(var_value)
				return TRUE
			return FALSE
		if(NAMEOF(src, anchored))
			set_anchored(var_value)
			. = TRUE
		if(NAMEOF(src, pulledby))
			set_pulledby(var_value)
			. = TRUE
		if(NAMEOF(src, glide_size))
			set_glide_size(var_value)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	return ..()


/atom/movable/proc/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	if(QDELETED(AM))
		return FALSE
	if(!(AM.can_be_pulled(src, state, force)))
		return FALSE

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		if(state == 0)
			stop_pulling()
			return FALSE
		// Are we trying to pull something we are already pulling? Then enter grab cycle and end.
		if(AM == pulling)
			setGrabState(state)
			if(istype(AM,/mob/living))
				var/mob/living/AMob = AM
				AMob.grabbedby(src)
			return TRUE
		stop_pulling()

	SEND_SIGNAL(src, COMSIG_ATOM_START_PULL, AM, state, force)

	if(AM.pulledby)
		log_combat(AM, AM.pulledby, "pulled from", src)
		AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.
	pulling = AM
	AM.set_pulledby(src)
	setGrabState(state)
	if(ismob(AM))
		var/mob/M = AM
		log_combat(src, M, "grabbed", addition="passive grab")
		if(!supress_message)
			M.visible_message("<span class='warning'>[src] grabs [M] passively.</span>", \
				"<span class='danger'>[src] grabs you passively.</span>")
	SEND_SIGNAL(pulling, COMSIG_MOVABLE_PULLED)
	return TRUE

/atom/movable/proc/stop_pulling()
	if(pulling)
		pulling.set_pulledby(null)
		setGrabState(GRAB_PASSIVE)
		SEND_SIGNAL(pulling, COMSIG_MOVABLE_NO_LONGER_PULLED)
		pulling = null


///Reports the event of the change in value of the pulledby variable.
/atom/movable/proc/set_pulledby(new_pulledby)
	if(new_pulledby == pulledby)
		return FALSE //null signals there was a change, be sure to return FALSE if none happened here.
	. = pulledby
	pulledby = new_pulledby


/atom/movable/proc/Move_Pulled(atom/A)
	if(!pulling)
		return FALSE
	if(pulling.anchored || pulling.move_resist > move_force || !pulling.Adjacent(src))
		stop_pulling()
		return FALSE
	if(isliving(pulling))
		var/mob/living/L = pulling
		if(L.buckled && L.buckled.buckle_prevents_pull) //if they're buckled to something that disallows pulling, prevent it
			stop_pulling()
			return FALSE
	if(A == loc && pulling.density)
		return FALSE
	var/move_dir = get_dir(pulling.loc, A)
	if(!Process_Spacemove(move_dir))
		return FALSE
	pulling.Move(get_step(pulling.loc, move_dir), move_dir, glide_size)
	return TRUE

/mob/living/Move_Pulled(atom/A)
	. = ..()
	if(!. || !isliving(A))
		return
	var/mob/living/L = A
	set_pull_offsets(L, grab_state)

/**
 * Checks if the pulling and pulledby should be stopped because they're out of reach.
 * If z_allowed is TRUE, the z level of the pulling will be ignored.This is to allow things to be dragged up and down stairs.
 */
/atom/movable/proc/check_pulling(only_pulling = FALSE, z_allowed = FALSE)
	if(pulling)
		if(get_dist(src, pulling) > 1 || (z != pulling.z && !z_allowed))
			stop_pulling()
		else if(!isturf(loc))
			stop_pulling()
		else if(pulling && !isturf(pulling.loc) && pulling.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
			log_game("DEBUG:[src]'s pull on [pulling] wasn't broken despite [pulling] being in [pulling.loc]. Pull stopped manually.")
			stop_pulling()
		else if(pulling.anchored || pulling.move_resist > move_force)
			stop_pulling()
	if(!only_pulling && pulledby && moving_diagonally != FIRST_DIAG_STEP && (get_dist(src, pulledby) > 1 || z != pulledby.z)) //separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()


/atom/movable/proc/set_glide_size(target = 8)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, target)
	glide_size = target

	for(var/mob/buckled_mob as anything in buckled_mobs)
		buckled_mob.set_glide_size(target)

/**
 * meant for movement with zero side effects. only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts)
 * if you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this
 * most of the time you want forceMove()
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	var/atom/old_loc = loc
	var/direction = get_dir(old_loc, new_loc)
	loc = new_loc
	Moved(old_loc, direction)

////////////////////////////////////////
// Here's where we rewrite how byond handles movement except slightly different
// To be removed on step_ conversion
// All this work to prevent a second bump
/atom/movable/Move(atom/newloc, direct=0, glide_size_override = 0)
	. = FALSE
	if(!newloc || newloc == loc)
		return

	if(!direct)
		direct = get_dir(src, newloc)

	if(set_dir_on_move && dir != direction)
		setDir(direction)

	if(!loc.Exit(src, newloc))
		return

	if(!newloc.Enter(src, src.loc))
		return

	if (SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
		return

	// Past this is the point of no return
	var/atom/oldloc = loc
	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)
	loc = newloc
	. = TRUE
	oldloc.Exited(src, newloc)
	if(oldarea != newarea)
		oldarea.Exited(src, newloc)

	for(var/i in oldloc)
		if(i == src) // Multi tile objects
			continue
		var/atom/movable/thing = i
		thing.Uncrossed(src)

	newloc.Entered(src, oldloc)
	if(oldarea != newarea)
		newarea.Entered(src, oldloc)

	for(var/i in loc)
		if(i == src) // Multi tile objects
			continue
		var/atom/movable/thing = i
		thing.Crossed(src)

////////////////////////////////////////

/atom/movable/Move(atom/newloc, direct, glide_size_override = 0)
	var/atom/movable/pullee = pulling
	var/turf/T = loc
	if(!moving_from_pull)
		check_pulling(z_allowed = TRUE)
	if(!loc || !newloc)
		return FALSE
	var/atom/oldloc = loc
	//Early override for some cases like diagonal movement
	if(glide_size_override && glide_size != glide_size_override)
		set_glide_size(glide_size_override)

	if(loc != newloc)
		if (!(direct & (direct - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			var/first_step_dir
			// The `&& moving_diagonally` checks are so that a forceMove taking
			// place due to a Crossed, Bumped, etc. call will interrupt
			// the second half of the diagonal movement, or the second attempt
			// at a first half if step() fails because we hit something.
			if (direct & NORTH)
				if (direct & EAST)
					if (step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if (moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
				else if (direct & WEST)
					if (step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if (moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
			else if (direct & SOUTH)
				if (direct & EAST)
					if (step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if (moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
				else if (direct & WEST)
					if (step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if (moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
			if(moving_diagonally == SECOND_DIAG_STEP)
				if(!. && set_dir_on_move)
					setDir(first_step_dir)
			moving_diagonally = 0
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		set_currently_z_moving(FALSE, TRUE)
		return

	if(.)
		Moved(oldloc, direct)
	if(. && pulling && pulling == pullee && pulling != moving_from_pull) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
		else
			//puller and pullee more than one tile away or in diagonal position and whatever the pullee is pulling isn't already moving from a pull as it'll most likely result in an infinite loop a la ouroborus.
			if(!pulling.pulling?.moving_from_pull)
				var/pull_dir = get_dir(pulling, src)
				var/target_turf = current_turf

				// Pulling things down/up stairs. zMove() has flags for check_pulling and stop_pulling calls.
				// You may wonder why we're not just forcemoving the pulling movable and regrabbing it.
				// The answer is simple. forcemoving and regrabbing is ugly and breaks conga lines.
				if(pulling.z != z)
					target_turf = get_step(pulling, get_dir(pulling, current_turf))

				if(target_turf != current_turf || (moving_diagonally != SECOND_DIAG_STEP && ISDIAGONALDIR(pull_dir)) || get_dist(src, pulling) > 1)
					pulling.move_from_pull(src, target_turf, glide_size)
			check_pulling()


	//glide_size strangely enough can change mid movement animation and update correctly while the animation is playing
	//This means that if you don't override it late like this, it will just be set back by the movement update that's called when you move turfs.
	if(glide_size_override && glide_size != glide_size_override)
		set_glide_size(glide_size_override)

	last_move = direct

	if(set_dir_on_move && dir != direct)
		setDir(direct)
	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, glide_size_override)) //movement failed due to buckled mob(s)
		. = FALSE

	if(currently_z_moving)
		if(. && loc == newloc)
			var/turf/pitfall = get_turf(src)
			pitfall.zFall(src, falling_from_move = TRUE)
		else
			set_currently_z_moving(FALSE, TRUE)

/// Called when src is being moved to a target turf because another movable (puller) is moving around.
/atom/movable/proc/move_from_pull(atom/movable/puller, turf/target_turf, glide_size_override)
	moving_from_pull = puller
	Move(target_turf, get_dir(src, target_turf), glide_size_override)
	moving_from_pull = null

/**
 * Called after a successful Move(). By this point, we've already moved.
 * Arguments:
 * * old_loc is the location prior to the move. Can be null to indicate nullspace.
 * * movement_dir is the direction the movement took place. Can be NONE if it was some sort of teleport.
 * * The forced flag indicates whether this was a forced move, which skips many checks of regular movement.
 * * The old_locs is an optional argument, in case the moved movable was present in multiple locations before the movement.
 * * momentum_change represents whether this movement is due to a "new" force if TRUE or an already "existing" force if FALSE
 **/
/atom/movable/proc/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if (!inertia_moving && momentum_change)
		newtonian_move(movement_dir)
	// If we ain't moving diagonally right now, update our parallax
	// We don't do this all the time because diag movements should trigger one call to this, not two
	// Waste of cpu time, and it fucks the animate
	if (!moving_diagonally && client_mobs_in_contents)
		update_parallax_contents()

	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, movement_dir, forced, old_locs, momentum_change)

	if(old_loc)
		SEND_SIGNAL(old_loc, COMSIG_ATOM_ABSTRACT_EXITED, src, movement_dir)
	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_ABSTRACT_ENTERED, src, old_loc, old_locs)

	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(src)

	if (old_turf?.z != new_turf?.z)
		on_changed_z_level(old_turf, new_turf)

	if(HAS_SPATIAL_GRID_CONTENTS(src))
		if(old_turf && new_turf && (old_turf.z != new_turf.z \
			|| GET_SPATIAL_INDEX(old_turf.x) != GET_SPATIAL_INDEX(new_turf.x) \
			|| GET_SPATIAL_INDEX(old_turf.y) != GET_SPATIAL_INDEX(new_turf.y)))

			SSspatial_grid.exit_cell(src, old_turf)
			SSspatial_grid.enter_cell(src, new_turf)

		else if(old_turf && !new_turf)
			SSspatial_grid.exit_cell(src, old_turf)

		else if(new_turf && !old_turf)
			SSspatial_grid.enter_cell(src, new_turf)

	return TRUE

// Make sure you know what you're doing if you call this, this is intended to only be called by byond directly.
// You probably want CanPass()
/atom/movable/Cross(atom/movable/AM)
	. = TRUE
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSS, AM)
	return CanPass(AM, AM.loc, TRUE)

//oldloc = old location on atom, inserted when forceMove is called and ONLY when forceMove is called!
/atom/movable/Crossed(atom/movable/AM, oldloc)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)

/atom/movable/Uncross(atom/movable/AM, atom/newloc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_UNCROSS, AM) & COMPONENT_MOVABLE_BLOCK_UNCROSS)
		return FALSE
	if(isturf(newloc) && !CheckExit(AM, newloc))
		return FALSE

/atom/movable/Uncrossed(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNCROSSED, AM)

/atom/movable/Bump(atom/A)
	if(!A)
		CRASH("Bump was called with no argument.")
	SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, A)
	. = ..()
	if(!QDELETED(throwing))
		throwing.hit_atom(A)
		. = TRUE
		if(QDELETED(A))
			return
	bumped_atom.Bumped(src)

/atom/movable/Exited(atom/movable/gone, direction)
	. = ..()

	if(!LAZYLEN(gone.important_recursive_contents))
		return
	var/list/nested_locs = get_nested_locs(src) + src
	for(var/channel in gone.important_recursive_contents)
		for(var/atom/movable/location as anything in nested_locs)
			var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
			recursive_contents[channel] -= gone.important_recursive_contents[channel]
			switch(channel)
				if(RECURSIVE_CONTENTS_CLIENT_MOBS, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
					if(!length(recursive_contents[channel]))
						// This relies on a nice property of the linked recursive and gridmap types
						// They're defined in relation to each other, so they have the same value
						SSspatial_grid.remove_grid_awareness(location, channel)
			ASSOC_UNSETEMPTY(recursive_contents, channel)
			UNSETEMPTY(location.important_recursive_contents)

/atom/movable/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	if(!LAZYLEN(arrived.important_recursive_contents))
		return
	var/list/nested_locs = get_nested_locs(src) + src
	for(var/channel in arrived.important_recursive_contents)
		for(var/atom/movable/location as anything in nested_locs)
			LAZYINITLIST(location.important_recursive_contents)
			var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
			LAZYINITLIST(recursive_contents[channel])
			switch(channel)
				if(RECURSIVE_CONTENTS_CLIENT_MOBS, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
					if(!length(recursive_contents[channel]))
						SSspatial_grid.add_grid_awareness(location, channel)
			recursive_contents[channel] |= arrived.important_recursive_contents[channel]

///allows this movable to hear and adds itself to the important_recursive_contents list of itself and every movable loc its in
/atom/movable/proc/become_hearing_sensitive(trait_source = TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)
	if(!HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYINITLIST(location.important_recursive_contents)
		var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
		if(!length(recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
			SSspatial_grid.add_grid_awareness(location, SPATIAL_GRID_CONTENTS_TYPE_HEARING)
		recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] += list(src)

	var/turf/our_turf = get_turf(src)
	SSspatial_grid.add_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_HEARING)

/**
 * removes the hearing sensitivity channel from the important_recursive_contents list of this and all nested locs containing us if there are no more sources of the trait left
 * since RECURSIVE_CONTENTS_HEARING_SENSITIVE is also a spatial grid content type, removes us from the spatial grid if the trait is removed
 *
 * * trait_source - trait source define or ALL, if ALL, force removes hearing sensitivity. if a trait source define, removes hearing sensitivity only if the trait is removed
 */
/atom/movable/proc/lose_hearing_sensitivity(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return
	REMOVE_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)
	if(HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return

	var/turf/our_turf = get_turf(src)
	/// We get our awareness updated by the important recursive contents stuff, here we remove our membership
	SSspatial_grid.remove_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_HEARING)

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
		recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] -= src
		if(!length(recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
			SSspatial_grid.remove_grid_awareness(location, SPATIAL_GRID_CONTENTS_TYPE_HEARING)
		ASSOC_UNSETEMPTY(recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
		UNSETEMPTY(location.important_recursive_contents)

///allows this movable to know when it has "entered" another area no matter how many movable atoms its stuffed into, uses important_recursive_contents
/atom/movable/proc/become_area_sensitive(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADDASSOCLIST(location.important_recursive_contents, RECURSIVE_CONTENTS_AREA_SENSITIVE, src)
	ADD_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)

///removes the area sensitive channel from the important_recursive_contents list of this and all nested locs containing us if there are no more source of the trait left
/atom/movable/proc/lose_area_sensitivity(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		return
	REMOVE_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)
	if(HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		return

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_AREA_SENSITIVE, src)

///propogates ourselves through our nested contents, similar to other important_recursive_contents procs
///main difference is that client contents need to possibly duplicate recursive contents for the clients mob AND its eye
/mob/proc/enable_client_mobs_in_contents()
	for(var/atom/movable/movable_loc as anything in get_nested_locs(src) + src)
		LAZYINITLIST(movable_loc.important_recursive_contents)
		var/list/recursive_contents = movable_loc.important_recursive_contents // blue hedgehog velocity
		if(!length(recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]))
			SSspatial_grid.add_grid_awareness(movable_loc, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
		LAZYINITLIST(recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] |= src

	var/turf/our_turf = get_turf(src)
	/// We got our awareness updated by the important recursive contents stuff, now we add our membership
	SSspatial_grid.add_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)

///Clears the clients channel of this mob
/mob/proc/clear_important_client_contents()
	var/turf/our_turf = get_turf(src)
	SSspatial_grid.remove_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)

	for(var/atom/movable/movable_loc as anything in get_nested_locs(src) + src)
		var/list/recursive_contents = movable_loc.important_recursive_contents // blue hedgehog velocity
		recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] -= src
		if(!length(recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]))
			SSspatial_grid.remove_grid_awareness(movable_loc, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
		ASSOC_UNSETEMPTY(recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS)
		UNSETEMPTY(movable_loc.important_recursive_contents)

///called when this movable becomes the parent of a storage component that is currently being viewed by a player. uses important_recursive_contents
/atom/movable/proc/become_active_storage(datum/component/storage/component_source)
	if(!HAS_TRAIT(src, TRAIT_ACTIVE_STORAGE))
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADDASSOCLIST(location.important_recursive_contents, RECURSIVE_CONTENTS_ACTIVE_STORAGE, src)
	ADD_TRAIT(src, TRAIT_ACTIVE_STORAGE, component_source)

///called when this movable's storage component is no longer viewed by any players, unsets important_recursive_contents
/atom/movable/proc/lose_active_storage(datum/component/storage/component_source)
	if(!HAS_TRAIT(src, TRAIT_ACTIVE_STORAGE))
		return
	REMOVE_TRAIT(src, TRAIT_ACTIVE_STORAGE, component_source)
	if(HAS_TRAIT(src, TRAIT_ACTIVE_STORAGE))
		return

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_ACTIVE_STORAGE, src)

///Sets the anchored var and returns if it was sucessfully changed or not.
/atom/movable/proc/set_anchored(anchorvalue)
	SHOULD_CALL_PARENT(TRUE)
	if(anchored == anchorvalue)
		return
	. = anchored
	anchored = anchorvalue
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_ANCHORED, anchorvalue)

/// Sets the currently_z_moving variable to a new value. Used to allow some zMovement sources to have precedence over others.
/atom/movable/proc/set_currently_z_moving(new_z_moving_value, forced = FALSE)
	if(forced)
		currently_z_moving = new_z_moving_value
		return TRUE
	var/old_z_moving_value = currently_z_moving
	currently_z_moving = max(currently_z_moving, new_z_moving_value)
	return currently_z_moving > old_z_moving_value

/atom/movable/proc/forceMove(atom/destination)
	. = FALSE
	if(destination)
		. = doMove(destination)
	else
		CRASH("No valid destination passed into forceMove")

/atom/movable/proc/moveToNullspace()
	return doMove(null)

/atom/movable/proc/doMove(atom/destination)
	. = FALSE
	var/atom/oldloc = loc
	var/is_multi_tile = bound_width > world.icon_size || bound_height > world.icon_size
	if(destination)
		///zMove already handles whether a pull from another movable should be broken.
		if(pulledby && !currently_z_moving)
			pulledby.stop_pulling()
		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)

		loc = destination
		moving_diagonally = 0

		if(!same_loc)
			if(is_multi_tile && isturf(destination))
				var/list/new_locs = block(
					destination,
					locate(
						min(world.maxx, destination.x + ROUND_UP(bound_width / 32)),
						min(world.maxy, destination.y + ROUND_UP(bound_height / 32)),
						destination.z
					)
				)
				if(old_area && old_area != destarea)
					old_area.Exited(src, movement_dir)
				for(var/atom/left_loc as anything in locs - new_locs)
					left_loc.Exited(src, movement_dir)

				for(var/atom/entering_loc as anything in new_locs - locs)
					entering_loc.Entered(src, movement_dir)

				if(old_area && old_area != destarea)
					destarea.Entered(src, movement_dir)
			else
				if(oldloc)
					oldloc.Exited(src, movement_dir)
					if(old_area && old_area != destarea)
						old_area.Exited(src, movement_dir)
				destination.Entered(src, oldloc)
				if(destarea && old_area != destarea)
					destarea.Entered(src, old_area)

		Moved(oldloc, NONE, TRUE)
		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE

		if (oldloc)
			loc = null
			var/area/old_area = get_area(oldloc)
			if(is_multi_tile && isturf(oldloc))
				for(var/atom/old_loc as anything in locs)
					old_loc.Exited(src, NONE)
			else
				oldloc.Exited(src, NONE)

			if(old_area)
				old_area.Exited(src, null)
		loc = null

/atom/movable/proc/onTransitZ(old_z,new_z)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED, old_z, new_z)
	for (var/item in src) // Notify contents of Z-transition. This can be overridden IF we know the items contents do not care.
		var/atom/movable/AM = item
		AM.onTransitZ(old_z,new_z)

/**
 * Called whenever an object moves and by mobs when they attempt to move themselves through space
 * And when an object or action applies a force on src, see [newtonian_move][/atom/movable/proc/newtonian_move]
 *
 * Return FALSE to have src start/keep drifting in a no-grav area and TRUE to stop/not start drifting
 *
 * Mobs should return 1 if they should be able to move of their own volition, see [/client/proc/Move]
 *
 * Arguments:
 * * movement_dir - 0 when stopping or any dir when trying to move
 */
/atom/movable/proc/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(has_gravity())
		return TRUE

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_SPACEMOVE, movement_dir, continuous_move) & COMSIG_MOVABLE_STOP_SPACEMOVE)
		return TRUE

	if(pulledby && (pulledby.pulledby != src || moving_from_pull))
		return TRUE

	if(throwing)
		return TRUE

	if(!isturf(loc))
		return TRUE

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return TRUE

	return FALSE


/// Only moves the object if it's under no gravity
/atom/movable/proc/newtonian_move(direction)
	if(!isturf(loc) || Process_Spacemove(0))
		inertia_dir = 0
		return FALSE

	inertia_dir = direction
	if(!direction)
		return TRUE
	inertia_last_loc = loc
	SSspacedrift.processing[src] = src
	return TRUE

/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	set waitfor = FALSE
	var/hitpush = TRUE
	var/impact_signal = SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
	if(impact_signal & COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH)
		hitpush = FALSE // hacky, tie this to something else or a proper workaround later

	if(!(impact_signal && (impact_signal & COMPONENT_MOVABLE_IMPACT_NEVERMIND))) // in case a signal interceptor broke or deleted the thing before we could process our hit
		return hit_atom.hitby(src, throwingdatum=throwingdatum, hitpush=hitpush)

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked, datum/thrownthing/throwingdatum)
	if(!anchored && hitpush && (!throwingdatum || (throwingdatum.force >= (move_resist * MOVE_FORCE_PUSH_RATIO))))
		step(src, AM.dir)
	..()

/atom/movable/proc/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE)
	if((force < (move_resist * MOVE_FORCE_THROW_RATIO)) || (move_resist == INFINITY))
		return
	return throw_at(target, range, speed, thrower, spin, diagonals_first, callback, force, gentle)

///If this returns FALSE then callback will not be called.
/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE, quickstart = TRUE)
	. = FALSE

	if(QDELETED(src))
		return

	if (!target || speed <= 0)
		return

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_THROW, args) & COMPONENT_CANCEL_THROW)
		return

	if (pulledby)
		pulledby.stop_pulling()

	//They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if (thrower && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag*2)
		var/user_momentum = thrower.cached_multiplicative_slowdown
		if (!user_momentum) //no movement_delay, this means they move once per byond tick, lets calculate from that instead.
			user_momentum = world.tick_lag

		user_momentum = 1 / user_momentum // convert from ds to the tiles per ds that throw_at uses.

		if (get_dir(thrower, target) & last_move)
			user_momentum = user_momentum //basically a noop, but needed
		else if (get_dir(target, thrower) & last_move)
			user_momentum = -user_momentum //we are moving away from the target, lets slowdown the throw accordingly
		else
			user_momentum = 0


		if (user_momentum)
			//first lets add that momentum to range.
			range *= (user_momentum / speed) + 1
			//then lets add it to speed
			speed += user_momentum
			if (speed <= 0)
				return//no throw speed, the user was moving too fast.

	. = TRUE // No failure conditions past this point.

	var/target_zone
	if(QDELETED(thrower))
		thrower = null //Let's not pass a qdeleting reference if any.
	else
		target_zone = thrower.zone_selected

	var/datum/thrownthing/TT = new(src, target, get_turf(target), get_dir(src, target), range, speed, thrower, diagonals_first, force, gentle, callback, target_zone)

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	if (dist_x == dist_y)
		TT.pure_diagonal = 1

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx
	TT.dist_x = dist_x
	TT.dist_y = dist_y
	TT.dx = dx
	TT.dy = dy
	TT.diagonal_error = dist_x/2 - dist_y
	TT.start_time = world.time

	if(pulledby)
		pulledby.stop_pulling()
	if (quickstart && (throwing || SSthrowing.state == SS_RUNNING)) //Avoid stack overflow edgecases.
		quickstart = FALSE
	throwing = TT
	if(spin)
		SpinAnimation(5, 1)

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW, TT, spin)
	if(thrower)
		SEND_SIGNAL(thrower, COMSIG_MOB_THREW_MOVABLE, target, TT)
	SSthrowing.processing[src] = TT
	if (SSthrowing.state == SS_PAUSED && length(SSthrowing.currentrun))
		SSthrowing.currentrun[src] = TT
	if (quickstart)
		TT.tick()

/atom/movable/proc/handle_buckled_mob_movement(newloc, direct, glide_size_override)
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(buckled_mob.loc != newloc && !buckled_mob.Move(newloc, direct, glide_size_override))
			Move(buckled_mob.loc, direct)
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
			return FALSE
	return TRUE

/atom/movable/proc/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/proc/force_push(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.force_pushed(src, force, direction)
	if(!silent && .)
		visible_message("<span class='warning'>[src] forcefully pushes against [AM]!</span>", "<span class='warning'>You forcefully push against [AM]!</span>")

/atom/movable/proc/move_crush(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.move_crushed(src, force, direction)
	if(!silent && .)
		visible_message("<span class='danger'>[src] crushes past [AM]!</span>", "<span class='danger'>You crush [AM]!</span>")

/atom/movable/proc/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover in buckled_mobs)
		return TRUE

/// Returns true or false to allow src to move through the blocker, mover has final say
/atom/movable/proc/CanPassThrough(atom/blocker, turf/target, blocker_opinion)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	return blocker_opinion

/// called when this atom is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/atom/movable/proc/on_exit_storage(datum/component/storage/concrete/master_storage)
	SEND_SIGNAL(src, COMSIG_STORAGE_EXITED, master_storage)

/// called when this atom is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/atom/movable/proc/on_enter_storage(datum/component/storage/concrete/master_storage)
	SEND_SIGNAL(src, COMSIG_STORAGE_ENTERED, master_storage)

/atom/movable/proc/get_spacemove_backup()
	var/atom/movable/dense_object_backup
	for(var/A in orange(1, get_turf(src)))
		if(isarea(A))
			continue
		else if(isturf(A))
			var/turf/turf = A
			if(!turf.density)
				continue
			return turf
		else
			var/atom/movable/AM = A
			if(!AM.CanPass(src) || AM.density)
				if(AM.anchored)
					return AM
				dense_object_backup = AM
				break
	. = dense_object_backup

///called when a mob resists while inside a container that is itself inside something.
/atom/movable/proc/relay_container_resist_act(mob/living/user, obj/O)
	return


/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	if(A == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/turn_dir = 1

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
		turn_dir = prob(50) ? -1 : 1
	else if(direction & SOUTH)
		pixel_y_diff = -8
		turn_dir = prob(50) ? -1 : 1

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8
		turn_dir = -1

	var/matrix/initial_transform = matrix(transform)
	var/matrix/rotated_transform = transform.Turn(15 * turn_dir)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, transform=rotated_transform, time = 1, easing=BACK_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, transform=initial_transform, time = 2, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/atom/movable/proc/do_item_attack_animation(atom/A, visual_effect_icon, obj/item/used_item)
	var/image/I
	if(visual_effect_icon)
		I = image('icons/effects/effects.dmi', A, visual_effect_icon, A.layer + 0.1)
	else if(used_item)
		I = image(icon = used_item, loc = A, layer = A.layer + 0.1)
		I.plane = GAME_PLANE

		// Scale the icon.
		I.transform *= 0.4
		// The icon should not rotate.
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

		// Set the direction of the icon animation.
		var/direction = get_dir(src, A)
		if(direction & NORTH)
			I.pixel_y = -12
		else if(direction & SOUTH)
			I.pixel_y = 12

		if(direction & EAST)
			I.pixel_x = -14
		else if(direction & WEST)
			I.pixel_x = 14

		if(!direction) // Attacked self?!
			I.pixel_z = 16

	if(!I)
		return

	flick_overlay(I, GLOB.clients, 10)

	// And animate the attack!
	animate(I, alpha = 175, transform = matrix() * 0.75, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)
	animate(time = 1)
	animate(alpha = 0, time = 3, easing = CIRCULAR_EASING|EASE_OUT)

/atom/movable/vv_get_dropdown()
	. = ..()
	. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(src)]'>Follow</option>"
	. += "<option value='?_src_=holder;[HrefToken()];admingetmovable=[REF(src)]'>Get</option>"

/atom/movable/proc/ex_check(ex_id)
	if(!ex_id)
		return TRUE
	LAZYINITLIST(acted_explosions)
	if(ex_id in acted_explosions)
		return FALSE
	acted_explosions += ex_id
	return TRUE

/* 	Language procs
*	Unless you are doing something very specific, these are the ones you want to use.
*/

/// Gets or creates the relevant language holder. For mindless atoms, gets the local one. For atom with mind, gets the mind one.
/atom/movable/proc/get_language_holder(get_minds = TRUE)
	if(!language_holder)
		language_holder = new initial_language_holder(src)
	return language_holder

/// Grants the supplied language and sets omnitongue true.
/atom/movable/proc/grant_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_ATOM)
	var/datum/language_holder/LH = get_language_holder()
	return LH.grant_language(language, understood, spoken, source)

/// Grants every language.
/atom/movable/proc/grant_all_languages(understood = TRUE, spoken = TRUE, grant_omnitongue = TRUE, source = LANGUAGE_MIND)
	var/datum/language_holder/LH = get_language_holder()
	return LH.grant_all_languages(understood, spoken, grant_omnitongue, source)

/// Removes a single language.
/atom/movable/proc/remove_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_ALL)
	var/datum/language_holder/LH = get_language_holder()
	return LH.remove_language(language, understood, spoken, source)

/// Removes every language and sets omnitongue false.
/atom/movable/proc/remove_all_languages(source = LANGUAGE_ALL, remove_omnitongue = FALSE)
	var/datum/language_holder/LH = get_language_holder()
	return LH.remove_all_languages(source, remove_omnitongue)

/// Adds a language to the blocked language list. Use this over remove_language in cases where you will give languages back later.
/atom/movable/proc/add_blocked_language(language, source = LANGUAGE_ATOM)
	var/datum/language_holder/LH = get_language_holder()
	return LH.add_blocked_language(language, source)

/// Removes a language from the blocked language list.
/atom/movable/proc/remove_blocked_language(language, source = LANGUAGE_ATOM)
	var/datum/language_holder/LH = get_language_holder()
	return LH.remove_blocked_language(language, source)

/// Checks if atom has the language. If spoken is true, only checks if atom can speak the language.
/atom/movable/proc/has_language(language, spoken = FALSE)
	var/datum/language_holder/LH = get_language_holder()
	return LH.has_language(language, spoken)

/// Checks if atom can speak the language.
/atom/movable/proc/can_speak_language(language)
	var/datum/language_holder/LH = get_language_holder()
	return LH.can_speak_language(language)

/// Returns the result of tongue specific limitations on spoken languages.
/atom/movable/proc/could_speak_language(language)
	return TRUE

/// Returns selected language, if it can be spoken, or finds, sets and returns a new selected language if possible.
/atom/movable/proc/get_selected_language()
	var/datum/language_holder/LH = get_language_holder()
	return LH.get_selected_language()

/// Gets a random understood language, useful for hallucinations and such.
/atom/movable/proc/get_random_understood_language()
	var/datum/language_holder/LH = get_language_holder()
	return LH.get_random_understood_language()

/// Gets a random spoken language, useful for forced speech and such.
/atom/movable/proc/get_random_spoken_language()
	var/datum/language_holder/LH = get_language_holder()
	return LH.get_random_spoken_language()

/// Copies all languages into the supplied atom/language holder. Source should be overridden when you
/// do not want the language overwritten by later atom updates or want to avoid blocked languages.
/atom/movable/proc/copy_languages(from_holder, source_override)
	if(isatom(from_holder))
		var/atom/movable/thing = from_holder
		from_holder = thing.get_language_holder()
	var/datum/language_holder/LH = get_language_holder()
	return LH.copy_languages(from_holder, source_override)

/// Empties out the atom specific languages and updates them according to the current atoms language holder.
/// As a side effect, it also creates missing language holders in the process.
/atom/movable/proc/update_atom_languages()
	var/datum/language_holder/LH = get_language_holder()
	return LH.update_atom_languages(src)

/* End language procs */

//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return

/atom/movable/proc/can_be_pulled(user, grab_state, force)
	if(src == user || !isturf(loc))
		return FALSE
	if(anchored || throwing)
		return FALSE
	if(force < (move_resist * MOVE_FORCE_PULL_RATIO))
		return FALSE
	return TRUE

/**
 * Updates the grab state of the movable
 *
 * This exists to act as a hook for behaviour
 */
/atom/movable/proc/setGrabState(newstate)
	if(newstate == grab_state)
		return
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_GRAB_STATE, newstate)
	. = grab_state
	grab_state = newstate
	switch(grab_state) // Current state.
		if(GRAB_PASSIVE)
			REMOVE_TRAIT(pulling, TRAIT_IMMOBILIZED, CHOKEHOLD_TRAIT)
			REMOVE_TRAIT(pulling, TRAIT_HANDS_BLOCKED, CHOKEHOLD_TRAIT)
			if(. >= GRAB_NECK) // Previous state was a a neck-grab or higher.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
		if(GRAB_AGGRESSIVE)
			if(. >= GRAB_NECK) // Grab got downgraded.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
			else // Grab got upgraded from a passive one.
				ADD_TRAIT(pulling, TRAIT_IMMOBILIZED, CHOKEHOLD_TRAIT)
				ADD_TRAIT(pulling, TRAIT_HANDS_BLOCKED, CHOKEHOLD_TRAIT)
		if(GRAB_NECK, GRAB_KILL)
			if(. <= GRAB_AGGRESSIVE)
				ADD_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)

/**
 * Adds the deadchat_plays component to this atom with simple movement commands.
 *
 * Returns the component added.
 * Arguments:
 * * mode - Either ANARCHY_MODE or DEMOCRACY_MODE passed to the deadchat_control component. See [/datum/component/deadchat_control] for more info.
 * * cooldown - The cooldown between command inputs passed to the deadchat_control component. See [/datum/component/deadchat_control] for more info.
 */
/atom/movable/proc/deadchat_plays(mode = ANARCHY_MODE, cooldown = 12 SECONDS)
	return AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(), cooldown)

/atom/movable/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_DEADCHAT_PLAYS, "Start/Stop Deadchat Plays")

/atom/movable/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_DEADCHAT_PLAYS] && check_rights(R_FUN))
		if(alert(usr, "Allow deadchat to control [src] via chat commands?", "Deadchat Plays [src]", "Allow", "Cancel") == "Cancel")
			return

		// Alert is async, so quick sanity check to make sure we should still be doing this.
		if(QDELETED(src))
			return

		// This should never happen, but if it does it should not be silent.
		if(deadchat_plays() == COMPONENT_INCOMPATIBLE)
			to_chat(usr, "<span class='warning'>Deadchat control not compatible with [src].</span>")
			CRASH("deadchat_control component incompatible with object of type: [type]")

		to_chat(usr, "<span class='notice'>Deadchat now control [src].</span>")
		log_admin("[key_name(usr)] has added deadchat control to [src]")
		message_admins("<span class='notice'>[key_name(usr)] has added deadchat control to [src]</span>")

/**
* A wrapper for setDir that should only be able to fail by living mobs.
*
* Called from [/atom/movable/proc/keyLoop], this exists to be overwritten by living mobs with a check to see if we're actually alive enough to change directions
*/
/atom/movable/proc/keybind_face_direction(direction)
	setDir(direction)
