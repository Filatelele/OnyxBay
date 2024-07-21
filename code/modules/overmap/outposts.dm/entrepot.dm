/datum/shuttle/autodock/ferry/outpost/entrepot
	name = "Entrepot"
	location = TRUE
	warmup_time = 0
	shuttle_area = /area/shuttle/ferry/outpost/entrepot
	dock_target = "ship_dock"
	waypoint_offsite = "nav_outpost_away_entrepot"
	waypoint_station = "nav_outpost_dock"

/area/shuttle/ferry/outpost/entrepot

/obj/effect/shuttle_landmark/outpost/entrepot_away
	name = "Entrepot Away"
	landmark_tag = "nav_outpost_away_entrepot"
	docking_controller = "ship_dock"
	autoset = FALSE

/datum/map_template/outpost/entrepot
	name = "Entrepot"
	mappaths = list('maps/outposts/entrepot.dmm')
	shuttle_datum = /datum/shuttle/autodock/ferry/outpost/entrepot
