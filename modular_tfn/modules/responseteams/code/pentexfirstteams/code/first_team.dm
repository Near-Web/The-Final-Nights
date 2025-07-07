/datum/outfit/job/first_team
	name = "First Team Operator"
	ears = /obj/item/p25radio/police/government
	uniform = /obj/item/clothing/under/response/firstteam_uniform
	gloves = /obj/item/clothing/gloves/response/firstteam
	mask = /obj/item/clothing/mask/vampire/balaclava
	r_pocket = /obj/item/flashlight
	l_pocket = /obj/item/ammo_box/magazine/px66f
	shoes = /obj/item/clothing/shoes/response/firstteam
	belt = /obj/item/gun/ballistic/automatic/response/px66f
	suit = /obj/item/clothing/suit/response/firstteam_armor
	head = /obj/item/clothing/head/response/firstteam_helmet
	backpack_contents = list(
		/obj/item/ammo_box/magazine/px66f = 3,
		/obj/item/gun/ballistic/automatic/vampire/beretta=1,
		/obj/item/ammo_box/vampire/c556/silver = 1,
		/obj/item/vamp/keys/pentex = 1,
		/obj/item/veil_contract = 1
		)

/datum/antagonist/first_team/proc/equip_first_team()
	var/mob/living/carbon/human/H = owner.current
	if(!ishuman(owner.current))
		return
	H.equipOutfit(first_team_outfit)
	H.set_species(/datum/species/human)
	H.set_clan(null)
	H.generation = 13
	H.maxHealth = round((initial(H.maxHealth)-initial(H.maxHealth)/4)+(initial(H.maxHealth)/4)*(H.physique+13-H.generation))
	H.health = round((initial(H.health)-initial(H.health)/4)+(initial(H.health)/4)*(H.physique+13-H.generation))
	for(var/datum/action/A in H.actions)
		if(A.vampiric)
			A.Remove(H)
	H.thaumaturgy_knowledge = FALSE
	var/obj/item/organ/eyes/NV = new()
	NV.Insert(H, TRUE, FALSE)

	var/list/landmarkslist = list()
	for(var/obj/effect/landmark/start/S in GLOB.start_landmarks_list)
		if(S.name == name)
			landmarkslist += S
	var/obj/effect/landmark/start/D = pick(landmarkslist)
	H.forceMove(D.loc)

/datum/antagonist/first_team/proc/offer_loadout()
	var/list/loadouts = list(
		"Flamethrower",
		"Medic",
		"Sniper",
		"Ammo Carrier"
	)
	var/loadout_type = input(owner.current, "Choose your loadout:", "Loadout Selection") in loadouts
	switch(loadout_type)
		if("Flamethrower")
			owner.current.put_in_r_hand(new /obj/item/vampire_flamethrower(owner.current))
			owner.current.put_in_l_hand(new /obj/item/gas_can/full(owner.current))
		if("Medic")
			owner.current.put_in_r_hand(new /obj/item/storage/firstaid/tactical(owner.current))
		if("Sniper")
			owner.current.put_in_r_hand(new /obj/item/gun/ballistic/automatic/vampire/sniper(owner.current))
			owner.current.put_in_l_hand(new /obj/item/ammo_box/vampire/c50(owner.current))
		if("Ammo Carrier")
			owner.current.put_in_r_hand(new /obj/item/ammo_box/vampire/c556/incendiary(owner.current))
			owner.current.put_in_l_hand(new /obj/item/ammo_box/vampire/c556/silver(owner.current))

/obj/effect/landmark/start/first_team
	name = "First Team"
	delete_after_roundstart = FALSE

/datum/antagonist/first_team
	name = "First Team"
	roundend_category = "first_team"
	antagpanel_category = "First Team"
	job_rank = ROLE_FIRST_TEAM
	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "synd"
	antag_moodlet = /datum/mood_event/focused
	show_to_ghosts = TRUE
	var/always_new_team = FALSE
	var/datum/team/first_team/first_team_team
	var/first_team_outfit = /datum/outfit/job/first_team
	var/custom_objective

/datum/antagonist/first_team/sergeant
	name = "First Team Sergeant"
	always_new_team = TRUE
	var/title

/datum/antagonist/first_team/on_gain()
	randomize_appearance()
	forge_objectives()
	add_antag_hud(ANTAG_HUD_OPS, "synd", owner.current)
	owner.special_role = src
	equip_first_team()
	give_alias()
	offer_loadout()
	return ..()

/datum/antagonist/first_team/on_removal()
	..()
	to_chat(owner.current,"<span class='userdanger'>You are no longer in the First Team!</span>")
	owner.special_role = null

