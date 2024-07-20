/datum/kpi_handler/money
	kpi_reward = 0.1

/datum/kpi_handler/money/check_mob(mob/M)
	var/total_balance = 0

	var/datum/mind/mind = M.mind
	var/datum/money_account/initial_account = mind.initial_account
	total_balance += initial_account?.get_balance()

	var/list/contents = M.get_all_contents()
	for(var/obj/item/card/id/card in contents)
		var/datum/money_account/card_account = get_account(card.associated_account_number)
		if(card_account == initial_account)
			continue

		total_balance += card_account?.get_balance()

	for(var/obj/item/spacecash/cash in contents)
		total_balance += cash.worth

	var/list/result = list()
	if(total_balance >= 2000)
		result["text"] = "You have managed to raise enough money not to worry about the immediate future."
		result["kpi"] = kpi_reward
	else
		result["text"] = "Your bank account is low on funds. How you're going to pay your bills?"
		result["kpi"] = kpi_failure

	return result
