/obj/item/arcane_tome
	name = "arcane tome"
	desc = "The secrets of Blood Magic..."
	icon_state = "arcane"
	icon = 'modular_tfn/modules/magic/icons/arcane_tome.dmi'
	onflooricon = 'code/modules/wod13/onfloor.dmi'
	w_class = WEIGHT_CLASS_SMALL
	is_magic = TRUE

/obj/item/arcane_tome/Initialize()
	. = ..()
	for(var/i in subtypesof(/obj/ritualrune))
		if(i)
			var/obj/ritualrune/R = new i(src)
			rituals |= R

/obj/item/arcane_tome/attack_self(mob/user)
	. = ..()
	for(var/obj/ritualrune/R in rituals)
		if(R)
			if(R.sacrifices.len > 0)
				var/list/required_items = list()
				for(var/item_type in R.sacrifices)
					var/obj/item/I = new item_type(src)
					required_items += I.name
					qdel(I)
				var/required_list
				if(required_items.len == 1)
					required_list = required_items[1]
				else
					for(var/item_name in required_items)
						required_list += (required_list == "" ? item_name : ", [item_name]")
				to_chat(user, "[R.thaumlevel] [R.name] - [R.desc] Requirements: [required_list].")
			else
				to_chat(user, "[R.thaumlevel] [R.name] - [R.desc]")
