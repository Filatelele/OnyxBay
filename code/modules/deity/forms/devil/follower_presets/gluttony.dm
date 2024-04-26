/datum/devil_follower/gluttony
	starting_actions = list(/datum/action/cooldown/spell/gluttony_heal)
	modifiers = list(/datum/modifier/sin/gluttony)

#define GLUTTONY_HEAL_REDUCTION 10

/datum/action/cooldown/spell/gluttony_heal
	name = "Heal"
	desc = "GLLUTTONY HEAL!!!"
	button_icon_state = "undead_heal"

	cooldown_time = 30 SECONDS

	cast_range = 1 /// Basically must be adjacent

/datum/action/cooldown/spell/gluttony_heal/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/gluttony_heal/cast(mob/living/carbon/human/cast_on)
	var/mob/living/carbon/carbon_owner = owner
	if(!istype(carbon_owner))
		return

	cast_on.adjustBruteLoss(carbon_owner.nutrition / GLUTTONY_HEAL_REDUCTION)
	cast_on.adjustFireLoss(carbon_owner.nutrition / GLUTTONY_HEAL_REDUCTION)
	cast_on.adjustToxLoss(carbon_owner.nutrition / GLUTTONY_HEAL_REDUCTION)
	cast_on.adjustOxyLoss(carbon_owner.nutrition / GLUTTONY_HEAL_REDUCTION)

/datum/modifier/sin/gluttony
	name = "Gluttony"
	desc = "GLUTTONY."

	metabolism_percent = 2
	incoming_healing_percent = 1.5

	var/sin_points = 0

/datum/modifier/sin/gluttony/tick()
	var/mob/living/carbon/human/H = holder
	ASSERT(H)

	var/normalized_nutrition = H.nutrition / H.body_build.stomach_capacity
	if(normalized_nutrition >= STOMACH_FULLNESS_HIGH)
		sin_points += 1 * SSmobs.wait

/datum/action/cooldown/spell/fat_protection
	name = "fat_protection"
	desc = "fat_protection!!!"
	button_icon_state = "undead_heal"

	cooldown_time = 30 SECONDS

	cast_range = 1 /// Basically must be adjacent
	var/list/foods_to_orbit = list()
	var/list/foods = list()

/datum/action/cooldown/spell/fat_protection/New()
	. = ..()
	add_think_ctx("food_orbit", CALLBACK(src, nameof(.proc/add_food)), 0)

/datum/action/cooldown/spell/fat_protection/Destroy()
	foods.Cut()
	foods_to_orbit.Cut()
	return ..()

/datum/action/cooldown/spell/fat_protection/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/fat_protection/cast(mob/living/carbon/human/cast_on)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return

	register_signal(H, SIGNAL_HUMAN_CHECK_SHIELDS, nameof(.proc/check_shield))
	for(var/obj/item/reagent_containers/food/food in view(world.view))
		food.forceMove(get_turf(H))
		foods_to_orbit |= food
		register_signal(food, SIGNAL_QDELETING, nameof(.proc/remove_food))

	set_next_think_ctx("food_orbit", world.time + rand(5, 10))

/datum/action/cooldown/spell/fat_protection/proc/add_food()
	var/obj/item/reagent_containers/food/food = pick_n_take(foods_to_orbit)
	food.orbit(owner, 25, TRUE)
	foods |= food

	if(LAZYLEN(foods_to_orbit))
		set_next_think_ctx("food_orbit", world.time + rand(5, 10))

/datum/action/cooldown/spell/fat_protection/proc/check_shield()

/datum/action/cooldown/spell/fat_protection/proc/remove_food(atom/movable/qdeleted_food)
	qdeleted_food.stop_orbit(owner.orbiters)
	foods -= qdeleted_food
