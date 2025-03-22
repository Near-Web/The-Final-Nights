//Returns true if player_a wins, false if not. There is always a winner or a loser!
/mob/living/proc/opposed_roll(mob/player_a, mob/player_b, dice_a = 1, dice_b = 1, difficulty=6, stat_test_a_header="", stat_test_b_header="", show_player_a=TRUE, show_player_b=TRUE, draw_goes_to_b=TRUE)
	if(dice_a < 1)
		dice_a = 1
	
	if(dice_b < 1)
		dice_b = 1

	var/successes_a = 0
	var/list/success_list_a = new()
	var/list/fail_list_a = new()
	for (var/i in 1 to dice_a)
		var/roll = rand(1, 10)

		if (roll == 1)
			successes_a--
			fail_list_a.Add(roll)
			continue

		if (roll < difficulty)
			fail_list_a.Add(roll)
		else
			successes_a++
			success_list_a.Add(roll)

	var/successes_b = 0
	var/list/success_list_b = new()
	var/list/fail_list_b = new()
	for (var/i in 1 to dice_b)
		var/roll = rand(1, 10)

		if (roll == 1)
			successes_b--
			fail_list_b.Add(roll)
			continue

		if (roll < difficulty)
			fail_list_b.Add(roll)
		else
			successes_b++
			success_list_b.Add(roll)
	
	var/player_a_succeeded = FALSE
	if(successes_a > successes_b || (successes_a == successes_b && !draw_goes_to_b))
		player_a_succeeded = TRUE
	
	var/success_text = " - <span style='color:green'>Success!</span></h2>"
	var/fail_text = " - <span style='color:DarkRed'>Failure!</span></h2>"
	if(show_player_a && player_a.mind && player_a?.client?.prefs?.chat_toggles & CHAT_ROLL_INFO)
		var/roll_log = "<h2>[stat_test_a_header] vs [successes_b]</h2><br>"
		roll_log += "<h2>Difficulty: [difficulty]</h2><br>"
		roll_log += "<h2>Your Roll:"
		if(success_list_a)
			roll_log += "<span style='color:green'>"
			for(var/roll_result in success_list_a)
				roll_log += " [get_dice_char(roll_result)]"
			roll_log += "</span>"
		if(fail_list_a)
			roll_log += "<span style='color:DarkRed'>"
			for(var/roll_result in fail_list_a)
				roll_log += " [get_dice_char(roll_result)]"
			roll_log += "</span>"
		if(player_a_succeeded)
			roll_log += success_text
		else
			roll_log += fail_text
		to_chat(player_a, roll_log)

	if(show_player_b && player_b.mind && player_b?.client?.prefs?.chat_toggles & CHAT_ROLL_INFO)
		var/roll_log = "<h2>[stat_test_b_header] vs [successes_a]</h2><br>"
		roll_log += "<h2>Difficulty: [difficulty]</h2><br>"
		roll_log += "<h2>Your Roll:"
		if(success_list_b)
			roll_log += "<span style='color:green'>"
			for(var/roll_result in success_list_b)
				roll_log += " [get_dice_char(roll_result)]"
			roll_log += "</span>"
		if(fail_list_b)
			roll_log += "<span style='color:DarkRed'>"
			for(var/roll_result in fail_list_b)
				roll_log += " [get_dice_char(roll_result)]"
			roll_log += "</span>"
		if(!player_a_succeeded)
			roll_log += success_text
		else
			roll_log += fail_text
		to_chat(player_b, roll_log)

	return player_a_succeeded
	

