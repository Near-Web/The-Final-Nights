	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-date if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we generate the standing version and then rotate the mob as necessary..

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing. //22 and counting, good job guys
	var/overlays_standing[20]		//For the standing stance

Most of the time we only wish to update one overlay:
	e.g. - we dropped the fireaxe out of our left hand and need to remove its icon from our mob
	e.g.2 - our hair colour has changed, so we need to update our hair icons on our mob
In these cases, instead of updating every overlay using the old behaviour (regenerate_icons), we instead call
the appropriate update_X proc.
	e.g. - update_l_hand()
	e.g.2 - update_hair()

Note: Recent changes by aranclanos+carn:
	update_icons() no longer needs to be called.
	the system is easier to use. update_icons() should not be called unless you absolutely -know- you need it.
	IN ALL OTHER CASES it's better to just call the specific update_X procs.

Note: The defines for layer numbers is now kept exclusvely in __DEFINES/misc.dm instead of being defined there,
	then redefined and undefiend everywhere else. If you need to change the layering of sprites (or add a new layer)
	that's where you should start.

All of this means that this code is more maintainable, faster and still fairly easy to use.

There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src), rather than using the helper procs)
	You will need to call the relevant update_inv_* proc

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_damage_overlays()	//handles damage overlays for brute/burn damage
		update_body()				//Handles updating your mob's body layer and mutant bodyparts
									as well as sprite-accessories that didn't really fit elsewhere (underwear, undershirts, socks, lips, eyes)
									//NOTE: update_mutantrace() is now merged into this!
		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())


*/

//HAIR OVERLAY
/mob/living/carbon/human/update_hair()
	dna.species.handle_hair(src)

//used when putting/removing clothes that hide certain mutant body parts to just update those and not update the whole body.
/mob/living/carbon/human/proc/update_mutant_bodyparts()
	dna.species.handle_mutant_bodyparts(src)

/mob/living/carbon/human/update_body()
	for(var/obj/item/I in GetAllContents())
		I.update_bodyfied(src)

	update_inv_w_uniform()
	update_inv_wear_id()
	update_inv_gloves()
	update_inv_glasses()
	update_inv_ears()
	update_inv_shoes()
	update_inv_s_store()
	update_inv_wear_mask()
	update_inv_head()
	update_inv_belt()
	update_inv_back()
	update_inv_wear_suit()
	update_inv_pockets()
	update_inv_neck()
	remove_overlay(BODY_LAYER)
	dna.species.handle_body(src)
	..()

/mob/living/carbon/human/update_fire()
	..((fire_stacks > HUMAN_FIRE_STACK_ICON_NUM) ? "Standing" : "Generic_mob_burning")


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()

	if(!..())
		icon_render_key = null //invalidate bodyparts cache
		update_body()
		update_hair()
		update_inv_w_uniform()
		update_inv_wear_id()
		update_inv_gloves()
		update_inv_glasses()
		update_inv_ears()
		update_inv_shoes()
		update_inv_s_store()
		update_inv_wear_mask()
		update_inv_head()
		update_inv_belt()
		update_inv_back()
		update_inv_wear_suit()
		update_inv_pockets()
		update_inv_neck()
		update_transform()
		//mutations
		update_mutations_overlay()
		//damage overlays
		update_damage_overlays()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ICLOTHING) + 1]
		inv.update_icon()

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = w_uniform
		U.screen_loc = ui_iclothing
		if(client && hud_used?.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += w_uniform
		update_observer_view(w_uniform,1)

		if(wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT))
			return


		var/target_overlay = U.icon_state
		if(U.adjusted == ALT_STYLE)
			target_overlay = "[target_overlay]_d"
		else if(U.adjusted == DIGITIGRADE_STYLE)
			target_overlay = "[target_overlay]_l"


		var/mutable_appearance/uniform_overlay

		if(dna?.species.sexes)
			if(body_type == FEMALE && U.fitted != NO_FEMALE_UNIFORM)
				uniform_overlay = U.build_worn_icon(default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, femaleuniform = U.fitted, override_state = target_overlay)

		if(!uniform_overlay)
			uniform_overlay = U.build_worn_icon(default_layer = UNIFORM_LAYER, default_icon_file = 'icons/mob/clothing/under/default.dmi', isinhands = FALSE, override_state = target_overlay)

		if(OFFSET_UNIFORM in dna.species.offset_features)
			uniform_overlay.pixel_x += dna.species.offset_features[OFFSET_UNIFORM][1]
			uniform_overlay.pixel_y += dna.species.offset_features[OFFSET_UNIFORM][2]
		overlays_standing[UNIFORM_LAYER] = uniform_overlay

	apply_overlay(UNIFORM_LAYER)
	update_mutant_bodyparts()


