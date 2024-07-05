/**
 * This extension allows turfs to hold ores/minerals/materials, whatever you call em.
 */

/datum/component/mineable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Assoc list of available resources [resource] -> amt
	var/list/resources

/datum/component/connect_mob_behalf/Initialize()
	. = ..()
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
