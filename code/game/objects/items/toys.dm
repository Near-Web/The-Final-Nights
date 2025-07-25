/* Toys!
 * Contains
 *		Balloons
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Crayons
 *		Snap pops
 *		AI core prizes
 *		Toy codex gigas
 * 		Skeleton toys
 *		Cards
 *		Toy nuke
 *		Fake meteor
 *		Foam armblade
 *		Toy big red button
 *		Beach ball
 *		Toy xeno
 *      Kitty toys!
 *		Snowballs
 *		Clockwork Watches
 *		Toy Daggers
 *		Squeaky Brain
 *		Broken Radio
 */

/obj/item/toy
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0


/*
 * Balloons
 */
/obj/item/toy/waterballoon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	inhand_icon_state = "balloon-empty"


/obj/item/toy/waterballoon/Initialize()
	. = ..()
	create_reagents(10)

/obj/item/toy/waterballoon/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/toy/waterballoon/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/waterballoon/afterattack(atom/A as mob|obj, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if (istype(A, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/RD = A
		if(RD.reagents.total_volume <= 0)
			to_chat(user, "<span class='warning'>[RD] is empty.</span>")
		else if(reagents.total_volume >= 10)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else
			A.reagents.trans_to(src, 10, transfered_by = user)
			to_chat(user, "<span class='notice'>You fill the balloon with the contents of [A].</span>")
			desc = "A translucent balloon with some form of liquid sloshing around in it."
			update_appearance()

/obj/item/toy/waterballoon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass))
		if(I.reagents)
			if(I.reagents.total_volume <= 0)
				to_chat(user, "<span class='warning'>[I] is empty.</span>")
			else if(reagents.total_volume >= 10)
				to_chat(user, "<span class='warning'>[src] is full.</span>")
			else
				desc = "A translucent balloon with some form of liquid sloshing around in it."
				to_chat(user, "<span class='notice'>You fill the balloon with the contents of [I].</span>")
				I.reagents.trans_to(src, 10, transfered_by = user)
				update_appearance()
	else if(I.get_sharpness())
		balloon_burst()
	else
		return ..()

/obj/item/toy/waterballoon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		balloon_burst(hit_atom)

/obj/item/toy/waterballoon/proc/balloon_burst(atom/AT)
	if(reagents.total_volume >= 1)
		var/turf/T
		if(AT)
			T = get_turf(AT)
		else
			T = get_turf(src)
		T.visible_message("<span class='danger'>[src] bursts!</span>","<span class='hear'>You hear a pop and a splash.</span>")
		reagents.expose(T)
		for(var/atom/A in T)
			reagents.expose(A)
		icon_state = "burst"
		qdel(src)

/obj/item/toy/waterballoon/update_icon_state()
	if(reagents.total_volume >= 1)
		icon_state = "waterballoon"
		inhand_icon_state = "balloon"
	else
		icon_state = "waterballoon-e"
		inhand_icon_state = "balloon-empty"
	return ..()

#define BALLOON_COLORS list("red", "blue", "green", "yellow")

/obj/item/toy/balloon
	name = "balloon"
	desc = "No birthday is complete without it."
	icon = 'icons/obj/balloons.dmi'
	icon_state = "balloon"
	inhand_icon_state = "balloon"
	lefthand_file = 'icons/mob/inhands/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/balloons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0
	var/random_color = TRUE

/obj/item/toy/balloon/Initialize(mapload)
	. = ..()
	if(random_color)
		var/chosen_balloon_color = pick(BALLOON_COLORS)
		name = "[chosen_balloon_color] [name]"
		icon_state = "[icon_state]_[chosen_balloon_color]"
		inhand_icon_state = icon_state

/obj/item/toy/balloon/corgi
	name = "corgi balloon"
	desc = "A balloon with a corgi face on it. For the all year good boys."
	icon_state = "corgi"
	inhand_icon_state = "corgi"
	random_color = FALSE

/obj/item/toy/balloon/syndicate
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	icon_state = "syndballoon"
	inhand_icon_state = "syndballoon"
	random_color = FALSE

/obj/item/toy/balloon/syndicate/pickup(mob/user)
	. = ..()
	if(user && user.mind && user.mind.has_antag_datum(/datum/antagonist, TRUE))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "badass_antag", /datum/mood_event/badass_antag)

/obj/item/toy/balloon/syndicate/dropped(mob/user)
	if(user)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "badass_antag", /datum/mood_event/badass_antag)
	. = ..()


/obj/item/toy/balloon/syndicate/Destroy()
	if(ismob(loc))
		var/mob/M = loc
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "badass_antag", /datum/mood_event/badass_antag)
	. = ..()


/obj/item/toy/balloon/arrest
	name = "arreyst balloon"
	desc = "A half inflated balloon about a boyband named Arreyst that was popular about ten years ago, famous for making fun of red jumpsuits as unfashionable."
	icon_state = "arrestballoon"
	inhand_icon_state = "arrestballoon"
	random_color = FALSE

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "gravitational singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/obj/item/toy/spinningtoy/suicide_act(mob/living/carbon/human/user)
	var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
	if(!myhead)
		user.visible_message("<span class='suicide'>[user] tries consuming [src]... but [user.p_they()] [user.p_have()] no mouth!</span>") // and i must scream
		return SHAME
	user.visible_message("<span class='suicide'>[user] consumes [src]! It looks like [user.p_theyre()] trying to commit suicicide!</span>")
	playsound(user, 'sound/items/eatfood.ogg', 50, TRUE)
	user.adjust_nutrition(50) // mmmm delicious
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), (3SECONDS))
	return MANUAL_SUICIDE

