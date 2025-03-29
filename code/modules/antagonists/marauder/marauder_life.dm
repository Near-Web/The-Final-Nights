//Processing procs related to dreamer, so he hallucinates and shit
/datum/antagonist/marauder/process()
	if(!owner.current || triumphed)
		STOP_PROCESSING(SSobj, src)
		return
	handle_marauder_visions(owner.current, hallucinations)
	if(waking_up)
		handle_waking_up(owner.current)
	else
		handle_marauder_hallucinations(owner.current)
	//handle_marauder_floors(owner.current)
	handle_marauder_walls(owner.current)


/proc/handle_marauder_visions(mob/living/target, atom/movable/screen/fullscreen/marauder/hallucinations)
	if(prob(4))
		hallucinations.jumpscare(target)
	//Random laughter
	else if(prob(2))
		var/static/list/funnies = list(
			'sound/marauder/comic1.ogg',
			'sound/marauder/comic2.ogg',
			'sound/marauder/comic3.ogg',
			'sound/marauder/comic4.ogg',
		)
		target.playsound_local(target, pick(funnies), vol = 100, vary = FALSE)

/proc/handle_marauder_hallucinations(mob/living/target)
	//Chasing mob
	if(prob(1))
		INVOKE_ASYNC(target, GLOBAL_PROC_REF(handle_marauder_mob_hallucination), target)
	//Talking objects
	else if(prob(4))
		INVOKE_ASYNC(target, GLOBAL_PROC_REF(handle_marauder_object_hallucination), target)
	//Meta hallucinations
	else if(prob(1) && prob(5))
		INVOKE_ASYNC(target, GLOBAL_PROC_REF(handle_marauder_admin_bwoink_hallucination), target)
	else if(prob(1) && prob(2))
		INVOKE_ASYNC(target, GLOBAL_PROC_REF(handle_marauder_admin_ban_hallucination), target)

/proc/handle_marauder_object_hallucination(mob/living/target)
	var/list/objects = list()

	for(var/obj/object in view(target))
		if((object.invisibility > target.see_invisible) || !object.loc || !object.name)
			continue
		var/weight = 1
		if(isitem(object))
			weight = 3
		else if(isstructure(object))
			weight = 2
		else if(ismachinery(object))
			weight = 2
		objects[object] = weight
	objects -= target.contents

	if(!length(objects))
		return

	var/static/list/speech_sounds = list(
		'sound/marauder/female_talk1.ogg',
		'sound/marauder/female_talk2.ogg',
		'sound/marauder/female_talk3.ogg',
		'sound/marauder/female_talk4.ogg',
		'sound/marauder/female_talk5.ogg',
		'sound/marauder/male_talk1.ogg',
		'sound/marauder/male_talk2.ogg',
		'sound/marauder/male_talk3.ogg',
		'sound/marauder/male_talk4.ogg',
		'sound/marauder/male_talk5.ogg',
		'sound/marauder/male_talk6.ogg',
	)

	var/obj/speaker = pickweight(objects)
	var/speech
	if(prob(1))
		speech = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"
	else
		speech = pick_list_replacements("marauder.json", "dreamer_object")
		speech = replacetext(speech, "%OWNER", "[target.real_name]")
	var/language = target.get_random_understood_language()
	var/message = target.compose_message(speaker, language, speech)
	target.playsound_local(target, pick(speech_sounds), vol = 60, vary = FALSE)
	if(target.client?.prefs?.chat_on_map)
		target.create_chat_message(speaker, language, speech, spans = list(target.speech_span))
	to_chat(target, message)