/datum/antagonist/first_team/greet()
	to_chat(owner.current, "<span class='alertsyndie'>You're in the First Team.</span>")
	to_chat(owner, "<span class='notice'>You are a [first_team_team ? first_team_team.first_team_name : "first team"] operator!</span>")
	owner.announce_objectives()


/datum/antagonist/first_team/proc/give_alias()
	var/my_name = "Tyler"
	var/list/military_ranks = list("Private", "Private First Class", "Specialist", "Corporal")
	var/selected_rank = pick(military_ranks)
	if(owner.current.gender == MALE)
		my_name = pick(GLOB.first_names_male)
	else
		my_name = pick(GLOB.first_names_female)
	var/my_surname = pick(GLOB.last_names)
	owner.current.fully_replace_character_name(null,"[selected_rank] [my_name] [my_surname]")

/datum/antagonist/first_team/proc/forge_objectives()
	if(first_team_team)
		objectives |= first_team_team.objectives

/datum/antagonist/first_team/sergeant/give_alias()
	var/my_name = "Tyler"
	if(owner.current.gender == MALE)
		my_name = pick(GLOB.first_names_male)
	else
		my_name = pick(GLOB.first_names_female)
	var/my_surname = pick(GLOB.last_names)
	owner.current.fully_replace_character_name(null,"Sergeant [my_name] [my_surname]")

/datum/team/first_team/antag_listing_name()
	if(first_team_name)
		return "[first_team_name] Operators"
	else
		return "Operators"


/datum/antagonist/first_team/sergeant/greet()
	to_chat(owner, "<B>You are the leading sergeant for this mission. You are responsible for guiding your team's operation.</B>")
	to_chat(owner, "<B>If you feel you are not up to this task, give your command to another operator.</B>")
	owner.announce_objectives()
	addtimer(CALLBACK(src, PROC_REF(first_teamteam_name_assign)), 1)

/datum/antagonist/first_team/sergeant/proc/first_teamteam_name_assign()
	if(!first_team_team)
		return
	first_team_team.rename_team(ask_name())

/datum/antagonist/first_team/sergeant/proc/ask_name()
	var/randomname = pick(GLOB.last_names)
	var/newname = stripped_input(owner.current,"You are the sergeant. Please choose a name for your team.", "Name change",randomname)
	if (!newname)
		newname = randomname
	else
		newname = reject_bad_name(newname)
		if(!newname)
			newname = randomname

