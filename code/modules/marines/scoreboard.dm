/datum/subsystem/ticker/proc/scoreboard()
//MARINES

	// Was the shuttle called?
	//if(emergency_shuttle.location==2)
	if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
		score_shuttle_called = 1


	// Who is MIA
	for (var/mob/living/carbon/human/I in mob_list)
		if (I.stat == 2 && I.z != 6 && I.z != 2)  //Bodies not on Sulaco or centcomm are missing
			score_marines_mia++
	// Who is KIA
		else if (I.stat == 2)
			score_marines_kia++

	for(var/client/C in clients)
		// Marines alive
		if(ishuman(C.mob) && C.mob.stat != DEAD) //Not survivors
			score_marines_survived++
		// Marines evacuated
		if(ishuman(C.mob) && C.mob.stat != DEAD && C.mob.z == 2)
			score_crew_evacuated++
	/*// Alive Active Survivors
		if(ishuman(C.mob) && C.mob.stat != DEAD) //Survivors only
			score_survivors_rescued++*/




//End game score bonus
	if (round_end_situation == 1 || SSshuttle.emergency.mode >= SHUTTLE_ENDGAME)
		score_aliens_won = 1
	else if (round_end_situation == 2)
		score_marines_won = 1
	else if (round_end_situation == 4)
		score_aliens_won = 2
	else if (round_end_situation == 5)
		score_marines_won = 2

//ALIENS
	// Aliens dead
	for (var/mob/living/carbon/alien/A in mob_list)
		if (A.stat == 2 && !isqueen(A) && !islarva(A))
			score_aliens_dead++
	// Larvas dead
		if (A.stat == 2 && islarva(A))
			score_larvas_dead++
	// Queens dead
		if (A.stat == 2 && isqueen(A))
			score_queens_dead++
	// Alive Active Aliens
	for(var/client/C in clients)
		if(isalien(C.mob) && C.mob.stat != DEAD)
			score_aliens_survived++

	// Check how many weeds there are
	for (var/obj/structure/alien/weeds/M in world)
		score_weeds_made += 1

	// Original queen alive?
	if (score_queens_dead == 0)
		score_queen_survived = 1
//-*------------------------------------------*-\\

//MARINE SCORE
	var/marine_mia_points = score_marines_mia * 350
	var/marine_kia_points = score_marines_kia * 150
	var/marine_survived_points = score_marines_survived * 200
	var/marine_hit_called_points = score_hit_called * 5000
	var/marine_won_points = score_marines_won * 5000
	var/marine_rescue_points = score_survivors_rescued * 1000
	var/marine_cloned_points = score_marines_cloned * 1000
	var/marine_larvas_extracted_points = score_larvas_extracted * 500
	var/marine_chestbursted_points = score_marines_chestbursted * 500
	var/marine_shuttle_called_points = score_shuttle_called * 10000
	var/marine_crew_evacuated_points = (score_marines_survived - score_crew_evacuated) * 1000

//Calculate Marine Good Things
	score_marinescore += marine_survived_points
	score_marinescore += marine_survived_points
	score_marinescore += marine_won_points
	score_marinescore += marine_rescue_points
	score_marinescore += marine_cloned_points
	score_marinescore += marine_larvas_extracted_points

//Calculate Marine Bad Things
	score_marinescore -= marine_mia_points
	score_marinescore -= marine_kia_points
	score_marinescore -= marine_chestbursted_points
	score_marinescore -= marine_hit_called_points
	score_marinescore -= marine_crew_evacuated_points
	score_marinescore -= marine_shuttle_called_points


//ALIEN SCORE
	var/alien_survived_points = score_aliens_survived * 500
	var/alien_queen_survived_points = score_queen_survived * 5000
	var/alien_dead_points = score_aliens_dead * 300
	var/alien_queens_dead_points = score_queens_dead * 2000
	var/alien_eggs_made_points = score_eggs_made * 25
	var/alien_weeds_made_points = score_weeds_made * 2
	var/alien_hosts_infected_points = score_hosts_infected * 100
	var/alien_won_points = score_aliens_won * 5000
	var/alien_dead_larvas_points = score_larvas_dead * 500

//Calculate Alien Good Things
	score_alienscore += alien_survived_points
	score_alienscore += alien_queen_survived_points
	score_alienscore += alien_eggs_made_points
	score_alienscore += alien_weeds_made_points
	score_alienscore += alien_hosts_infected_points
	score_alienscore += alien_won_points

//Calculate Alien Bad Things
	score_alienscore -= alien_dead_points
	score_alienscore -= alien_queens_dead_points
	score_alienscore -= alien_dead_larvas_points

//-*------------------------------------------*-\\

	// Show the score
	world << "<b>The game final score is:</b>"
	world << "<b><font size='4'>[score_marinescore - score_alienscore]</font></b>"
	for(var/mob/E in player_list)
		if(E.client) E.scorestats()
	return


//Show the score window
/mob/proc/scorestats()
	var/dat = {"<B>Round Statistics and Score</B><BR><HR>"}


