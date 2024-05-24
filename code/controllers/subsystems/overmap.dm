//The NSV13 Version of Game Mode, except it for the overmap and runs parallel to Game Mode

#define STATUS_INPROGRESS 0
#define STATUS_COMPLETED 1
#define STATUS_FAILED 2
#define STATUS_OVERRIDE 3

#define REMINDER_OBJECTIVES 0
#define REMINDER_COMBAT_RESET 1
#define REMINDER_COMBAT_DELAY 2
#define REMINDER_OVERRIDE 3

SUBSYSTEM_DEF(overmap_mode)
	name = "overmap_mode"
	wait = 1 SECOND
	priority = SS_PRIORITY_OVERMAP
	init_order = SS_INIT_OVERMAP

	/// Admin ability to tweak current mission difficulty level
	var/escalation = 0
	/// Threat generated or reduced via various activities, directly buffing enemy fleet sizes and possibly other things if implemented.
	var/threat_elevation = 0
	/// What was the highest amount of objectives completed? If it increases, reduce threat.
	var/highest_objective_completion = 0
	/// Number of players connected when the check is made for gamemode
	var/player_check = 0
	/// The assigned mode
	var/datum/overmap_gamemode/mode
	/// Admin forced gamemode prior to initialization
	var/datum/overmap_gamemode/forced_mode = null

	/// Are we currently using the reminder system?
	var/objective_reminder_override = FALSE
	/// Last time the crew interacted with one of our objectives
	var/last_objective_interaction = 0
	/// Next time we automatically remind the crew to proceed with objectives
	var/next_objective_reminder = 0
	/// How many times has the crew been automatically reminded of objectives without any progress
	var/objective_reminder_stacks = 0
	/// Do we only reset the reminder when we complete an objective?
	var/objective_resets_reminder = FALSE
	/// Does combat in the overmap reset the reminder?
	var/combat_resets_reminder = FALSE
	/// Does combat in the overmap delay the reminder?
	var/combat_delays_reminder = FALSE
	/// How much the reminder is delayed by combat
	var/combat_delay_amount = 0

	/// How long do we wait?
	var/announce_delay = 3 MINUTES
	/// Have we announced the objectives yet?
	var/announced_objectives = FALSE
	/// Has the round already been extended already?
	var/round_extended = FALSE
	/// Stops the mission ending
	var/admin_override = FALSE
	/// Did they finish all the objectives that are available to them?
	var/objectives_completed = FALSE
	/// Is the round already in an ending state, i.e. we return jumped
	var/already_ended = FALSE
	var/mode_initialised = FALSE

	/// Used by admins to force disable player boarders
	var/override_ghost_boarders = FALSE
	/// Used by admins to force disable player ghost ships
	var/override_ghost_ships = FALSE
	var/check_completion_timer = 0

	var/list/mode_cache

	var/list/modes
	var/list/mode_names

/**
 * Retreives the list of overmap gammeods, checks map for black- and white- lists.
 * Filters overmap gammodes based on player number.
 * Loads and sets objectvies. Initializes starting systems for the player ship.
 */


/datum/controller/subsystem/overmap_mode/Initialize(start_timeofday)
	mode_cache = subtypesof(/datum/overmap_gamemode)
	for(var/M in mode_cache)
		var/datum/overmap_gamemode/GM = M
		if(initial(GM.whitelist_only)) // Remove all of our only whitelisted modes
			mode_cache -= M

	if(length(config.overmap.blacklisted_gammemodes))
		if(locate("all") in config.overmap.blacklisted_gammemodes)
			mode_cache.Cut()
		else
			for(var/S in config.overmap.blacklisted_gammemodes) //Grab the string to be the path - is there a proc for this?
				var/B = text2path("/datum/overmap_gamemode/[S]")
				mode_cache -= B

	for(var/mob/new_player/P in GLOB.player_list) //Count the number of connected players
		if(P.client)
			player_check ++

	for(var/M in mode_cache) // Remove any gamemodes that do not satisfy player criteria
		var/datum/overmap_gamemode/GM = M
		var/required_players = initial(GM.required_players)

		var/max_players = initial(GM.max_players)

		if(player_check < required_players)
			mode_cache -= M

		else if((max_players > 0) && (player_check > max_players))
			mode_cache -= M

	if(length(mode_cache))
		var/list/mode_select = list()
		if(forced_mode)
			mode = new forced_mode
		else
			for(var/M in mode_cache)
				var/datum/overmap_gamemode/GM = M
				var/selection_weight = initial(GM.selection_weight)

				for(var/I = 0, I < selection_weight, I++) // Populate with weight number of instances
					mode_select += M

			if(length(mode_select))
				var/mode_type = pick(mode_select)
				mode = new mode_type

	//if(mode)
	//	message_admins("[mode.name] has been selected as the overmap gamemode")
	//	log_game("[mode.name] has been selected as the overmap gamemode")
	//else
	//	mode = new /datum/overmap_gamemode/patrol() //Holding that as the default for now - REPLACE ME LATER
	//	message_admins("Error: mode section pool empty - defaulting to PATROL")
	//	log_game("Error: mode section pool empty - defaulting to PATROL")

	return ..()

