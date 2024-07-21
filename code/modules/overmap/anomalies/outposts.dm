/obj/effect/overmap_anomaly/outpost
	name = "Outpost"
	icon = 'icons/overmap/neutralstation.dmi'
	icon_state = "combust"
	/// Link to this outpost's shuttle
	var/datum/shuttle/autodock/ferry/outpost/shuttle = null
	/// Outpost's atmosphere. Just in case you want a fully enclosed dock.
	var/datum/gas_mixture/atmosphere
	var/datum/map_template/outpost/map_template

/obj/effect/overmap_anomaly/outpost/Initialize()
	. = ..()
	SSshuttle.initialise_shuttle(map_template.shuttle_datum)
	shuttle = locate(map_template.shuttle_datum) in SSshuttle.shuttles

/obj/effect/overmap_anomaly/outpost/starting
	name = "Sectoral Central Command"
	map_template = /datum/map_template/outpost/centcom17

/obj/effect/overmap_anomaly/outpost/entrepot1
	name = "Entrepot Theta"
	map_template = /datum/map_template/outpost/entrepot
