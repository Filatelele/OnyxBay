//Weapon modes

#define FIRE_MODE_ANTI_AIR 1
#define FIRE_MODE_TORPEDO 2

//Revision 2.
#define FIRE_MODE_AMS_LASER 3 // Laser AMS should be fired before expensive missiles are fired, so this is prioritized first
#define FIRE_MODE_AMS 4 //You don't get to physically fire this one.
#define FIRE_MODE_MAC 5
#define FIRE_MODE_RAILGUN 6
#define FIRE_MODE_GAUSS 7
#define FIRE_MODE_PDC 8
#define FIRE_MODE_BROADSIDE 9
#define FIRE_MODE_PHORON 10

//Base Armor Values

#define OM_ARMOR list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 80, "bio" = 100, "rad" = 100, "acid" = 100, "stamina" = 100)

//Deprecated / legacy weapons.

#define FIRE_MODE_FLAK 11
#define FIRE_MODE_MISSILE 12
#define FIRE_MODE_FIGHTER_SLOT_ONE 13
#define FIRE_MODE_FIGHTER_SLOT_TWO 14

//Special cases

#define FIRE_MODE_RED_LASER 15
#define FIRE_MODE_LASER_PD 16
#define FIRE_MODE_BLUE_LASER 17
#define FIRE_MODE_HYBRID_RAIL 18

#define MAX_POSSIBLE_FIREMODE 18 //This should relate to the maximum number of weapons a ship can ever have. Keep this up to date please!

//Weapon classes for AIs
#define WEAPON_CLASS_LIGHT 1
#define WEAPON_CLASS_HEAVY 2

// AMS targeting modes for STS
#define AMS_LOCKED_TARGETS "Locked Targets"
#define AMS_PAINTED_TARGETS "Painted Targets"

//Northeast, Northwest, Southeast, Southwest
#define ARMOUR_FORWARD_PORT "forward_port"
#define ARMOUR_FORWARD_STARBOARD "forward_starboard"
#define ARMOUR_AFT_PORT "aft_port"
#define ARMOUR_AFT_STARBOARD "aft_starboard"

//AI behaviour

#define AI_AGGRESSIVE 1
#define AI_PASSIVE 2
#define AI_RETALIATE 3
#define AI_GUARD 4

#define isovermap(A) (istype(A, /obj/structure/overmap))
#define isasteroid(A) (istype(A, /obj/structure/overmap/asteroid))
#define isanomaly(A) (istype(A, /obj/effect/overmap_anomaly))

//Assigning player ships goes here

#define NORMAL_OVERMAP 1
#define MAIN_OVERMAP 2
#define MAIN_MINING_SHIP 3
#define PVP_SHIP 4
#define INSTANCED_MIDROUND_SHIP 5

//Sensor resolution

#define SENSOR_VISIBILITY_FULL 1
#define SENSOR_VISIBILITY_TARGETABLE 0.70 //You have to be close up, or not cloaked to be targetable by the ship's gunner.
#define SENSOR_VISIBILITY_FAINT 0.5
#define SENSOR_VISIBILITY_VERYFAINT 0.25
#define SENSOR_VISIBILITY_GHOST 0 //Totally impervious to scans.

#define SENSOR_RANGE_DEFAULT 40
#define SENSOR_RANGE_FIGHTER 30 //Fighters have crappier sensors. Coordinate with the ATC!

#define CLOAK_TEMPORARY_LOSS 2 //Cloak handling. When you fire a weapon, you temporarily lose your cloak, and AIs can target you.

GLOBAL_LIST_INIT(overmap_objects, list())
GLOBAL_LIST_INIT(overmap_anomalies, list())

#define NO_INTERIOR 0
#define INTERIOR_EXCLUSIVE 1 // Only one of them at a time, occupies a whole Z level
#define INTERIOR_DYNAMIC 2 // Can have more than one, reserves space on the reserved Z

#define INTERIOR_NOT_LOADED 0
#define INTERIOR_LOADING 1
#define INTERIOR_READY 2
#define INTERIOR_DELETING 3
#define INTERIOR_DELETED 4

