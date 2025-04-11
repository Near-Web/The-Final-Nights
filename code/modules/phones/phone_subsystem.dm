// Subsystem that is responsible for handling the phone system.
// Generates a list of all phone numbers roundstart and lists them respectively to who needs them.
// Handles phone calls.

SUBSYSTEM_DEF(phones)
	name = "Phones"
	init_order = INIT_ORDER_DEFAULT
	flags = SS_NO_FIRE

	// Seven digits, always start with 5
	var/list/assigned_phone_numbers = list()
	// List of frequencies that can be used
	var/list/usable_frequencies = list()
	// List of frequencies in use
	var/list/frequencies_in_use = list()
	var/list/ringing_timers = list()


/datum/controller/subsystem/phones/Initialize()
	for(var/frequency in 1 to USABLE_RADIO_FREQUENCIES_FOR_PHONES)
		usable_frequencies += frequency
	return TRUE

//Generates a random phone number from the available ranges, seven digits, starts with a 5.
/datum/controller/subsystem/phones/proc/random_number()
	return rand(5000000, 5999999)

// If this ever goes over the hard limit of 1000000 phone numbers, we have a problem.
/datum/controller/subsystem/phones/proc/generate_phone_number(obj/item/sim_card/sim_card)
	for(var/generation_attempt in 1 to 1000000)
		var/randomly_generated_phone_number = random_number()
		if(randomly_generated_phone_number in assigned_phone_numbers)
			continue
		assigned_phone_numbers[sim_card] |= randomly_generated_phone_number
		return randomly_generated_phone_number
	CRASH("[src] failed to generate a unique phone number after 1000000 attempts.")

/datum/controller/subsystem/phones/proc/initiate_phone_call(obj/item/sim_card/sim_card, phone_number)
	var/established_frequency = establish_secure_frequency()
	frequencies_in_use["[sim_card.phone_number]"] |= established_frequency //The frequency in use is being used by the phone number that is calling the other phone.

	var/obj/item/sim_card/called_sim_card = validate_phone_number(phone_number)
	if(!called_sim_card)
		to_chat(usr, span_notice("The number you have dialed is not in service."))
		return

	var/obj/item/smartphone/phone = called_sim_card.phone_weakref?.resolve()
	if(!phone)
		CRASH("SIM card without a phone weakref. This should not be happening.")
	if(phone.phone_flags & PHONE_IN_CALL)
		to_chat(usr, span_notice("The number you have dialed is currently busy."))
		return

	SEND_SIGNAL(called_sim_card, COMSIG_PHONE_RING, sim_card, sim_card.phone_number, established_frequency) // Tell the phone number they are being called.
	ringing_timers[sim_card] = addtimer(CALLBACK(src, PROC_REF(phone_ring_timeout), sim_card, called_sim_card, sim_card.phone_number, established_frequency), TIME_TO_RING)
	return established_frequency //Give the phone who is calling which frequency to use.

/datum/controller/subsystem/phones/proc/cancel_ring_timeout(obj/item/sim_card/sim_card)
	deltimer(ringing_timers[sim_card])

/datum/controller/subsystem/phones/proc/phone_ring_timeout(obj/item/sim_card/sim_card, obj/item/sim_card/called_sim_card, phone_number, established_frequency)
	SEND_SIGNAL(sim_card, COMSIG_PHONE_RING_TIMEOUT, phone_number, established_frequency)
	SEND_SIGNAL(called_sim_card, COMSIG_PHONE_RING_TIMEOUT, phone_number, established_frequency)

/datum/controller/subsystem/phones/proc/establish_secure_frequency()
	var/secure_frequency = pick(usable_frequencies - frequencies_in_use)
	if(!secure_frequency)
		CRASH("[src] failed to create secure frequency. Possibly more than 100 phone calls ongoing?")
	return pick(usable_frequencies - frequencies_in_use)

/datum/controller/subsystem/phones/proc/end_phone_call(obj/item/sim_card/sim_card, phone_number)
	var/obj/item/sim_card/called_sim_card = validate_phone_number(phone_number)
	if(called_sim_card)
		SEND_SIGNAL(called_sim_card, COMSIG_PHONE_CALL_ENDED, sim_card.phone_number)
		frequencies_in_use.Remove(sim_card.phone_number)

/datum/controller/subsystem/phones/proc/validate_phone_number(phone_number)
	var/obj/item/sim_card/called_sim_card
	for(var/obj/item/sim_card/checking_sim_card as anything in assigned_phone_numbers)
		if(checking_sim_card.phone_number == text2num(phone_number))
			called_sim_card = checking_sim_card
	return called_sim_card
