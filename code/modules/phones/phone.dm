/obj/item/flip_phone
	name = "flip phone"
	desc = "A portable device to call anyone you want."
	icon = 'icons/wod13/items/items.dmi'
	icon_state = "phone0"
	inhand_icon_state = "phone0"
	lefthand_file = 'icons/wod13/lefthand.dmi'
	righthand_file = 'icons/wod13/righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF | ACID_PROOF

	// There's a radio in my phone that calls me stud muffin.
	var/obj/item/radio/phone_radio

	/// Do we have a SIM card?
	var/obj/item/sim_card/sim_card
	/// Phone flags
	var/phone_flags = NONE
	/// The number the user is currently dialing.
	var/dialed_number
	// The frequency the phone is currently using to call another phone.
	var/secure_frequency
	// The frequency that is calling us.
	var/incoming_frequency
	var/obj/item/sim_card/incoming_sim_card

/obj/item/flip_phone/Initialize(mapload)
	. = ..()
	sim_card = new()
	sim_card.phone_weakref = WEAKREF(src)
	phone_radio = new()
	RegisterSignal(sim_card, COMSIG_PHONE_RING, PROC_REF(ring))
	RegisterSignal(sim_card, COMSIG_PHONE_RING_TIMEOUT, PROC_REF(ring_timeout))

/obj/item/flip_phone/Destroy(force)
	. = ..()
	UnregisterSignal(COMSIG_PHONE_RING)
	UnregisterSignal(COMSIG_PHONE_RING_TIMEOUT)
	if(sim_card)
		sim_card.phone_weakref = null
		QDEL_NULL(sim_card)
	if(phone_radio)
		QDEL_NULL(phone_radio)

/obj/item/flip_phone/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Interact")] to look at the screen.")
	. += span_notice("[EXAMINE_HINT("Alt-Click")] or [EXAMINE_HINT("Right-Click")] to toggle the screen.")
	if(sim_card)
		. += span_notice("[EXAMINE_HINT("Ctrl-Click")] to remove [sim_card].")
	else
		. += span_notice("You can [EXAMINE_HINT("Insert")] a SIM card.")

/obj/item/flip_phone/attack_self(mob/user, modifiers)
	. = ..()
	if(!(phone_flags & PHONE_OPEN))
		toggle_screen(user)
	ui_interact()

/obj/item/flip_phone/click_alt(mob/user)
	toggle_screen(user)
	return TRUE

/obj/item/flip_phone/attack_self_secondary(mob/user, modifiers)
	toggle_screen(user)
	return TRUE

/obj/item/flip_phone/item_ctrl_click(mob/user)
	if(!(user.is_holding(src)))
		return FALSE
	if(!sim_card)
		balloon_alert(user, "no sim card!")
		return FALSE
	if(do_after(user, 2 SECONDS, src))
		balloon_alert(user, "you remove \the [sim_card]!")
		end_phone_call()
		user.put_in_hands(sim_card)
		sim_card.phone_weakref = null
		sim_card = null
		phone_flags |= PHONE_NO_SIM
		UnregisterSignal(COMSIG_PHONE_RING)
		UnregisterSignal(COMSIG_PHONE_RING_TIMEOUT)
		return TRUE
	return FALSE

/obj/item/flip_phone/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/sim_card))
		if(sim_card)
			balloon_alert(user, "[sim_card] already installed!")
			return FALSE
		balloon_alert(user, "you insert \the [attacking_item]!")
		sim_card = attacking_item
		user.transferItemToLoc(attacking_item, src)
		sim_card.phone_weakref = WEAKREF(src)
		phone_flags &= ~PHONE_NO_SIM
		RegisterSignal(sim_card, COMSIG_PHONE_RING, PROC_REF(ring))
		RegisterSignal(sim_card, COMSIG_PHONE_RING_TIMEOUT, PROC_REF(ring_timeout))
		return TRUE
	return ..()

/obj/item/flip_phone/ui_status(mob/user, datum/ui_state/state)
	if(!(phone_flags & PHONE_OPEN))
		return UI_CLOSE
	return ..()

/obj/item/flip_phone/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Telephone")
		ui.open()

/obj/item/flip_phone/ui_data(mob/user)
	var/list/data = list()
	data["dialed_number"] = dialed_number
	data["my_number"] = sim_card ? sim_card.phone_number : "No SIM card inserted."
	data["being_called"] = (phone_flags & PHONE_RINGING) ? TRUE : FALSE
	data["in_call"] = (phone_flags & PHONE_IN_CALL) ? TRUE : FALSE
	data["calling_user"] = incoming_sim_card.phone_number
	return data

/obj/item/flip_phone/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("keypad")
			switch(params["value"])
				if("C")
					dialed_number = null
					return TRUE
			dialed_number += params["value"]
			return TRUE
		if("call")
			initialize_phone_call(usr)
			return TRUE
		if("hang")
			end_phone_call()
			return TRUE
		if("accept")
			accept_phone_call()
			return TRUE
		if("decline")
			end_phone_call()
			return TRUE
	return FALSE

/obj/item/flip_phone/proc/toggle_screen(mob/user)
	if(phone_flags & PHONE_OPEN)
		phone_flags &= ~PHONE_OPEN
	else
		phone_flags |= PHONE_OPEN
	icon_state = (phone_flags & PHONE_OPEN) ? "phone2" : "phone0"
	inhand_icon_state = (phone_flags & PHONE_OPEN) ? "phone2" : "phone0"
	update_icon()

/obj/item/flip_phone/proc/initialize_phone_call(mob/user)
	if(!sim_card)
		balloon_alert(user, "no SIM card installed!")
		return
	if(!secure_frequency)
		secure_frequency = SSphones.initiate_phone_call(sim_card, dialed_number)
	if(secure_frequency)
		phone_radio.set_frequency(secure_frequency)
		phone_radio.set_broadcasting(TRUE)
		phone_radio.set_listening(TRUE)
		phone_flags |= PHONE_IN_CALL

/obj/item/flip_phone/proc/end_phone_call()
	phone_radio.set_frequency(0)
	phone_radio.set_broadcasting(FALSE)
	phone_radio.set_listening(FALSE)
	secure_frequency = null
	SSphones.end_phone_call(sim_card, dialed_number)
	phone_flags &= ~PHONE_IN_CALL

/obj/item/flip_phone/proc/accept_phone_call()
	SSphones.cancel_ring_timeout(incoming_sim_card)
	incoming_sim_card = null
	secure_frequency = incoming_frequency
	phone_flags &= ~PHONE_RINGING
	initialize_phone_call()

// called_sim_card: the SIM card that is being called right now.
// caller_sim_card: the SIM card that is calling right now.
// phone_number: The phone number of who is calling.
// established_frequency: On what frequency we are being called.
/obj/item/flip_phone/proc/ring(obj/item/sim_card/called_sim_card, obj/item/sim_card/caller_sim_card, phone_number, established_frequency)
	SIGNAL_HANDLER

	say("RING RING RING")
	incoming_frequency = established_frequency
	incoming_sim_card = caller_sim_card
	phone_flags |= PHONE_RINGING

// sim_card: the SIM card that was calling right now.
// phone_number: The phone number of who was calling.
// established_frequency: On what frequency we were being called.
/obj/item/flip_phone/proc/ring_timeout(obj/item/sim_card/sim_card, phone_number, established_frequency)
	SIGNAL_HANDLER

	if(secure_frequency)
		end_phone_call()
	incoming_frequency = null
	incoming_sim_card = null
	phone_flags &= ~PHONE_RINGING
