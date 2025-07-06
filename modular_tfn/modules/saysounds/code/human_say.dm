/mob/living/carbon/human/proc/send_voice(message, skip_thingy)
	if(!message || !length(message))
		return
	if(dna.species)
		dna.species.send_voice(src)

/mob/living/carbon/human/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, message_mods, original_message)
	. = ..()
	if(!message_mods[WHISPER_MODE])
		send_voice(message)

/datum/species/proc/send_voice(mob/living/L)
	// Only play sounds for mobs with a ckey (player-controlled)
	if(!L.ckey)
		return

	// Get the client's vocal sound preference
	var/vocal_sound_pref = "Talk" // Default fallback
	if(L.client?.prefs?.vocal_sound)
		vocal_sound_pref = L.client.prefs.vocal_sound

	// Play the appropriate sound based on preference
	switch(vocal_sound_pref)
		if("Talk")
			playsound(get_turf(L), 'modular_tfn/modules/saysounds/sounds/talk.ogg', 50, FALSE, -1)
		if("Pencil")
			playsound(get_turf(L), 'modular_tfn/modules/saysounds/sounds/pencil.ogg', 50, FALSE, -1)
		if("None")
			return // Don't play any sound
		else
			playsound(get_turf(L), 'modular_tfn/modules/saysounds/sounds/talk.ogg', 50, FALSE, -1) // Default fallback
