/datum/component/about_me/proc/create_chronicle()
	set name = "Create Chronicle"
	set desc = "Create a personal chronicle entry."

	var/title = input(owner, "Chronicle Title:", "Create Chronicle") as text
	if (!title) return
	var/details = input(owner, "Chronicle Details:", "Describe what happened.") as message
	if (!details) return

	var/datum/chronicle_entry/E = new(title, details)
	chronicle_events += E
	save_to_file()
	to_chat(owner, "<span class='notice'>Chronicle entry '<b>[title]</b>' created.</span>")

/datum/component/about_me/proc/edit_chronicle(var/id)
	if (!id || !length(chronicle_events)) return

	for (var/datum/chronicle_entry/E in chronicle_events)
		if (E.id == id)
			var/title = input(owner, "Edit Title:", "", E.title) as null|text
			var/details = input(owner, "Edit Details:", "", E.details) as null|message

			if (title) E.title = title
			if (details) E.details = details
			save_to_file()
			to_chat(owner, "<span class='notice'>Chronicle entry '[E.title]' updated.</span>")
			return

/datum/component/about_me/proc/delete_chronicle(var/id)
	if (!id || !length(chronicle_events)) return

	for (var/datum/chronicle_entry/E in chronicle_events)
		if (E.id == id)
			chronicle_events -= E
			save_to_file()
			to_chat(owner, "<span class='notice'>Chronicle entry '[E.title]' deleted.</span>")
			return