/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_ID) + 1]
		inv.update_icon()

	var/mutable_appearance/id_overlay = overlays_standing[ID_LAYER]

	if(wear_id)
		wear_id.screen_loc = ui_id
		if(client && hud_used?.hud_shown)
			client.screen += wear_id
		update_observer_view(wear_id)

		//TODO: add an icon file for ID slot stuff, so it's less snowflakey
		id_overlay = wear_id.build_worn_icon(default_layer = ID_LAYER, default_icon_file = 'icons/mob/mob.dmi')
		if(OFFSET_ID in dna.species.offset_features)
			id_overlay.pixel_x += dna.species.offset_features[OFFSET_ID][1]
			id_overlay.pixel_y += dna.species.offset_features[OFFSET_ID][2]
		overlays_standing[ID_LAYER] = id_overlay

	apply_overlay(ID_LAYER)


/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)

	if(client && hud_used?.inv_slots[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1])
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_GLOVES) + 1]
		inv.update_icon()

	if(!gloves && blood_in_hands && !(NOBLOODOVERLAY in dna.species.species_traits))
		var/mutable_appearance/bloody_overlay = mutable_appearance('icons/effects/blood.dmi', "bloodyhands", -GLOVES_LAYER)
		if(num_hands < 2)
			if(has_left_hand(FALSE))
				bloody_overlay.icon_state = "bloodyhands_left"
			else if(has_right_hand(FALSE))
				bloody_overlay.icon_state = "bloodyhands_right"

		overlays_standing[GLOVES_LAYER] = bloody_overlay

	var/mutable_appearance/gloves_overlay = overlays_standing[GLOVES_LAYER]
	if(gloves)
		gloves.screen_loc = ui_gloves
		if(client && hud_used?.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += gloves
		update_observer_view(gloves,1)
		overlays_standing[GLOVES_LAYER] = gloves.build_worn_icon(default_layer = GLOVES_LAYER, default_icon_file = 'icons/mob/clothing/hands.dmi')
		gloves_overlay = overlays_standing[GLOVES_LAYER]
		if(OFFSET_GLOVES in dna.species.offset_features)
			gloves_overlay.pixel_x += dna.species.offset_features[OFFSET_GLOVES][1]
			gloves_overlay.pixel_y += dna.species.offset_features[OFFSET_GLOVES][2]
	overlays_standing[GLOVES_LAYER] = gloves_overlay
	apply_overlay(GLOVES_LAYER)


/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //decapitated
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EYES) + 1]
		inv.update_icon()

	if(glasses)
		glasses.screen_loc = ui_glasses		//...draw the item in the inventory screen
		if(client && hud_used?.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open ...
				client.screen += glasses				//Either way, add the item to the HUD
		update_observer_view(glasses,1)
		if(!(head && (head.flags_inv & HIDEEYES)) && !(wear_mask && (wear_mask.flags_inv & HIDEEYES)))
			overlays_standing[GLASSES_LAYER] = glasses.build_worn_icon(default_layer = GLASSES_LAYER, default_icon_file = 'icons/mob/clothing/eyes.dmi')

		var/mutable_appearance/glasses_overlay = overlays_standing[GLASSES_LAYER]
		if(glasses_overlay)
			if(OFFSET_GLASSES in dna.species.offset_features)
				glasses_overlay.pixel_x += dna.species.offset_features[OFFSET_GLASSES][1]
				glasses_overlay.pixel_y += dna.species.offset_features[OFFSET_GLASSES][2]
			overlays_standing[GLASSES_LAYER] = glasses_overlay
	apply_overlay(GLASSES_LAYER)


/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)

	if(!get_bodypart(BODY_ZONE_HEAD)) //decapitated
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_EARS) + 1]
		inv.update_icon()

	if(ears)
		ears.screen_loc = ui_ears	//move the item to the appropriate screen loc
		if(client && hud_used?.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += ears					//add it to the client's screen
		update_observer_view(ears,1)
		overlays_standing[EARS_LAYER] = ears.build_worn_icon(default_layer = EARS_LAYER, default_icon_file = 'icons/mob/clothing/ears.dmi')
		var/mutable_appearance/ears_overlay = overlays_standing[EARS_LAYER]
		if(OFFSET_EARS in dna.species.offset_features)
			ears_overlay.pixel_x += dna.species.offset_features[OFFSET_EARS][1]
			ears_overlay.pixel_y += dna.species.offset_features[OFFSET_EARS][2]
		overlays_standing[EARS_LAYER] = ears_overlay
	apply_overlay(EARS_LAYER)


/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)

	if(num_legs < 2)
		return

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_FEET) + 1]
		inv.update_icon()

	if(shoes)
		shoes.screen_loc = ui_shoes					//move the item to the appropriate screen loc
		if(client && hud_used?.hud_shown)
			if(hud_used.inventory_shown)			//if the inventory is open
				client.screen += shoes					//add it to client's screen
		update_observer_view(shoes,1)
		overlays_standing[SHOES_LAYER] = shoes.build_worn_icon(default_layer = SHOES_LAYER, default_icon_file = 'icons/mob/clothing/feet.dmi')
		var/mutable_appearance/shoes_overlay = overlays_standing[SHOES_LAYER]
		if(OFFSET_SHOES in dna.species.offset_features)
			shoes_overlay.pixel_x += dna.species.offset_features[OFFSET_SHOES][1]
			shoes_overlay.pixel_y += dna.species.offset_features[OFFSET_SHOES][2]
		overlays_standing[SHOES_LAYER] = shoes_overlay

	apply_overlay(SHOES_LAYER)


