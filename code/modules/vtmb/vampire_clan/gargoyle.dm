/datum/vampire_clan/gargoyle
	name = CLAN_GARGOYLE
	desc = "The Gargoyles are a vampiric bloodline created by the Tremere as their servitors. Although technically not a Tremere bloodline, the bloodline is largely under their control. In the Final Nights, Gargoyle populations seem to be booming; this is largely because older, free Gargoyles are coming out of hiding to join the Camarilla, because more indentured Gargoyles break free from the clutches of the Tremere, and because the free Gargoyles have also begun to Embrace more mortals on their own."
	curse = "All Gargoyles, much like the Nosferatu, are hideous to look at, a byproduct of their occult origins (and the varied Kindred stock from which they originate). This means that Gargoyles, just like the Nosferatu, have to hide their existence from common mortals, as their mere appearance is a breach of the Masquerade. In addition, the nature of the bloodline's origin manifests itself in the fact that Gargoyles are highly susceptible to mind control of any source. This weakness is intentional; a flaw placed into all Gargoyles by the Tremere in the hope that it would make them easier to control (and less likely to rebel)."
	clan_disciplines = list(
		/datum/discipline/fortitude,
		/datum/discipline/potence,
		/datum/discipline/visceratika
	)
	clan_traits = list(
		TRAIT_CANNOT_RESIST_MIND_CONTROL,
		TRAIT_MASQUERADE_VIOLATING_FACE
	)
	alt_sprite = "gargoyle"
	no_facial = FALSE
	male_clothes = /obj/item/clothing/under/vampire/malkavian
	female_clothes = /obj/item/clothing/under/vampire/malkavian
	default_accessory = "gargoyle_full"
	accessories = list("gargoyle_full", "gargoyle_left", "gargoyle_right", "gargoyle_broken", "gargoyle_round", "gargoyle_devil", "gargoyle_oni", "none")
	accessories_layers = list("gargoyle_full" = UNICORN_LAYER, "gargoyle_left" = UNICORN_LAYER, "gargoyle_right" = UNICORN_LAYER, "gargoyle_broken" = UNICORN_LAYER, "gargoyle_round" = UNICORN_LAYER, "gargoyle_devil" = UNICORN_LAYER, "gargoyle_oni" = UNICORN_LAYER, "none" = UNICORN_LAYER)
	whitelisted = FALSE

/datum/vampire_clan/gargoyle/on_gain(mob/living/carbon/human/gargoyle)
	..()
	gargoyle.dna.species.wings_icon = "Gargoyle"
	gargoyle.physiology.brute_mod = 0.8
	gargoyle.dna.species.GiveSpeciesFlight(gargoyle)
