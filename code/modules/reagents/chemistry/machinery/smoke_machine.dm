#define REAGENTS_BASE_VOLUME 100 // actual volume is REAGENTS_BASE_VOLUME plus REAGENTS_BASE_VOLUME * rating for each matterbin

/obj/machinery/smoke_machine
	name = "smoke machine"
	desc = "A machine with a centrifuge installed into it. It produces smoke with any reagents you put into the machine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "smoke0"
	base_icon_state = "smoke"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/smoke_machine
	processing_flags = NONE

	var/efficiency = 10
	var/on = FALSE
	var/cooldown = 0
	var/screen = "home"
	var/useramount = 30 // Last used amount
	var/setting = 1 // displayed range is 3 * setting
	var/max_range = 3 // displayed max range is 3 * max range

/datum/effect_system/smoke_spread/chem/smoke_machine/set_up(datum/reagents/carry, setting=1, efficiency=10, loc, silent=FALSE)
	amount = setting
	carry.copy_to(chemholder, 20)
	carry.remove_any(amount * 16 / efficiency)
	location = loc

/datum/effect_system/smoke_spread/chem/smoke_machine
	effect_type = /obj/effect/particle_effect/smoke/chem/smoke_machine

/obj/effect/particle_effect/smoke/chem/smoke_machine
	opaque = FALSE
	alpha = 100

/obj/machinery/smoke_machine/Initialize()
	. = ..()
	create_reagents(REAGENTS_BASE_VOLUME)
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		reagents.maximum_volume += REAGENTS_BASE_VOLUME * B.rating
	if(is_operational)
		begin_processing()


/obj/machinery/smoke_machine/update_icon_state()
	if((!is_operational) || (!on) || (reagents.total_volume == 0))
		icon_state = "[base_icon_state]0[panel_open ? "-o" : null]"
		return ..()
	icon_state = "[base_icon_state]1"
	return ..()

/obj/machinery/smoke_machine/RefreshParts()
	var/new_volume = REAGENTS_BASE_VOLUME
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		new_volume += REAGENTS_BASE_VOLUME * B.rating
	if(!reagents)
		create_reagents(new_volume)
	reagents.maximum_volume = new_volume
	if(new_volume < reagents.total_volume)
		reagents.expose(loc, TOUCH) // if someone manages to downgrade it without deconstructing
		reagents.clear_reagents()
	efficiency = 9
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		efficiency += C.rating
	max_range = 1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		max_range += M.rating
	max_range = max(3, max_range)


/obj/machinery/smoke_machine/on_set_is_operational(old_value)
	if(old_value) //Turned off
		end_processing()
	else //Turned on
		begin_processing()


/obj/machinery/smoke_machine/process()
	..()
	if(reagents.total_volume == 0)
		on = FALSE
		update_appearance()
		return
	var/turf/T = get_turf(src)
	var/smoke_test = locate(/obj/effect/particle_effect/smoke) in T
	if(on && !smoke_test)
		update_appearance()
		var/datum/effect_system/smoke_spread/chem/smoke_machine/smoke = new()
		smoke.set_up(reagents, setting*3, efficiency, T)
		smoke.start()

/obj/machinery/smoke_machine/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		var/obj/item/reagent_containers/RC = I
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this, transfered_by = user)
		if(units)
			to_chat(user, "<span class='notice'>You transfer [units] units of the solution to [src].</span>")
			return
	if(default_unfasten_wrench(user, I, 40))
		on = FALSE
		return
	if(default_deconstruction_screwdriver(user, "smoke0-o", "smoke0", I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/smoke_machine/deconstruct()
	reagents.expose(loc, TOUCH)
	reagents.clear_reagents()
	return ..()

/obj/machinery/smoke_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmokeMachine", name)
		ui.open()

/obj/machinery/smoke_machine/ui_data(mob/user)
	var/data = list()
	var/TankContents[0]
	var/TankCurrentVolume = 0
	for(var/datum/reagent/R in reagents.reagent_list)
		TankContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
		TankCurrentVolume += R.volume
	data["TankContents"] = TankContents
	data["isTankLoaded"] = reagents.total_volume ? TRUE : FALSE
	data["TankCurrentVolume"] = reagents.total_volume ? reagents.total_volume : null
	data["TankMaxVolume"] = reagents.maximum_volume
	data["active"] = on
	data["setting"] = setting
	data["screen"] = screen
	data["maxSetting"] = max_range
	return data

/obj/machinery/smoke_machine/ui_act(action, params)
	. = ..()

	if(. || !anchored)
		return
	switch(action)
		if("purge")
			reagents.clear_reagents()
			update_appearance()
			. = TRUE
		if("setting")
			var/amount = text2num(params["amount"])
			if(amount in 1 to max_range)
				setting = amount
				. = TRUE
		if("power")
			on = !on
			update_appearance()
			if(on)
				message_admins("[ADMIN_LOOKUPFLW(usr)] activated a smoke machine that contains [english_list(reagents.reagent_list)] at [ADMIN_VERBOSEJMP(src)].")
				log_game("[key_name(usr)] activated a smoke machine that contains [english_list(reagents.reagent_list)] at [AREACOORD(src)].")
				log_combat(usr, src, "has activated [src] which contains [english_list(reagents.reagent_list)] at [AREACOORD(src)].")
		if("goScreen")
			screen = params["screen"]
			. = TRUE

#undef REAGENTS_BASE_VOLUME
