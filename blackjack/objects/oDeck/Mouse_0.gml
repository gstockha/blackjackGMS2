switch(state){
	case states.play:	
		dealCard(true,true);
		gameState("player");
		break;
	case states.win:
		startGame(false,true);
		break;
	case states.lose:
		startGame(false,false);
		break;
}