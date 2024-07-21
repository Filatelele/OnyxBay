#define SIGNAL_OVERMAP_STATE_CHANGE "ftl_state_change"
#define SIGNAL_OVERMAP_SHIP_KILLED "ship_killed"
#define SIGNAL_OM_LOCK_LOST "lock_lost"

/// Called on '/obj/structure/overmap/proc/dock()' (/obj/structure/overmap, datum/star_system, obj/effect/overmap_anomaly/outpost/target)
#define SIGNAL_OVERMAP_DOCKED "overmap_docked"

/// Called on '/obj/structure/overmap/proc/undock()' (/obj/structure/overmap, datum/star_system, obj/effect/overmap_anomaly/outpost/target)
#define SIGNAL_OVERMAP_UNDOCKED "overmap_undocked"

/// Called on '/obj/structure/overmap/proc/land()' (/obj/structure/overmap, datum/star_system, obj/effect/overmap_anomaly/visitable/planetoid)
#define SIGNAL_OVERMAP_LANDED "overmap_landed"

/// Called on '/obj/structure/overmap/proc/takeoff()' (/obj/structure/overmap, datum/star_system)
#define SIGNAL_OVERMAP_TOOK_OFF "overmap_tookoff"