/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_SUITSTORE) + 1]
		if (inv) //inv can be null when joining, causing runtimes
			inv.update_icon()

	if(s_store)
		s_store.screen_loc = ui_sstore1
		if(client && hud_used?.hud_shown)
			client.screen += s_store
		update_observer_view(s_store)
		overlays_standing[SUIT_STORE_LAYER]	= s_store.build_worn_icon(default_layer = SUIT_STORE_LAYER, default_icon_file = 'icons/mob/clothing/belt_mirror.dmi')
		var/mutable_appearance/s_store_overlay = overlays_standing[SUIT_STORE_LAYER]
		if(OFFSET_S_STORE in dna.species.offset_features)
			s_store_overlay.pixel_x += dna.species.offset_features[OFFSET_S_STORE][1]
			s_store_overlay.pixel_y += dna.species.offset_features[OFFSET_S_STORE][2]
		overlays_standing[SUIT_STORE_LAYER] = s_store_overlay
	apply_overlay(SUIT_STORE_LAYER)


/mob/living/carbon/human/update_inv_head()
	..()
	update_mutant_bodyparts()
	var/mutable_appearance/head_overlay = overlays_standing[HEAD_LAYER]
	if(head_overlay)
		remove_overlay(HEAD_LAYER)
		if(OFFSET_HEAD in dna.species.offset_features)
			head_overlay.pixel_x += dna.species.offset_features[OFFSET_HEAD][1]
			head_overlay.pixel_y += dna.species.offset_features[OFFSET_HEAD][2]
			overlays_standing[HEAD_LAYER] = head_overlay
	apply_overlay(HEAD_LAYER)

/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_BELT) + 1]
		inv.update_icon()

	if(belt)
		belt.screen_loc = ui_belt
		if(client && hud_used?.hud_shown)
			client.screen += belt
		update_observer_view(belt)
		overlays_standing[BELT_LAYER] = belt.build_worn_icon(default_layer = BELT_LAYER, default_icon_file = 'icons/mob/clothing/belt.dmi')
		var/mutable_appearance/belt_overlay = overlays_standing[BELT_LAYER]
		if(OFFSET_BELT in dna.species.offset_features)
			belt_overlay.pixel_x += dna.species.offset_features[OFFSET_BELT][1]
			belt_overlay.pixel_y += dna.species.offset_features[OFFSET_BELT][2]
		overlays_standing[BELT_LAYER] = belt_overlay

	apply_overlay(BELT_LAYER)



