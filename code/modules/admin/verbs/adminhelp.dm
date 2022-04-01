GLOBAL_DATUM_INIT(ahelp_tickets, /datum/help_tickets/admin, new)

/// Client Stuff

/client
	var/adminhelptimerid = 0	//a timer id for returning the ahelp verb
	var/datum/help_ticket/current_adminhelp_ticket	//the current ticket the (usually) not-admin client is dealing with

/client/proc/openTicketManager()
	set name = "Ticket Manager"
	set desc = "Opens the ticket manager"
	set category = "Admin"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	GLOB.ahelp_tickets.BrowseTickets(usr)

/datum/help_tickets/admin/BrowseTickets(mob/user)
	var/client/C = user.client
	if(!C)
		return
	var/datum/admins/admin_datum = GLOB.admin_datums[C.ckey]
	if(!admin_datum)
		message_admins("[C.ckey] attempted to browse tickets, but had no admin datum")
		return
	if(!admin_datum.admin_interface)
		admin_datum.admin_interface = new(user)
	admin_datum.admin_interface.ui_interact(user)

/client/proc/giveadminhelpverb()
	add_verb(src, /client/verb/adminhelp)
	deltimer(adminhelptimerid)
	adminhelptimerid = 0

GLOBAL_DATUM_INIT(admin_help_ui_handler, /datum/admin_help_ui_handler, new)

/datum/admin_help_ui_handler
	var/list/ahelp_cooldowns = list()

/datum/admin_help_ui_handler/ui_state(mob/user)
	return GLOB.always_state

/datum/admin_help_ui_handler/ui_data(mob/user)
	. = list()
	var/list/admins = get_admin_counts(R_BAN)
	.["adminCount"] = length(admins["present"])

/datum/admin_help_ui_handler/ui_static_data(mob/user)
	. = list()
	.["bannedFromUrgentAhelp"] = is_banned_from(user.ckey, "Urgent Adminhelp")
	.["urgentAhelpPromptMessage"] = CONFIG_GET(string/urgent_ahelp_user_prompt)
	var/webhook_url = CONFIG_GET(string/urgent_adminhelp_webhook_url)
	if(webhook_url)
		.["urgentAhelpEnabled"] = TRUE

/datum/admin_help_ui_handler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Adminhelp")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/admin_help_ui_handler/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/client/user_client = usr.client
	var/message = sanitize_text(trim(params["message"]))
	var/urgent = !!params["urgent"]
	var/list/admins = get_admin_counts(R_BAN)
	if(length(admins["present"]) != 0 || is_banned_from(user_client.ckey, "Urgent Adminhelp"))
		urgent = FALSE

	if(user_client.adminhelptimerid)
		return

	perform_adminhelp(user_client, message, urgent)
	ui.close()

/datum/admin_help_ui_handler/proc/perform_adminhelp(client/user_client, message, urgent)
	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	if(!message)
		return

	//handle muting and automuting
	if(user_client.prefs.muted & MUTE_ADMINHELP)
		to_chat(user_client, span_danger("Error: Admin-PM: You cannot send adminhelps (Muted)."), confidential = TRUE)
		return
	if(user_client.handle_spam_prevention(message, MUTE_ADMINHELP))
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Adminhelp") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

	if(urgent)
		if(!COOLDOWN_FINISHED(src, ahelp_cooldowns?[user_client.ckey]))
			urgent = FALSE // Prevent abuse
		else
			COOLDOWN_START(src, ahelp_cooldowns[user_client.ckey], CONFIG_GET(number/urgent_ahelp_cooldown) * (1 SECONDS))

	if(user_client.current_adminhelp_ticket)
		user_client.current_adminhelp_ticket.TimeoutVerb()
		if(urgent)
			var/sanitized_message = sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN))
			user_client.current_adminhelp_ticket.send_message_to_tgs(sanitized_message, urgent = TRUE)
		user_client.current_adminhelp_ticket.MessageNoRecipient(message, urgent)
		return

	var/datum/help_ticket/admin/ticket = new(user_client)
	ticket.Create(message, FALSE)


/client/verb/no_tgui_adminhelp(message as message)
	set name = "NoTguiAdminhelp"
	set hidden = TRUE

	if(adminhelptimerid)
		return

	message = trim(message)

	GLOB.admin_help_ui_handler.perform_adminhelp(src, message, FALSE)

/client/verb/adminhelp()
	set category = "Admin"
	set name = "Adminhelp"
	GLOB.admin_help_ui_handler.ui_interact(mob)
	to_chat(src, span_boldnotice("Adminhelp failing to open or work? <a href='byond://?src=[REF(src)];tguiless_adminhelp=1'>Click here</a>"))