/**
 * Internal function used in the toy singularity suicide
 *
 * Cavity implants the toy singularity into the body of the user (arg1), and kills the user.
 * Makes the user vomit and receive 120 suffocation damage if there already is a cavity implant in the user.
 * Throwing the singularity away will cause the user to start choking themself to death.
 * Arguments:
 * * user - Whoever is doing the suiciding
 */
/obj/item/toy/spinningtoy/proc/manual_suicide(mob/living/carbon/human/user)
	if(!user)
		return
	if(!user.is_holding(src)) // Half digestion? Start choking to death
		user.visible_message("<span class='suicide'>[user] panics and starts choking [user.p_them()]self to death!</span>")
		user.adjustOxyLoss(200)
		user.death(FALSE) // unfortunately you have to handle the suiciding yourself with a manual suicide
		user.ghostize(FALSE) // get the fuck out of our body
		return
	var/obj/item/bodypart/chest/CH = user.get_bodypart(BODY_ZONE_CHEST)
	if(CH.cavity_item) // if he's (un)bright enough to have a round and full belly...
		user.visible_message("<span class='danger'>[user] regurgitates [src]!</span>") // I swear i dont have a fetish
		user.vomit(100, TRUE, distance = 0)
		user.adjustOxyLoss(120)
		user.dropItemToGround(src) // incase the crit state doesn't drop the singulo to the floor
		user.set_suicide(FALSE)
		return
	user.transferItemToLoc(src, user, TRUE)
	CH.cavity_item = src // The mother came inside and found Andy, dead with a HUGE belly full of toys
	user.adjustOxyLoss(200) // You know how most small toys in the EU have that 3+ onion head icon and a warning that says "Unsuitable for children under 3 years of age due to small parts - choking hazard"? This is why.
	user.death(FALSE)
	user.ghostize(FALSE)



/*
 * Toy gun: Why isn't this an /obj/item/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "revolver"
	inhand_icon_state = "gun"
	worn_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=10)
	attack_verb_continuous = list("strikes", "pistol whips", "hits", "bashes")
	attack_verb_simple = list("strike", "pistol whip", "hit", "bash")
	var/bullets = 7

/obj/item/toy/gun/examine(mob/user)
	. = ..()
	. += "There [bullets == 1 ? "is" : "are"] [bullets] cap\s left."

/obj/item/toy/gun/attackby(obj/item/toy/ammo/gun/A, mob/user, params)

	if(istype(A, /obj/item/toy/ammo/gun))
		if (src.bullets >= 7)
			to_chat(user, "<span class='warning'>It's already fully loaded!</span>")
			return 1
		if (A.amount_left <= 0)
			to_chat(user, "<span class='warning'>There are no more caps!</span>")
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			to_chat(user, text("<span class='notice'>You reload [] cap\s.</span>", A.amount_left))
			A.amount_left = 0
		else
			to_chat(user, text("<span class='notice'>You reload [] cap\s.</span>", 7 - src.bullets))
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_appearance()
		return 1
	else
		return ..()

/obj/item/toy/gun/afterattack(atom/target as mob|obj|turf|area, mob/user, flag)
	. = ..()
	if (flag)
		return
	if (!ISADVANCEDTOOLUSER(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("<span class='warning'>*click*</span>", MSG_AUDIBLE)
		playsound(src, 'sound/weapons/gun/revolver/dry_fire.ogg', 30, TRUE)
		return
	playsound(user, 'sound/weapons/gun/revolver/shot.ogg', 100, TRUE)
	src.bullets--
	user.visible_message("<span class='danger'>[user] fires [src] at [target]!</span>", \
		"<span class='danger'>You fire [src] at [target]!</span>", \
		"<span class='hear'>You hear a gunshot!</span>")

/obj/item/toy/ammo/gun
	name = "capgun ammo"
	desc = "Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357OLD-7"
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=10)
	var/amount_left = 7

/obj/item/toy/ammo/gun/update_icon_state()
	icon_state = "357OLD-[amount_left]"
	return ..()

/obj/item/toy/ammo/gun/examine(mob/user)
	. = ..()
	. += "There [amount_left == 1 ? "is" : "are"] [amount_left] cap\s left."

/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/transforming_energy.dmi'
	icon_state = "sword0"
	inhand_icon_state = "sword0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	var/active = 0
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("attacks", "strikes", "hits")
	attack_verb_simple = list("attack", "strike", "hit")
	var/hacked = FALSE
	var/saber_color

/obj/item/toy/sword/attack_self(mob/user)
	active = !( active )
	if (active)
		to_chat(user, "<span class='notice'>You extend the plastic blade with a quick flick of your wrist.</span>")
		playsound(user, 'sound/weapons/saberon.ogg', 20, TRUE)
		if(hacked)
			icon_state = "swordrainbow"
			inhand_icon_state = "swordrainbow"
		else
			icon_state = "swordblue"
			inhand_icon_state = "swordblue"
		w_class = WEIGHT_CLASS_BULKY
	else
		to_chat(user, "<span class='notice'>You push the plastic blade back down into the handle.</span>")
		playsound(user, 'sound/weapons/saberoff.ogg', 20, TRUE)
		icon_state = "sword0"
		inhand_icon_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL
	add_fingerprint(user)

// Copied from /obj/item/melee/transforming/energy/sword/attackby
/obj/item/toy/sword/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/toy/sword))
		if(HAS_TRAIT(W, TRAIT_NODROP) || HAS_TRAIT(src, TRAIT_NODROP))
			to_chat(user, "<span class='warning'>\the [HAS_TRAIT(src, TRAIT_NODROP) ? src : W] is stuck to your hand, you can't attach it to \the [HAS_TRAIT(src, TRAIT_NODROP) ? W : src]!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You attach the ends of the two plastic swords, making a single double-bladed toy! You're fake-cool.</span>")
			var/obj/item/dualsaber/toy/newSaber = new /obj/item/dualsaber/toy(user.loc)
			if(hacked) // That's right, we'll only check the "original" "sword".
				newSaber.hacked = TRUE
				newSaber.saber_color = "rainbow"
			qdel(W)
			qdel(src)
	else if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			saber_color = "rainbow"
			to_chat(user, "<span class='warning'>RNBW_ENGAGE</span>")

			if(active)
				icon_state = "swordrainbow"
				user.update_inv_hands()
		else
			to_chat(user, "<span class='warning'>It's already fabulous!</span>")
	else
		return ..()

/*
 * Foam armblade
 */