//Aliens
	dat += {"<B><U>ALIEN STATS</U></B><BR>
	<U>THE GOOD:</U><BR>"}
	var/alien_win_message
	if (score_aliens_won == 0)
		alien_win_message = "Failed"
	else if (score_aliens_won == 1)
		alien_win_message = "Infestation remains"
	else if (score_aliens_won == 2)
		alien_win_message = "Infestation expands"
	dat +={"<B>Infestation expanded?:</B>		[alien_win_message] 			([score_aliens_won * 5000] Points)<BR>
	<B>Total live aliens:</B>					[score_aliens_survived]			 ([score_aliens_survived * 500] Points)<BR>
	<B>Original queen survived:</B>				[score_queen_survived ? "Yes" : "No"] 			([score_queen_survived * 5000] Points)<BR>
	<BR>
	<B>Eggs produced:</B>						[score_eggs_made] 			([score_eggs_made * 25] Points)<BR>
	<B>Station tiles infested:</B>				[score_weeds_made] 			([score_weeds_made * 2] Points)<BR>
	<B>Hosts infected:</B> 						[score_hosts_infected] 			([score_hosts_infected * 100] Points) <BR>
	<BR>"}
	dat += {"<U>THE BAD:</U><BR>
	<B>Queens died:</B> 						[score_queens_dead] 			([-score_queens_dead * 2000] Points)<BR>
	<B>Aliens died:</B> 						[score_aliens_dead] 			([-score_aliens_dead * 300] Points)<BR>
	<B>Larvas died:</B> 						[score_larvas_dead]				([-score_larvas_dead * 500] Points)<BR>
	<BR>
	<U>OTHER</U><BR>
	<B>Resin constructed:</B> 					[score_resin_made]<BR>
	<B>Tackles:</B> 							[score_tackles_made]<BR>
	<B>Slashes:</B>								[score_slashes_made]<BR>
	<BR>"}
	dat += {"<HR><BR>
	<B><U>FINAL ALIEN SCORE: [score_alienscore]</U></B><BR><HR>"}

//Marines
	dat += {"<B><U>MARINE STATS</U></B><BR>
	<U>THE GOOD:</U><BR>"}
	var/marine_win_message
	if (score_marines_won == 0)
		marine_win_message = "Failed"
	else if (score_marines_won == 1)
		marine_win_message = "Nuke deployed"
	else if (score_marines_won == 2)
		marine_win_message = "Infestation cleared"
	dat +={"<B>Infestation eradicated?:</B> 				[marine_win_message] 			([score_marines_won * 5000] Points)<BR>
	<B>Survivors saved:</B> 					[score_survivors_rescued] ([score_survivors_rescued * 1000] Points)<BR>
	<B>Marines survived:</B> 					[score_marines_survived] ([score_marines_survived * 100] Points)<BR>
	<BR>
	<B>Marines revived:</B> 													(-) Points)<BR>
	<B>Marines cloned</B> 						[score_marines_cloned] ([score_marines_cloned * 1000] Points)<BR>
	<B>Larvas extracted</B> 					[score_larvas_extracted] ([score_larvas_extracted * 500] Points)<BR>
	<BR>"}
	dat += {"<U>THE BAD:</U><BR>
	<B>Marines MIA:</B> 						[score_marines_mia] 			([-score_marines_mia * 350] Points)<BR>
	<B>Marines KIA:</B> 						[score_marines_kia] 			([-score_marines_kia * 150] Points)<BR>
	<B>Marines chestbursted:</B> 				[score_marines_chestbursted]			([-score_marines_chestbursted * 500] Points)<BR>
	<BR>"}
	if (score_hit_called != 0)
		dat += {"<B>HIT called:</B>							[score_hit_called ? "Yes" : "No"] 			([-score_hit_called * 5000] Points)<BR>"}
	if (score_shuttle_called != 0)
		dat += {"<B>Sulaco evacuated:</B> 					[score_shuttle_called ? "Yes" : "No"] 			([-score_shuttle_called * 10000] Points)<BR>
	<B>Marines left behind:</B> 				[score_marines_survived - score_crew_evacuated] 			([(score_marines_survived - score_crew_evacuated) * -1000] Points)<BR>"}
	dat += {"<BR>
	<U>OTHER</U><BR>
	<B>Rounds fired:</B> 						[score_rounds_fired]<BR>"}
	if (score_rounds_fired != 0) //Let's not divide by 0 ever again
		dat += {"<B>Rounds hit:</B> 							[score_rounds_hit] ([score_rounds_hit * 100 / score_rounds_fired]%)<BR>"}
	dat += {"<B>Clamps:</B> 								[score_aliens_clamped]<BR>
	<BR>"}
	dat += {"<HR><BR>
	<B><U>FINAL MARINE SCORE: [score_marinescore]</U></B><BR>"}
	dat += {"<HR><BR>
	<B><U>TOTAL SCORE: [score_marinescore - score_alienscore]</U></B><BR>"}


//TODO: Score rating for marines(positive number) and aliens(negative number)
	var/score_rating = "The Aristocrats!"
	switch(score_marinescore)
		if(-99999 to -50000) score_rating = "Even the Singularity Deserves Better"
		if(-49999 to -5000) score_rating = "Singularity Fodder"
		if(-4999 to -1000) score_rating = "You're All Fired"
		if(-999 to -500) score_rating = "A Waste of Perfectly Good Oxygen"
		if(-499 to -250) score_rating = "A Wretched Heap of Scum and Incompetence"
		if(-249 to -100) score_rating = "Outclassed by Lab Monkeys"
		if(-99 to -21) score_rating = "The Undesirables"
		if(-20 to 20) score_rating = "Ambivalently Average"
		if(21 to 99) score_rating = "Not Bad, but Not Good"
		if(100 to 249) score_rating = "Skillful Servants of Science"
		if(250 to 499) score_rating = "Best of a Good Bunch"
		if(500 to 999) score_rating = "Lean Mean Machine Thirteen"
		if(1000 to 4999) score_rating = "Promotions for Everyone"
		if(5000 to 9999) score_rating = "Ambassadors of Discovery"
		if(10000 to 49999) score_rating = "The Pride of Science Itself"
		if(50000 to INFINITY) score_rating = "Nanotrasen's Finest"
	dat += "<B><U>RATING:</U></B> [score_rating]"
	src << browse(dat, "window=roundstats;size=500x600")
	return
