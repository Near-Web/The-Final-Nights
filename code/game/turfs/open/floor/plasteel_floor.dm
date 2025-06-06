/turf/open/floor/plasteel
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/plasteel/setup_broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/plasteel/setup_burnt_states()
	return list("floorscorched1", "floorscorched2")


/turf/open/floor/plasteel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's a <b>small crack</b> on the edge of it.</span>"


/turf/open/floor/plasteel/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	ChangeTurf(/turf/open/floor/plating/rust)


/turf/open/floor/plasteel/update_icon_state()
	if(broken || burnt)
		return ..()
	icon_state = base_icon_state
	return ..()


/turf/open/floor/plasteel/airless

/turf/open/floor/plasteel/telecomms

/turf/open/floor/plasteel/icemoon

/turf/open/floor/plasteel/dark
	icon_state = "darkfull"
	base_icon_state = "darkfull"

/turf/open/floor/plasteel/dark/airless

/turf/open/floor/plasteel/dark/telecomms

/turf/open/floor/plasteel/airless/dark
	icon_state = "darkfull"
	base_icon_state = "darkfull"

/turf/open/floor/plasteel/dark/side
	icon_state = "dark"
	base_icon_state = "dark"

/turf/open/floor/plasteel/dark/corner
	icon_state = "darkcorner"
	base_icon_state = "darkcorner"

/turf/open/floor/plasteel/checker
	icon_state = "checker"
	base_icon_state = "checker"


/turf/open/floor/plasteel/white
	icon_state = "white"
	base_icon_state = "white"

/turf/open/floor/plasteel/white/side
	icon_state = "whitehall"
	base_icon_state = "whitehall"

/turf/open/floor/plasteel/white/corner
	icon_state = "whitecorner"
	base_icon_state = "whitecorner"

/turf/open/floor/plasteel/airless/white
	icon_state = "white"
	base_icon_state = "white"

/turf/open/floor/plasteel/airless/white/side
	icon_state = "whitehall"
	base_icon_state = "whitehall"

/turf/open/floor/plasteel/airless/white/corner
	icon_state = "whitecorner"
	base_icon_state = "whitecorner"

/turf/open/floor/plasteel/white/telecomms

/turf/open/floor/plasteel/airless/showroomfloor
	icon_state = "showroomfloor"
	base_icon_state = "showroomfloor"


/turf/open/floor/plasteel/yellowsiding
	icon_state = "yellowsiding"
	base_icon_state = "yellowsiding"

/turf/open/floor/plasteel/yellowsiding/corner
	icon_state = "yellowcornersiding"
	base_icon_state = "yellowcornersiding"


/turf/open/floor/plasteel/recharge_floor
	icon_state = "recharge_floor"
	base_icon_state = "recharge_floor"

/turf/open/floor/plasteel/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"
	base_icon_state = "recharge_floor_asteroid"


/turf/open/floor/plasteel/chapel
	icon_state = "chapel"
	base_icon_state = "chapel"

/turf/open/floor/plasteel/showroomfloor
	icon_state = "showroomfloor"
	base_icon_state = "showroomfloor"


/turf/open/floor/plasteel/solarpanel
	icon_state = "solarpanel"
	base_icon_state = "solarpanel"

/turf/open/floor/plasteel/airless/solarpanel
	icon_state = "solarpanel"
	base_icon_state = "solarpanel"


/turf/open/floor/plasteel/freezer
	icon_state = "freezerfloor"
	base_icon_state = "freezerfloor"

/turf/open/floor/plasteel/freezer/airless


/turf/open/floor/plasteel/kitchen_coldroom
	name = "cold room floor"

/turf/open/floor/plasteel/kitchen_coldroom/Initialize()
	. = ..()

/turf/open/floor/plasteel/kitchen_coldroom/freezerfloor
	icon_state = "freezerfloor"
	base_icon_state = "freezerfloor"


/turf/open/floor/plasteel/grimy
	icon_state = "grimy"
	base_icon_state = "grimy"
	tiled_dirt = FALSE

/turf/open/floor/plasteel/cafeteria
	icon_state = "cafeteria"
	base_icon_state = "cafeteria"

/turf/open/floor/plasteel/airless/cafeteria
	icon_state = "cafeteria"
	base_icon_state = "cafeteria"


/turf/open/floor/plasteel/cult
	name = "engraved floor"
	icon_state = "cult"
	base_icon_state = "cult"

/turf/open/floor/plasteel/vaporwave
	icon_state = "pinkblack"
	base_icon_state = "pinkblack"

/turf/open/floor/plasteel/goonplaque
	name = "commemorative plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	icon_state = "plaque"
	base_icon_state = "plaque"
	tiled_dirt = FALSE

/turf/open/floor/plasteel/cult/narsie_act()
	return

/turf/open/floor/plasteel/cult/airless


/turf/open/floor/plasteel/stairs
	icon_state = "stairs"
	base_icon_state = "stairs"
	tiled_dirt = FALSE

/turf/open/floor/plasteel/stairs/left
	icon_state = "stairs-l"
	base_icon_state = "stairs-l"

/turf/open/floor/plasteel/stairs/medium
	icon_state = "stairs-m"
	base_icon_state = "stairs-m"

/turf/open/floor/plasteel/stairs/right
	icon_state = "stairs-r"
	base_icon_state = "stairs-r"

/turf/open/floor/plasteel/stairs/old
	icon_state = "stairs-old"
	base_icon_state = "stairs-old"


/turf/open/floor/plasteel/rockvault
	icon_state = "rockvault"
	base_icon_state = "rockvault"

/turf/open/floor/plasteel/rockvault/alien
	icon_state = "alienvault"
	base_icon_state = "alienvault"

/turf/open/floor/plasteel/rockvault/sandstone
	icon_state = "sandstonevault"
	base_icon_state = "sandstonevault"


/turf/open/floor/plasteel/elevatorshaft
	icon_state = "elevatorshaft"
	base_icon_state = "elevatorshaft"

/turf/open/floor/plasteel/bluespace
	icon_state = "bluespace"
	base_icon_state = "bluespace"

/turf/open/floor/plasteel/sepia
	icon_state = "sepia"
	base_icon_state = "sepia"
