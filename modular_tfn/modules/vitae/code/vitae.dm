/datum/reagent/blood/vitae
	name = "Vitae"
	description = "It seems to be slightly glowing blood."
	reagent_state = LIQUID
	color = "#fc0000"
	self_consuming = TRUE
	metabolization_rate = 100 * REAGENTS_METABOLISM // Vitae is supposed to instantly be consumed by the organism.
	can_synth = FALSE
	glass_name = "glass of blood"
	glass_desc = "It seems to be a glass full of slightly glowing blood."

/datum/reagent/blood/vitae/on_mob_life(mob/living/carbon/human/victim)
	//Cant use a switch here since isblank checks dont have proper syntax.
	if(isghoul(victim) || iskindred(victim))
		if(current_cycle >= 10)

			victim.update_blood_hud()
	return ..()

/datum/reagent/blood/vitae/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()

	if(!ishuman(exposed_mob)) //We do not have vitae implementations for non-human mobs.
		return

	if(ishumanbasic(exposed_mob)) //Are we a human species?
		if(exposed_mob.stat == DEAD) //If the human we are being added to is dead, embrace them.
			var/mob/living/carbon/human/embracer = data["donor"]
			embracer.attempt_embrace_target(exposed_mob, (usr == data["donor"]) ? null : usr)
			return
		else //Otherwise, ghoul them, since they aren't dead.
			var/mob/living/carbon/human/victim = exposed_mob
			victim.ghoulificate(data["donor"])
			victim.prompt_permenant_ghouling()
			return
	if(isghoul(exposed_mob)) //Are we a ghoul  species?
		if(exposed_mob.stat == DEAD) //If the ghoul we are being added to is dead, embrace them.
			var/mob/living/carbon/human/embracer = data["donor"]
			embracer.attempt_embrace_target(exposed_mob, (usr == data["donor"]) ? null : usr)
			return
		else
			victim.bloodpool = min(victim.maxbloodpool, victim.bloodpool+1) //Otherwise, they just consume vitae normally.
			send_ghoul_vitae_consumption_message(data["donor"])
	if(iskindred(exposed_mob)) //Are we a kindred species?
		victim.bloodpool = min(victim.maxbloodpool, victim.bloodpool+1)
		if(data["donor"])
			victim.apply_status_effect(STATUS_EFFECT_INLOVE, data["donor"])
	if(isgarou(expose_mob)) //Are we a garou species?
		exposed_mob.rollfrenzy()