/obj/item/toy/foamblade
	name = "foam armblade"
	desc = "It says \"Sternside Changs #1 fan\" on it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamblade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	attack_verb_continuous = list("pricks", "absorbs", "gores")
	attack_verb_simple = list("prick", "absorb", "gore")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE


/obj/item/toy/windup_toolbox
	name = "windup toolbox"
	desc = "A replica toolbox that rumbles when you turn the key."
	icon_state = "his_grace"
	inhand_icon_state = "artistic_toolbox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	var/active = FALSE
	icon = 'icons/obj/items_and_weapons.dmi'
	hitsound = 'sound/weapons/smash.ogg'
	attack_verb_continuous = list("robusts")
	attack_verb_simple = list("robust")

/obj/item/toy/windup_toolbox/attack_self(mob/user)
	if(!active)
		icon_state = "his_grace_awakened"
		to_chat(user, "<span class='notice'>You wind up [src], it begins to rumble.</span>")
		active = TRUE
		playsound(src, 'sound/effects/pope_entry.ogg', 100)
		Rumble()
		addtimer(CALLBACK(src, PROC_REF(stopRumble)), 600)
	else
		to_chat(user, "<span class='warning'>[src] is already active!</span>")

/obj/item/toy/windup_toolbox/proc/Rumble()
	var/static/list/transforms
	if(!transforms)
		var/matrix/M1 = matrix()
		var/matrix/M2 = matrix()
		var/matrix/M3 = matrix()
		var/matrix/M4 = matrix()
		M1.Translate(-1, 0)
		M2.Translate(0, 1)
		M3.Translate(1, 0)
		M4.Translate(0, -1)
		transforms = list(M1, M2, M3, M4)
	animate(src, transform=transforms[1], time=0.2, loop=-1)
	animate(transform=transforms[2], time=0.1)
	animate(transform=transforms[3], time=0.2)
	animate(transform=transforms[4], time=0.3)

/obj/item/toy/windup_toolbox/proc/stopRumble()
	icon_state = initial(icon_state)
	active = FALSE
	animate(src, transform=matrix())

/*
 * Subtype of Double-Bladed Energy Swords
 */
/obj/item/dualsaber/toy
	name = "double-bladed toy sword"
	desc = "A cheap, plastic replica of TWO energy swords.  Double the fun!"
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	two_hand_force = 0
	attack_verb_continuous = list("attacks", "strikes", "hits")
	attack_verb_simple = list("attack", "strike", "hit")

/obj/item/dualsaber/toy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/dualsaber/toy/IsReflect() //Stops Toy Dualsabers from reflecting energy projectiles
	return 0

/obj/item/dualsaber/toy/impale(mob/living/user)//Stops Toy Dualsabers from injuring clowns
	to_chat(user, "<span class='warning'>You twirl around a bit before losing your balance and impaling yourself on [src].</span>")
	user.adjustStaminaLoss(25)

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "katana"
	inhand_icon_state = "katana"
	worn_icon_state = "katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices")
	attack_verb_simple = list("attack", "slash", "stab", "slice")
	hitsound = 'sound/weapons/bladeslice.ogg'

/*
 * Snap pops
 */

/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY
	var/ash_type = /obj/effect/decal/cleanable/ash

/obj/item/toy/snappop/proc/pop_burst(n=3, c=1)
	var/datum/effect_system/spark_spread/s = new()
	s.set_up(n, c, src)
	s.start()
	new ash_type(loc)
	visible_message("<span class='warning'>[src] explodes!</span>",
		"<span class='hear'>You hear a snap!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	qdel(src)

/obj/item/toy/snappop/fire_act(exposed_temperature, exposed_volume)
	pop_burst()

/obj/item/toy/snappop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		pop_burst()

/obj/item/toy/snappop/Crossed(H as mob|obj)
	. = ..()
	if(ishuman(H) || issilicon(H)) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(issilicon(H) || M.m_intent == MOVE_INTENT_RUN)
			to_chat(M, "<span class='danger'>You step on the snap pop!</span>")
			pop_burst(2, 0)

/obj/item/toy/snappop/phoenix
	name = "phoenix snap pop"
	desc = "Wow! And wow! And wow!"
	ash_type = /obj/effect/decal/cleanable/ash/snappop_phoenix

/obj/effect/decal/cleanable/ash/snappop_phoenix
	var/respawn_time = 300

/obj/effect/decal/cleanable/ash/snappop_phoenix/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn)), respawn_time)

