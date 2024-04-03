GLOBAL_LIST_EMPTY(all_synthetic_mind_to_data) // data: list of name and type of synthetic

/mob/living/silicon
	gender = NEUTER
	voice_name = "synthesized voice"
	var/playable_mob = TRUE
	var/syndicate = 0
	var/const/MAIN_CHANNEL = "Main Frequency"
	var/lawchannel = MAIN_CHANNEL // Default channel on which to state laws
	var/list/stating_laws = list()// Channels laws are currently being stated on
	var/obj/item/device/radio/silicon_radio

	var/list/hud_list[10]
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer

	//Used in say.dm.
	var/speak_statement = "states"
	var/speak_exclamation = "declares"
	var/speak_query = "queries"
	var/pose //Yes, now AIs can pose too.
	var/obj/item/device/camera/siliconcam/silicon_camera = null //photography
	var/local_transmit //If set, can only speak to others of the same type within a short range.

	var/sensor_mode = 0 //Determines the current HUD or Vision.

	var/next_alarm_notice
	var/list/datum/alarm/queued_alarms = new()
	var/list/access_rights
	var/obj/item/card/id/idcard = /obj/item/card/id/synthetic

	var/list/avaliable_huds
	var/active_hud

	/// List of subsystems to initialize when silicon is spawned.
	var/list/default_silicon_subsystems = list(
		/datum/nano_module/alarm_monitor/all,
		/datum/nano_module/law_manager,
		/datum/nano_module/records/ai
	)
	/// List of all created and managed subsystems.
	var/list/datum/nano_module/silicon_subsystems
	/// Asociative list typepath -> `datum/ui_state`, where typepath is subsystem's type.
	var/list/silicon_subsystems_states

	rad_resist = list(
		RADIATION_ALPHA_PARTICLE = 41.7 MEGA ELECTRONVOLT,
		RADIATION_BETA_PARTICLE = 23.9 MEGA ELECTRONVOLT,
		RADIATION_HAWKING = 1 ELECTRONVOLT
	)

/mob/living/silicon/New()
	if(playable_mob)
		GLOB.silicon_mob_list += src
	..()

	if(silicon_radio)
		silicon_radio = new silicon_radio(src)
	if(silicon_camera)
		silicon_camera = new silicon_camera(src)

	add_language(LANGUAGE_GALCOM)
	default_language = all_languages[LANGUAGE_GALCOM]
	init_id()
	init_subsystems()
	avaliable_huds = list("Disable", "Security", "Medical")		//("Security", "Medical", "Meson", "Science", "Night Vision", "Material", "Thermal", "X-Ray", "Flash Screen", "Disable")

	AddElement(/datum/element/last_words)

/mob/living/silicon/Destroy()
	GLOB.silicon_mob_list -= src

	QDEL_NULL(silicon_radio)
	QDEL_NULL(silicon_camera)

	for(var/datum/nano_module/subsystem in silicon_subsystems)
		remove_subsystem(subsystem.type)

	for(var/datum/alarm_handler/AH in SSalarm.all_handlers)
		AH.unregister_alarm(src)

	if(istype(idcard))
		QDEL_NULL(idcard)

	queued_alarms.Cut()
	silicon_subsystems_states.Cut() // Just in case...

	return ..()

/mob/living/silicon/mind_initialize()
	. = ..()
	GLOB.all_synthetic_mind_to_data[mind] = list(name, type, weakref(src))

/mob/living/silicon/SetName(new_name)
	. = ..()
	if(mind)
		GLOB.all_synthetic_mind_to_data[mind][1] = name

/mob/living/silicon/fully_replace_character_name(new_name)
	..()
	if(istype(idcard))
		idcard.registered_name = new_name
		idcard.update_name()

/mob/living/silicon/proc/init_id()
	if(ispath(idcard))
		idcard = new idcard(src)
		set_id_info(idcard)

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/can_unequip(obj/item/I)
	return FALSE // Let's just not

/mob/living/silicon/drop_active_hand(user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.hud_used.update_robot_modules_display()
	return

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			src.take_organ_damage(0,20,emp=1)
			Stun(rand(5,10))
		if(2)
			src.take_organ_damage(0,10,emp=1)
			confused = (min(confused + 2, 30))
	flash_eyes(affect_silicon = 1)
	to_chat(src, "<span class='danger'><B>*BZZZT*</B></span>")
	to_chat(src, "<span class='danger'>Warning: Electromagnetic pulse detected.</span>")
	..()

/mob/living/silicon/stun_effect_act(stun_amount, agony_amount, def_zone, used_weapon = null)
	return	//immune

/mob/living/silicon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0)

	if (istype(source, /obj/machinery/containment_field))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, loc)
		s.start()

		shock_damage *= 0.75	//take reduced damage
		take_overall_damage(0, shock_damage)
		visible_message("<span class='warning'>\The [src] was shocked by \the [source]!</span>", \
			"<span class='danger'>Energy pulse detected, system damaged!</span>", \
			"<span class='warning'>You hear an electrical crack</span>")
		if(prob(20))
			Stun(2)
		return