/client/verb/view_latest_ticket()
	set category = "Admin"
	set name = "View Latest Ticket"

	if(!current_adminhelp_ticket)
		// Check if the client had previous tickets, and show the latest one
		var/list/prev_tickets = list()
		var/datum/help_ticket/admin/last_ticket
		// Check all resolved tickets for this player
		for(var/datum/help_ticket/admin/resolved_ticket in GLOB.ahelp_tickets.resolved_tickets)
			if(resolved_ticket.initiator_ckey == ckey) // Initiator is a misnomer, it's always the non-admin player even if an admin bwoinks first
				prev_tickets += resolved_ticket
		// Check all closed tickets for this player
		for(var/datum/help_ticket/admin/closed_ticket in GLOB.ahelp_tickets.closed_tickets)
			if(closed_ticket.initiator_ckey == ckey)
				prev_tickets += closed_ticket
		// Take the most recent entry of prev_tickets and open the panel on it
		if(LAZYLEN(prev_tickets))
			last_ticket = pop(prev_tickets)
			last_ticket.TicketPanel()
			return

		// client had no tickets this round
		to_chat(src, span_warning("You have not had an ahelp ticket this round."))
		return

	current_adminhelp_ticket.TicketPanel()

/// Ticket List UI

/datum/help_ui/admin/ui_state(mob/user)
	return GLOB.admin_state

/datum/help_ui/admin/get_data_glob()
	return GLOB.ahelp_tickets

/datum/help_ui/admin/add_additional_ticket_data(data)
	// Add mentorhelp tickets to admin panel
	var/datum/help_tickets/data_glob = GLOB.mhelp_tickets
	data["unclaimed_tickets_mentor"] = data_glob.get_ui_ticket_data(TICKET_UNCLAIMED)
	data["open_tickets_mentor"] = data_glob.get_ui_ticket_data(TICKET_ACTIVE)
	data["closed_tickets_mentor"] = data_glob.get_ui_ticket_data(TICKET_CLOSED)
	data["resolved_tickets_mentor"] = data_glob.get_ui_ticket_data(TICKET_RESOLVED)
	return data

/datum/help_ui/admin/get_additional_ticket_data(ticket_id)
	return GLOB.mhelp_tickets.TicketByID(ticket_id) // make sure mhelp tickets can be retrieved for actions

/datum/help_ui/admin/check_permission(mob/user)
	return !!GLOB.admin_datums[user.ckey]

/datum/help_ui/admin/reply(whom)
	usr.client.cmd_ahelp_reply(whom)

/// Tickets Holder

/datum/help_tickets/admin

/datum/help_tickets/admin/get_active_ticket(client/C)
	return C.current_adminhelp_ticket

/datum/help_tickets/admin/set_active_ticket(client/C, datum/help_ticket/ticket)
	C.current_adminhelp_ticket = ticket

/// Ticket Datum

/datum/help_ticket/admin
	var/heard_by_no_admins = FALSE
	/// is the ahelp player to admin (not bwoink) or admin to player (bwoink)
	var/bwoink = FALSE

/datum/help_ticket/admin/get_data_glob()
	return GLOB.ahelp_tickets

/datum/help_ticket/admin/check_permission(mob/user)
	return !!GLOB.admin_datums[user.ckey]

/datum/help_ticket/admin/check_permission_act(mob/user)
	return !!GLOB.admin_datums[user.ckey] && check_rights(R_ADMIN)

/datum/help_ticket/admin/ui_state(mob/user)
	return GLOB.admin_state

/datum/help_ticket/admin/reply(whom, msg)
	usr.client.cmd_ahelp_reply_instant(whom, msg)

/**
 * Call this on its own to create a ticket, don't manually assign current_ticket
 *
 * Arguments:
 * * msg - The first message of this admin_help: used for the initial title of the ticket
 * * is_bwoink - Boolean operator, TRUE if this ticket was started by an admin PM
 */
