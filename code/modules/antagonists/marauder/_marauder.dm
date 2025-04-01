/datum/objective/marauder
	name = "WAKE UP"
	explanation_text = "FOLLOWING my HEART shall be the WHOLE of the law."

/datum/antagonist/marauder
	name = "Marauder"
	roundend_category = "marauders"
	antagpanel_category = "Marauder"
	antag_memory = "<b>Recently I've been visited by a lot of VISIONS. They're all about another WORLD, ANOTHER life. I will do EVERYTHING to know the TRUTH, and return to the REAL world.</b>"
	job_rank = ROLE_MARAUDER
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "villain"
	/// Traits we apply to the owner
	var/static/list/applied_traits = list(
		TRAIT_EMPATH,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_SCHIZO_AMBIENCE,
		TRAIT_NOBLEED,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHUNGER,
		TRAIT_SURGEON,
		TRAIT_NIGHT_VISION,
	)
	/// Traits that only get applied in the final sequence
	var/static/list/final_traits = list(
		TRAIT_MARAUDER_AWOKEN,
		TRAIT_SCREENSHAKE,
	)
	/// Weapons we can give to the dreamer
	var/static/list/possible_weapons = list(
		/obj/item/vamp/keys,
	)
	/// Wonder recipes
	var/static/list/recipe_progression = list(
		/datum/crafting_recipe/structure/wonder/first,
		/datum/crafting_recipe/structure/wonder/second,
		/datum/crafting_recipe/structure/wonder/third,
		/datum/crafting_recipe/structure/wonder/fourth,
	)
	/// Key number > Key text
	var/list/num_keys = list()
	/// Key text > key number
	var/list/key_nums = list()
	/// Every heart inscryption we have seen
	var/list/hearts_seen = list()
	/// Sum of the numbers of every key
	var/sum_keys = 0
	/// Keeps track of which wonder we are gonna make next
	var/current_wonder = 1
	/// Set to TRUE when we are on the last wonder (waking up)
	var/waking_up = FALSE
	/// Set to true when we WIN and are on the ending sequence
	var/triumphed = FALSE
	/// Wonders we have made
	var/list/wonders_made = list()
	/// Hallucinations screen object
	var/atom/movable/screen/fullscreen/marauder/hallucinations
	/// Film grain screen object
	var/atom/movable/screen/fullscreen/film_grain
	/// Special items that can be drawn from certain structures
	var/list/special_items = list()

GLOBAL_VAR_INIT(marauder_highlander, 0) // THERE CAN ONLY BE ONE!

/datum/antagonist/marauder/New()
	set_keys()
	load_strings_file("marauder.json")
	return ..()

/datum/antagonist/marauder/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/antagonist/marauder/on_gain()
	. = ..()
	//SSfake_world.should_bother = TRUE
	owner.special_role = ROLE_MARAUDER
	special_items["Marauder"] = pick(possible_weapons)
	special_items["Surgical Kit"] = /obj/item/storage/backpack/duffelbag/sec/surgery
	if(owner.current)
		if(ishuman(owner.current))
			var/mob/living/carbon/human/dreamer = owner.current
			regenerate_stats(dreamer)
			var/obj/item/organ/heart/heart = dreamer.getorganslot(ORGAN_SLOT_HEART)
			if(heart) // clear any inscryptions, in case of being made marauder midround
				heart.inscryptions = list()
				heart.inscryption_keys = list()
				heart.marauders2wonder_ids = list()
				heart.marauders = list()
		for(var/trait in applied_traits)
			ADD_TRAIT(owner.current, trait, "[type]")
		hallucinations = owner.current.overlay_fullscreen("marauder", /atom/movable/screen/fullscreen/marauder)
		film_grain = owner.current.overlay_fullscreen("film_grain", /atom/movable/screen/fullscreen/film_grain)
		film_grain.icon_state = "[rand(1, 9)]h"
	LAZYINITLIST(owner.learned_recipes)
	owner.learned_recipes |= recipe_progression[1]
	forge_villain_objectives()
	if(length(objectives))
		SEND_SOUND(owner.current, 'sound/marauder/ascendant_intro.ogg')
		to_chat(owner.current, span_danger("[antag_memory]"))
		owner.announce_objectives()
	START_PROCESSING(SSobj, src)