/obj/effect/decal/cleanable/ash/snappop_phoenix/proc/respawn()
	new /obj/item/toy/snappop/phoenix(get_turf(src))
	qdel(src)

/obj/item/toy/talking
	name = "talking action figure"
	desc = "A generic action figure modeled after nothing in particular."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = FALSE
	var/messages = list("I'm super generic!", "Mathematics class is of variable difficulty!")
	var/span = "danger"
	var/recharge_time = 30

	var/chattering = FALSE
	var/phomeme

// Talking toys are language universal, and thus all species can use them
/obj/item/toy/talking/attack_alien(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/item/toy/talking/attack_self(mob/user)
	if(!cooldown)
		activation_message(user)
		playsound(loc, 'sound/machines/click.ogg', 20, TRUE)

		INVOKE_ASYNC(src, PROC_REF(do_toy_talk), user)

		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), recharge_time)
		return
	..()

/obj/item/toy/talking/proc/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] pulls the string on \the [src].</span>",
		"<span class='notice'>You pull the string on \the [src].</span>",
		"<span class='notice'>You hear a string being pulled.</span>")

/obj/item/toy/talking/proc/generate_messages()
	return list(pick(messages))

/obj/item/toy/talking/proc/do_toy_talk(mob/user)
	for(var/message in generate_messages())
		toy_talk(user, message)
		sleep(10)

/obj/item/toy/talking/proc/toy_talk(mob/user, message)
	user.loc.visible_message("<span class='[span]'>[icon2html(src, viewers(user.loc))] [message]</span>")
	if(chattering)
		chatter(message, phomeme, user)

/*
 * AI core prizes
 */
/obj/item/toy/talking/ai
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon_state = "AI"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/talking/ai/generate_messages()
	return list(generate_ion_law())

/obj/item/toy/talking/codex_gigas
	name = "Toy Codex Gigas"
	desc = "A tool to help you write fictional devils!"
	icon = 'icons/obj/library.dmi'
	icon_state = "demonomicon"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	messages = list("You must challenge the devil to a dance-off!", "The devils true name is Ian", "The devil hates salt!", "Would you like infinite power?", "Would you like infinite  wisdom?", " Would you like infinite healing?")
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/codex_gigas/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon_state = "owlprize"
	messages = list("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
	chattering = TRUE
	phomeme = "owl"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/talking/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon_state = "griffinprize"
	messages = list("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
	chattering = TRUE
	phomeme = "griffin"
	w_class = WEIGHT_CLASS_SMALL

/*
|| A Deck of Cards for playing various games of chance ||
*/



/obj/item/toy/cards
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/parentdeck = null
	var/deckstyle = "nanotrasen"
	var/card_hitsound = null
	var/card_force = 0
	var/card_throwforce = 0
	var/card_throw_speed = 3
	var/card_throw_range = 7
	var/list/card_attack_verb_continuous = list("attacks")
	var/list/card_attack_verb_simple = list("attack")


/obj/item/toy/cards/Initialize()
	. = ..()
	if(card_attack_verb_continuous)
		card_attack_verb_continuous = string_list(card_attack_verb_continuous)
	if(card_attack_verb_simple)
		card_attack_verb_simple = string_list(card_attack_verb_simple)


/obj/item/toy/cards/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] wrists with \the [src]! It looks like [user.p_they()] [user.p_have()] a crummy hand!</span>")
	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/toy/cards/proc/apply_card_vars(obj/item/toy/cards/newobj, obj/item/toy/cards/sourceobj) // Applies variables for supporting multiple types of card deck
	if(!istype(sourceobj))
		return

/obj/item/toy/cards/deck
	name = "deck of cards"
	desc = "A deck of playing cards."
	icon = 'icons/obj/toy.dmi'
	deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/obj/machinery/computer/holodeck/holo = null // Holodeck cards should not be infinite
	var/list/cards = list()

/obj/item/toy/cards/deck/Initialize()
	. = ..()
	populate_deck()

///Generates all the cards within the deck.
/obj/item/toy/cards/deck/proc/populate_deck()
	icon_state = "deck_[deckstyle]_full"
	for(var/suit in list("Hearts", "Spades", "Clubs", "Diamonds"))
		cards += "Ace of [suit]"
		for(var/i in 2 to 10)
			cards += "[i] of [suit]"
		for(var/person in list("Jack", "Queen", "King"))
			cards += "[person] of [suit]"

//ATTACK HAND IGNORING PARENT RETURN VALUE
//ATTACK HAND NOT CALLING PARENT
/obj/item/toy/cards/deck/attack_hand(mob/user, list/modifiers)
	draw_card(user)

/obj/item/toy/cards/deck/proc/draw_card(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	var/choice = null
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	if(holo)
		holo.spawned += H // track them leaving the holodeck
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	var/O = src
	H.apply_card_vars(H,O)
	popleft(cards)
	H.pickup(user)
	user.put_in_hands(H)
	user.visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
	update_appearance()
	return H

/obj/item/toy/cards/deck/update_icon_state()
	switch(cards.len)
		if(27 to INFINITY)
			icon_state = "deck_[deckstyle]_full"
		if(11 to 27)
			icon_state = "deck_[deckstyle]_half"
		if(1 to 11)
			icon_state = "deck_[deckstyle]_low"
		else
			icon_state = "deck_[deckstyle]_empty"
	return ..()

/obj/item/toy/cards/deck/attack_self(mob/user)
	if(cooldown < world.time - 50)
		cards = shuffle(cards)
		playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
		user.visible_message("<span class='notice'>[user] shuffles the deck.</span>", "<span class='notice'>You shuffle the deck.</span>")
		cooldown = world.time

/obj/item/toy/cards/deck/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard))
		var/obj/item/toy/cards/singlecard/SC = I
		if(SC.parentdeck == src)
			if(!user.temporarilyRemoveItemFromInventory(SC))
				to_chat(user, "<span class='warning'>The card is stuck to your hand, you can't add it to the deck!</span>")
				return
			cards += SC.cardname
			user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(SC)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")
		update_appearance()
	else if(istype(I, /obj/item/toy/cards/cardhand))
		var/obj/item/toy/cards/cardhand/CH = I
		if(CH.parentdeck == src)
			if(!user.temporarilyRemoveItemFromInventory(CH))
				to_chat(user, "<span class='warning'>The hand of cards is stuck to your hand, you can't add it to the deck!</span>")
				return
			cards += CH.currenthand
			user.visible_message("<span class='notice'>[user] puts [user.p_their()] hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(CH)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")
		update_appearance()
	else
		return ..()

