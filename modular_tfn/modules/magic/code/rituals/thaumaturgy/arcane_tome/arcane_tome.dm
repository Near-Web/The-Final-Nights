/obj/item/arcane_tome
	name = "arcane tome"
	desc = "An archaic looking book."
	icon_state = "arcane"
	icon = 'modular_tfn/modules/magic/icons/arcane_tome.dmi'
	onflooricon = 'code/modules/wod13/onfloor.dmi'
	w_class = WEIGHT_CLASS_SMALL
	is_magic = TRUE

/obj/item/arcane_tome/attack_self(mob/user)
	. = ..()
	to_chat(user, span_notice("You don't know any rituals!"))