/datum/controller/subsystem/overmap_mode/proc/setup_overmap_mode()
	mode_initialised = TRUE

	var/obj/structure/overmap/MO = SSstar_system.find_main_overmap()
	if(MO)
		var/datum/star_system/target = SSstar_system.system_by_id(mode.starting_system)
		var/datum/star_system/curr = MO.current_system
		curr?.remove_ship(MO)
		MO.jump_end(target) //Move the ship to the designated start

	var/obj/structure/overmap/MM = SSstar_system.find_main_miner() //ditto for the mining ship until delete
	if(MM)
		var/datum/star_system/target = SSstar_system.system_by_id(mode.starting_system)
		var/datum/star_system/curr = MM.current_system
		curr?.remove_ship(MM)
		MM.jump_end(target)

/datum/controller/subsystem/overmap_mode/proc/instance_objectives()
	for( var/I = 1, I <= length( mode.objectives ), I++ )
		var/datum/overmap_objective/O = mode.objectives[ I ]
		if(O.instanced == FALSE)
			O.objective_number = I
			O.instance() //Setup any overmap assets

/datum/controller/subsystem/overmap_mode/proc/modify_threat_elevation(value)
	if(!value)
		return
	threat_elevation = max(threat_elevation + value, 0)	//threat never goes below 0

/datum/controller/subsystem/overmap_mode/fire()
	if(GAME_STATE >= RUNLEVEL_GAME) // Wait for the game to begin
		if(world.time >= check_completion_timer) // Fire this automatically every ten minutes to prevent round stalling
			if(world.time > TE_INITIAL_DELAY)
				modify_threat_elevation(TE_THREAT_PER_HOUR / 6)	// Accurate enough... although update this if the completion timer interval gets changed :)

			difficulty_calc() // Also do our difficulty check here
			mode.check_completion()
			check_completion_timer += 10 MINUTES

		if(!objective_reminder_override)
			if(world.time >= next_objective_reminder)
				mode.check_completion()
				if(objectives_completed || already_ended)
					return

				objective_reminder_stacks ++
				next_objective_reminder = world.time + mode.objective_reminder_interval
				if(!round_extended) //Normal Loop
					switch(objective_reminder_stacks)
						if(1) //something

							SSannounce.play_station_announce(/datum/announce/command_report, "[mode.reminder_one]", "[mode.reminder_origin]", null, null, TRUE, TRUE)
							mode.consequence_one()
						if(2) //something else
							SSannounce.play_station_announce(/datum/announce/command_report, "[mode.reminder_two]", "[mode.reminder_origin]", null, null, TRUE, TRUE)
							mode.consequence_two()
						if(3) //something else +
							SSannounce.play_station_announce(/datum/announce/command_report, "[mode.reminder_three]", "[mode.reminder_origin]", null, null, TRUE, TRUE)
							mode.consequence_three()
						if(4) //last chance
							SSannounce.play_station_announce(/datum/announce/command_report, "[mode.reminder_four]", "[mode.reminder_origin]", null, null, TRUE, TRUE)
							mode.consequence_four()
						if(5) //mission critical failure
							SSannounce.play_station_announce(/datum/announce/command_report, "[mode.reminder_five]", "[mode.reminder_origin]", null, null, TRUE, TRUE)
							mode.consequence_five()
						else // I don't know what happened but let's go around again
							objective_reminder_stacks = 0
				else
					var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
					var/datum/star_system/S = SSstar_system.return_system
					if(length(OM.current_system?.enemies_in_system))
						if(objective_reminder_stacks == 3)
							SSannounce.play_station_announce(/datum/announce/command_report, "Auto-recall to [S.name] will occur once you are out of combat.", "[mode.reminder_origin]", null, null, TRUE, TRUE)
						return // Don't send them home while there are enemies to kill
					switch(objective_reminder_stacks) //Less Stacks Here, Prevent The Post-Round Stalling
						if(1)
							SSannounce.play_station_announce(/datum/announce/command_report, "Auto-recall to [S.name] will occur in [(mode.objective_reminder_interval * 2) / 600] Minutes.", "[mode.reminder_origin]", null, null, TRUE, TRUE)

						if(2)
							SSannounce.play_station_announce(/datum/announce/command_report, "Auto-recall to [S.name] will occur in [(mode.objective_reminder_interval * 1) / 600] Minutes.", "[mode.reminder_origin]", null, null, TRUE, TRUE)

						else
							SSannounce.play_station_announce(/datum/announce/command_report, "Auto-recall to [S.name] activated, additional objective aborted.", "[mode.reminder_origin]", null, null, TRUE, TRUE)
							mode.victory()