/obj/item/toy/cards/deck/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || !(M.mobility_flags & MOBILITY_PICKUP))
		return
	if(Adjacent(usr))
		if(over_object == M && loc != M)
			M.put_in_hands(src)
			to_chat(usr, "<span class='notice'>You pick up the deck.</span>")

		else if(istype(over_object, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over_object
			if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
				to_chat(usr, "<span class='notice'>You pick up the deck.</span>")

	else
		to_chat(usr, "<span class='warning'>You can't reach it from here!</span>")



/obj/item/toy/cards/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "none"
	w_class = WEIGHT_CLASS_TINY
	var/list/currenthand = list()
	var/choice = null

/obj/item/toy/cards/cardhand/attack_self(mob/user)
	var/list/handradial = list()
	interact(user)

	for(var/t in currenthand)
		handradial[t] = image(icon = src.icon, icon_state = "sc_[t]_[deckstyle]")

	if(usr.stat || !ishuman(usr))
		return
	var/mob/living/carbon/human/cardUser = usr
	if(!(cardUser.mobility_flags & MOBILITY_USE))
		return
	var/O = src
	var/choice = show_radial_menu(usr,src, handradial, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	var/obj/item/toy/cards/singlecard/C = new/obj/item/toy/cards/singlecard(cardUser.loc)
	currenthand -= choice
	handradial -= choice
	C.parentdeck = parentdeck
	C.cardname = choice
	C.apply_card_vars(C,O)
	C.pickup(cardUser)
	cardUser.put_in_hands(C)
	cardUser.visible_message("<span class='notice'>[cardUser] draws a card from [cardUser.p_their()] hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

	interact(cardUser)
	update_sprite()
	if(length(currenthand) == 1)
		var/obj/item/toy/cards/singlecard/N = new/obj/item/toy/cards/singlecard(loc)
		N.parentdeck = parentdeck
		N.cardname = currenthand[1]
		N.apply_card_vars(N,O)
		qdel(src)
		N.pickup(cardUser)
		cardUser.put_in_hands(N)
		to_chat(cardUser, "<span class='notice'>You also take [currenthand[1]] and hold it.</span>")

/obj/item/toy/cards/cardhand/attackby(obj/item/toy/cards/singlecard/C, mob/living/user, params)
	if(istype(C))
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.visible_message("<span class='notice'>[user] adds a card to [user.p_their()] hand.</span>", "<span class='notice'>You add the [C.cardname] to your hand.</span>")
			qdel(C)
			interact(user)
			update_sprite(src)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")
	else
		return ..()

/obj/item/toy/cards/cardhand/apply_card_vars(obj/item/toy/cards/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	update_sprite()
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.card_attack_verb_continuous = sourceobj.card_attack_verb_continuous //null or unique list made by string_list()
	newobj.card_attack_verb_simple = sourceobj.card_attack_verb_simple //null or unique list made by string_list()
	newobj.resistance_flags = sourceobj.resistance_flags

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 */
/obj/item/toy/cards/cardhand/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/**
 * This proc updates the sprite for when you create a hand of cards
 */
/obj/item/toy/cards/cardhand/proc/update_sprite()
	cut_overlays()
	var/overlay_cards = currenthand.len
	if(overlay_cards < 2) // a single card should become a singlecard item, so do nothing
		return

	var/k = overlay_cards == 2 ? 1 : overlay_cards - 2
	for(var/i = k; i <= overlay_cards; i++)
		var/card_overlay = image(icon=src.icon,icon_state="sc_[currenthand[i]]_[deckstyle]",pixel_x=(1-i+k)*3,pixel_y=(1-i+k)*3)
		add_overlay(card_overlay)

/obj/item/toy/cards/singlecard
	name = "card"
	desc = "A playing card used to play card games like poker."
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down_nanotrasen"
	w_class = WEIGHT_CLASS_TINY
	var/cardname = null
	var/flipped = 0
	pixel_x = -5


/obj/item/toy/cards/singlecard/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.is_holding(src))
			cardUser.visible_message("<span class='notice'>[cardUser] checks [cardUser.p_their()] card.</span>", "<span class='notice'>The card reads: [cardname].</span>")
		else
			. += "<span class='warning'>You need to have the card in your hand to check it!</span>"


/obj/item/toy/cards/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return
	if(!flipped)
		src.flipped = 1
		if (cardname)
			src.icon_state = "sc_[cardname]_[deckstyle]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades_[deckstyle]"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down_[deckstyle]"
		src.name = "card"
		src.pixel_x = -5

/obj/item/toy/cards/singlecard/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard/))
		var/obj/item/toy/cards/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cards/cardhand/H = new/obj/item/toy/cards/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			H.apply_card_vars(H,C)
			to_chat(user, "<span class='notice'>You combine the [C.cardname] and the [src.cardname] into a hand.</span>")
			qdel(C)
			qdel(src)
			H.pickup(user)
			user.put_in_active_hand(H)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")

	if(istype(I, /obj/item/toy/cards/cardhand/))
		var/obj/item/toy/cards/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.visible_message("<span class='notice'>[user] adds a card to [user.p_their()] hand.</span>", "<span class='notice'>You add the [cardname] to your hand.</span>")
			qdel(src)
			H.interact(user)
			H.update_sprite()
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")
	else
		return ..()

/obj/item/toy/cards/singlecard/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user) || !(user.mobility_flags & MOBILITY_USE))
		return
	Flip()

