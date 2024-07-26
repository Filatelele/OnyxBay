/obj/item/organ_module/active/simple
	var/obj/item/holding = null
	var/holding_type = null

/obj/item/organ_module/active/simple/Initialize()
	. = ..()
	if(holding_type)
		holding = new holding_type(src)
		holding.canremove = FALSE

/obj/item/organ_module/active/simple/Destroy()
	if(holding)
		unregister_signal(holding, SIGNAL_ITEM_UNEQUIPPED)
		QDEL_NULL(holding)

	return ..()

/obj/item/organ_module/active/simple/proc/deploy(obj/item/organ/O, mob/living/carbon/human/H)
	var/slot = null
	if(O.organ_tag in list(BP_L_ARM, BP_L_HAND))
		slot = slot_l_hand
	else if(O.organ_tag in list(BP_R_ARM, BP_R_HAND))
		slot = slot_r_hand
	if(!H.equip_to_slot_if_possible(holding, slot))
		return

	H.visible_message(
		SPAN_WARNING("[H] extend \his [holding.name] from [O]."),
		SPAN_NOTICE("You extend your [holding.name] from [O].")
	)
	register_signal(holding, SIGNAL_ITEM_UNEQUIPPED, nameof(.proc/on_holding_unequipped))

/obj/item/organ_module/active/simple/proc/retract(obj/item/organ/O, mob/living/carbon/human/H)
	if(holding.loc == src)
		return

	if(ismob(holding.loc))
		var/mob/M = holding.loc
		M.drop(holding, force = TRUE)
		M.visible_message(
			SPAN_WARNING("[M] retracts \his [holding.name] into [O]."),
			SPAN_NOTICE("You retract your [holding.name] into [O].")
		)
	holding.forceMove(src)
	unregister_signal(H, SIGNAL_ITEM_UNEQUIPPED)

/obj/item/organ_module/active/simple/proc/on_holding_unequipped(obj/item, mob/mob)
	retract(mob, loc)

/obj/item/organ_module/active/simple/activate(obj/item/organ/O, mob/living/carbon/human/H)
	if(!can_activate(O, H))
		return

	if(holding.loc == src)
		deploy(O, H)
	else
		retract(O, H)

/obj/item/organ_module/active/simple/deactivate(obj/item/organ/O, mob/living/carbon/human/H)
	retract(O, H)
	return ..()

/obj/item/organ_module/active/simple/organ_removed(obj/item/organ/O, mob/living/carbon/human/H)
	retract(O, H)
	return ..()