/datum/help_ticket/admin/Create(msg, is_bwoink)
	if(!..())
		return FALSE
	if(is_bwoink)
		AddInteraction("blue", name, usr.ckey, initiator_key_name, "Administrator", "You")
		message_admins("<font color='blue'>Ticket [TicketHref("#[id]")] created</font>")
		Claim()	//Auto claim bwoinks
		bwoink = TRUE
	else
		MessageNoRecipient(msg)
		//send it to tgs if nobody is on and tell us how many were on
		var/admin_number_present = send2tgs_adminless_only(initiator_ckey, "Ticket #[id]: [msg]")
		log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK admins who have +BAN.")
		if(admin_number_present <= 0)
			to_chat(initiator, "<span class='notice'>No active admins are online, your adminhelp was sent through TGS to admins who are available. This may use IRC or Discord.</span>", type = message_type)
			heard_by_no_admins = TRUE
		send_message_to_tgs("**ADMINHELP: (#[id]) [initiator.key]: ** \"[msg]\" [heard_by_no_admins ? "**(NO ADMINS)**" : "" ]")
	return TRUE

/datum/help_ticket/admin/NewFrom(datum/help_ticket/old_ticket)
	if(!..())
		return FALSE
	MessageNoRecipient(initial_msg, FALSE)
	//send it to tgs if nobody is on and tell us how many were on
	var/admin_number_present = send2tgs_adminless_only(initiator_ckey, "Ticket #[id]: [initial_msg]")
	log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK admins who have +BAN.")
	if(admin_number_present <= 0)
		to_chat(initiator, "<span class='notice'>No active admins are online, your adminhelp was sent through TGS to admins who are available. This may use IRC or Discord.</span>")
		heard_by_no_admins = TRUE
	send_message_to_tgs("**ADMINHELP: (#[id]) [initiator.key]: ** \"[initial_msg]\" [heard_by_no_admins ? "**(NO ADMINS)**" : "" ]")
	return TRUE

/datum/help_ticket/admin/AddInteraction(msg_color, message, name_from, name_to, safe_from, safe_to)
	if(heard_by_no_admins && usr && usr.ckey != initiator_ckey)
		heard_by_no_admins = FALSE
		send2tgs(initiator_ckey, "Ticket #[id]: Answered by [key_name(usr)]")
	..()

/datum/help_ticket/admin/TimeoutVerb()
	remove_verb(initiator, /client/verb/adminhelp)
	initiator.adminhelptimerid = addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 1200, TIMER_STOPPABLE)

/datum/help_ticket/admin/get_ticket_additional_data(mob/user, list/data)
	data["antag_status"] = "None"
	if(initiator)
		var/mob/living/M = initiator.mob
		if(M?.mind?.antag_datums)
			var/datum/antagonist/AD = M.mind.antag_datums[1]
			data["antag_status"] = AD.name
	return data

/datum/help_ticket/admin/key_name_ticket(mob/user)
	return key_name_admin(user)

/datum/help_ticket/admin/message_ticket_managers(msg)
	message_admins(msg)

/datum/help_ticket/admin/MessageNoRecipient(msg, add_to_ticket = TRUE, sanitized = FALSE)
	var/ref_src = "[REF(src)]"
	var/sanitized_msg = sanitized ? msg : sanitize(msg)

	//Message to be sent to all admins
	var/admin_msg = "<span class='adminnotice'><span class='adminhelp'>Ticket [TicketHref("#[id]", ref_src)]</span><b>: [LinkedReplyName(ref_src)] [FullMonty(ref_src)]:</b> <span class='linkify'>[keywords_lookup(sanitized_msg)]</span></span>"

	if(add_to_ticket)
		AddInteraction("red", msg, initiator_key_name, claimee_key_name, "You", "Administrator")
	log_admin_private("Ticket #[id]: [key_name(initiator)]: [msg]")

	//send this msg to all admins
	for(var/client/X in GLOB.admins)
		SEND_SOUND(X, sound(reply_sound))
		window_flash(X, ignorepref = TRUE)
		to_chat(X,
			type = message_type,
			html = admin_msg)

	//show it to the person adminhelping too
	if(add_to_ticket)
		to_chat(initiator,
			type = message_type,
			html = "<span class='adminnotice'>PM to-<b>Admins</b>: <span class='linkify'>[sanitized_msg]</span></span>")