/datum/antagonist/marauder/on_removal()
	STOP_PROCESSING(SSobj, src)
	if(owner.current)
		if(!silent)
			to_chat(owner.current,span_danger("I am no longer a MARAUDER!"))
		if(ishuman(owner.current))
			var/mob/living/carbon/human/dreamer = owner.current
			var/client/clinet = dreamer?.client
			if(clinet) //clear screenshake animation
				animate(clinet, dreamer.pixel_y)
		for(var/trait in applied_traits)
			REMOVE_TRAIT(owner.current, trait, "[type]")
		for(var/trait in final_traits)
			REMOVE_TRAIT(owner.current, trait, "[type]")
		owner.current.clear_fullscreen("marauder")
	QDEL_LIST(wonders_made)
	wonders_made = null
	owner.learned_recipes -= recipe_progression
	owner.special_role = null
	hallucinations = null
	return ..()

/datum/antagonist/marauder/proc/regenerate_stats(mob/living/carbon/human/dreamer)
	dreamer.physique = 5
	dreamer.additional_physique = 5
	dreamer.dexterity = 5
	dreamer.additional_dexterity = 5
	dreamer.lockpicking = 5
	dreamer.additional_lockpicking = 5
	dreamer.athletics = 5
	dreamer.additional_athletics = 5
	dreamer.mentality = 5
	dreamer.additional_mentality = 5

	dreamer.maxHealth = round((initial(dreamer.maxHealth)+(initial(dreamer.maxHealth)/4)*(dreamer.physique + dreamer.additional_physique)))
	dreamer.health = dreamer.maxHealth

/datum/antagonist/marauder/proc/set_keys()
	key_nums = list()
	num_keys = list()
	//We need 4 numbers and four keys
	for(var/i in 1 to 4)
		//Make the number first
		var/randumb
		while(!randumb || (randumb in num_keys))
			randumb = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"
		//Make the key second
		var/rantelligent
		while(!rantelligent || (rantelligent in key_nums))
			rantelligent = uppertext("[pick(GLOB.alphabet)][pick(GLOB.alphabet)][pick(GLOB.alphabet)][pick(GLOB.alphabet)]")

		//Stick then in the lists, continue the loop
		num_keys[randumb] = rantelligent
		key_nums[rantelligent] = randumb

	sum_keys = 0
	for(var/i in num_keys)
		sum_keys += text2num(i)

/datum/antagonist/marauder/proc/forge_villain_objectives()
	var/datum/objective/marauder/wakeup = new()
	objectives += wakeup

/datum/antagonist/marauder/proc/agony(mob/living/carbon/dreamer)
	var/sound/im_sick = sound('sound/marauder/imsick.ogg', TRUE, FALSE, CHANNEL_DREAMER, 100)
	SEND_SOUND(dreamer, im_sick)
	dreamer.overlay_fullscreen("dream", /atom/movable/screen/fullscreen/dreaming)
	dreamer.overlay_fullscreen("wakeup", /atom/movable/screen/fullscreen/dreaming/waking_up)
	for(var/trait in final_traits)
		ADD_TRAIT(dreamer, trait, "[type]")
	waking_up = TRUE

