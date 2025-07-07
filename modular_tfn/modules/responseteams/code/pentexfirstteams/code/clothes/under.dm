/obj/item/clothing/under/response
	desc = "Some clothes."
	name = "clothes"
	icon_state = "error"
	has_sensor = NO_SENSORS
	random_sensor = FALSE
	can_adjust = FALSE
	icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/clothing.dmi'
	worn_icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/worn.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, WOUND = 15)
	onflooricon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/onfloor.dmi'
	body_worn = TRUE
	fitted = NO_FEMALE_UNIFORM

/obj/item/clothing/under/response/Initialize()
	. = ..()
	AddComponent(/datum/component/selling, 10, "undersuit", FALSE)

/obj/item/clothing/under/response/firstteam_uniform
	name = "First Team uniform"
	desc = "A completely blacked out uniform with a large '1' symbol sewn onto the shoulder-pad."
	icon_state = "ftuni"
