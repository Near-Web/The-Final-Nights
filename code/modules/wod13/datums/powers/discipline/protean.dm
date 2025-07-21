/datum/discipline/protean
	name = "Protean"
	desc = "Lets your beast out, making you stronger and faster. Violates Masquerade."
	icon_state = "protean"
	clan_restricted = TRUE
	power_type = /datum/discipline_power/protean

/datum/discipline_power/protean
	name = "Protean power name"
	desc = "Protean power description"

	activate_sound = 'code/modules/wod13/sounds/protean_activate.ogg'
	deactivate_sound = 'code/modules/wod13/sounds/protean_deactivate.ogg'



//EYES OF THE BEAST
/datum/discipline_power/protean/eyes_of_the_beast
	name = "Eyes of the Beast"
	desc = "Let your eyes be a gateway to your Beast. Gain its eyes."

	level = 1

	check_flags = DISC_CHECK_CONSCIOUS
	vitae_cost = 0
	violates_masquerade = FALSE

	toggled = TRUE
	var/original_eye_color


/datum/discipline_power/protean/eyes_of_the_beast/activate()
	. = ..()
	ADD_TRAIT(owner, TRAIT_PROTEAN_VISION, TRAIT_GENERIC)
	owner.update_sight()
	original_eye_color = owner.eye_color
	owner.eye_color = "#ff0000"
	var/obj/item/organ/eyes/organ_eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(!organ_eyes)
		return
	else
		organ_eyes.eye_color = owner.eye_color
	owner.update_body()

/datum/discipline_power/protean/eyes_of_the_beast/deactivate()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_PROTEAN_VISION, TRAIT_GENERIC)
	owner.update_sight()
	owner.eye_color = original_eye_color
	var/obj/item/organ/eyes/organ_eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(!organ_eyes)
		return
	else
		organ_eyes.eye_color = owner.eye_color
	owner.update_body()

//FERAL CLAWS
/datum/movespeed_modifier/protean2
	multiplicative_slowdown = -0.15

/datum/discipline_power/protean/feral_claws
	name = "Feral Claws"
	desc = "Become a predator and grow hideous talons."

	level = 2

	check_flags = DISC_CHECK_IMMOBILE | DISC_CHECK_CAPABLE

	violates_masquerade = TRUE

	toggled = TRUE
	duration_length = 2 TURNS

/datum/discipline_power/protean/feral_claws/activate()
	. = ..()
	owner.drop_all_held_items()
	owner.put_in_r_hand(new /obj/item/melee/vampirearms/knife/gangrel(owner))
	owner.put_in_l_hand(new /obj/item/melee/vampirearms/knife/gangrel(owner))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/protean2)

/datum/discipline_power/protean/feral_claws/deactivate()
	. = ..()
	for(var/obj/item/melee/vampirearms/knife/gangrel/G in owner.contents)
		qdel(G)
	owner.remove_client_colour(/datum/client_colour/glass_colour/red)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/protean2)

//Depreciated. Still kept since think there's mobs of this that are spawned
/mob/living/simple_animal/hostile/gangrel
	name = "warform"
	desc = "A horrid man-beast abomination."
	icon = 'code/modules/wod13/32x48.dmi'
	icon_state = "gangrel_f"
	icon_living = "gangrel_f"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mob_size = MOB_SIZE_HUGE
	speak_chance = 0
	speed = -0.4
	maxHealth = 275
	health = 275
	butcher_results = list(/obj/item/stack/human_flesh = 10)
	harm_intent_damage = 5
	melee_damage_lower = 30
	melee_damage_upper = 30
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	bloodpool = 10
	maxbloodpool = 10
	dextrous = TRUE
	held_items = list(null, null)

/mob/living/simple_animal/hostile/gangrel/best
	icon_state = "gangrel_m"
	icon_living = "gangrel_m"
	maxHealth = 400 //More in line with new health values.
	health = 400
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = -0.8


//Earth Meld

/datum/discipline_power/protean/earth_meld
	name = "Earth Meld"
	desc = "Place yourself on Earth."

	level = 3

	check_flags = DISC_CHECK_IMMOBILE | DISC_CHECK_CAPABLE

	violates_masquerade = TRUE

	cancelable = TRUE
	duration_length = 999 SCENES

/datum/discipline_power/protean/earth_meld/activate()
	. = ..()
	var/obj/structure/bury_pit/burial_pit = new (get_turf(owner))
	burial_pit.icon_state = "pit1"
	owner.forceMove(burial_pit)

/datum/discipline_power/protean/earth_meld/deactivate()
	. = ..()
	var/meld_check = SSroll.storyteller_roll(owner.morality_path.score, difficulty = 6, mobs_to_show_output = owner, numerical = FALSE)
	switch(meld_check)
		if(ROLL_BOTCH)
			owner.torpor("Earth Meld")
		if(ROLL_FAILURE)
			return
		if(ROLL_SUCCESS)
			owner.forceMove(get_turf(owner))
		else
			return