/datum/antagonist/first_team/create_team(datum/team/first_team/new_team)
	if(!new_team)
		if(!always_new_team)
			for(var/datum/antagonist/first_team/N in GLOB.antagonists)
				if(!N.owner)
					stack_trace("Antagonist datum without owner in GLOB.antagonists: [N]")
					continue
		first_team_team = new /datum/team/first_team
		first_team_team.update_objectives()
		return
	if(!istype(first_team_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	first_team_team = new_team

/datum/antagonist/first_team/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = ROLE_FIRST_TEAM
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has first team'd [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has first team'd [key_name(new_owner)].")

/datum/random_gen/first_team
	var/hair_colors = list("040404",	//Black
										"120b05",	//Dark Brown
										"342414",	//Brown
										"554433",	//Light Brown
										"695c3b",	//Dark Blond
										"ad924e",	//Blond
										"dac07f",	//Light Blond
										"802400",	//Ginger
										"a5380e",	//Ginger alt
										"ffeace",	//Albino
										"650b0b",	//Punk Red
										"14350e",	//Punk Green
										"080918")	//Punk Blue

	var/male_hair = list("Balding Hair",
										"Bedhead",
										"Bedhead 2",
										"Bedhead 3",
										"Boddicker",
										"Business Hair",
										"Business Hair 2",
										"Business Hair 3",
										"Business Hair 4",
										"Coffee House",
										"Combover",
										"Crewcut",
										"Father",
										"Flat Top",
										"Gelled Back",
										"Joestar",
										"Keanu Hair",
										"Oxton",
										"Volaju")

	var/male_facial = list("Beard (Abraham Lincoln)",
											"Beard (Chinstrap)",
											"Beard (Full)",
											"Beard (Cropped Fullbeard)",
											"Beard (Hipster)",
											"Beard (Neckbeard)",
											"Beard (Three o Clock Shadow)",
											"Beard (Five o Clock Shadow)",
											"Beard (Seven o Clock Shadow)",
											"Moustache (Hulk Hogan)",
											"Moustache (Watson)",
											"Sideburns (Elvis)",
											"Sideburns")

	var/female_hair = list("Ahoge",
										"Long Bedhead",
										"Beehive",
										"Beehive 2",
										"Bob Hair",
										"Bob Hair 2",
										"Bob Hair 3",
										"Bob Hair 4",
										"Bobcurl",
										"Braided",
										"Braided Front",
										"Braid (Short)",
										"Braid (Low)",
										"Bun Head",
										"Bun Head 2",
										"Bun Head 3",
										"Bun (Large)",
										"Bun (Tight)",
										"Double Bun",
										"Emo",
										"Emo Fringe",
										"Feather",
										"Gentle",
										"Long Hair 1",
										"Long Hair 2",
										"Long Hair 3",
										"Long Over Eye",
										"Long Emo",
										"Long Fringe",
										"Ponytail",
										"Ponytail 2",
										"Ponytail 3",
										"Ponytail 4",
										"Ponytail 5",
										"Ponytail 6",
										"Ponytail 7",
										"Ponytail (High)",
										"Ponytail (Short)",
										"Ponytail (Long)",
										"Ponytail (Country)",
										"Ponytail (Fringe)",
										"Poofy",
										"Short Hair Rosa",
										"Shoulder-length Hair",
										"Volaju")

/datum/antagonist/first_team/proc/randomize_appearance()
	var/datum/random_gen/first_team/h_gen = new
	var/mob/living/carbon/human/H = owner.current
	H.gender = pick(MALE, FEMALE)
	H.body_type = H.gender
	H.age = rand(18, 36)
//	if(age >= 55)
//		hair_color = "a2a2a2"
//		facial_hair_color = hair_color
//	else
	H.hair_color = pick(h_gen.hair_colors)
	H.facial_hair_color = H.hair_color
	if(H.gender == MALE)
		H.hairstyle = pick(h_gen.male_hair)
		if(prob(25) || H.age >= 25)
			H.facial_hairstyle = pick(h_gen.male_facial)
		else
			H.facial_hairstyle = "Shaved"
	else
		H.hairstyle = pick(h_gen.female_hair)
		H.facial_hairstyle = "Shaved"
	H.name = H.real_name
	H.dna.real_name = H.real_name
	var/obj/item/organ/eyes/organ_eyes = H.getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		organ_eyes.eye_color = random_eye_color()
	H.underwear = random_underwear(H.gender)
	if(prob(50))
		H.underwear_color = organ_eyes.eye_color
	if(prob(50) || H.gender == FEMALE)
		H.undershirt = random_undershirt(H.gender)
	if(prob(25))
		H.socks = random_socks()
	H.update_body()
	H.update_hair()
	H.update_body_parts()

/datum/team/first_team/proc/rename_team(new_name)
	first_team_name = new_name
	name = "[first_team_name] Team"

/datum/team/first_team
	var/first_team_name
	var/core_objective = /datum/objective/first_team
	member_name = "First Team Operative"
	var/memorized_code
	var/list/team_discounts
	var/obj/item/nuclear_challenge/war_button

/datum/team/first_team/New()
	..()
	first_team_name = first_team_name()

/datum/team/first_team/proc/update_objectives()
	if(core_objective)
		var/datum/objective/O = new core_objective
		O.team = src
		objectives += O


/datum/team/first_team/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>[first_team_name] Operatives:</span>"

	var/text = "<br><span class='header'>The First Team were:</span>"
	text += printplayerlist(members)
	parts += text

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"




//////////////////////////////////////////////
//                                          //
//        FIRST TEAM SQUAD (MIDROUND)    //
//                                          //
//////////////////////////////////////////////

/datum/dynamic_ruleset/midround/from_ghosts/first_team
	name = "First Team Squad"
	antag_flag = ROLE_FIRST_TEAM
	antag_datum = /datum/antagonist/first_team
	required_candidates = 1
	weight = 5
	cost = 35
	requirements = list(90,90,90,80,60,40,30,20,10,10)
	var/list/operative_cap = list(2,2,3,3,4,5,5,5,5,5)
	var/datum/team/first_team/first_team_team
	flags = HIGHLANDER_RULESET

/datum/dynamic_ruleset/midround/from_ghosts/first_team/acceptable(population=0, threat=0)
	indice_pop = min(operative_cap.len, round(living_players.len/5)+1)
	required_candidates = max(5, operative_cap[indice_pop])
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/first_team/ready(forced = FALSE)
	if (required_candidates > (dead_players.len + list_observers.len))
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/first_team/finish_setup(mob/new_character, index)
	new_character.mind.special_role = "First Team"
	new_character.mind.assigned_role = "First Team"
	if (index == 1) // Our first guy is the leader
		var/datum/antagonist/first_team/sergeant/new_role = new
		first_team_team = new_role.first_team_team
		new_character.mind.add_antag_datum(new_role)
	else
		return ..()