/datum/help_ticket/admin/proc/FullMonty(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = ADMIN_FULLMONTY_NONAME(initiator.mob)
	if(state <= TICKET_ACTIVE)
		. += ClosureLinks(ref_src)

/datum/help_ticket/admin/proc/ClosureLinks(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reject'>REJT</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=icissue'>IC</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=close'>CLOSE</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=resolve'>RSLVE</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=mhelp'>MHELP</A>)"

/datum/help_ticket/admin/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reply'>[initiator_key_name]</A>"

/datum/help_ticket/admin/TicketHref(msg, ref_src, action = "ticket")
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=[action]'>[msg]</A>"

/datum/help_ticket/admin/blackbox_feedback(increment, data)
	SSblackbox.record_feedback("tally", "ahelp_stats", increment, data)

/// Resolve ticket with IC Issue message
/datum/help_ticket/admin/proc/ICIssue(key_name = key_name_ticket(usr))
	if(state > TICKET_ACTIVE)
		return

	if(!claimee)
		Claim(silent = TRUE)

	if(initiator)
		addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 5 SECONDS)
		SEND_SOUND(initiator, sound(reply_sound))
		resolve_message(status = "marked as IC Issue!", message = "\A [handling_name] has handled your ticket and has determined that the issue you are facing is an in-character issue and does not require [handling_name] intervention at this time.<br />\
		For further resolution, you should pursue options that are in character, such as filing a report with security or a head of staff.<br />\
		Thank you for creating a ticket, the adminhelp verb will be returned to you shortly.")

	blackbox_feedback(1, "IC")
	var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] marked as IC by [key_name]</span>"
	message_admins(msg)
	log_admin_private(msg)
	AddInteraction("red", "Marked as IC issue by [key_name]")
	Resolve(silent = TRUE)

	if(!bwoink)
		send_message_to_tgs("Ticket #[id] marked as IC by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/proc/MHelpThis(key_name = key_name_ticket(usr))
	if(state > TICKET_ACTIVE)
		return

	if(!claimee)
		Claim(silent = TRUE)

	if(initiator)
		initiator.giveadminhelpverb()
		SEND_SOUND(initiator, sound(reply_sound))
		resolve_message(status = "De-Escalated to Mentorhelp!", message = "This question may regard <b>game mechanics or how-tos</b>. Such questions should be asked with <b>Mentorhelp</b>.")

	blackbox_feedback(1, "mhelp this")
	var/msg = "<span class='[span_class]'>Ticket [TicketHref("#[id]")] transferred to mentorhelp by [key_name]</span>"
	AddInteraction("red", "Transferred to mentorhelp by [key_name].")
	if(!bwoink)
		send_message_to_tgs("Ticket #[id] transferred to mentorhelp by [key_name(usr, include_link = FALSE)]")
	Close(silent = TRUE, hide_interaction = TRUE)
	if(initiator.prefs.muted & MUTE_MHELP)
		message_admins(src, "<span class='danger'>Attempted de-escalation to mentorhelp failed because [initiator_key_name] is mhelp muted.</span>")
		return
	message_admins(msg)
	log_admin_private(msg)
	var/datum/help_ticket/mentor/ticket = new(initiator)
	ticket.NewFrom(src)

/// Forwarded action from admin/Topic
/datum/help_ticket/admin/proc/Action(action)
	testing("Ahelp action: [action]")
	switch(action)
		if("ticket")
			TicketPanel()
		if("retitle")
			Retitle()
		if("reject")
			Reject()
		if("reply")
			usr.client.cmd_ahelp_reply(initiator)
		if("icissue")
			ICIssue()
		if("close")
			Close()
		if("resolve")
			Resolve()
		if("reopen")
			Reopen()
		if("mhelp")
			MHelpThis()

/datum/help_ticket/admin/Claim(key_name = key_name_ticket(usr), silent = FALSE)
	..()
	if(!bwoink && !silent && !claimee)
		send_message_to_tgs("Ticket #[id] is being investigated by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/Close(key_name = key_name_ticket(usr), silent = FALSE, hide_interaction = FALSE)
	..()
	if(!bwoink && !silent)
		send_message_to_tgs("Ticket #[id] closed by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/Resolve(key_name = key_name_ticket(usr), silent = FALSE)
	..()
	addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 5 SECONDS)
	if(!bwoink)
		send_message_to_tgs("Ticket #[id] resolved by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/Reject(key_name = key_name_ticket(usr), extra_text = ", and clearly state the names of anybody you are reporting")
	..()
	if(initiator)
		initiator.giveadminhelpverb()
	if(!bwoink)
		send_message_to_tgs("Ticket #[id] rejected by [key_name(usr, include_link = FALSE)]")

/datum/help_ticket/admin/resolve_message(status = "Resolved", message = null, extratext = " If your ticket was a report, then the appropriate action has been taken where necessary.")
	..()

				// first we check if it's a ckey of an admin
				var/client/client_check = GLOB.directory[stripped_word]
				if(client_check?.holder)
					msglist[i] = "<u>[word]</u>"
					pinged_admins[stripped_word] = client_check
					modified = TRUE
					continue

				// then if not, we check if it's a datum ref

				var/word_with_brackets = "\[[stripped_word]\]" // the actual memory address lookups need the bracket wraps
				var/datum/datum_check = locate(word_with_brackets)
				if(!istype(datum_check))
					continue
				msglist[i] = "<u><a href='?_src_=vars;[HrefToken(TRUE)];Vars=[word_with_brackets]'>[word]</A></u>"
				modified = TRUE

			if("#") // check if we're linking a ticket
				var/possible_ticket_id = text2num(copytext(word, 2))
				if(!possible_ticket_id)
					continue

				var/datum/admin_help/ahelp_check = GLOB.ahelp_tickets?.TicketByID(possible_ticket_id)
				if(!ahelp_check)
					continue

				var/state_word
				switch(ahelp_check.state)
					if(AHELP_ACTIVE)
						state_word = "Active"
					if(AHELP_CLOSED)
						state_word = "Closed"
					if(AHELP_RESOLVED)
						state_word = "Resolved"

				msglist[i]= "<u><A href='?_src_=holder;[HrefToken()];ahelp=[REF(ahelp_check)];ahelp_action=ticket'>[word] ([state_word] | [ahelp_check.initiator_key_name])</A></u>"
				modified = TRUE

	if(modified)
		var/list/return_list = list()
		return_list[ASAY_LINK_NEW_MESSAGE_INDEX] = jointext(msglist, " ") // without tuples, we must make do!
		return_list[ASAY_LINK_PINGED_ADMINS_INDEX] = pinged_admins
		return return_list

/**
 * Checks a given message to see if any of the words are something we want to treat specially, as detailed below.
 *
 * There are 3 cases where a word is something we want to act on
 * 1. Admin pings, like @adminckey. Pings the admin in question, text is not clickable
 * 2. Datum refs, like @0x2001169 or @mob_23. Clicking on the link opens up the VV for that datum
 * 3. Ticket refs, like #3. Displays the status and ahelper in the link, clicking on it brings up the ticket panel for it.
 * Returns a list being used as a tuple. Index ASAY_LINK_NEW_MESSAGE_INDEX contains the new message text (with clickable links and such)
 * while index ASAY_LINK_PINGED_ADMINS_INDEX contains a list of pinged admin clients, if there are any.
 *
 * Arguments:
 * * msg - the message being scanned
 */
/proc/check_asay_links(msg)
	var/list/msglist = splittext(msg, " ") //explode the input msg into a list
	var/list/pinged_admins = list() // if we ping any admins, store them here so we can ping them after
	var/modified = FALSE // did we find anything?

	var/i = 0
	for(var/word in msglist)
		i++
		if(!length(word))
			continue

		switch(word[1])
			if("@")
				var/stripped_word = ckey(copytext(word, 2))

				// first we check if it's a ckey of an admin
				var/client/client_check = GLOB.directory[stripped_word]
				if(client_check?.holder)
					msglist[i] = "<u>[word]</u>"
					pinged_admins[stripped_word] = client_check
					modified = TRUE
					continue

				// then if not, we check if it's a datum ref

				var/word_with_brackets = "\[[stripped_word]\]" // the actual memory address lookups need the bracket wraps
				var/datum/datum_check = locate(word_with_brackets)
				if(!istype(datum_check))
					continue
				msglist[i] = "<u><a href='byond://?_src_=vars;[HrefToken(forceGlobal = TRUE)];Vars=[word_with_brackets]'>[word]</A></u>"
				modified = TRUE

			if("#") // check if we're linking a ticket
				var/possible_ticket_id = text2num(copytext(word, 2))
				if(!possible_ticket_id)
					continue

				var/datum/admin_help/ahelp_check = GLOB.ahelp_tickets?.TicketByID(possible_ticket_id)
				if(!ahelp_check)
					continue

				var/state_word
				switch(ahelp_check.state)
					if(AHELP_ACTIVE)
						state_word = "Active"
					if(AHELP_CLOSED)
						state_word = "Closed"
					if(AHELP_RESOLVED)
						state_word = "Resolved"

				msglist[i]= "<u><A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];ahelp=[REF(ahelp_check)];ahelp_action=ticket'>[word] ([state_word] | [ahelp_check.initiator_key_name])</A></u>"
				modified = TRUE

	if(modified)
		var/list/return_list = list()
		return_list[ASAY_LINK_NEW_MESSAGE_INDEX] = jointext(msglist, " ") // without tuples, we must make do!
		return_list[ASAY_LINK_PINGED_ADMINS_INDEX] = pinged_admins
		return return_list



#undef WEBHOOK_URGENT
#undef WEBHOOK_NONE
#undef WEBHOOK_NON_URGENT
