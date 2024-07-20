/datum/shuttle/autodock/ferry/outpost/centcom17
	name = "Centcomm-17"
	location = TRUE
	warmup_time = 0
	shuttle_area = /area/shuttle/ferry/outpost/centcomm17
	dock_target = "ship_dock"
	waypoint_offsite = "nav_outpost_away_c17"
	waypoint_station = "nav_outpost_dock"

/area/shuttle/ferry/outpost/centcomm17

/obj/effect/shuttle_landmark/outpost/starting
	name = "C-17 away"
	landmark_tag = "nav_outpost_away_c17"
	docking_controller = "ship_dock"
	autoset = FALSE

/datum/map_template/outpost/centcom17
	name = "Centcomm17"
	mappaths = list('maps/outposts/centcomm17.dmm')
	essential = TRUE
	shuttle_datum = /datum/shuttle/autodock/ferry/outpost/centcom17
