/// Big version of the me emote verb
/mob/verb/me_big_verb(message as message)
	set name = "Me(big)"
	set category = "IC"

	// If they don't type anything just drop the message.
	//set_typing_indicator(FALSE)
	if(!length(message))
		return
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_notice("Speech is currently admin-disabled."))
		return
	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	usr.emote("me",1,message,TRUE)
