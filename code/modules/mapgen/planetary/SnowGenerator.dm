/area/generated/planetoid/ice
	base_turf = /turf/simulated/floor/asteroid/snow

/datum/map_generator/planet_generator/snow
	mountain_height = 0.40
	perlin_zoom = 55

	initial_closed_chance = 45
	smoothing_iterations = 20
	birth_limit = 4
	death_limit = 3

	primary_area_type = /area/generated/planetoid/ice

	biome_table = list(
		BIOME_COLDEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/arctic/rocky,
			BIOME_LOW_HUMIDITY = /datum/biome/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/iceberg/lake,
			BIOME_HIGH_HUMIDITY = /datum/biome/iceberg,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/iceberg
		),
		BIOME_COLD = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/arctic,
			BIOME_LOW_HUMIDITY = /datum/biome/arctic/rocky,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/lush,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/iceberg
		),
		BIOME_WARM = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/snow/thawed,
			BIOME_LOW_HUMIDITY = /datum/biome/snow/forest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/iceberg
		),
		BIOME_TEMPERATE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/snow/lush,
			BIOME_LOW_HUMIDITY = /datum/biome/snow/forest/dense,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/forest/dense,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow/forest,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/snow/lush
		),
		BIOME_HOT = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/snow,
			BIOME_LOW_HUMIDITY = /datum/biome/snow/forest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/thawed,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow/lush,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/snow
		),
		BIOME_HOTTEST = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/snow/forest/dense,
			BIOME_LOW_HUMIDITY = /datum/biome/snow/forest,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/snow/thawed,
			BIOME_HIGH_HUMIDITY = /datum/biome/snow/forest/dense,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/snow/thawed
		)
	)

	cave_biome_table = list(
		BIOME_COLDEST_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/snow,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/snow,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/snow,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/snow/ice
		),
		BIOME_COLD_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/snow,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/snow,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/snow/ice,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/snow/ice
		),
		BIOME_WARM_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/snow,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/snow,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/snow/thawed,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/snow/thawed,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/snow
		),
		BIOME_HOT_CAVE = list(
			BIOME_LOWEST_HUMIDITY = /datum/biome/cave/snow/thawed,
			BIOME_LOW_HUMIDITY = /datum/biome/cave/snow/thawed,
			BIOME_MEDIUM_HUMIDITY = /datum/biome/cave/volcanic/lava/plasma,
			BIOME_HIGH_HUMIDITY = /datum/biome/cave/volcanic/lava,
			BIOME_HIGHEST_HUMIDITY = /datum/biome/cave/volcanic/lava/total
		)
	)

/datum/biome/snow
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow = 25
	)
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 4,
		/obj/structure/rock/icy = 4,
		/obj/structure/rock/icy/pile = 4,
		/obj/structure/flora/grass/snowy/both = 12,
	)
	flora_spawn_chance = 10
	mob_spawn_chance = 1
	mob_spawn_list = list(
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
	)

/datum/biome/snow/lush
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow = 25
	)
	flora_spawn_list = list(
		/obj/structure/flora/grass/snowy/both = 1,
	)
	flora_spawn_chance = 30

/datum/biome/snow/thawed
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow/icerock = 1
	)
	flora_spawn_chance = 40
	flora_spawn_list = list(
		/obj/structure/flora/ausbushes/fullgrass = 1,
		/obj/structure/flora/ausbushes/sparsegrass = 1,
		/obj/structure/flora/ausbushes = 1,
		/obj/structure/flora/ausbushes/ppflowers = 1,
		/obj/structure/flora/ausbushes/lavendergrass = 1,
	)

/datum/biome/snow/forest
	flora_spawn_chance = 15
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 20,
		/obj/structure/flora/tree/dead = 6,
		/obj/structure/flora/grass/snowy/both = 8,
		/obj/structure/landmine = 1,
	)

/datum/biome/snow/forest/dense
	flora_spawn_chance = 25
	flora_spawn_list = list(
		/obj/structure/flora/tree/pine = 20,
		//obj/structure/flora/grass/snowy/both = 6,
		/obj/structure/flora/tree/dead = 3,
		/obj/structure/landmine = 1,
	)

/datum/biome/arctic
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow = 1
	)
	feature_spawn_chance = 0.1
	feature_spawn_list = list(
		//obj/structure/statue/snow/snowman = 3,
		//obj/structure/statue/snow/snowlegion = 1,
	)
	mob_spawn_list = list(
	)
	mob_spawn_chance = 1

/datum/biome/arctic/rocky
	flora_spawn_chance = 5
	flora_spawn_list = list(
		/obj/structure/rock/icy = 2,
		/obj/structure/rock/icy/pile = 2,
	)

/datum/biome/iceberg
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow/iceberg = 6,
		/turf/simulated/floor/natural/ice/iceberg = 1,
		/turf/unsimulated/mask = 10
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
	)
	feature_spawn_chance = 0.3

/datum/biome/iceberg/lake
	open_turf_types = list(
		/turf/simulated/floor/natural/ice/fancy = 1
	)

/datum/biome/plasma
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow/icerock/smooth = 1
	)

/datum/biome/cave/snow
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow/icerock = 1
	)
	flora_spawn_chance = 6
	flora_spawn_list = list(
		/obj/structure/flora/grass/snowy/both = 10,
		//obj/structure/flora/rock/icy = 2,
		//obj/structure/flora/rock/icy/pile = 2,
		/obj/structure/landmine = 2
	)
	closed_turf_types = list(
		/turf/unsimulated/mask = 1
	)
	mob_spawn_chance = 2
	mob_spawn_list = list(
	)
	feature_spawn_chance = 0.2
	feature_spawn_list = list(
		/obj/effect/minefield = 2,
	)

/datum/biome/cave/snow/thawed
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow/icerock/cracked = 1
	)
	closed_turf_types = list(
		/turf/unsimulated/mask = 1
	)

/datum/biome/cave/snow/ice
	open_turf_types = list(
		/turf/simulated/floor/asteroid/snow/icerock = 20,
		/turf/simulated/floor/natural/ice/fancy = 3
	)
	closed_turf_types = list(
		/turf/unsimulated/mask = 1
	)

/datum/biome/cave/volcanic
	open_turf_types = list(
		/turf/simulated/floor/asteroid/basalt = 1
	)
	closed_turf_types = list(
		/turf/unsimulated/mask = 1
		)
	mob_spawn_chance = 2
	mob_spawn_list = list(
	)
	flora_spawn_chance = 3
	flora_spawn_list = list(
		/obj/structure/landmine = 1,
	)
	feature_spawn_chance = 0.2

/datum/biome/cave/volcanic/lava
	open_turf_types = list(
		/turf/simulated/floor/natural/lava = 10,
		/turf/simulated/floor/asteroid/snow/icerock/smooth = 1
	)

/datum/biome/cave/volcanic/lava/total
	open_turf_types = list(
		/turf/simulated/floor/natural/lava = 1
	)

/datum/biome/cave/volcanic/lava/plasma
	open_turf_types = list(
		/turf/simulated/floor/natural/lava = 7,
		/turf/simulated/floor/asteroid/snow/icerock/smooth = 1
	)
