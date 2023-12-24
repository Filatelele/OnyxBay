//Alloys that contain subsets of each other's ingredients must be ordered in the desired sequence
//eg. steel comes after plasteel because plasteel's ingredients contain the ingredients for steel and
//it would be impossible to produce.

/datum/alloy
	var/list/requires
	var/product_mod = 1
	var/product
	var/metaltag

/datum/alloy/plasteel
	metaltag = "plasteel"
	requires = list(
		ORE_PLATINUM = 1,
		ORE_COAL = 2,
		ORE_IRON = 2
	)
	product_mod = 0.3
	product = /obj/item/stack/material/plasteel

/datum/alloy/steel
	metaltag = DEFAULT_WALL_MATERIAL
	requires = list(
		ORE_COAL = 1,
		ORE_IRON = 1
	)
	product = /obj/item/stack/material/steel

/datum/alloy/borosilicate
	metaltag = "borosilicate glass"
	requires = list(
		ORE_PLATINUM = 1,
		ORE_SAND = 2
	)
	product = /obj/item/stack/material/glass/phoronglass
