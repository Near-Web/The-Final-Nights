// ================================
// about_me Component - Group Tools
// ================================

/datum/component/about_me/proc/create_group()
	set name = "Create Group"
	set desc = "Create a new group or affiliation."

	var/name = input(owner, "Group name:", "Create Group") as text
	if (!name) return

	var/gtype = input(owner, "Group type:", "", "coterie") as null|anything in list("sect", "clan", "faction", "organization", "party", "coterie")
	if (!gtype) return

	var/desc = input(owner, "Description:", "", "A newly formed group.") as null|text
	var/icon = input(owner, "Icon path (optional):", "", "") as null|text

	var/typepath = "/datum/groups/[gtype]"
	var/datum/groups/G = ispath(typepath) ? new typepath() : new /datum/groups/player_created

	G.name = name
	G.desc = desc
	G.icon = icon
	G.group_type = gtype
	G.leader_ckey = owner.ckey
	G.AddMember(owner.ckey)
	global_groups += G
	G.save_to_file()

	to_chat(owner, "<span class='notice'>You created a new group: <b>[name]</b></span>")


/datum/component/about_me/proc/edit_group(var/id)
	if (!id) return

	for (var/datum/groups/G in global_groups)
		if (G.id == id)
			var/name = input(owner, "Edit name:", "", G.name) as null|text
			var/gtype = input(owner, "Edit group type:", "", G.group_type) as null|anything in list("sect", "clan", "faction", "organization", "party", "coterie")
			var/desc = input(owner, "Edit description:", "", G.desc) as null|text
			var/icon = input(owner, "Edit icon path:", "", G.icon) as null|text

			if (name) G.name = name
			if (gtype) G.group_type = gtype
			if (desc) G.desc = desc
			if (icon) G.icon = icon
			G.save_to_file()
			to_chat(owner, "<span class='notice'>Group '[G.name]' updated.</span>")
			return


/datum/component/about_me/proc/delete_group(var/id)
	if (!id) return

	for (var/datum/groups/G in global_groups)
		if (G.id == id)
			global_groups -= G
			G.save_to_file()
			to_chat(owner, "<span class='notice'>Group '[G.name]' deleted.</span>")
			return


/datum/component/about_me/proc/join_group(var/id)
	for (var/datum/groups/G in global_groups)
		if (G.id == id && !G.IsMember(owner.ckey))
			G.AddMember(owner.ckey)
			G.save_to_file()
			to_chat(owner, "<span class='notice'>You joined the group: [G.name]</span>")
			return

/datum/component/about_me/proc/leave_group(var/id)
	for (var/datum/groups/G in global_groups)
		if (G.id == id && G.IsMember(owner.ckey))
			G.RemoveMember(owner.ckey)
			G.save_to_file()
			to_chat(owner, "<span class='notice'>You left the group: [G.name]</span>")
			return

/datum/component/about_me/proc/get_player_groups()
	var/list/my_groups = list()
	for (var/datum/groups/G in global_groups)
		if (G.IsMember(owner.ckey))
			my_groups += G
	return my_groups

// Assign a role to a group member
/datum/groups/proc/SetMemberRole(var/ckey, var/role)
	if (!islist(member_roles))
		member_roles = list()
	member_roles[ckey] = role
	return

// Retrieve a member's role
/datum/groups/proc/GetMemberRole(var/ckey)
	if (!islist(member_roles))
		return null
	return member_roles[ckey]


