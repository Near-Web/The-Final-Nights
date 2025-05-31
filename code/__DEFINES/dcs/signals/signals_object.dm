///from /obj/machinery/can_interact(mob/user): Called on user when attempting to interact with a machine (obj/machinery/machine)
#define COMSIG_TRY_USE_MACHINE "try_use_machine"
	/// Can't interact with the machine
	#define COMPONENT_CANT_USE_MACHINE_INTERACT (1<<0)
	/// Can't use tools on the machine
	#define COMPONENT_CANT_USE_MACHINE_TOOLS (1<<1)

///sent from clicking while you have no equipment selected. Sent before cooldown and adjacency checks, so you can use this for infinite range things if you want.
#define COMSIG_MECHA_MELEE_CLICK "mecha_action_melee_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_MELEE_CLICK (1<<0)
///sent from clicking while you have equipment selected.
#define COMSIG_MECHA_EQUIPMENT_CLICK "mecha_action_equipment_click"
	/// Prevents click from happening.
	#define COMPONENT_CANCEL_EQUIPMENT_CLICK (1<<0)
