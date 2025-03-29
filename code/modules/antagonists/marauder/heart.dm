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