/mob/living/silicon/proc/damage_mob(brute = 0, fire = 0, tox = 0)
	return

/mob/living/silicon/IsAdvancedToolUser()
	return 1

/mob/living/silicon/bullet_act(obj/item/projectile/Proj)

	if(!Proj.nodamage)
		switch(Proj.damage_type)
			if(BRUTE)
				adjustBruteLoss(Proj.damage)
			if(BURN)
				adjustFireLoss(Proj.damage)

	Proj.on_hit(src,100) //wow this is a terrible hack
	updatehealth()
	return 100

/mob/living/silicon/apply_effect(effect = 0,effecttype = STUN, blocked = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if (bot.connected_ai == ai)
		return 1
	return 0


// this function shows the health of the AI in the Status panel
/mob/living/silicon/proc/show_system_integrity()
	. = list()

	if(!src.stat)
		. += "System integrity: [round((health/maxHealth)*100)]%"
	else
		. += "Systems nonfunctional"


// This is a pure virtual function, it should be overwritten by all subclasses
/mob/living/silicon/proc/show_malf_ai(list/stats)
	return list()


// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/get_status_tab_items()
	. = ..()

	. += show_system_integrity()
	. += show_malf_ai()


// this function displays the stations manifest in a separate window
/mob/living/silicon/proc/show_station_manifest()
	var/dat = "<meta charset=\"utf-8\">"
	dat += "<h4>Crew Manifest</h4>"
	dat += html_crew_manifest(1) // make it monochrome
	dat += "<br>"
	show_browser(src, dat, "window=airoster")
	onclose(src, "airoster")

//can't inject synths
/mob/living/silicon/can_inject(mob/user, target_zone)
	to_chat(user, "<span class='warning'>The armoured plating is too tough.</span>")
	return 0


//Silicon mob language procs

/mob/living/silicon/can_speak(datum/language/speaking)
	return universal_speak || (speaking in src.speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(language, can_speak=1)
	var/datum/language/added_language = all_languages[language]
	if(!added_language)
		return

	. = ..(language)
	if (can_speak && (added_language in languages) && !(added_language in speech_synthesizer_langs))
		speech_synthesizer_langs += added_language
		return 1

/mob/living/silicon/remove_language(rem_language)
	var/datum/language/removed_language = all_languages[rem_language]
	if(!removed_language)
		return

	..(rem_language)
	speech_synthesizer_langs -= removed_language

/mob/living/silicon/proc/toggle_sensor_mode()
	active_hud = null
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in avaliable_huds
	switch(sensor_type)
		if ("Security")
			sensor_mode = SEC_VISION
			active_hud = HUD_SECURITY
			to_chat(src, "<span class='notice'>Security records overlay enabled.</span>")
		if ("Medical")
			sensor_mode = MED_VISION
			active_hud = HUD_MEDICAL
			to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
		if ("Meson")
			sensor_mode = MESON_VISION
			to_chat(src, "<span class='notice'>Meson vision overlay enabled.</span>")
		if ("Science")
			sensor_mode = SCIENCE_VISION
			active_hud = HUD_SCIENCE
			to_chat(src, "<span class='notice'>Science vision overlay enabled.</span>")
		if ("Night Vision")
			sensor_mode = NVG_VISION
			to_chat(src, "<span class='notice'>Night vision overlay enabled.</span>")
		if ("Material")
			sensor_mode = MATERIAL_VISION
			to_chat(src, "<span class='notice'>Material vision overlay enabled.</span>")
		if ("Thermal")
			sensor_mode = THERMAL_VISION
			to_chat(src, "<span class='notice'>Thermal vision overlay enabled.</span>")
		if ("X-Ray")
			sensor_mode = XRAY_VISION
			to_chat(src, "<span class='notice'>X-Ray vision overlay enabled.</span>")
		if ("Flash Screen")
			sensor_mode = FLASH_PROTECTION_VISION
		if ("Disable")
			sensor_mode = 0
			to_chat(src, "Sensor augmentations disabled.")

/mob/living/silicon/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(input(usr, "This is [src]. It is...", "Pose", null)  as text)

/mob/living/silicon/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", null)  as text)

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/ex_act(severity)
	if(!blinded)
		flash_eyes()

	var/brute
	var/burn
	switch(severity)
		if(1.0)
			brute = 400
			burn = 100
			if(!anchored && !prob(get_flat_armor(null, "bomb")))
				gib()
		if(2.0)
			brute = 60
			burn = 60
		if(3.0)
			brute = 30

	var/protection = blocked_mult(get_flat_armor(null, "bomb"))
	brute *= protection
	burn *= protection

	adjustBruteLoss(brute)
	adjustFireLoss(burn)

	updatehealth()

/mob/living/silicon/blob_act(damage)
	if(is_ic_dead())
		return

	var/protection = blocked_mult(get_flat_armor(null, "bomb"))
	var/brute = damage * 2

	brute *= protection
	adjustBruteLoss(brute)

	updatehealth()

/mob/living/silicon/proc/receive_alarm(datum/alarm_handler/alarm_handler, datum/alarm/alarm, was_raised)
	if(!next_alarm_notice)
		next_alarm_notice = world.time + SecondsToTicks(10)

	var/list/alarms = queued_alarms[alarm_handler]
	if(was_raised)
		// Raised alarms are always set
		alarms[alarm] = 1
	else
		// Alarms that were raised but then cleared before the next notice are instead removed
		if(alarm in alarms)
			alarms -= alarm
		// And alarms that have only been cleared thus far are set as such
		else
			alarms[alarm] = -1

/mob/living/silicon/proc/process_queued_alarms()
	if(next_alarm_notice && (world.time > next_alarm_notice))
		next_alarm_notice = 0

		var/text = ""
		var/alarm_raised = 0
		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			var/reported = 0
			for(var/datum/alarm/A in alarms)
				if(alarms[A] == 1)
					alarm_raised = 1
					if(!reported)
						reported = 1
						text += SPAN("warning", "--- [AH.category] Detected ---\n")
					text += raised_alarm(A)

		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			var/reported = 0
			for(var/datum/alarm/A in alarms)
				if(alarms[A] == -1)
					if(!reported)
						reported = 1
						text += SPAN("notice", "--- [AH.category] Cleared ---\n")
					text += "\The [A.alarm_name()].\n"

		if(alarm_raised)
			text += "<A HREF=?src=\ref[src];showalerts=1>\[Show Alerts\]</A>"

		if(text)
			to_chat(src, text)

		for(var/datum/alarm_handler/AH in queued_alarms)
			var/list/alarms = queued_alarms[AH]
			alarms.Cut()

/mob/living/silicon/proc/raised_alarm(datum/alarm/A)
	return "[A.alarm_name()]!\n"

/mob/living/silicon/ai/raised_alarm(datum/alarm/A)
	var/cameratext = ""
	for(var/obj/machinery/camera/C in A.cameras())
		cameratext += "[(cameratext == "")? "" : "|"]<A HREF=?src=\ref[src];switchcamera=\ref[C]>[C.c_tag]</A>"
	return "[A.alarm_name()]! ([(cameratext)? cameratext : "No Camera"])\n"


/mob/living/silicon/proc/is_traitor()
	return mind && (mind in GLOB.traitors.current_antagonists)

/mob/living/silicon/proc/is_malf()
	return mind && (mind in GLOB.malf.current_antagonists)

/mob/living/silicon/proc/is_malf_or_traitor()
	return is_traitor() || is_malf()

/mob/living/silicon/adjustEarDamage()
	return

/mob/living/silicon/setEarDamage()
	return

/mob/living/silicon/reset_view()
	..()
	if(cameraFollow)
		cameraFollow = null

/mob/living/silicon/proc/clear_client()
	//Handle job slot/tater cleanup.
	var/job = mind.assigned_role

	job_master.FreeRole(job)

	if(mind.objectives.len)
		qdel(mind.objectives)
		mind.special_role = null

	clear_antag_roles(mind)

	ghostize(0)
	qdel(src)

/mob/living/silicon/flash_eyes(intensity = FLASH_PROTECTION_MODERATE, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE, type = /atom/movable/screen/fullscreen/flash)
	if(affect_silicon)
		return ..()

/mob/living/silicon/proc/update_protocols(decl/security_level/alert) //procs when alert level is changed
	if (istype(src,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = src
		switch (alert.name)
			if ("code green")
				if (R.module)
					if (istype(R.module,/obj/item/robot_module/security/general) && !R.emagged)
						var/obj/item/gun/energy/laser/mounted/cyborg/LC = locate(/obj/item/gun/energy/laser/mounted/cyborg) in R.module.modules
						LC.locked = 1
						to_chat(src, "<span class='notice'>Security protocols has been changed: Safety locks in place.</span>")
			if ("code red")
				if (R.module)
					if (istype(R.module,/obj/item/robot_module/security/general))
						var/obj/item/gun/energy/laser/mounted/cyborg/LC = locate(/obj/item/gun/energy/laser/mounted/cyborg) in R.module.modules
						LC.locked = 0
						to_chat(src, "<span class='warning'>Security protocols has been changed: Safety locks is now lifted.</span>")
