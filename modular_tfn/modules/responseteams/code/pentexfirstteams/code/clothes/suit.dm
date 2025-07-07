//SUITS

//SUITS

//SUITS

/obj/item/clothing/suit/response
	icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/clothing.dmi'
	worn_icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/worn.dmi'
	onflooricon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/onfloor.dmi'

	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	max_integrity = 250
	resistance_flags = NONE
	armor = list(MELEE = 10, BULLET = 0, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 10, WOUND = 10)
	body_worn = TRUE

/obj/item/clothing/suit/response/Initialize()
	. = ..()
	AddComponent(/datum/component/selling, 15, "suit", FALSE)


/obj/item/clothing/suit/response/firstteam_armor
	name = "First Team Armoured Vest"
	desc = "A strong looking, armoured-vest with a large '1' engraved onto the breast."
	icon_state = "ftarmor"
	armor = list(MELEE = 80, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 80, BIO = 80, RAD = 80, FIRE = 80, ACID = 90, WOUND = 40)
