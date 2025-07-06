/datum/component/about_me/ui_state(mob/user)
    // This can be expanded for more advanced state logic; for now, always enabled.
    return GLOB.always_state

/datum/component/about_me/ui_data(mob/user)
    return list("overview" = get_full_payload())

/datum/component/about_me/ui_static_data(mob/user)
    // No static data needed for now, but you could add config or labels here if desired.
    return list()

/datum/component/about_me/ui_interact(mob/user, datum/tgui/ui)
    ui = SStgui.try_update_ui(user, src, ui)
    if(!ui)
        ui = new(user, src, "AboutmeInt")
        ui.open()

/datum/component/about_me/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
    // If you want About Me to handle act (button) events, add them here.
    // For now, just call parent so you get future compatibility.
    . = ..()
    if (.)
        return
    // Example: if(action == "edit_name") { ... }




/datum/action/about_me
	name = "About Me"
	desc = "View character profile, disciplines, stats, relationships, and memories."
	button_icon_state = "masquerade"
	check_flags = NONE
	var/datum/component/about_me/about_me_component

/datum/action/about_me/New()
	. = ..()

/datum/action/about_me/Trigger(trigger_flags)
	about_me_component = owner.GetComponent(/datum/component/about_me)
	if (about_me_component)
		about_me_component.ui_interact(owner)