/datum/controller/subsystem/overmap_mode/proc/start_reminder()
	next_objective_reminder = world.time + mode.objective_reminder_interval
	//addtimer(CALLBACK(src, PROC_REF(announce_objectives)), announce_delay)

/datum/controller/subsystem/overmap_mode/proc/announce_objectives()
	/**
	* Replace with a SMEAC brief?
	* - Situation
	* - Mission
	* - Execution
	* - Administration
	* - Communication
	*/

	var/text = "<b>[station_name()]</b>, <br>You have been assigned the following mission by NT Naval Command and are expected to complete it with all due haste. Please ensure your crew is properly informed of your objectives and delegate tasks accordingly."
	var/static/title = ""
	if(!announced_objectives)
		title += "Mission Briefing: [game_id]"
	else //Add an extension if this isn't roundstart
		title += "-Ext."

	text = "[text] <br><br> [mode.brief] <br><br> Objectives:"

	for(var/datum/overmap_objective/O in mode.objectives)
		text = "[text] <br> - [O.brief]"

		if(!SSovermap_mode.announced_objectives)  // Prevents duplicate report spam when assigning additional objectives
			O.print_objective_report()

	SSannounce.play_station_announce(/datum/announce/command_report, text, title, null, null, TRUE, TRUE)
	announced_objectives = TRUE

/datum/controller/subsystem/overmap_mode/proc/update_reminder(objective = FALSE)
	if(objective && objective_resets_reminder) //Is objective? Full Reset
		last_objective_interaction = world.time
		objective_reminder_stacks = 0
		next_objective_reminder = world.time + mode.objective_reminder_interval
		return

	if(combat_resets_reminder) //Set for full reset on combat
		objective_reminder_stacks = 0
		next_objective_reminder = world.time + mode.objective_reminder_interval
		return

	if(combat_delays_reminder) //Set for time extension on combat
		next_objective_reminder += combat_delay_amount
		return

/datum/controller/subsystem/overmap_mode/proc/request_additional_objectives()
	for(var/datum/overmap_objective/O in mode.objectives)
		O.ignore_check = TRUE

	instance_objectives()

	announce_objectives() //Let them all know

	//Reset the reminder system & impose a hard timelimit
	combat_resets_reminder = FALSE
	combat_delays_reminder = FALSE
	mode.objective_reminder_interval = 10 MINUTES
	objective_reminder_stacks = 0
	next_objective_reminder = world.time + mode.objective_reminder_interval

/datum/controller/subsystem/overmap_mode/proc/difficulty_calc()
	var/players = length(GLOB.living_mob_list_)
	mode.difficulty = Clamp((CEILING(players / 10, 1)), 1, 5)
	mode.difficulty += escalation //Our admin adjustment
	if(mode.difficulty <= 0)
		mode.difficulty = 1

