/mob/living/carbon/human/proc/send_voice(message, skip_thingy)
	if(!message || !length(message))
		return
	if(dna.species)
		dna.species.send_voice(src)

/mob/living/carbon/human/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, message_mods, original_message)
	. = ..()
	if(!message_mods[WHISPER_MODE])
		send_voice(message)

/datum/species/proc/send_voice(mob/living/carbon/human/H)
	playsound(get_turf(H), 'modular_tfn/modules/saysounds/sounds/talk.ogg', 100, FALSE, -1)
