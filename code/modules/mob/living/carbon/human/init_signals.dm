/mob/living/carbon/human/register_init_signals()
	. = ..()
	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_SALUBRI_EYE), SIGNAL_REMOVETRAIT(TRAIT_SALUBRI_EYE)), PROC_REF(on_salubri_eye))

/mob/living/carbon/human/proc/on_salubri_eye()
	SIGNAL_HANDLER

	var/datum/action/salubri_eye/salubri_opener = new()
	if(HAS_TRAIT(src, TRAIT_SALUBRI_EYE))
		var/obj/item/organ/eyes/salubri = src.getorgan(/obj/item/organ/eyes)

		if(salubri)
			salubri.Remove(TRUE, FALSE)
		update_body()
		if(!(HAS_TRAIT_FROM(src, TRAIT_SALUBRI_EYE_OPEN, SALUBRI_EYE_TRAIT)))
			salubri_opener.Grant(src)
			ADD_TRAIT(src, TRAIT_SALUBRI_EYE_OPEN, SALUBRI_EYE_TRAIT)
	else
		var/obj/item/organ/eyes/salubri/salubri = new()
		salubri.Insert(TRUE, FALSE)
		update_body()
		salubri_opener.Remove(src)
		REMOVE_TRAIT(src, TRAIT_SALUBRI_EYE_OPEN, SALUBRI_EYE_TRAIT)

/*
		if(!(HAS_TRAIT_FROM(src, TRAIT_SALUBRI_EYE_OPEN, SALUBRI_EYE_TRAIT)))
			var/datum/action/salubri_eye/salubri_opener = new()
			salubri_opener.Grant(src)
			ADD_TRAIT(src, TRAIT_SALUBRI_EYE_OPEN, SALUBRI_EYE_TRAIT)
*/