/datum/overmap_objective
	/// Name for admins
	var/name
	/// Short description for admins
	var/desc
	/// Description for players
	var/brief
	/// For multi step objectives
	var/stage
	/// Is this just a simple T/F objective?
	var/binary = TRUE
	/// How many of the objective goal has been completed
	var/tally = 0
	/// How many of the objective goal is required
	var/target = 0
	/// 0 = In-progress, 1 = Completed, 2 = Failed, 3 = Victory Override (this will end the round)
	var/status = STATUS_INPROGRESS
	/// Is this objective available to be a random extended round objective?
	var/extension_supported = FALSE
	/// Used for checking extended rounds
	var/ignore_check = FALSE
	/// Have we yet run the instance proc for this objective?
	var/instanced = FALSE
	/// The objective's index in the list. Useful for creating arbitrary report titles
	var/objective_number = 0
	/// Minimum number of players to get this if it's a random/extended objective
	var/required_players = 0
	/// Maximum number of players to get this if it's a random/extended objective. 0 is unlimited.
	var/maximum_players = 0

/datum/overmap_objective/New()

/datum/overmap_objective/proc/instance() //Used to generate any in world assets
	if(SSovermap_mode.announced_objectives)
		// If this objective was manually added by admins after announce, prints a new report. Otherwise waits for the gamemode to be announced before instancing reports
		print_objective_report()

	instanced = TRUE

/datum/overmap_objective/proc/check_completion()

/datum/overmap_objective/proc/print_objective_report()

/datum/overmap_objective/custom
	name = "Custom"

/datum/overmap_objective/custom/New(passed_input) //Receive the string and make it brief/desc
	.=..()
	desc = passed_input
	brief = passed_input

//////ADMIN TOOLS//////

/// Admin Verb for the Overmap Gamemode controller
/client/proc/overmap_mode_controller()
	set name = "Overmap Gamemode Controller"
	set desc = "Manage the Overmap Gamemode"
	set category = "Adminbus"
	var/datum/overmap_mode_controller/omc = new(usr)
	omc.tgui_interact(usr)

/datum/overmap_mode_controller
	var/name = "Overmap Gamemode Controller"
	var/client/holder = null

/datum/overmap_mode_controller/New(H)
	if(istype(H, /client))
		var/client/C = H
		holder = C
	else
		var/mob/M = H
		holder = M.client
	.=..()

/datum/overmap_mode_controller/tgui_state(mob/user)
	return GLOB.admin_state

/datum/overmap_mode_controller/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapGamemodeController")
		ui.open()
		ui.set_autoupdate(TRUE) // Countdowns