/datum/antagonist/marauder/proc/spawn_trey_liam()
	var/turf/spawnturf
	var/obj/effect/landmark/treyliam/trey = locate(/obj/effect/landmark/treyliam) in GLOB.landmarks_list
	if(trey)
		spawnturf = get_turf(trey)
	if(spawnturf)
		var/mob/living/carbon/human/trey_liam = new /mob/living/carbon/human(spawnturf)
		trey_liam.fully_replace_character_name(trey_liam.name, "Trey Liam")
		trey_liam.gender = MALE
		trey_liam.skin_tone = "ffe0d1"
		trey_liam.hair_color = "999999"
		trey_liam.hairstyle = "Plain Long"
		trey_liam.facial_hair_color = "999999"
		trey_liam.facial_hairstyle = "Knowledge"
		trey_liam.age = 90
		trey_liam.equipOutfit(/datum/outfit/treyliam)
		trey_liam.regenerate_icons()
		for(var/obj/structure/chair/chair in spawnturf)
			chair.buckle_mob(trey_liam)
			break
		return trey_liam
	return

/datum/antagonist/marauder/proc/wake_up()
	if(GLOB.marauder_highlander) // another Marauder has TRIUMPHED before we could
		if(src.owner && src.owner.current)
			var/straggler = src.owner.current
			to_chat(straggler, span_danger("IT'S NO USE! I CAN'T WAKE UP!"))
		return
	GLOB.marauder_highlander = 1
	STOP_PROCESSING(SSobj, src)
	triumphed = TRUE
	waking_up = FALSE
	var/mob/living/carbon/dreamer = owner.current
	dreamer.log_message("prayed their sum ([sum_keys]), beginning the Marauder TRIUMPH sequence and the end of the round.", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(dreamer)] as Marauder TRIUMPHED[sum_keys ? " with sum [sum_keys]" : ""]. The round will end shortly.")
	// var/client/dreamer_client = dreamer.client // Trust me, we need it later
	to_chat(dreamer, "...It couldn't be.")
	dreamer.clear_fullscreen("dream")
	dreamer.clear_fullscreen("wakeup")
	var/client/clinet = dreamer?.client
	if(clinet) //clear screenshake animation
		animate(clinet, dreamer.pixel_y)
	for(var/datum/objective/objective in objectives)
		objective.completed = TRUE
	for(var/mob/connected_player in GLOB.player_list)
		if(!connected_player.client)
			continue
		SEND_SOUND(connected_player, sound(null))
		SEND_SOUND(connected_player, 'sound/marauder/dreamer_win.ogg')
	var/mob/living/carbon/human/trey_liam = PROC_REF(spawn_trey_liam)
	if(trey_liam)
		owner.transfer_to(trey_liam)
		//Explodie all our wonders
		for(var/obj/structure/wonder/wondie as anything in wonders_made)
			if(istype(wondie))
				explosion(wondie, 8, 16, 32, 64)
		var/obj/item/organ/brain/brain = dreamer.getorganslot(ORGAN_SLOT_BRAIN)
		var/obj/item/bodypart/head/head = dreamer.get_bodypart(BODY_ZONE_HEAD)
		if(head)
			head.dismember(BURN)
			if(!QDELETED(head))
				qdel(head)
		if(brain)
			qdel(brain)
		cull_competitors(trey_liam)
		trey_liam.SetSleeping(25 SECONDS)
		// TODO: replace with addtimer
		sleep(1.5 SECONDS)
		to_chat(trey_liam, span_deadsay("<span class='reallybig'>... WHERE AM I? ...</span>"))
		// TODO: replace with addtimer
		sleep(1.5 SECONDS)
		var/static/list/slop_lore = list(
			span_deadsay("... San Francisco? 2015? No ... That can't be ..."),
			span_deadsay("... My name is Trey. Trey Liam, Scientific Overseer ..."),
			span_deadsay("... I'm on the Aeon, a self sustaining ship, used to preserve what remains of humanity ..."),
			span_deadsay("... Launched into the stars, preserving their memories ... Their personalities ..."),
			span_deadsay("... Keeps them alive in cyberspace, oblivious to the catastrophe of 1999 ..."),
			span_deadsay("... There is no hope left. Only the cyberspace deck lets me live in the forgery ..."),
			span_deadsay("... What have I done!? ..."),
		)
		for(var/slop in slop_lore)
			to_chat(trey_liam, slop)
			// TODO: replace with addtimer
			sleep(3 SECONDS)
	else
		INVOKE_ASYNC(src, PROC_REF(cant_wake_up), dreamer)
		cull_competitors(dreamer)
	// TODO: replace with addtimer
	sleep(15 SECONDS)
	to_chat(world, span_deadsay("<span class='reallybig'>The Marauder has AWAKENED!</span>"))
	SSticker.declare_completion()

