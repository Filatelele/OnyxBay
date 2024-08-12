///Returns the jetpack associated with this atom.
// Being an atom proc allows it to be overridden by non mob types, like mechas
// The user proc optionally allows us to state who we're getting it for.
// This allows mechas to return a jetpack for the driver, but not the passengers
/atom/proc/get_jetpack(mob/user)
	return

/mob/living/carbon/human/get_jetpack(mob/user)
	if (!istype(loc, /turf)) //This generally means vehicles/mechs
		return loc?.get_jetpack(src)

	// Search the human for a jetpack. Either on back or on a RIG that's on
	// on their back.
	if(istype(back, /obj/item/tank/jetpack))
		return back
	else if(istype(s_store, /obj/item/tank/jetpack))
		return s_store
	else if(istype(back, /obj/item/rig))
		var/obj/item/rig/rig = back
		for(var/obj/item/rig_module/maneuvering_jets/module in rig.installed_modules)
			return module.jets

/mob/living/silicon/robot/get_jetpack(mob/user)
	return jetpack
