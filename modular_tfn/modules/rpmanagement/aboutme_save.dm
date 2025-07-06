// Save
/datum/component/about_me/proc/get_save_path()
	if (!owner || !owner.ckey)
		return null
	var/ckey = lowertext(owner.ckey)
	var/subfolder = copytext(ckey, 1, 2) // e.g., "m"
	return "data/player_saves/[subfolder]/[ckey]/about_me.sav"


//This saves to the player's save file for now. In its own file for modularity.
//The component handles saving/loading its own data.
/datum/component/about_me/proc/save_to_file()
	var/path = get_save_path()
	if (!path) {
		message_admins("[src]: Failed to resolve save path.")
		return
	}
	// Open or create savefile at path
	var/savefile/F = new(path)
	if (!F) {
		message_admins("[src]: Failed to open save file at [path].")
		return
	}
	F["version"] << 1
	F["memories_all"] << memories_all
	F["chronicle_events"] << chronicle_events
	F["group_relationships"] << group_relationships
	F["sect_text"] << sect_text
	F["organization_text"] << organization_text
	F["party_text"] << party_text
	F["current_status"] << current_status
	F["faction_alignment"] << faction_alignment
	message_admins("[src]: about_me data saved to [path].")


//LOAD
/datum/component/about_me/proc/load_from_file()
	var/path = get_save_path()
	if (!path || !fexists(path)) {
		message_admins("[src]: No save found at [path], creating new default data.")
		save_to_file()
		return
	}

	var/savefile/F = new(path)
	if (!F) {
		message_admins("[src]: Failed to open save file at [path], generating defaults.")
		save_to_file()
		return
	}

	var/version
	F["version"] >> version
	F["memories_all"] >> memories_all
	F["chronicle_events"] >> chronicle_events
	F["group_relationships"] >> group_relationships
	F["sect_text"] >> sect_text
	F["organization_text"] >> organization_text
	F["party_text"] >> party_text
	F["current_status"] >> current_status
	F["faction_alignment"] >> faction_alignment

	message_admins("[src]: Loaded about_me data from [path].")
