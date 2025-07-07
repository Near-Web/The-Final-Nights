//HATS

//HATS

//HATS

/obj/item/clothing/head/response
	icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/clothing.dmi'
	worn_icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/worn.dmi'
	onflooricon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/onfloor.dmi'
	armor = list(MELEE = 10, BULLET = 0, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 10, WOUND = 10)
	body_worn = TRUE

/obj/item/clothing/head/response/Initialize()
	. = ..()
	AddComponent(/datum/component/selling, 10, "headwear", FALSE)

/obj/item/clothing/head/response/firstteam_helmet
	name = "First Team helmet"
	desc = "A black helmet with two, green-glowing eye-pieces that seem to stare through your soul."
	icon_state = "fthelmet"
	armor = list(MELEE = 80, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 80, BIO = 80, RAD = 80, FIRE = 80, ACID = 80, WOUND = 80)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	clothing_flags = NO_HAT_TRICKS|SNUG_FIT
	dynamic_hair_suffix = ""
	dynamic_fhair_suffix = ""
	visor_flags_inv = HIDEFACE|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
