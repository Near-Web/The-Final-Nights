/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'modular_tfn/master_files/icons/obj/bloodpack.dmi' //TFN EDIT, ORIGINAL: icon = 'icons/obj/bloodpack.dmi'
	icon_state = "blood0" //TFN EDIT, ORIGINAL: icon_state = "bloodpack"
	volume = 200
	var/blood_type = "O-" //TFN edit, ORIGINAL: var/blood_type = null
	var/unique_blood = null
	var/labelled = FALSE
	fill_icon_thresholds = list(0, 25, 50, 75, 100) //TFN EDIT, ORIGINAL: fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)

/* TFN REMOVAL, SEE: modular_tfn/modules/vitae/code/blood_pack.dm
/obj/item/reagent_containers/blood/canconsume(mob/eater, mob/user)
	return FALSE

/obj/item/reagent_containers/blood/Initialize()
	. = ..()
	if(blood_type != null)
		reagents.add_reagent(unique_blood ? unique_blood : /datum/reagent/blood, 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
		update_appearance()

/// Handles updating the container when the reagents change.
/obj/item/reagent_containers/blood/on_reagent_change(datum/reagents/holder, ...)
	var/datum/reagent/blood/B = holder.has_reagent(/datum/reagent/blood)
	if(B && B.data && B.data["blood_type"])
		blood_type = B.data["blood_type"]
	else
		blood_type = null
	return ..()

/obj/item/reagent_containers/blood/update_name(updates)
	. = ..()
	if(labelled)
		return
	name = "blood_pack[blood_type ? " - [blood_type]" : null]"
*/

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize()
	icon_state = "bloodpack"
	blood_type = random_blood_type() // TFN EDIT, ORIGINAL: blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-", "L")
	return ..()

/obj/item/reagent_containers/blood/a_plus
	blood_type = "A+"

/obj/item/reagent_containers/blood/a_minus
	blood_type = "A-"

/obj/item/reagent_containers/blood/b_plus
	blood_type = "B+"

/obj/item/reagent_containers/blood/b_minus
	blood_type = "B-"

/obj/item/reagent_containers/blood/o_plus
	blood_type = "O+"

/obj/item/reagent_containers/blood/o_minus
	blood_type = "O-"

/* TFN REMOVAL
/obj/item/reagent_containers/blood/lizard
	blood_type = "L"

/obj/item/reagent_containers/blood/ethereal
	blood_type = "LE"
	unique_blood = /datum/reagent/consumable/liquidelectricity
*/

/obj/item/reagent_containers/blood/universal
	blood_type = "U"

/obj/item/reagent_containers/blood/attackby(obj/item/I, mob/user, params)
	if (IS_WRITING_UTENSIL(I))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on the label of [src]!</span>")
			return
		var/t = tgui_input_text(user, "What would you like to label the blood pack?", "Blood Pack", name, max_length = MAX_NAME_LEN)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(user.get_active_held_item() != I)
			return
		if(t)
			labelled = TRUE
			name = "blood pack - [t]"
			playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
			balloon_alert(user, "new label set")
		else
			labelled = FALSE
			update_name()
	else
		return ..()