/datum/overmap_mode_controller/tgui_act(action, params)
	. = ..()
	if(.)
		return

	var/adjust = text2num(params["adjust"])
	if(action == "current_escalation")
		if(isnum(adjust))
			SSovermap_mode.escalation = adjust
			if(SSovermap_mode.escalation > 5)
				SSovermap_mode.escalation = 5
			if(SSovermap_mode.escalation < -5)
				SSovermap_mode.escalation = -5
			SSovermap_mode.difficulty_calc()

	switch(action)
		if("adjust_threat")
			var/amount = input("Enter amount of threat to add (or substract if negative)", "Adjust Threat") as num|null
			SSovermap_mode.modify_threat_elevation(amount)
		if("change_gamemode")
			if(SSovermap_mode.mode_initialised)
				message_admins("Post Initilisation Overmap Gamemode Changes Not Currently Supported") //SoonTM
				return

			var/list/gamemode_pool = subtypesof(/datum/overmap_gamemode)
			var/datum/overmap_gamemode/S = input(usr, "Select Overmap Gamemode", "Change Overmap Gamemode") as null|anything in gamemode_pool
			if(isnull(S))
				return

			if(SSovermap_mode.mode_initialised)
				qdel(SSovermap_mode.mode)
				SSovermap_mode.mode = new S()
				message_admins("[key_name_admin(usr)] has changed the overmap gamemode to [SSovermap_mode.mode.name]")
			else
				SSovermap_mode.forced_mode = S
				message_admins("[key_name_admin(usr)] has changed the overmap gamemode to [initial(S.name)]")
			return

		if("add_objective")
			var/list/objectives_pool = (subtypesof(/datum/overmap_objective) - /datum/overmap_objective/custom)
			var/datum/overmap_objective/S = input(usr, "Select objective to add", "Add Objective") as null|anything in objectives_pool
			if(isnull(S))
				return

			var/extra
			if(ispath(S, /datum/overmap_objective/clear_system))
				extra = input(usr, "Select a target system", "Select System") as null|anything in SSstar_system.systems
			SSovermap_mode.mode.objectives += new S(extra)
			SSovermap_mode.instance_objectives()
			return

		if("add_custom_objective")
			var/custom_desc = input("Input Objective Briefing", "Custom Objective") as text|null
			SSovermap_mode.mode.objectives += new /datum/overmap_objective/custom(custom_desc)
			return

		if("view_vars")
			usr.client.debug_variables(locate(params["target"]))
			return

		if("remove_objective")
			var/datum/overmap_objective/O = locate(params["target"])
			SSovermap_mode.mode.objectives -= O
			qdel(O)
			return

		if("change_objective_state")
			var/list/o_state = list("In-Progress",
									"Completed",
									"Failed",
									"Victory Override")
			var/new_state = input("Select state to set", "Change Objective State") as null|anything in o_state
			if(new_state == "In-Progress")
				new_state = STATUS_INPROGRESS
			else if(new_state == "Completed")
				new_state = STATUS_COMPLETED
			else if(new_state == "Failed")
				new_state = STATUS_FAILED
			else if(new_state == "Victory Override")
				new_state = STATUS_OVERRIDE
			var/datum/overmap_objective/O = locate(params["target"])
			O.status = new_state
			return

		if("toggle_reminder")
			SSovermap_mode.objective_reminder_override = !SSovermap_mode.objective_reminder_override
			return

		if("extend_reminder")
			var/amount = input("Enter amount to extend by in minutes:", "Extend Reminder") as num|null
			SSovermap_mode.next_objective_reminder += amount MINUTES
			return

		if("reset_stage")
			SSovermap_mode.objective_reminder_stacks = 0
			return

		if("override_completion")
			SSovermap_mode.admin_override = !SSovermap_mode.admin_override
			return

		if("spawn_ghost_ship")
			set waitfor = FALSE

			//Choose spawn location logic
			var/target_location
			switch(alert(usr, "Spawn at a random spot in the current mainship Z level or your location?", "Select Spawn Location", "Ship Z", "Current Loc", "Cancel"))
				if("Cancel")
					return

				if("Ship Z")
					var/obj/structure/overmap/MS = SSstar_system.find_main_overmap()
					target_location = locate(rand(round(world.maxx/2) + 10, world.maxx - 39), rand(40, world.maxy - 39), MS.z)
				if("Current Loc")
					target_location = usr.loc

			//Choose ship spawn
			var/list/ship_list = list()
			ship_list += typesof(/obj/structure/overmap/nanotrasen/ai)
			ship_list += typesof(/obj/structure/overmap/spacepirate/ai)
			ship_list += typesof(/obj/structure/overmap/syndicate/ai)
			ship_list += typesof(/obj/structure/overmap/nanotrasen/solgov/ai)
			var/obj/structure/overmap/target_ship = input(usr, "Select which ship to spawn (note: factions will apply):", "Select Ship") as null|anything in ship_list

			//Choose ghost logic
			var/target_ghost
			switch(alert(usr, "Who is going to pilot this ghost ship?", "Pilot Select Format", "Open", "Choose", "Cancel"))
				if("Cancel")
					return
				if("Open")
					var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to pilot a [initial(target_ship.name)]?", ROLE_GHOSTSHIP, /datum/role_preference/midround_ghost/ghost_ship, 20 SECONDS, POLL_IGNORE_GHOSTSHIP)
					if(LAZYLEN(candidates))
						var/mob/dead/observer/C = pick(candidates)
						target_ghost = C
					else
						return
				if("Choose")
					target_ghost = input(usr, "Select player to pilot ghost ship:", "Select Player") as null|anything in GLOB.clients

			//Now the actual spawning
			var/obj/structure/overmap/GS = new target_ship(target_location)
			GS.ghost_ship(target_ghost)
			message_admins("[key_name_admin(usr)] has spawned a ghost [GS.name]!")
			log_admin("[key_name_admin(usr)] has spawned a ghost [GS.name]!")

		if("toggle_ghost_ships")
			if(SSovermap_mode.override_ghost_ships)
				SSovermap_mode.override_ghost_ships = FALSE
				message_admins("[key_name_admin(usr)] has ENABLED player ghost ships.")
			else if(!SSovermap_mode.override_ghost_ships)
				SSovermap_mode.override_ghost_ships = TRUE
				message_admins("[key_name_admin(usr)] has DISABLED player ghost ships.")

		if("toggle_ghost_boarders")
			if(SSovermap_mode.override_ghost_boarders)
				SSovermap_mode.override_ghost_boarders = FALSE
				message_admins("[key_name_admin(usr)] has ENABLED player antag boarders.")
			else if(!SSovermap_mode.override_ghost_boarders)
				SSovermap_mode.override_ghost_boarders = TRUE
				message_admins("[key_name_admin(usr)] has DISABLED player antag boarders.")

