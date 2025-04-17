/datum/auspice
	var/name = "Loh"
	var/desc = "Furry ebaka"
	var/level = 1
	var/start_rage = 1
	var/rage = 1
	var/start_gnosis = 1
	var/gnosis = 1
	var/base_breed = "Homid"
	var/tribe = "Galestalkers"
	var/list/gifts = list()
	var/force_abomination = FALSE

	var/list/galestalkers = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/ghostcouncil = list(
		/datum/action/gift/shroud = 1,
		/datum/action/gift/coils_of_the_serpent = 2,
		/datum/action/gift/banish_totem = 3
	)

	var/list/hartwardens = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/glasswalker = list(
		/datum/action/gift/smooth_move = 1,
		/datum/action/gift/digital_feelings = 2,
		/datum/action/gift/elemental_improvement = 3
	)

	var/list/bonegnawer = list(
		/datum/action/gift/guise_of_the_hound = 1,
		/datum/action/gift/infest = 2,
		/datum/action/gift/gift_of_the_termite = 3
	)

	var/list/childrenofgaia = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/getoffenris = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/blackfuries = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/silentstriders = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/shadowlords = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/redtalons = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/silverfangs = list(
		/datum/action/gift/stoic_pose = 1,
		/datum/action/gift/freezing_wind = 2,
		/datum/action/gift/bloody_feast = 3
	)

	var/list/spiral = list(
		/datum/action/gift/stinky_fur = 1,
		/datum/action/gift/venom_claws = 2,
		/datum/action/gift/burning_scars = 3
	)

	var/list/ronin = list(
		/datum/action/gift/guise_of_the_hound = 1,
		/datum/action/gift/stoic_pose = 2,
		/datum/action/gift/smooth_move = 3,
		/datum/action/gift/shroud = 4
	)

/datum/auspice/proc/on_gain(var/mob/living/carbon/C)
	C.update_rage_hud()

	var/mob/living/carbon/werewolf/lupus/lupus = C.transformator.lupus_form?.resolve()
	var/mob/living/carbon/werewolf/crinos/crinos = C.transformator.crinos_form?.resolve()

	lupus?.auspice = src
	lupus?.dna = C.dna
	crinos?.auspice = src
	crinos?.dna = C.dna


	rage = start_rage
	if(length(gifts))
		for(var/i in gifts)
			var/datum/action/A1 = new i()
			A1.Grant(C)
			var/datum/action/A2 = new i()
			A2.Grant(lupus)
			var/datum/action/A3 = new i()
			A3.Grant(crinos)

	for(var/i in 1 to level)
		var/zalupa
		switch(tribe)
			if("Galestalkers")
				zalupa = galestalkers[i]
			if("Ghost Council")
				zalupa = ghostcouncil[i]
			if("Hart Wardens")
				zalupa = hartwardens[i]
			if("Glasswalkers")
				zalupa = glasswalker[i]
			if("Bone Gnawers")
				zalupa = bonegnawer[i]
			if("Children of Gaia")
				zalupa = childrenofgaia[i]
			if("Ronin")
				zalupa = ronin[i]
			if("Black Spiral Dancers")
				zalupa = spiral[i]
			if("Get of Fenris")
				zalupa = getoffenris[i]
			if("Black Furies")
				zalupa = blackfuries[i]
			if("Silver Fangs")
				zalupa = silverfangs[i]
			if("Silent Striders")
				zalupa = silentstriders[i]
			if("Shadow Lords")
				zalupa = shadowlords[i]
			if("Red Talons")
				zalupa = redtalons[i]
		var/datum/action/A = new zalupa()
		A.Grant(C)
		var/datum/action/A1 = new zalupa()
		A1.Grant(lupus)
		var/datum/action/A2 = new zalupa()
		A2.Grant(crinos)

/datum/auspice/ahroun
	name = "Ahroun"
	desc = "The Ahroun is the archetype of the werewolf as murderous beast, though they range from unapologetic berserkers to hardened veterans tempering their Rage with discipline. Their high levels of Rage put them on the edge at all times - the Full Moon's blessing is a hair trigger, among other things. Those closer to the waxing moon tend to exult in the glory of the war, while those closer to the waning moon are more viciously pragmatic, ruthless in their bloodthirst. Every Ahroun is a dangerous individual to be around, but when the forces of the Wyrm attack, their packmates are glad to have a Full Moon warrior at the front of the charge."
	start_rage = 5
	gifts = list(/datum/action/gift/falling_touch, /datum/action/gift/inspiration, /datum/action/gift/razor_claws)

/datum/auspice/galliard
	name = "Galliard"
	desc = "Where the Philodox is stoic, the Galliard is a creature of unbridled passion. The Gibbous Moon is a fiery muse, and stirs its children into great heights and depths of emotion. While all Galliards are prone to immense mirth and immense melancholy, those born under a waning moon fall more readily into dark, consuming passions; they are the tragedians of the Garou, mastering tales of doom, ruin, sacrifice and loss. Conversely, their waxing-moon cousins sing of triumph and conquest, of the pounding heart and the love of life. They tend to be the soul of their pack's morale - when the Galliard is willing to go on, so too are all the others."
	start_rage = 4
	gifts = list(/datum/action/gift/beast_speech, /datum/action/gift/call_of_the_wyld, /datum/action/gift/mindspeak)

/datum/auspice/philodox
	name = "Philodox"
	desc = "Buried so heavily in his role as impartial judge and jury, the Philodox may seem aloof, even surprisingly cold-blooded for a werewolf. Those born under the waxing Half Moon may seem unusually serene and disaffected, their emotions only emerging when their Rage comes to a boil. The waning-moon Philodox is more incisive and judgmental, his all-seeing eye always carefully watching his packmates and colleagues for any departure from the expected. The Half Moons' opinions are somewhat feared, yet highly respected - a word of praise or condemnation means much coming from those born to see both sides of every struggle."
	start_rage = 3
	gifts = list(/datum/action/gift/resist_pain, /datum/action/gift/scent_of_the_true_form, /datum/action/gift/truth_of_gaia)

/datum/auspice/theurge
	name = "Theurge"
	desc = "The Crescent Moons can be strange and enigmatic, prone to falling into the convoluted symbolic logic of the spirits they truck with rather than the more familiar logic of humanity. Those Theurges born under the waning moon frequently have a harsher, more adversarial relationship with the spirit world - they tend to excel at binding and forcing spirits to their will, and are more vicious when battling spirits. Theurges born under the waxing moon tend to be more generous and open with the spirits, charming and cajoling rather than intimidating and threatening."
	start_rage = 2
	gifts = list(/datum/action/gift/mothers_touch, /datum/action/gift/sense_wyrm, /datum/action/gift/spirit_speech)

/datum/auspice/ragabash
	name = "Ragabash"
	desc = "The Ragabash born under the waxing new moon is usually light-hearted and capricious, while one born under the waning new moon has a slightly more wicked and ruthless streak. It's a rare Ragabash indeed that lacks a keen wit and the capacity to find some humor in any situation, no matter how bleak. Many other werewolves are slow to take the Ragabash seriously, though, as it's difficult to tell the difference between a New Moon's mockery that points out a grievous flaw in a plan and similar mockery that simply amuses him. Sometimes a Ragabash points out that the emperor has no clothes - but sometimes they're the first to cry wolf, so to speak."
	start_rage = 1
	gifts = list(/datum/action/gift/blur_of_the_milky_eye, /datum/action/gift/open_seal, /datum/action/gift/infectious_laughter)