//SHAPE OF THE BEAST
/obj/effect/proc_holder/spell/targeted/shapeshift/gangrel
	name = "Gangrel Form"
	desc = "Take on the shape a wolf."
	charge_max = 50
	cooldown_min = 5 SECONDS
	revert_on_death = TRUE
	die_with_shapeshifted_form = FALSE
	shapeshift_type = null
	possible_shapes = list(
		/mob/living/simple_animal/hostile/bear/wod13, \
		/mob/living/simple_animal/hostile/beastmaster/rat/flying, \
		/mob/living/simple_animal/hostile/beastmaster/shapeshift, \
		/mob/living/simple_animal/pet/dog/corgi, \
		/mob/living/simple_animal/hostile/beastmaster/shapeshift/wolf, \
		/mob/living/simple_animal/hostile/beastmaster/shapeshift/wolf/gray, \
		/mob/living/simple_animal/hostile/beastmaster/shapeshift/wolf/red, \
		/mob/living/simple_animal/hostile/beastmaster/shapeshift/wolf/white, \
		/mob/living/simple_animal/hostile/beastmaster/shapeshift/wolf/ginger, \
		/mob/living/simple_animal/hostile/beastmaster/shapeshift/wolf/brown
	)
	var/non_gangrel_shapes = list(
		/mob/living/simple_animal/hostile/beastmaster/rat/flying, \
		/mob/living/simple_animal/hostile/beastmaster/shapeshift/wolf
	)
	var/is_gangrel = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/gangrel/cast(list/targets,mob/user = usr)
	if(src in user.mob_spell_list)
		LAZYREMOVE(user.mob_spell_list, src)
		user.mind.AddSpell(src)
	if(user.buckled)
		user.buckled.unbuckle_mob(src,force=TRUE)
	for(var/mob/living/M in targets)
		if(!shapeshift_type)
			var/list/animal_list = list()
			var/list/display_animals = list()
			if(!is_gangrel)
				for(var/path in non_gangrel_shapes)
					var/mob/living/simple_animal/animal = path
					animal_list[initial(animal.name)] = path
					var/image/animal_image = image(icon = initial(animal.icon), icon_state = initial(animal.icon_state))
					display_animals += list(initial(animal.name) = animal_image)
			else
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

/datum/action/transform_back
	name = "Return to Form"
	desc = "Transform back to your original form."
	button_icon_state = "protean"
	button_icon = 'code/modules/wod13/UI/actions.dmi'
	background_icon_state = "gift"
	icon_icon = 'code/modules/wod13/UI/actions.dmi'
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/transform_back/Trigger(trigger_flags)
	. = ..()
	var/obj/shapeshift_holder/Shape = locate() in owner
	if(Shape)
		. =  Shape.stored
		Shape.restore()
	else
		to_chat(owner, "<span class='warning'>You cannot transform back to your original form as you are already in your original form. Unless you believe it is not?</span>")


/datum/discipline_power/protean/shape_of_the_beast
	name = "Shape of the Beast"
	desc = "Assume the form of an animal and retain your power."

	level = 4

	check_flags = DISC_CHECK_IMMOBILE | DISC_CHECK_CAPABLE

	violates_masquerade = TRUE

	cancelable = TRUE
	duration_length = 999 SCENES
	cooldown_length = 20 SECONDS

	grouped_powers = list(
		/datum/discipline_power/protean/mist_form
	)

	var/obj/effect/proc_holder/spell/targeted/shapeshift/gangrel/GA

/datum/discipline_power/protean/shape_of_the_beast/activate()
	. = ..()
	if (!GA)
		GA = new(owner)
	owner.drop_all_held_items()
	if(GA.shapeshift_type)
		GA.shapeshift_type = null
	if(owner.clan?.name == CLAN_GANGREL)
		GA.is_gangrel = TRUE
	GA.cast(list(owner), owner)

/datum/discipline_power/protean/shape_of_the_beast/deactivate()
	. = ..()
	GA.Restore(GA.myshape)
	owner.Stun(1.5 SECONDS)
	owner.do_jitter_animation(30)

//MIST FORM
/obj/effect/proc_holder/spell/targeted/shapeshift/gangrel/mist
	shapeshift_type = /mob/living/simple_animal/hostile/smokecrawler/mist

/mob/living/simple_animal/hostile/smokecrawler/mist
	name = "Mist"
	desc = "Levitating Spritz of Water."
	speed = -1
	alpha = 20

/datum/discipline_power/protean/mist_form
	name = "Mist Form"
	desc = "Dissipate your body and move as mist."

	level = 5

	check_flags = DISC_CHECK_IMMOBILE | DISC_CHECK_CAPABLE

	violates_masquerade = TRUE

	cancelable = TRUE
	duration_length = 999 SCENES
	cooldown_length = 20 SECONDS

	grouped_powers = list(
		/datum/discipline_power/protean/shape_of_the_beast
	)

	var/obj/effect/proc_holder/spell/targeted/shapeshift/gangrel/mist/GA

/datum/discipline_power/protean/mist_form/activate()
	. = ..()
	if (!GA)
		GA = new(owner)
	owner.drop_all_held_items()
	GA.Shapeshift(owner)

/datum/discipline_power/protean/mist_form/deactivate()
	. = ..()
	GA.Restore(GA.myshape)
	owner.Stun(1 SECONDS)
	owner.do_jitter_animation(15)