/proc/handle_marauder_mob_hallucination(mob/living/target)
	if(!target.client)
		return

	var/mob_message = pick("It's mom!", "I have to HURRY UP!", "They are CLOSE!","They are NEAR!")
	var/turf/spawning_turf
	var/list/turf/spawning_turfs = list()
	for(var/turf/turf in view(target))
		spawning_turfs += turf
	if(length(spawning_turfs))
		spawning_turf = pick(spawning_turfs)
	if(!spawning_turf)
		return
	var/mob_state = pick("mom", "shadow", "deepone")
	if(mob_message == "It's mom!")
		mob_state = "mom"
	var/image/mob_image = image('icons/marauder/dreamer_mobs.dmi', spawning_turf, mob_state, FLOAT_LAYER, get_dir(spawning_turf, target))
	mob_image.plane = FLY_LAYER
	target.client.images += mob_image
	to_chat(target, span_userdanger("<span class='big'>[mob_message]</span>"))
	addtimer(CALLBACK(target, GLOBAL_PROC_REF(marauder_chase_stage1), target, spawning_turf, mob_image), 5 SECONDS)

/proc/marauder_chase_stage1(mob/living/target, turf/spawning_turf, image/mob_image)
	if(!target?.client)
		return
	var/static/list/spookies = pick(
		'sound/marauder/hall_attack1.ogg',
		'sound/marauder/hall_attack2.ogg',
		'sound/marauder/hall_attack3.ogg',
		'sound/marauder/hall_attack4.ogg',
	)
	target.playsound_local(target, pick(spookies), 100)
	var/chase_tiles = 7
	var/chase_wait = rand(4,6)
	var/caught_dreamer = FALSE
	var/turf/current_turf = spawning_turf
	while(chase_tiles > 0)
		if(!target?.client)
			return
		var/face_direction = get_dir(current_turf, target)
		current_turf = get_step(current_turf, face_direction)
		if(!current_turf)
			break
		mob_image.dir = face_direction
		mob_image.loc = current_turf
		if(current_turf == get_turf(target))
			caught_dreamer = TRUE
			break
		chase_tiles--

	addtimer(CALLBACK(target, GLOBAL_PROC_REF(marauder_chase_stage2), target, caught_dreamer, chase_wait, mob_image), chase_wait SECONDS)

/proc/marauder_chase_stage2(mob/living/target, caught_dreamer, chase_wait, image/mob_image)
	if(!target?.client)
		return
	if(caught_dreamer)
		target.Stun(rand(2, 4) SECONDS)
		var/pain_message = pick("NO!", "THEY GOT ME!", "AGH!")
		to_chat(target, span_userdanger("[pain_message]"))

	addtimer(CALLBACK(target, GLOBAL_PROC_REF(marauder_chase_stage3), target, mob_image), chase_wait SECONDS)

/proc/marauder_chase_stage3(mob/living/target, image/mob_image)
	if(!target?.client)
		return
	target.client.images -= mob_image

/proc/handle_marauder_floors(mob/living/target)
	return

/proc/handle_marauder_floor(turf/open/floor, mob/living/target)
	return

/proc/handle_marauder_walls(mob/living/target)
	if(!target.client)
		return
	//Shit on THA walls
	for(var/turf/closed/wall in view(target))
		if(!prob(4))
			continue
		INVOKE_ASYNC(target, GLOBAL_PROC_REF(handle_marauder_wall), wall, target)

/proc/handle_marauder_wall(turf/closed/wall, mob/living/target)
	var/image/shit = image('icons/marauder/shit.dmi', wall, "splat[rand(1,8)]")
	target.client?.images += shit
	var/offset = pick(-1, 1, 2)
	var/disappearfirst = rand(2 SECONDS, 4 SECONDS)
	animate(shit, pixel_y = offset, time = disappearfirst, flags = ANIMATION_RELATIVE)
	addtimer(CALLBACK(target, GLOBAL_PROC_REF(marauder_wall_stage1), target, offset, shit), disappearfirst, TIMER_CLIENT_TIME)

/proc/marauder_wall_stage1(mob/living/target, offset, image/shit)
	var/disappearsecond = rand(2 SECONDS, 4 SECONDS)
	animate(shit, pixel_y = -offset, time = disappearsecond, flags = ANIMATION_RELATIVE)
	addtimer(CALLBACK(target, GLOBAL_PROC_REF(marauder_wall_stage2), target, shit), disappearsecond, TIMER_CLIENT_TIME)

