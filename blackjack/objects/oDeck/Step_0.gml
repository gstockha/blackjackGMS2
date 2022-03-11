if mouse_check_button_pressed(mb_left){
	if (state == states.play){
		dealCard(true,true);
		gameState("player");
	}
	else if (state == states.win){
		startGame(false);
	}
	else if (state == states.lose){
		startGame(false);
	}
	else if (state == states.tie){
		startGame(false);
	}
}
else if mouse_check_button_pressed(mb_right){
	if (state != states.play) exit;
	gameState("dealer");
}
else if keyboard_check_pressed(vk_space){
	if (state == states.bet){
		chips -= tempbet;
		bet += tempbet - 1;
		tempbet = 1;
		dealCard(true,true);
		dealCard(true,true);
		dealCard(false,true);
		gameState("player");
	}
	else if (state == states.play && ds_grid_height(hand) < 3){
		if ((bet * 2) > chips){
			show_debug_message("Not enough chips to double down!");
			exit;
		}
		chips -= bet;
		bet *= 2;
		doubledown = true;
		show_debug_message("Double down!");
		dealCard(true,true);
		gameState("dealer");
	}
}
else if mouse_check_button(mb_left){
	if (state != states.bet || alarm[0] > 0) exit;
	if ((chips - tempbet) > 0){
		tempbet ++;
		alarm[0] = 4; //buffer
	}
}
else if mouse_check_button(mb_right){
	if (state != states.bet || alarm[0] > 0) exit;
	if (tempbet > 1){
		tempbet --;
		alarm[0] = 4; //buffer
	}
}