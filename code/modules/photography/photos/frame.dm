// Picture frames

/obj/item/wallframe/picture
	name = "picture frame"
	desc = "The perfect showcase for your favorite deathtrap memories."
	icon = 'icons/obj/decals.dmi'
	custom_materials = list(/datum/material/wood = 2000)
	resistance_flags = FLAMMABLE
	flags_1 = 0
	icon_state = "frame-overlay"
	result_path = /obj/structure/sign/picture_frame
	var/obj/item/photo/displayed
	pixel_shift = 30

/obj/item/wallframe/picture/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/photo))
		if(!displayed)
			if(!user.transferItemToLoc(I, src))
				return
			displayed = I
			update_appearance()
		else
			to_chat(user, "<span class=notice>\The [src] already contains a photo.</span>")
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/wallframe/picture/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() != src)
		..()
		return
	if(contents.len)
		var/obj/item/I = pick(contents)
		user.put_in_hands(I)
		to_chat(user, "<span class='notice'>You carefully remove the photo from \the [src].</span>")
		displayed = null
		update_appearance()
	return ..()

/obj/item/wallframe/picture/attack_self(mob/user)
	user.examinate(src)

/obj/item/wallframe/picture/examine(mob/user)
	if(user.is_holding(src) && displayed)
		displayed.show(user)
		return list()
	else
		return ..()

/obj/item/wallframe/picture/update_overlays()
	. = ..()
	if(displayed)
		. += displayed

/obj/item/wallframe/picture/after_attach(obj/O)
	..()
	var/obj/structure/sign/picture_frame/PF = O
	PF.copy_overlays(src)
	if(displayed)
		PF.framed = displayed
	if(contents.len)
		var/obj/item/I = pick(contents)
		I.forceMove(PF)

/obj/structure/sign/picture_frame
	name = "picture frame"
	desc = "Every time you look it makes you laugh."
	icon = 'icons/obj/decals.dmi'
	icon_state = "frame-overlay"
	custom_materials = list(/datum/material/wood = 2000)
	resistance_flags = FLAMMABLE
	var/obj/item/photo/framed
	var/persistence_id
	var/can_decon = TRUE

#define FRAME_DEFINE(id) /obj/structure/sign/picture_frame/##id/persistence_id = #id

//Put default persistent frame defines here!

#undef FRAME_DEFINE

/obj/structure/sign/picture_frame/Initialize(mapload, dir, building)
	. = ..()
	AddElement(/datum/element/art, OK_ART)
	LAZYADD(SSpersistence.photo_frames, src)
	if(dir)
		setDir(dir)

/obj/structure/sign/picture_frame/Destroy()
	LAZYREMOVE(SSpersistence.photo_frames, src)
	return ..()

/obj/structure/sign/picture_frame/proc/get_photo_id()
	if(istype(framed) && istype(framed.picture))
		return framed.picture.id

//Manual loading, DO NOT USE FOR HARDCODED/MAPPED IN ALBUMS. This is for if an album needs to be loaded mid-round from an ID.
/obj/structure/sign/picture_frame/proc/persistence_load()
	var/list/data = SSpersistence.GetPhotoFrames()
	if(data[persistence_id])
		load_from_id(data[persistence_id])

/obj/structure/sign/picture_frame/proc/load_from_id(id)
	var/obj/item/photo/old/P = load_photo_from_disk(id)
	if(istype(P))
		if(istype(framed))
			framed.forceMove(drop_location())
		else
			qdel(framed)
		framed = P
		update_appearance()

/obj/structure/sign/picture_frame/examine(mob/user)
	if(in_range(src, user) && framed)
		framed.show(user)
		return list()
	else
		return ..()

/obj/structure/sign/picture_frame/attackby(obj/item/I, mob/user, params)
	if(can_decon && (I.tool_behaviour == TOOL_SCREWDRIVER || I.tool_behaviour == TOOL_WRENCH))
		to_chat(user, "<span class='notice'>You start unsecuring [name]...</span>")
		if(I.use_tool(src, user, 30, volume=50))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			to_chat(user, "<span class='notice'>You unsecure [name].</span>")
			deconstruct()

	else if(I.tool_behaviour == TOOL_WIRECUTTER && framed)
		framed.forceMove(drop_location())
		framed = null
		user.visible_message("<span class='warning'>[user] cuts away [framed] from [src]!</span>")
		return

	else if(istype(I, /obj/item/photo))
		if(!framed)
			var/obj/item/photo/P = I
			if(!user.transferItemToLoc(P, src))
				return
			framed = P
			update_appearance()
		else
			to_chat(user, "<span class=notice>\The [src] already contains a photo.</span>")

	..()

/obj/structure/sign/picture_frame/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(framed)
		framed.show(user)

/obj/structure/sign/picture_frame/update_overlays()
	. = ..()
	if(framed)
		. += framed

/obj/structure/sign/picture_frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/wallframe/picture/F = new /obj/item/wallframe/picture(loc)
		if(framed)
			F.displayed = framed
			framed = null
		if(contents.len)
			var/obj/item/I = pick(contents)
			I.forceMove(F)
		F.update_appearance()
	qdel(src)


/obj/structure/sign/picture_frame/showroom
	name = "distinguished crew display"
	desc = "A photo frame to commemorate crewmembers that distinguished themselves in the line of duty. WARNING: unauthorized tampering will be severely punished."
	can_decon = FALSE

//persistent frames, make sure the same ID doesn't appear more than once per map
/obj/structure/sign/picture_frame/showroom/one
	persistence_id = "frame_showroom1"

/obj/structure/sign/picture_frame/showroom/two
	persistence_id = "frame_showroom2"

/obj/structure/sign/picture_frame/showroom/three
	persistence_id = "frame_showroom3"

/obj/structure/sign/picture_frame/showroom/four
	persistence_id = "frame_showroom4"