/proc/marauder_wall_stage2(mob/living/target, image/shit)
	target.client?.images -= shit

/datum/antagonist/marauder/proc/handle_waking_up(mob/living/dreamer)
	if(!dreamer.client)
		return
	if(prob(2.5))
		dreamer.emote("laugh")
	//Floors go crazier go stupider
	for(var/turf/open/floor in view(dreamer))
		if(!prob(20))
			continue
		INVOKE_ASYNC(src, PROC_REF(handle_waking_up_floor), floor, dreamer)

/datum/antagonist/marauder/proc/handle_waking_up_floor(turf/open/floor, mob/living/dreamer)
	var/mutable_appearance/fake_floor = image('icons/marauder/dreamer_floors.dmi', floor,  pick("rcircuitanim", "gcircuitanim"), floor.layer + 0.1)
	dreamer.client.images += fake_floor
	var/offset = pick(-1, 1, 2)
	var/disappearfirst = 3 SECONDS
	animate(fake_floor, pixel_y = offset, time = disappearfirst, flags = ANIMATION_RELATIVE)
	addtimer(CALLBACK(dreamer, PROC_REF(marauder_floor_stage1), dreamer, offset, fake_floor), disappearfirst, TIMER_CLIENT_TIME)

/datum/antagonist/marauder/proc/marauder_floor_stage1(mob/living/dreamer, offset, mutable_appearance/fake_floor)
	var/disappearsecond = 3 SECONDS
	animate(fake_floor, pixel_y = -offset, time = disappearsecond, flags = ANIMATION_RELATIVE)
	addtimer(CALLBACK(dreamer, PROC_REF(marauder_floor_stage2), dreamer, fake_floor), disappearsecond, TIMER_CLIENT_TIME)

/datum/antagonist/marauder/proc/marauder_floor_stage2(mob/living/dreamer, mutable_appearance/fake_floor)
	dreamer.client?.images -= fake_floor

/proc/handle_marauder_admin_bwoink_hallucination(mob/living/target)
	var/fakemin = "Trey Liam"
	if(length(GLOB.admin_datums))
		var/datum/admins/badmin = GLOB.admin_datums[pick(GLOB.admin_datums)]
		if(badmin?.owner?.key)
			fakemin = badmin.owner.key
	var/message = ""
	message = pick_list_replacements("marauder.json", "dreamer_ahelp")
	to_chat(target, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
	to_chat(target, span_adminsay("Admin PM from-<b><span style='color: #0b4990;'>[fakemin]</span></b>: [message]"))
	to_chat(target, span_adminsay("<i>Click on the administrator's name to die.</i>"))
	SEND_SOUND(target, sound('sound/effects/adminhelp.ogg'))

/proc/handle_marauder_admin_ban_hallucination(mob/living/target)
	var/fakemin = "Trey Liam"
	if(length(GLOB.admin_datums))
		var/datum/admins/badmin = GLOB.admin_datums[pick(GLOB.admin_datums)]
		if(badmin?.owner?.key)
			fakemin = badmin.owner.key
	var/message = ""
	var/ban_appeal = pick("your grave", "WAKE UP WAKE UP WAKE UP")
	message = pick_list_replacements("marauder.json", "dreamer_ban")
	to_chat(target, span_boldannounce("<BIG>You have been banned by [fakemin] from the server.\nReason: [message]</BIG>"))
	to_chat(target, span_boldannounce("This is a permanent ban. The round ID is [GLOB.round_id]."))
	to_chat(target, span_boldannounce("To appeal this ban go to <span style='color: #0099cc;'>[ban_appeal].</span>"))
	to_chat(target, "<div class='connectionClosed internal'>You are either AFK, experiencing lag or the connection has closed.</div>")
	SEND_SOUND(target, sound(null))