/obj/item/toy/cards/singlecard/apply_card_vars(obj/item/toy/cards/singlecard/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "singlecard_down_[deckstyle]" // Without this the card is invisible until flipped. It's an ugly hack, but it works.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.hitsound = newobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.force = newobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.throwforce = newobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.throw_speed = newobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.throw_range = newobj.card_throw_range
	newobj.attack_verb_continuous = newobj.card_attack_verb_continuous = sourceobj.card_attack_verb_continuous //null or unique list made by string_list()
	newobj.attack_verb_simple = newobj.card_attack_verb_simple = sourceobj.card_attack_verb_simple //null or unique list made by string_list()

/*
|| Syndicate playing cards, for pretending you're Gambit and playing poker for the nuke disk. ||
*/

/obj/item/toy/cards/deck/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	icon_state = "deck_syndicate_full"
	deckstyle = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 10
	card_throw_speed = 3
	card_throw_range = 7
	card_attack_verb_continuous = list("attacks", "slices", "dices", "slashes", "cuts")
	card_attack_verb_simple = list("attack", "slice", "dice", "slash", "cut")
	resistance_flags = NONE

/*
 * Fake nuke
 */

/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if (obj_flags & EMAGGED && cooldown < world.time)
		cooldown = world.time + 600
		user.visible_message("<span class='hear'>You hear the click of a button.</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>")
		sleep(5)
		playsound(src, 'sound/machines/alarm.ogg', 20, FALSE)
		sleep(140)
		user.visible_message("<span class='alert'>[src] violently explodes!</span>")
		explosion(src, 0, 0, 1, 0)
		qdel(src)
	else if (cooldown < world.time)
		cooldown = world.time + 600 //1 minute
		user.visible_message("<span class='warning'>[user] presses a button on [src].</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='hear'>You hear the click of a button.</span>")
		sleep(5)
		icon_state = "nuketoy"
		playsound(src, 'sound/machines/alarm.ogg', 20, FALSE)
		sleep(135)
		icon_state = "nuketoycool"
		sleep(cooldown - world.time)
		icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on the small display.</span>")
		sleep(5)


/obj/item/toy/nuke/emag_act(mob/user)
	if (obj_flags & EMAGGED)
		return
	to_chat(user, "<span class = 'notice'> You short-circuit \the [src].</span>")
	obj_flags |= EMAGGED
/*
 * Fake meteor
 */

/obj/item/toy/minimeteor
	name = "\improper Mini-Meteor"
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor Co. is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/minimeteor/emag_act(mob/user)
	if (obj_flags & EMAGGED)
		return
	to_chat(user, "<span class = 'notice'> You short-circuit whatever electronics exist inside \the [src], if there even are any.</span>")
	obj_flags |= EMAGGED

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if (obj_flags & EMAGGED)
		playsound(src, 'sound/effects/meteorimpact.ogg', 40, TRUE)
		explosion(get_turf(hit_atom), -1, -1, 1)
		for(var/mob/M in urange(10, src))
			if(!M.stat && !isAI(M))
				shake_camera(M, 3, 1)
	else
		playsound(src, 'sound/effects/meteorimpact.ogg', 40, TRUE)
		for(var/mob/M in urange(10, src))
			if(!M.stat && !isAI(M))
				shake_camera(M, 3, 1)

/*
 * Toy big red button
 */
/obj/item/toy/redbutton
	name = "big red button"
	desc = "A big, plastic red button. Reads 'From HonkCo Pranks!' on the back."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/redbutton/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		user.visible_message("<span class='warning'>[user] presses the big red button.</span>", "<span class='notice'>You press the button, it plays a loud noise!</span>", "<span class='hear'>The button clicks loudly.</span>")
		playsound(src, 'sound/effects/explosionfar.ogg', 50, FALSE)
		for(var/mob/M in urange(10, src)) // Checks range
			if(!M.stat && !isAI(M)) // Checks to make sure whoever's getting shaken is alive/not the AI
				// Short delay to match up with the explosion sound
				// Shakes player camera 2 squares for 1 second.
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(shake_camera), M, 2, 1), 0.8 SECONDS)

	else
		to_chat(user, "<span class='alert'>Nothing happens.</span>")

