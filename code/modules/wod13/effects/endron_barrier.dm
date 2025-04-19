/obj/effect/vip_barrier/endron
	name = "Employees Only Area"
	desc = "Marks the zone where the Corporate slaves work, and the citizens watch."
	protected_zone_id = "endron"
	social_roll_difficulty = 9

/obj/effect/vip_barrier/endron/endron_2
	protected_zone_id = "endron_2"

/obj/effect/vip_barrier/endron/endron_backdoor
	protected_zone_id = "endron_backdoor"

/obj/effect/vip_barrier/endron/endron_lab
	protected_zone_id = "endron_lab"

/obj/effect/vip_barrier/endron/check_entry_permission_custom(var/mob/living/carbon/human/entering_mob)
	if(iskindred(entering_mob) || isghoul(entering_mob))
		return TRUE
	return FALSE
