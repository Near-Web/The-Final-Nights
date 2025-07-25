/obj/effect/proc_holder/spell/targeted/shapeshift
	name = "Shapechange"
	desc = "Take on the shape of another for a time to use their natural abilities. Once you've made your choice it cannot be changed."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 200
	cooldown_min = 50
	range = -1
	include_user = TRUE
	invocation = "RAC'WA NO!"
	invocation_type = INVOCATION_SHOUT
	action_icon_state = "shapeshift"

	var/mob/living/myshape

	var/revert_on_death = TRUE
	var/die_with_shapeshifted_form = TRUE
	var/convert_damage = TRUE //If you want to convert the caster's health and blood to the shift, and vice versa.
	var/convert_damage_type = BRUTE //Since simplemobs don't have advanced damagetypes, what to convert damage back into.

	var/mob/living/shapeshift_type
	var/list/possible_shapes = list(/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/pet/dog/corgi,\
		/mob/living/simple_animal/hostile/carp/ranged/chaos,\
		/mob/living/simple_animal/bot/secbot/ed209,\
		/mob/living/simple_animal/hostile/poison/giant_spider/viper/wizard,\
		/mob/living/simple_animal/hostile/construct/juggernaut)

/obj/effect/proc_holder/spell/targeted/shapeshift/cast(list/targets,mob/user = usr)
	if(src in user.mob_spell_list)
		LAZYREMOVE(user.mob_spell_list, src)
		user.mind.AddSpell(src)
	if(user.buckled)
		user.buckled.unbuckle_mob(src,force=TRUE)
	for(var/mob/living/M in targets)
		if(!shapeshift_type)
			var/list/animal_list = list()
			var/list/display_animals = list()
			for(var/path in possible_shapes)
				var/mob/living/simple_animal/animal = path
				animal_list[initial(animal.name)] = path
				var/image/animal_image = image(icon = initial(animal.icon), icon_state = initial(animal.icon_state))
				display_animals += list(initial(animal.name) = animal_image)
			sort_list(display_animals)
			var/new_shapeshift_type = show_radial_menu(M, M, display_animals, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 38, require_near = TRUE)
			if(shapeshift_type)
				return
			shapeshift_type = new_shapeshift_type
			if(!shapeshift_type) //If you aren't gonna decide I am!
				shapeshift_type = pick(animal_list)
			shapeshift_type = animal_list[shapeshift_type]

		var/obj/shapeshift_holder/S = locate() in M
		if(S)
			M = Restore(M)
		else
			M = Shapeshift(M)

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 */
/obj/effect/proc_holder/spell/targeted/shapeshift/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/H = locate() in caster
	if(H)
		to_chat(caster, "<span class='warning'>You're already shapeshifted!</span>")
		return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	myshape = shape
	if(istype(shape, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/hostile = shape
		hostile.my_creator = caster
	H = new(shape,src,caster)
	if(HAS_TRAIT(caster, TRAIT_WARRIOR) && !HAS_TRAIT(shape, TRAIT_WARRIOR))
		ADD_TRAIT(shape, TRAIT_WARRIOR, ROUNDSTART_TRAIT)

	clothes_req = FALSE
	human_req = FALSE
	return shape

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Restore(mob/living/shape)
	var/obj/shapeshift_holder/H = locate() in shape
	if(!H)
		return

	. =  H.stored
	H.restore()

	clothes_req = initial(clothes_req)
	human_req = initial(human_req)

/obj/effect/proc_holder/spell/targeted/shapeshift/dragon
	name = "Dragon Form"
	desc = "Take on the shape a lesser ash drake."
	invocation = "RAAAAAAAAWR!"
	convert_damage = FALSE


	shapeshift_type = /mob/living/simple_animal/hostile/megafauna/dragon/lesser


/obj/shapeshift_holder
	name = "Shapeshift holder"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF
	var/mob/living/stored
	var/mob/living/shape
	var/restoring = FALSE
	var/obj/effect/proc_holder/spell/targeted/shapeshift/source

/obj/shapeshift_holder/Initialize(mapload,obj/effect/proc_holder/spell/targeted/shapeshift/_source, mob/living/caster)
	. = ..()
	source = _source
	shape = loc
	if(!istype(shape))
		CRASH("shapeshift holder created outside mob/living")
	stored = caster
	if(stored.mind)
		stored.mind.transfer_to(shape)
	stored.forceMove(src)
	stored.notransform = TRUE
	if(source.convert_damage)
		var/damage_percent = (stored.maxHealth - stored.health)/stored.maxHealth;
		var/damapply = damage_percent * shape.maxHealth;

		shape.apply_damage(damapply, source.convert_damage_type, forced = TRUE, wound_bonus=CANT_WOUND);

	RegisterSignals(shape, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(shape_death))
	RegisterSignals(stored, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(caster_death))

/obj/shapeshift_holder/Destroy()
	// Restore manages signal unregistering. If restoring is TRUE, we've already unregistered the signals and we're here
	// because restore() qdel'd src.
	if(!restoring)
		restore()
	stored = null
	shape = null
	return ..()

/obj/shapeshift_holder/Moved()
	. = ..()
	if(!restoring || QDELETED(src))
		restore()

/obj/shapeshift_holder/handle_atom_del(atom/A)
	if(A == stored && !restoring)
		restore()

/obj/shapeshift_holder/Exited(atom/movable/AM)
	if(AM == stored && !restoring)
		restore()

/obj/shapeshift_holder/proc/caster_death()
	SIGNAL_HANDLER
	//Something kills the stored caster through direct damage.
	if(source.revert_on_death)
		restore(death=TRUE)
	else
		shape.death()

/obj/shapeshift_holder/proc/shape_death()
	SIGNAL_HANDLER
	//Shape dies.
	if(source.die_with_shapeshifted_form)
		if(source.revert_on_death)
			restore(death=TRUE)
	else
		restore()

/obj/shapeshift_holder/proc/restore(death=FALSE)
	// Destroy() calls this proc if it hasn't been called. Unregistering here prevents multiple qdel loops
	// when caster and shape both die at the same time.
	UnregisterSignal(shape, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	UnregisterSignal(stored, list(COMSIG_PARENT_QDELETING, COMSIG_LIVING_DEATH))
	restoring = TRUE
	stored.forceMove(shape.loc)
	stored.notransform = FALSE
	if(shape.mind)
		shape.mind.transfer_to(stored)
	if(death)
		stored.death()
	else if(source.convert_damage)
		stored.revive(full_heal = TRUE, admin_revive = FALSE)
//TFN MODIFIED STUFF
		var/dam_percentage = ((shape.health / shape.maxHealth)) // getting percentage of your current hp compared to max HP in shape form
		var/percent_carbon = (stored.maxHealth * dam_percentage) //this will get the HP remaining left you have in carbon form at base
		var/gross_damage = (stored.maxHealth - percent_carbon) //This will give you the relative percentage damage you'd take once transforming back
/* EXAMPLE CALCULATION
dama_percentage = ( 1 (current HP) / 100 (max hp) ) = 0.002
percent_carbon = 100 * 0.002 = 0.2
gross_damage = 100 - 0.2 = 99.75

Result: you take at least 90 damage when you trasnform back
*/
		stored.apply_damage(gross_damage, source.convert_damage_type, forced = TRUE, wound_bonus=CANT_WOUND)

//END OF TFN MODIFIED STUFF

//	if(source.convert_damage)
//		stored.blood_volume = shape.blood_volume;

	// This guard is important because restore() can also be called on COMSIG_PARENT_QDELETING for shape, as well as on death.
	// This can happen in, for example, [/proc/wabbajack] where the mob hit is qdel'd.
	if(!QDELETED(shape))
		QDEL_NULL(shape)

	qdel(src)