/*
 * Snowballs
 */

/obj/item/toy/snowball
	name = "snowball"
	desc = "A compact ball of snow. Good for throwing at people."
	icon = 'icons/obj/toy.dmi'
	icon_state = "snowball"
	throwforce = 20 //the same damage as a disabler shot
	damtype = STAMINA //maybe someday we can add stuffing rocks (or perhaps ore?) into snowballs to make them deal brute damage

/obj/item/toy/snowball/afterattack(atom/target as mob|obj|turf|area, mob/user)
	. = ..()
	if(user.dropItemToGround(src))
		throw_at(target, throw_range, throw_speed)

/obj/item/toy/snowball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		playsound(src, 'sound/effects/pop.ogg', 20, TRUE)
		qdel(src)

/*
 * Beach ball
 */
/obj/item/toy/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	inhand_icon_state = "beachball"
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/*
 * Clockwork Watch
 */

/obj/item/toy/clockwork_watch
	name = "steampunk watch"
	desc = "A stylish steampunk watch made out of thousands of tiny cogwheels."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "dread_ipad"
	worn_icon_state = "dread_ipad"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/clockwork_watch/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message("<span class='warning'>[user] rotates a cogwheel on [src].</span>", "<span class='notice'>You rotate a cogwheel on [src], it plays a loud noise!</span>", "<span class='hear'>You hear cogwheels turning.</span>")
		playsound(src, 'sound/magic/clockwork/ark_activation.ogg', 50, FALSE)
	else
		to_chat(user, "<span class='alert'>The cogwheels are already turning!</span>")

/obj/item/toy/clockwork_watch/examine(mob/user)
	. = ..()
	. += "<span class='info'>Station Time: [station_time_timestamp()]</span>"

/*
 * Toy Dagger
 */

/obj/item/toy/toy_dagger
	name = "toy dagger"
	desc = "A cheap plastic replica of a dagger. Produced by THE ARM Toys, Inc."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	inhand_icon_state = "cultdagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

/*
 * Xenomorph action figure
 */

/obj/item/toy/toy_xeno
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_xeno"
	name = "xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 50) //5 second cooldown
		user.visible_message("<span class='notice'>[user] pulls back the string on [src].</span>")
		icon_state = "[initial(icon_state)]_used"
		sleep(5)
		audible_message("<span class='danger'>[icon2html(src, viewers(src))] Hiss!</span>")
		var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
		var/chosen_sound = pick(possible_sounds)
		playsound(get_turf(src), chosen_sound, 50, TRUE)
		addtimer(VARSET_CALLBACK(src, icon_state, "[initial(icon_state)]"), 4.5 SECONDS)
	else
		to_chat(user, "<span class='warning'>The string on [src] hasn't rewound all the way!</span>")
		return

// TOY MOUSEYS :3 :3 :3

/obj/item/toy/cattoy
	name = "toy mouse"
	desc = "A colorful toy mouse!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_mouse"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	resistance_flags = FLAMMABLE


/*
 * Action Figures
 */

/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = null
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	var/cooldown = 0
	var/toysay = "What the fuck did you do?"
	var/toysound = 'sound/machines/click.ogg'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/figure/Initialize()
	. = ..()
	desc = "A \"Space Life\" brand [src]."

/obj/item/toy/figure/attack_self(mob/user as mob)
	if(cooldown <= world.time)
		cooldown = world.time + 50
		to_chat(user, "<span class='notice'>[src] says \"[toysay]\"</span>")
		playsound(user, toysound, 20, TRUE)

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	icon_state = "assistant"
	toysay = "Grey tide world wide!"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	icon_state = "bartender"
	toysay = "Where is Pun Pun?"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."
	toysound = 'sound/voice/liveagain.ogg'

/obj/item/toy/figure/botanist
	name = "Botanist action figure"
	icon_state = "botanist"
	toysay = "Blaze it!"

/obj/item/toy/figure/captain
	name = "Captain action figure"
	icon_state = "captain"
	toysay = "Any heads of staff?"

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	icon_state = "chaplain"
	toysay = "Praise Space Jesus!"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	icon_state = "chef"
	toysay = " I'll make you into a burger!"

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	icon_state = "clown"
	toysay = "Honk!"
	toysound = 'sound/items/bikehorn.ogg'

/obj/item/toy/figure/ian
	name = "Ian action figure"
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/dsquad
	name = "Death Squad Officer action figure"
	icon_state = "dsquad"
	toysay = "Kill em all!"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	icon_state = "geneticist"
	toysay = "Smash!"

/obj/item/toy/figure/hop
	name = "Head of Personnel action figure"
	icon_state = "hop"
	toysay = "Giving out all access!"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	icon_state = "hos"
	toysay = "Go ahead, make my day."

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	icon_state = "qm"
	toysay = "Please sign this form in triplicate and we will see about geting you a welding mask within 3 business days."

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/lawyer
	name = "Lawyer action figure"
	icon_state = "lawyer"
	toysay = "My client is a dirty traitor!"

