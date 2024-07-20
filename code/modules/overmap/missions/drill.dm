/datum/mission/drill
	name = "Class 1 core sample mission"
	desc = "We require geological information from one of the neighboring planetoids . \
			Please anchor the drill in place and defend it until it has gathered enough samples.\
			Operation of the core sampling drill is extremely dangerous, caution is advised. "
	reward = 2000
	duration = 15 MINUTES
	weight = 8

	var/obj/machinery/drill/mission/sampler
	var/num_wanted = 4
	var/class_wanted = 1

/datum/mission/drill/New(...)
	num_wanted = rand(num_wanted - 2,num_wanted + 2)
	reward += num_wanted * 100
	return ..()

/datum/mission/drill/classtwo
	name = "Class 2 core sample mission"
	reward = 3500
	weight = 6
	class_wanted = 2
	num_wanted = 6

/datum/mission/drill/classthree
	name = "Class 3 core sample mission"
	reward = 5000
	weight = 4
	duration = 100 MINUTES
	class_wanted = 3
	num_wanted = 8
