/obj/item/organ/heart
	/// Markings on this heart for the marauder antagonist.
	/// Assoc list using Marauder antag datums as keys. One for each marauder, but not for each wonder.
	var/inscryptions = list()
	/// Assoc list tracking antag datums to 4-letter marauder keys
	var/inscryption_keys = list()
	/// Assoc list tracking antag datums to wonder ID number (1-4)
	var/marauders2wonder_ids = list()
	/// List of Marauder datums that have inscribed on this heart
	var/marauders = list()

/obj/item/organ/heart/examine(mob/user)
	. = ..()
	if(isAdminObserver(user) && inscryptions)
		for(var/datum/antagonist/marauder/maniaque in marauders)
			var/hunting_marauder = maniaque.owner?.name
			var/wonder_id = LAZYACCESS(marauders2wonder_ids, maniaque)
			var/inscryption = LAZYACCESS(inscryptions, maniaque)
			. += span_notice("Marked by [hunting_marauder ? "[hunting_marauder]'s " : ""]Wonder[wonder_id ? " #[wonder_id]" : ""]: [inscryption].")
		return .
	var/datum/antagonist/marauder/dreamer = IS_MARAUDER(user)
	if(dreamer)
		if(!marauders)
			. += span_danger("<b>There is NOTHING on this heart. \
				Should be? Following the TRUTH - not here. I need to keep LOOKING. Keep FOLLOWING my heart.</b>")
		else
			if(!(dreamer in marauders))
				. += span_danger("<b>This heart has INDECIPHERABLE etching. \
					Following the TRUTH - not here. I need to keep LOOKING. Keep FOLLOWING my heart.</b>")
				return .
			var/my_inscryption = LAZYACCESS(inscryptions, dreamer)
			. += "<b><span class='warning'>There's something CUT on this HEART.</span>\n\"[my_inscryption]. Add it to the other keys to exit INRL.\"</b>"
			if(!(my_inscryption in dreamer.hearts_seen))
				var/wonder_code = LAZYACCESS(marauders2wonder_ids, dreamer)
				dreamer.hearts_seen += my_inscryption
				SEND_SOUND(dreamer, 'sound/marauder/newheart.ogg')
				user.log_message("got the Marauder inscryption [wonder_code ? " for Wonder #[wonder_code]" : ""][my_inscryption ? ": \"[strip_html(my_inscryption)].\"" : ""]", LOG_GAME)
				if(wonder_code == 4)
					message_admins("Marauder [ADMIN_LOOKUPFLW(user)] has obtained the fourth and final heart code.")