/obj/item/toy/figure/curator
	name = "Curator action figure"
	icon_state = "curator"
	toysay = "One day while..."

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/paramedic
	name = "Paramedic action figure"
	icon_state = "paramedic"
	toysay = "And the best part? I'm not even a real doctor!"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	icon_state = "mime"
	toysay = "..."
	toysound = null

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	icon_state = "miner"
	toysay = "COLOSSUS RIGHT OUTSIDE THE BASE!"

/obj/item/toy/figure/ninja
	name = "Ninja action figure"
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	icon_state = "wizard"
	toysay = "Ei Nath!"
	toysound = 'sound/magic/disintegrate.ogg'

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	icon_state = "roboticist"
	toysay = "Big stompy mechs!"
	toysound = 'sound/mecha/mechstep.ogg'

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	icon_state = "scientist"
	toysay = "I call toxins."
	toysound = 'sound/effects/explosionfar.ogg'

/obj/item/toy/figure/syndie
	name = "Nuclear Operative action figure"
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	icon_state = "secofficer"
	toysay = "I am the law!"
	toysound = 'sound/runtime/complionator/dredd.ogg'

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	icon_state = "virologist"
	toysay = "The cure is potassium!"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	icon_state = "warden"
	toysay = "Seventeen minutes for coughing at an officer!"


/obj/item/toy/dummy
	name = "ventriloquist dummy"
	desc = "It's a dummy, dummy."
	icon = 'icons/obj/toy.dmi'
	icon_state = "assistant"
	inhand_icon_state = "doll"
	var/doll_name = "Dummy"

//Add changing looks when i feel suicidal about making 20 inhands for these.
/obj/item/toy/dummy/attack_self(mob/user)
	var/new_name = stripped_input(usr,"What would you like to name the dummy?","Input a name",doll_name,MAX_NAME_LEN)
	if(!new_name)
		return
	doll_name = new_name
	to_chat(user, "<span class='notice'>You name the dummy as \"[doll_name]\".</span>")
	name = "[initial(name)] - [doll_name]"

/obj/item/toy/dummy/talk_into(atom/movable/A, message, channel, list/spans, datum/language/language, list/message_mods)
	var/mob/M = A
	if (istype(M))
		M.log_talk(message, LOG_SAY, tag="dummy toy")

	say(message, language)
	return NOPASS

/obj/item/toy/dummy/GetVoice()
	return doll_name

/obj/item/toy/seashell
	name = "seashell"
	desc = "May you always have a shell in your pocket and sand in your shoes. Whatever that's supposed to mean."
	icon = 'icons/misc/beach.dmi'
	icon_state = "shell1"
	var/static/list/possible_colors = list("" =  2, COLOR_PURPLE_GRAY = 1, COLOR_OLIVE = 1, COLOR_PALE_BLUE_GRAY = 1, COLOR_RED_GRAY = 1)

/obj/item/toy/seashell/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	icon_state = "shell[rand(1,3)]"
	color = pickweight(possible_colors)
	setDir(pick(GLOB.cardinals))

/obj/item/toy/brokenradio
	name = "broken radio"
	desc = "An old radio that produces nothing but static when turned on."
	icon = 'icons/obj/toy.dmi'
	icon_state = "broken_radio"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/brokenradio/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 300)
		user.visible_message("<span class='notice'>[user] adjusts the dial on [src].</span>")
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/items/radiostatic.ogg', 50, FALSE), 0.5 SECONDS)
	else
		to_chat(user, "<span class='warning'>The dial on [src] jams up</span>")
		return

/obj/item/toy/braintoy
	name = "squeaky brain"
	desc = "A Mr. Monstrous brand toy made to imitate a human brain in smell and texture."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain-old"
	var/cooldown = 0

/obj/item/toy/braintoy/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 10)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/effects/blobattack.ogg', 50, FALSE), 0.5 SECONDS)


/*
 * Eldritch Toys
 */

/obj/item/toy/eldritch_book
	name = "Codex Cicatrix"
	desc = "A toy book that closely resembles the Codex Cicatrix. Covered in fake polyester human flesh and has a huge goggly eye attached to the cover. The runes are gibberish and cannot be used to summon demons... Hopefully?"
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("sacrifices", "transmutes", "graspes", "curses")
	attack_verb_simple = list("sacrifice", "transmute", "grasp", "curse")
	/// Helps determine the icon state of this item when it's used on self.
	var/book_open = FALSE

/obj/item/toy/eldritch_book/attack_self(mob/user)
	book_open = !book_open
	update_appearance()

/obj/item/toy/eldritch_book/update_icon_state()
	icon_state = book_open ? "book_open" : "book"
	return ..()

/*
 * Fake tear
 */

/obj/item/toy/reality_pierce
	name = "Pierced reality"
	desc = "Hah. You thought it was the real deal!"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"

/obj/item/storage/box/heretic_box
	name = "box of pierced realities"
	desc = "A box containing toys resembling pierced realities."

/obj/item/storage/box/heretic_box/PopulateContents()
	for(var/i in 1 to rand(1,4))
		new /obj/item/toy/reality_pierce(src)

#undef BALLOON_COLORS