/datum/antagonist/marauder/proc/cant_wake_up(mob/living/dreamer)
	if(!iscarbon(dreamer))
		return
	to_chat(dreamer, span_deadsay("<span class='reallybig'>I CAN'T WAKE UP.</span>"))
	// TODO: replace with addtimer
	sleep(2 SECONDS)
	for(var/i in 1 to 10)
		to_chat(dreamer, span_deadsay("<span class='reallybig'>ICANTWAKEUP</span>"))
		// TODO: replace with addtimer
		sleep(0.5 SECONDS)
	var/obj/item/organ/brain/brain = dreamer.getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/bodypart/head/head = dreamer.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.dismember(BURN)
		if(!QDELETED(head))
			qdel(head)
	if(brain)
		qdel(brain)

// Culls any living marauders in the world apart from the victor.
/datum/antagonist/marauder/proc/cull_competitors(mob/living/carbon/victor)
	for(var/mob/living/carbon/C in GLOB.carbon_list - victor)
		var/datum/antagonist/marauder/competitor = C.mind?.has_antag_datum(/datum/antagonist/marauder)
		if(competitor)
			STOP_PROCESSING(SSobj, competitor)
			competitor.waking_up = FALSE
			C.clear_fullscreen("dream")
			C.clear_fullscreen("wakeup")
			//clear screenshake animation. traits need to be removed in case the guy ghosts in cmode
			var/client/cnc = C?.client
			if(cnc)
				animate(cnc, C.pixel_y)
			REMOVE_TRAIT(C, TRAIT_SCREENSHAKE, "/datum/antagonist/marauder")
			REMOVE_TRAIT(C, TRAIT_SCHIZO_AMBIENCE, "/datum/antagonist/marauder")
			C.log_message("was culled by the TRIUMPH of Marauder [key_name(victor)].", LOG_GAME)
			// TODO: replace with addtimer
			sleep(1 SECONDS)
			to_chat(C, span_userdanger("What?! No, no, this can't be!"))
			// TODO: replace with addtimer
			sleep(2 SECONDS)
			to_chat(C, span_userdanger("How can I be TOO LATE-"))
			// TODO: replace with addtimer
			sleep(1 SECONDS)
			INVOKE_ASYNC(src, PROC_REF(cant_wake_up), C)
			QDEL_LIST(competitor.wonders_made)
			competitor.wonders_made = null

//TODO Collate
/datum/antagonist/roundend_report()
	var/traitorwin = TRUE

	to_chat(world, printplayer(owner))

	var/count = 0
	if(objectives.len)//If the traitor had no objectives, don't need to process this.
		for(var/datum/objective/objective in objectives)
			objective.update_explanation_text()
			if(objective.check_completion())
				to_chat(world, "<B>#[count]</B>: [objective.explanation_text] <span class='greentext'>AWAKENED!</span>")
			else
				to_chat(world, "<B>#[count]</B>: [objective.explanation_text] <span class='redtext'>Failure.</span>")
				traitorwin = FALSE

	var/special_role_text = lowertext(name)
	if(!considered_alive(owner))
		traitorwin = FALSE

	if(traitorwin)
		to_chat(world, span_greentext("The [special_role_text] has AWAKENED!"))
	else
		to_chat(world, span_redtext("The [special_role_text] has FAILED!"))