//Overmap flags
#define OVERMAP_FLAG_ZLEVEL_CARRIER (1<<0) //! This overmap is meant to carry a z with it, prompting restoration in certain cases.

//Ship mass
#define MASS_TINY 1 //1 Player - Fighters
#define MASS_SMALL 2 //2-5 Players - FoB/Mining Ship
#define MASS_MEDIUM 3 //10-20 Players - Small Capital Ships
#define MASS_MEDIUM_LARGE 5 //10-20 Players - Small Capital Ships
#define MASS_LARGE 7 //20-40 Players - Medium Capital Ships
#define MASS_TITAN 150 //40+ Players - Large Capital Ships
#define MASS_IMMOBILE 200 //Things that should not be moving. See: stations

//Fun tools
#define SHIELD_NOEFFECT 0 //!Shield failed to absorb hit.
#define SHIELD_ABSORB 1 //!Shield absorbed hit.
#define SHIELD_FORCE_DEFLECT 2 //!Shield absorbed hit and is redirecting projectile with slightly turned vector.
#define SHIELD_FORCE_REFLECT 3 //!Shield absorbed hit and is redirecting projectile in reverse direction.

//Time between each 'combat cycle' of starsystems. Every combat cycle, every system that has opposing fleets in it gets iterated through, with the fleets firing at eachother.
#define COMBAT_CYCLE_INTERVAL 180 SECONDS

//Threat level of star systems
#define THREAT_LEVEL_NONE 0
#define THREAT_LEVEL_UNSAFE 2
#define THREAT_LEVEL_DANGEROUS 4

//The different sectors, keep this updated
#define ALL_STARMAP_SECTORS 1,2,3

#define SECTOR_SOL 1
#define SECTOR_NEUTRAL 2
#define SECTOR_SYNDICATE 3

//Overmap deletion behavior - Occupants are defined as non-simple mobs.
/// Not a real bitflag, just here for readability. If no damage flags are set, damage will delete the overmap immediately regardless of anyone in it
#define DAMAGE_ALWAYS_DELETES 		    0
/// When the overmap takes enough damage to be destroyed, begin a countdown after which it will be deleted
#define DAMAGE_STARTS_COUNTDOWN		    (1<<0)
/// When the overmap takes enough damage to be destroyed, if there are no occupants, delete it immediately. Modifies DAMAGE_STARTS_COUNTDOWN
#define DAMAGE_DELETES_UNOCCUPIED	    (1<<1)
/// Even if the overmap takes enough damage to be destroyed, never delete it if it's occupied. I don't know when we'd use this it just seems useful
#define NEVER_DELETE_OCCUPIED		    (1<<2)
/// When a fighter/dropship leaves the map level for the overmap level, look for remaining occupants. If none exist, delete
#define DELETE_UNOCCUPIED_ON_DEPARTURE 	(1<<3)
/// Docked overmaps count as occupants when deciding whether to delete something
#define FIGHTERS_ARE_OCCUPANTS		    (1<<4)

//Starsystem Traits
#define STARSYSTEM_NO_ANOMALIES (1<<0)//Prevents Anomalies Spawning
#define STARSYSTEM_NO_ASTEROIDS (1<<1)	//Prevents Asteroids Spawning
#define STARSYSTEM_NO_WORMHOLE (1<<2)//Prevents Incoming Wormholes
#define STARSYSTEM_END_ON_ENTER (1<<3) //End the round after entering this system (Outpost 45)

// FTL Drive Computer States. (Legacy only)
#define FTL_STATE_IDLE 1
#define FTL_STATE_SPOOLING 2
#define FTL_STATE_READY 3
#define FTL_STATE_JUMPING 4

#define OVERMAP_USER_ROLE_PILOT (1<<0)
#define OVERMAP_USER_ROLE_GUNNER (1<<1)
#define OVERMAP_USER_ROLE_SECONDARY_GUNNER (1<<2)
#define OVERMAP_USER_ROLE_OBSERVER (1<<3)