/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)

	if(client && hud_used)
		var/atom/movable/screen/inventory/inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_OCLOTHING) + 1]
		inv.update_icon()

	if(istype(wear_suit, /obj/item/clothing/suit))
		wear_suit.screen_loc = ui_oclothing
		if(client && hud_used?.hud_shown)
			if(hud_used.inventory_shown)
				client.screen += wear_suit
		update_observer_view(wear_suit,1)
		overlays_standing[SUIT_LAYER] = wear_suit.build_worn_icon(default_layer = SUIT_LAYER, default_icon_file = 'icons/mob/clothing/suit.dmi')
		var/mutable_appearance/suit_overlay = overlays_standing[SUIT_LAYER]
		if(OFFSET_SUIT in dna.species.offset_features)
			suit_overlay.pixel_x += dna.species.offset_features[OFFSET_SUIT][1]
			suit_overlay.pixel_y += dna.species.offset_features[OFFSET_SUIT][2]
		overlays_standing[SUIT_LAYER] = suit_overlay
	update_hair()
	update_mutant_bodyparts()

	apply_overlay(SUIT_LAYER)


/mob/living/carbon/human/update_inv_pockets()
	if(client && hud_used)
		var/atom/movable/screen/inventory/inv

		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_LPOCKET) + 1]
		inv.update_icon()

		inv = hud_used.inv_slots[TOBITSHIFT(ITEM_SLOT_RPOCKET) + 1]
		inv.update_icon()

		if(l_store)
			l_store.screen_loc = ui_storage1
			if(hud_used.hud_shown)
				client.screen += l_store
			update_observer_view(l_store)

		if(r_store)
			r_store.screen_loc = ui_storage2
			if(hud_used.hud_shown)
				client.screen += r_store
			update_observer_view(r_store)


/mob/living/carbon/human/update_inv_wear_mask()
	..()
	var/mutable_appearance/mask_overlay = overlays_standing[FACEMASK_LAYER]
	if(mask_overlay)
		remove_overlay(FACEMASK_LAYER)
		if(OFFSET_FACEMASK in dna.species.offset_features)
			mask_overlay.pixel_x += dna.species.offset_features[OFFSET_FACEMASK][1]
			mask_overlay.pixel_y += dna.species.offset_features[OFFSET_FACEMASK][2]
		overlays_standing[FACEMASK_LAYER] = mask_overlay

	apply_overlay(FACEMASK_LAYER)
	update_mutant_bodyparts() //e.g. upgate needed because mask now hides lizard snout

/mob/living/carbon/human/update_inv_back()
	..()
	var/mutable_appearance/back_overlay = overlays_standing[BACK_LAYER]
	if(back_overlay)
		remove_overlay(BACK_LAYER)
		if(OFFSET_BACK in dna.species.offset_features)
			back_overlay.pixel_x += dna.species.offset_features[OFFSET_BACK][1]
			back_overlay.pixel_y += dna.species.offset_features[OFFSET_BACK][2]
			overlays_standing[BACK_LAYER] = back_overlay
		apply_overlay(BACK_LAYER)

/mob/living/carbon/human/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	clear_alert("legcuffed")
	if(legcuffed)
		overlays_standing[LEGCUFF_LAYER] = mutable_appearance('icons/mob/mob.dmi', "legcuff1", -LEGCUFF_LAYER)
		apply_overlay(LEGCUFF_LAYER)
		throw_alert("legcuffed", /atom/movable/screen/alert/restrained/legcuffed, new_master = src.legcuffed)

/proc/wear_female_version(t_color, icon, layer, type, greyscale_colors)
	var/index = "[t_color]-[greyscale_colors]"
	var/icon/female_clothing_icon = GLOB.female_clothing_icons[index]
	if(!female_clothing_icon) //Create standing/laying icons if they don't exist
		generate_female_clothing(index, t_color, icon, type)
	return mutable_appearance(GLOB.female_clothing_icons[index], layer = -layer)

