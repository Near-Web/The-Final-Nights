/// from /mob/living/*/UnarmedAttack(), before sending [COMSIG_LIVING_UNARMED_ATTACK]: (mob/living/source, atom/target, proximity, modifiers)
/// The only reason this exists is so hulk can fire before Fists of the North Star.
/// Note that this is called before [/mob/living/proc/can_unarmed_attack] is called, so be wary of that.
#define COMSIG_LIVING_EARLY_UNARMED_ATTACK "human_pre_attack_hand"
/// from mob/living/*/UnarmedAttack(): (mob/living/source, atom/target, proximity, modifiers)
#define COMSIG_LIVING_UNARMED_ATTACK "living_unarmed_attack"
