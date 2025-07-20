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
	var/vocal_sound_pref = L.client?.prefs?.vocal_sound || "Talk"

	// Determine the sound file based on preference
	var/sound_file
	switch(vocal_sound_pref)
		if("Talk")
			sound_file = 'modular_tfn/modules/saysounds/sounds/talk.ogg'
		if("Pencil")
			sound_file = 'modular_tfn/modules/saysounds/sounds/pencil.ogg'
		if("None")
			return // Don't play any sound
		else
			sound_file = 'modular_tfn/modules/saysounds/sounds/talk.ogg' // Default fallback

	// Build a list of clients who want to hear vocal sounds
	var/list/clients_to_play_to = list()

	// Use viewers() to include the speaker and everyone who can see them
	for(var/mob/M in hearers(world.view, get_turf(L)))
		if(M.client && !M.client.prefs?.disable_vocal_sounds)
			clients_to_play_to += M.client

	// Play the sound only to those clients who want to hear it
	if(length(clients_to_play_to))
		for(var/client/C in clients_to_play_to)
			C << sound(sound_file)