/mob/living/carbon/human/proc/get_overlays_copy(list/unwantedLayers)
	var/list/out = new
	for(var/i in 1 to TOTAL_LAYERS)
		if(overlays_standing[i])
			if(i in unwantedLayers)
				continue
			out += overlays_standing[i]
	return out


//human HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/human/update_hud_head(obj/item/I)
	I.screen_loc = ui_head
	if(client && hud_used?.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our mask item appears on our hud.
/mob/living/carbon/human/update_hud_wear_mask(obj/item/I)
	I.screen_loc = ui_mask
	if(client && hud_used?.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our neck item appears on our hud.
/mob/living/carbon/human/update_hud_neck(obj/item/I)
	I.screen_loc = ui_neck
	if(client && hud_used?.hud_shown)
		if(hud_used.inventory_shown)
			client.screen += I
	update_observer_view(I,1)

//update whether our back item appears on our hud.
/mob/living/carbon/human/update_hud_back(obj/item/I)
	I.screen_loc = ui_back
	if(client && hud_used?.hud_shown)
		client.screen += I
	update_observer_view(I)

/*
Does everything in relation to building the /mutable_appearance used in the mob's overlays list
covers:
Inhands and any other form of worn item
Rentering large appearances
Layering appearances on custom layers
Building appearances from custom icon files

By Remie Richards (yes I'm taking credit because this just removed 90% of the copypaste in update_icons())

state: A string to use as the state, this is FAR too complex to solve in this proc thanks to shitty old code
so it's specified as an argument instead.

default_layer: The layer to draw this on if no other layer is specified

default_icon_file: The icon file to draw states from if no other icon file is specified

isinhands: If true then alternate_worn_icon is skipped so that default_icon_file is used,
in this situation default_icon_file is expected to match either the lefthand_ or righthand_ file var

femalueuniform: A value matching a uniform item's fitted var, if this is anything but NO_FEMALE_UNIFORM, we
generate/load female uniform sprites matching all previously decided variables


*/
/obj/item/proc/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null)

	//Find a valid icon_state from variables+arguments
	var/t_state
	if(override_state)
		t_state = override_state
	else
		t_state = !isinhands ? (worn_icon_state ? worn_icon_state : icon_state) : (inhand_icon_state ? inhand_icon_state : icon_state)

	//Find a valid icon file from variables+arguments
	var/file2use = !isinhands ? (worn_icon ? worn_icon : default_icon_file) : default_icon_file

	//Find a valid layer from variables+arguments
	var/layer2use = alternate_worn_layer ? alternate_worn_layer : default_layer

	var/mutable_appearance/standing
	if(femaleuniform)
		standing = wear_female_version(t_state, file2use, layer2use, femaleuniform, greyscale_colors) //should layer2use be in sync with the adjusted value below? needs testing - shiz
	if(!standing)
		standing = mutable_appearance(file2use, t_state, -layer2use)

	//Get the overlays for this item when it's being worn
	//eg: ammo counters, primed grenade flashes, etc.
	var/list/worn_overlays = worn_overlays(isinhands, file2use)
	if(worn_overlays?.len)
		if(!isinhands && default_layer && ishuman(loc))
			var/mob/living/carbon/human/human_loc = loc
			if(human_loc.get_mob_height() != HUMAN_HEIGHT_MEDIUM)
				var/string_form_layer = num2text(default_layer)
				var/offset_amount = GLOB.layers_to_offset[string_form_layer]
				if(isnull(offset_amount))
					// Worn overlays don't get batched in with standing overlays because they are overlay overlays
					// ...So we need to apply human height here as well
					for(var/mutable_appearance/applied_appearance as anything in worn_overlays)
						if(isnull(applied_appearance))
							continue
						human_loc.apply_height_filters(applied_appearance)

				else
					for(var/mutable_appearance/applied_appearance in worn_overlays)
						if(isnull(applied_appearance))
							continue
						human_loc.apply_height_offsets(applied_appearance, offset_amount)

		standing.overlays.Add(worn_overlays)

	standing = center_image(standing, isinhands ? inhand_x_dimension : worn_x_dimension, isinhands ? inhand_y_dimension : worn_y_dimension)

	//Handle held offsets
	var/mob/M = loc
	if(istype(M))
		var/list/L = get_held_offsets()
		if(L)
			standing.pixel_x += L["x"] //+= because of center()ing
			standing.pixel_y += L["y"]

	standing.alpha = alpha
	standing = color_atom_overlay(standing)

	return standing


/obj/item/proc/get_held_offsets()
	var/list/L
	if(ismob(loc))
		var/mob/M = loc
		L = M.get_item_offsets_for_index(M.get_held_index_of_item(src))
	return L


//Can't think of a better way to do this, sadly
/mob/proc/get_item_offsets_for_index(i)
	switch(i)
		if(3) //odd = left hands
			return list("x" = 0, "y" = 16)
		if(4) //even = right hands
			return list("x" = 0, "y" = 16)
		else //No offsets or Unwritten number of hands
			return list("x" = 0, "y" = 0)//Handle held offsets

//produces a key based on the human's limbs
/mob/living/carbon/human/generate_icon_render_key()
	. = "[dna.species.limbs_id]"

	if(dna.check_mutation(HULK))
		. += "-coloured-hulk"
	else if(dna.species.use_skintones)
		. += "-coloured-[skin_tone]"
	else if(dna.species.fixed_mut_color)
		. += "-coloured-[dna.species.fixed_mut_color]"
	else if(dna.features["mcolor"])
		. += "-coloured-[dna.features["mcolor"]]"
	else
		. += "-not_coloured"

	. += "-[body_type]"

	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		. += "-[BP.body_zone]"
		if(BP.status == BODYPART_ORGANIC)
			. += "-organic"
		else
			. += "-robotic"
		if(BP.use_digitigrade)
			. += "-digitigrade[BP.use_digitigrade]"
		if(BP.dmg_overlay_type)
			. += "-[BP.dmg_overlay_type]"

	if(HAS_TRAIT(src, TRAIT_HUSK))
		. += "-husk"

/mob/living/carbon/human/load_limb_from_cache()
	..()
	update_hair()



/mob/living/carbon/human/proc/update_observer_view(obj/item/I, inventory)
	if(observers?.len)
		for(var/M in observers)
			var/mob/dead/observe = M
			if(observe.client && observe.client.eye == src)
				if(observe.hud_used)
					if(inventory && !observe.hud_used.inventory_shown)
						continue
					observe.client.screen += I
			else
				observers -= observe
				if(!observers.len)
					observers = null
					break

// Only renders the head of the human
/mob/living/carbon/human/proc/update_body_parts_head_only()
	if (!dna)
		return

	if (!dna.species)
		return

	var/obj/item/bodypart/HD = get_bodypart("head")

	if (!istype(HD))
		return

	HD.update_limb()

	add_overlay(HD.get_limb_icon())
	update_damage_overlays()

	if(HD && !(HAS_TRAIT(src, TRAIT_HUSK)))
		// lipstick
		if(lip_style && (LIPS in dna.species.species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips_[lip_style]", -BODY_LAYER)
			if(base_body_mod == SLIM_BODY_MODEL)
				lip_overlay = mutable_appearance('icons/mob/human_face_f.dmi', "lips_[lip_style]", -BODY_LAYER)
			lip_overlay.color = lip_color
			if(OFFSET_FACE in dna.species.offset_features)
				lip_overlay.pixel_x += dna.species.offset_features[OFFSET_FACE][1]
				lip_overlay.pixel_y += dna.species.offset_features[OFFSET_FACE][2]
			add_overlay(lip_overlay)

		// eyes
		if(!(NOEYESPRITES in dna.species.species_traits))
			var/obj/item/organ/eyes/E = getorganslot(ORGAN_SLOT_EYES)
			var/mutable_appearance/eye_overlay
			if(!E)
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eyes_missing", -BODY_LAYER)
				if(base_body_mod == SLIM_BODY_MODEL)
					eye_overlay = mutable_appearance('icons/mob/human_face_f.dmi', "eyes_missing", -BODY_LAYER)
			else
				eye_overlay = mutable_appearance('icons/mob/human_face.dmi', E.eye_icon_state, -BODY_LAYER)
				if(base_body_mod == SLIM_BODY_MODEL)
					eye_overlay = mutable_appearance('icons/mob/human_face_f.dmi', E.eye_icon_state, -BODY_LAYER)
			if((EYECOLOR in dna.species.species_traits) && E)
				eye_overlay.color = eye_color
			if(OFFSET_FACE in dna.species.offset_features)
				eye_overlay.pixel_x += dna.species.offset_features[OFFSET_FACE][1]
				eye_overlay.pixel_y += dna.species.offset_features[OFFSET_FACE][2]
			add_overlay(eye_overlay)

	dna.species.handle_hair(src)

	update_inv_head()
	update_inv_wear_mask()

// Hooks into human apply overlay so that we can modify all overlays applied through standing overlays to our height system.
// Some of our overlays will be passed through a displacement filter to make our mob look taller or shorter.
// Some overlays can't be displaced as they're too close to the edge of the sprite or cross the middle point in a weird way.
// So instead we have to pass them through an offset, which is close enough to look good.
/mob/living/carbon/human/apply_overlay(cache_index)
	if(get_mob_height() == HUMAN_HEIGHT_MEDIUM)
		return ..()

	var/raw_applied = overlays_standing[cache_index]
	var/string_form_index = num2text(cache_index)
	var/offset_amount = GLOB.layers_to_offset[string_form_index]
	if(isnull(offset_amount))
		if(islist(raw_applied))
			for(var/mutable_appearance/applied_appearance as anything in raw_applied)
				if(isnull(applied_appearance))
					continue
				apply_height_filters(applied_appearance)
		else if(!isnull(raw_applied))
			apply_height_filters(raw_applied)
	else
		if(islist(raw_applied))
			for(var/mutable_appearance/applied_appearance as anything in raw_applied)
				if(isnull(applied_appearance))
					continue
				apply_height_offsets(applied_appearance, offset_amount)
		else if(!isnull(raw_applied))
			apply_height_offsets(raw_applied, offset_amount)

	return ..()

/**
 * Used in some circumstances where appearances can get cut off from the mob sprite from being too tall
 *
 * upper_torso is to specify whether the appearance is locate in the upper half of the mob rather than the lower half,
 * higher up things (hats for example) need to be offset more due to the location of the filter displacement
 */
/mob/living/carbon/human/proc/apply_height_offsets(mutable_appearance/appearance, upper_torso)
	var/height_to_use = num2text(get_mob_height())
	var/final_offset = 0
	switch(upper_torso)
		if(UPPER_BODY)
			final_offset = GLOB.human_heights_to_offsets[height_to_use][1]
		if(LOWER_BODY)
			final_offset = GLOB.human_heights_to_offsets[height_to_use][2]
		else
			return

	appearance.pixel_y += final_offset
	return appearance

/**
 * Applies a filter to an appearance according to mob height
 */
/mob/living/carbon/human/proc/apply_height_filters(mutable_appearance/appearance)
	var/static/icon/cut_torso_mask = icon('icons/effects/cut.dmi', "Cut1")
	var/static/icon/cut_legs_mask = icon('icons/effects/cut.dmi', "Cut2")
	var/static/icon/lenghten_torso_mask = icon('icons/effects/cut.dmi', "Cut3")
	var/static/icon/lenghten_legs_mask = icon('icons/effects/cut.dmi', "Cut4")

	appearance.remove_filter(list(
		"Cut_Torso",
		"Cut_Legs",
		"Lenghten_Legs",
		"Lenghten_Torso",
		"Gnome_Cut_Torso",
		"Gnome_Cut_Legs",
	))

	switch(get_mob_height())
		// Don't set this one directly, use TRAIT_DWARF
		if(HUMAN_HEIGHT_DWARF)
			appearance.add_filter("Gnome_Cut_Torso", 1, displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2))
			appearance.add_filter("Gnome_Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 3))
		if(HUMAN_HEIGHT_SHORTEST)
			appearance.add_filter("Cut_Torso", 1, displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 1))
			appearance.add_filter("Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_SHORT)
			appearance.add_filter("Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_TALL)
			appearance.add_filter("Lenghten_Legs", 1, displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_TALLEST)
			appearance.add_filter("Lenghten_Torso", 1, displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1))
			appearance.add_filter("Lenghten_Legs", 1, displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1))

	return appearance