/datum/overmap_mode_controller/tgui_data(mob/user)
	var/list/data = list()
	var/list/objectives = list()
	if(SSovermap_mode.mode)
		data["current_gamemode"] = SSovermap_mode.mode.name
	else if(SSovermap_mode.forced_mode)
		data["current_gamemode"] = initial(SSovermap_mode.forced_mode.name)
	data["current_description"] = SSovermap_mode.mode?.desc
	data["mode_initalised"] = SSovermap_mode?.mode_initialised
	data["current_difficulty"] = SSovermap_mode.mode?.difficulty
	data["current_escalation"] = SSovermap_mode.escalation
	data["reminder_time_remaining"] = (SSovermap_mode.next_objective_reminder - world.time) / 10 //Seconds
	data["reminder_interval"] = SSovermap_mode.mode?.objective_reminder_interval / 600 //Minutes
	data["reminder_stacks"] = SSovermap_mode.objective_reminder_stacks
	data["toggle_reminder"] = SSovermap_mode.objective_reminder_override
	data["toggle_override"] = SSovermap_mode.admin_override
	data["threat_elevation"] = SSovermap_mode.threat_elevation
	//data["threat_per_size_point"] = TE_POINTS_PER_FLEET_SIZE
	data["toggle_ghost_ships"] = SSovermap_mode.override_ghost_ships
	data["toggle_ghost_boarders"] = SSovermap_mode.override_ghost_boarders
	for(var/datum/overmap_objective/O in SSovermap_mode.mode?.objectives)
		var/list/objective_data = list()
		objective_data["name"] = O.name
		objective_data["desc"] = O.desc
		switch(O.status)
			if(STATUS_INPROGRESS)
				objective_data["status"] = "In-Progress"
			if(STATUS_COMPLETED)
				objective_data["status"] = "Completed"
			if(STATUS_FAILED)
				objective_data["status"] = "Failed"
			if(STATUS_OVERRIDE)
				objective_data["status"] = "Completed - VICTORY OVERRIDE"
		objective_data["datum"] = "\ref[O]"
		objectives[++objectives.len] = objective_data
	data["objectives_list"] = objectives
	return data

/obj/structure/overmap/proc/stop_piloting(mob/living/M)
	LAZYREMOVE(operators,M)
	M.remove_verb(overmap_verbs)
	M.overmap_ship = null
	if(M.click_intercept == src)
		M.click_intercept = null
	if(pilot && M == pilot)
		LAZYREMOVE(M.mousemove_intercept_objects, src)
		pilot = null
		keyboard_delta_angle_left = 0
		keyboard_delta_angle_right = 0
		if(helm)
			playsound(helm, 'sound/effects/computer/hum.ogg', 100, 1)
	if(gunner && M == gunner)
		if(tactical)
			playsound(tactical, 'sound/effects/computer/hum.ogg', 100, 1)
		gunner = null
		target_lock = null
	if(LAZYFIND(gauss_gunners, M))
		var/datum/component/overmap_gunning/C = M.GetComponent(/datum/component/overmap_gunning)
		C.end_gunning()
	if(M.client)
		M.client.view_size.resetToDefault()
		M.client.overmap_zoomout = 0
	var/mob/camera/ai_eye/remote/overmap_observer/eyeobj = M.remote_control
	M.cancel_camera()
	if(M.client) //Reset px, y
		M.client.pixel_x = 0
		M.client.pixel_y = 0

	if(istype(M, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/hal = M
		hal.view_core()
		hal.remote_control = null
		qdel(eyeobj)
		qdel(eyeobj?.off_action)
		qdel(M.remote_control)
		return

	qdel(eyeobj)
	qdel(eyeobj?.off_action)
	qdel(M.remote_control)
	M.remote_control = null
	M.set_focus(M)
	M.cancel_camera()
	return TRUE

#undef STATUS_INPROGRESS
#undef STATUS_COMPLETED
#undef STATUS_FAILED
#undef STATUS_OVERRIDE
#undef REMINDER_OBJECTIVES
#undef REMINDER_COMBAT_RESET
#undef REMINDER_COMBAT_DELAY
#undef REMINDER_OVERRIDE
