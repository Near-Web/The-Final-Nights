/obj/item/gun/ballistic/response
	icon = 'code/modules/wod13/weapons.dmi'
	lefthand_file = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/righthand.dmi'
	righthand_file = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/lefthand.dmi'
	worn_icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/worn.dmi'
	onflooricon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/onfloor.dmi'
	can_suppress = FALSE
	recoil = 2

/obj/item/gun/ballistic/automatic/response
	icon = 'code/modules/wod13/weapons.dmi'
	lefthand_file = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/righthand.dmi'
	righthand_file = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/lefthand.dmi'
	worn_icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/worn.dmi'
	onflooricon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/onfloor.dmi'
	can_suppress = FALSE
	recoil = 2

/obj/item/ammo_box/magazine/px66f
	name = "PX66F magazine (5.56mm)"
	icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/ammo.dmi'
	lefthand_file = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/righthand.dmi'
	righthand_file = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/lefthand.dmi'
	worn_icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/worn.dmi'
	onflooricon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/onfloor.dmi'
	icon_state = "px66f"
	ammo_type = /obj/item/ammo_casing/vampire/c556mm
	caliber = CALIBER_556
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/response/px66f
	name = "\improper PX66F Rifle"
	desc = "A three-round burst 5.56 death machine, with a Spiral brand below the barrel."
	icon = 'modular_tfn/modules/responseteams/code/pentexfirstteams/sprites/48x32weapons.dmi'
	icon_state = "px66f"
	inhand_icon_state = "px66f"
	worn_icon_state = "rifle"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM //Bullpup makes it easy to fire with one hand, but we still don't want these dual-wielded
	mag_type = /obj/item/ammo_box/magazine/px66f
	burst_size = 3
	fire_delay = 1
	spread = 2
	bolt_type = BOLT_TYPE_LOCKING
	show_bolt_icon = FALSE
	mag_display = TRUE
	fire_sound = 'code/modules/wod13/sounds/rifle.ogg'
	masquerade_violating = TRUE
	is_iron = FALSE

/obj/item/gun/ballistic/automatic/response/px66f/Initialize()
	. = ..()
	AddComponent(/datum/component/selling, 350, "aug", FALSE)
