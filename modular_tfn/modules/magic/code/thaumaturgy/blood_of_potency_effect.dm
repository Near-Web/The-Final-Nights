/datum/status_effect/blood_of_potency
	id = "blood_of_potency"
	duration = 1 INGAME_HOURS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/blood_of_potency

/datum/status_effect/blood_of_potency/on_creation(mob/living/new_owner, generation, time)
	. = ..()
	duration = time
	owner.generation = generation
	owner.maxbloodpool = 10 + ((13 - generation) * 3)

/datum/status_effect/blood_of_potency/on_remove()
	. = ..()
	owner.generation = initial(owner.generation)
	owner.maxbloodpool = initial(owner.maxbloodpool)
	if(owner.bloodpool > owner.maxbloodpool)
		owner.bloodpool = owner.maxbloodpool

/atom/movable/screen/alert/status_effect/blood_of_potency
	name = "Blood of Potency"
	desc = "You can feel your blood being stronger!"
	icon_state = "blooddrunk"
