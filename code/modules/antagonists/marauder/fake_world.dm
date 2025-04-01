/obj/structure/fake_door
	icon = 'icons/marauder/dreamer_structures.dmi'
	icon_state = "door_closed"
	resistance_flags = INDESTRUCTIBLE

/turf/open/floor/plasteel/marauder
	icon = 'icons/marauder/dreamer_floors.dmi'
	icon_state = "polar"

/turf/open/floor/plasteel/marauder/setup_broken_states()
	return list("ldamaged1", "ldamaged2", "ldamaged3", "ldamaged4")

/turf/open/floor/plasteel/marauder/setup_burnt_states()
	return list("lscorched1", "lscorched2")

/turf/open/floor/plasteel/marauder/damaged
	icon_state = "ldamaged1"

/turf/open/floor/plasteel/marauder/damaged/Initialize(mapload)
	. = ..()
	break_tile()

//Mostly garbage related to the ending "cutscene"
/obj/item/clothing/head/cyberdeck
	name = "cyberdeck headset"
	desc = "Sweet dreams..."
	icon = 'icons/marauder/clothing.dmi'
	worn_icon = 'icons/marauder/clothing.dmi'
	onflooricon = 'icons/marauder/clothing.dmi'
	icon_state = "cyberdeck"
	armor = list("blunt" = 25, "slash" = 25, "stab" = 25, "piercing" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/under/vampire/office/trey_liam
	name = "TNC shirt"
	desc = "The Technocracy is the fairest organization I know, atleast I think?."

/datum/outfit/treyliam
	name = "Trey Liam"
	head = /obj/item/clothing/head/cyberdeck
	undershirt = /obj/item/clothing/under/vampire/office/trey_liam
	shoes = /obj/item/clothing/shoes/vampire/businessblack

/obj/effect/landmark/treyliam
	name = "trey"

/obj/item/gun/ballistic/vampire/revolver/last_resort
	name = "\proper last resort"
	desc = "There is always a way out."
