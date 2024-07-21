/datum/map_template/outpost
	/// If TRUE - will be loaded instantly during init
	var/essential = FALSE
	var/shuttle_datum = /datum/shuttle/autodock/ferry/outpost

/datum/shuttle/autodock/ferry/outpost
	name = "Outpost Shuttle"
	location = TRUE
	warmup_time = 0
	shuttle_area = /area/shuttle/ferry/outpost
	dock_target = "ship_dock"
	waypoint_offsite = "nav_outpost_away"
	waypoint_station = "nav_outpost_dock"

/datum/shuttle/autodock/ferry/outpost/New()
	. = ..()
	short_jump(waypoint_station)

/area/shuttle/ferry/outpost

/obj/effect/shuttle_landmark/outpost/starting
	name = "Outpost"
	landmark_tag = "nav_outpost_away"
	docking_controller = "ship_dock"
	autoset = FALSE

/obj/effect/shuttle_landmark/outpost/docked
	name = "Outpost Docking loc"
	landmark_tag = "nav_outpost_dock"
	docking_controller = "ship_dock"
	autoset = FALSE
