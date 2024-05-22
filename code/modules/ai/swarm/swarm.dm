#define PET_CULT_ATTACK 10
#define PET_CULT_HEALTH 50

/mob/living/basic/pet/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	if(!(FACTION_CULT in faction))
		return

	var/datum/team/cult_team = locate(/datum/team/cult) in GLOB.antagonist_teams
	if(isnull(cult_team))
		return

	mind.add_antag_datum(/datum/antagonist/cult, cult_team)
	update_appearance(UPDATE_OVERLAYS)


#undef PET_CULT_ATTACK
#undef PET_CULT_HEALTH
