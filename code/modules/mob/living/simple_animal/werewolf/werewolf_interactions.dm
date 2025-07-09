/atom/proc/attack_werewolf(mob/living/carbon/werewolf/user, list/modifiers)
	attack_paw(user, modifiers)

/obj/item/attack_werewolf(mob/living/carbon/werewolf/user, list/modifiers)
	if (!user.can_hold_items(src))
		if (user.contents.Find(src))
			user.dropItemToGround(src)
		// Lupus and Corvids can only hold small and tiny items respectively
		if (iscorvid(user))
			to_chat(user, span_warning("\The [src] is too large to hold in your beak!"))
		else if (islupus(user))
			to_chat(user, span_warning("\The [src] is too large to hold in your mouth!"))

		return

	attack_paw(user, modifiers)
