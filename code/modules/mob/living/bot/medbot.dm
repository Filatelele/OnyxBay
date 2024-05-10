/mob/living/bot/medbot
	name = "Medbot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon_state = "medibot0"
	req_one_access = list(access_medical, access_robotics)
	botcard_access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology)

	var/skin = null // Set to "tox", "fire", "o2", "adv" or "bezerk" for different firstaid styles.

	//AI vars
	var/vocal = TRUE

	//Healing vars
	var/obj/item/reagent_containers/vessel/reagent_glass = null // Can be set to draw from this for reagents.
	var/injection_amount = 15 // How much reagent do we inject at a time?
	var/heal_threshold = 10 // Start healing when they have this much damage in a category
	var/use_beaker = FALSE // Use reagents in beaker instead of default treatment agents.
	var/treatment_brute = /datum/reagent/tricordrazine
	var/treatment_oxy = /datum/reagent/dexalin
	var/treatment_fire = /datum/reagent/tricordrazine
	var/treatment_tox = /datum/reagent/dylovene
	var/treatment_virus = /datum/reagent/spaceacillin
	var/treatment_emag = /datum/reagent/toxin
	var/declare_treatment = 0 // When attempting to treat a patient, should it notify everyone wearing medhuds?
	var/should_treat_brute = TRUE
	var/should_treat_oxy = TRUE
	var/should_treat_fire = TRUE
	var/should_treat_tox = TRUE

/mob/living/bot/medbot/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/station_bot/medbot)

/mob/living/bot/medbot/UnarmedAttack(mob/living/carbon/human/H, proximity)
	if(!..())
		return

	if(!on)
		return

	if(!istype(H))
		return

	if(busy)
		return

	// TODO: Fix bot ai so this check can actually be done somewhen
	if(H.is_ic_dead())
		var/list/death_messagevoice = list("No! NO!" = 'sound/voice/medbot/no.ogg', "Live, damnit! LIVE!" = 'sound/voice/medbot/live.ogg', "I... I've never lost a patient before. Not today, I mean." = 'sound/voice/medbot/lost.ogg')
		var/death_message = pick(death_messagevoice)
		say(death_message)
		playsound(src, death_messagevoice[death_message], 75, FALSE)
		return

	icon_state = "medibots"
	visible_message("<span class='warning'>[src] is trying to inject [H]!</span>")
	if(declare_treatment)
		var/area/location = get_area(src)
		broadcast_medical_hud_message("[src] is treating <b>[H]</b> in <b>[location]</b>", src)
	busy = TRUE
	update_icons()
	if(!do_mob(src, H, 30))
		return

	if(QDELETED(H))
		return

	if(reagent_glass && use_beaker && (
		(should_treat_brute && (H.getBruteLoss() >= heal_threshold)) || \
		(should_treat_fire && (H.getFireLoss() >= heal_threshold)) || \
		(should_treat_tox && (H.getToxLoss() >= heal_threshold)) || \
		(should_treat_oxy && (H.getOxyLoss() >= (heal_threshold + 15)))
	))

		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(!H.reagents.has_reagent(R))
				return reagent_glass.reagents.trans_to_mob(H, injection_amount, CHEM_BLOOD)
	else if(should_treat_brute && (H.getBruteLoss() >= heal_threshold) && (!H.reagents.has_reagent(treatment_brute)))
		H.reagents.add_reagent(treatment_brute, injection_amount)

	else if(should_treat_oxy && (H.getOxyLoss() >= (15 + heal_threshold)) && (!H.reagents.has_reagent(treatment_oxy)))
		H.reagents.add_reagent(treatment_oxy, injection_amount)

	else if(should_treat_fire && (H.getFireLoss() >= heal_threshold) && (!H.reagents.has_reagent(treatment_fire)))
		H.reagents.add_reagent(treatment_fire, injection_amount)

	else if(should_treat_tox && (H.getToxLoss() >= heal_threshold) && (!H.reagents.has_reagent(treatment_tox)))
		H.reagents.add_reagent(treatment_tox, injection_amount)

	visible_message("<span class='warning'>[src] injects [H] with the syringe!</span>")
	busy = FALSE
	update_icons()
	var/list/messagevoice = list("All patched up!" = 'sound/voice/medbot/patchedup.ogg', "An apple a day keeps me away." = 'sound/voice/medbot/apple.ogg', "Feel better soon!" = 'sound/voice/medbot/feelbetter.ogg')
	var/message = pick(messagevoice)
	say(message)
	playsound(src, messagevoice[message], 75, FALSE)

/obj/item/firstaid_arm_assembly
	name = "first aid/robot arm assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "firstaid_arm"
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	w_class = ITEM_SIZE_NORMAL

/obj/item/firstaid_arm_assembly/Initialize()
	. = ..()
	if(skin)
		AddOverlays(image('icons/obj/aibots.dmi', "kit_skin_[skin]"))

/obj/item/firstaid_arm_assembly/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/pen))
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return

		if(!in_range(src, usr) && loc != usr)
			return

		created_name = t
	else
		switch(build_step)
			if(0)
				if(istype(W, /obj/item/device/healthanalyzer))
					if(!user.drop(W))
						return

					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the health sensor to [src].</span>")
					SetName("First aid/robot arm/health analyzer assembly")
					AddOverlays(image('icons/obj/aibots.dmi', "na_scanner"))

			if(1)
				if(isprox(W))
					if(!user.drop(W))
						return

					qdel(W)
					to_chat(user, "<span class='notice'>You complete the Medibot! Beep boop.</span>")
					var/turf/T = get_turf(src)
					var/mob/living/bot/medbot/S = new /mob/living/bot/medbot(T)
					S.skin = skin
					S.SetName(created_name)
					S.update_icons() // apply the skin
					user.drop(src)
					qdel(src)
