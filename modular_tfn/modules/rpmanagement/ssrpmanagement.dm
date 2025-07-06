// ================================
// RP Management Subsystem - ssrpmanagement.dm
// ================================
// Initializes RP-related systems:
// - Groups (Factions, Sects, Clans, Coteries)
// - Memories, Relationships (future support)
// Loads shared storyteller save data
// ================================

SUBSYSTEM_DEF(rpmanagement)
	name = "RP Management"
	init_order = INIT_ORDER_DEFAULT
	wait = 10

// All defined groups (clans, sects, etc.)
var/global/list/global_groups = list()

// Options
// var/global/list/global_relationship_templates = list()

/datum/controller/subsystem/rpmanagement/Initialize()
	load_all_groups()
	// Future: load predefined memories, relationships
	// load_all_relationship_templates()
	return ..()

// ---------------------------------------------
// Group Loading
// ---------------------------------------------

/proc/load_all_groups()
	var/path = "data/groups_storyteller_saves.json"
	if (!fexists(path))
		world.log << "[SSrpmanagement.name]: No group save file found at [path]. Starting fresh."
		return

	var/savefile/F = new(path)
	if (!F)
		world.log << "[SSrpmanagement.name]: Failed to open savefile at [path]."
		return

	var/version
	F["version"] >> version
	F["groups"] >> global_groups

	world.log << "[SSrpmanagement.name]: Loaded [length(global_groups)] groups from storyteller save."

// ================================
// Group Persistence Utilities
// ================================

/proc/SaveGlobalGroups()
	var/savefile/F = new("data/groups_storyteller_saves.json")
	if (!F) return

	F["version"] << 1
	F["groups"] << global_groups

/proc/LoadGlobalGroups()
	if (!fexists("data/groups_storyteller_saves.json")) return
	var/savefile/F = new("data/groups_storyteller_saves.json")
	if (!F) return

	var/list/L
	F["groups"] >> L
	if (islist(L))
		global_groups = L
