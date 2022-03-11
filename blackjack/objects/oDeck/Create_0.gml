deck = ds_grid_create(3,52); //value, suit, sprite
hand = ds_grid_create(4,0); //value, suit, sprite, faceup
dealerHand = ds_grid_create(4,0);
total = 0;
dealerTotal = 0;
chips = 100;
bet = 0;
tempbet = 1;
doubledown = false;
alarm[0] = -1;
state = states.play;
enum states{
	play,
	win,
	lose,
	tie,
	bet
}
function shuffleDeck(){
	randomize();
	var tempDeck = ds_grid_create(3,52); //temporary shuffle grid
	var randIndex;
	var height;
	for (var i = 0; i < 52; i++){
		height = ds_grid_height(deck) - 1; //get the updated deck size
		randIndex = irandom(height); //choose from remaining deck
		if (randIndex < 0) randIndex = 0; //don't go below index 0
		ds_grid_set(tempDeck,0,i,ds_grid_get(deck,0,randIndex)); //value
		ds_grid_set(tempDeck,1,i,ds_grid_get(deck,1,randIndex)); //suit
		ds_grid_set(tempDeck,2,i,ds_grid_get(deck,2,randIndex)); //sprite
		for (var c = randIndex; c < height; c++){ //truncate deck by 1
			ds_grid_set(deck,0,c,ds_grid_get(deck,0,c+1));
			ds_grid_set(deck,1,c,ds_grid_get(deck,1,c+1));
			ds_grid_set(deck,2,c,ds_grid_get(deck,2,c+1));
		}
		ds_grid_resize(deck,3,height); //decrease deck size
	}
	ds_grid_destroy(deck); //clear the grid
	deck = ds_grid_create(3,52); //recreate the grid
	for (i = 0; i < 52; i++){ //fill it out with the shuffled grid
		ds_grid_set(deck,0,i,ds_grid_get(tempDeck,0,i)); //value
		ds_grid_set(deck,1,i,ds_grid_get(tempDeck,1,i)); //suit
		ds_grid_set(deck,2,i,ds_grid_get(tempDeck,2,i)); //sprite
		//show_debug_message(string(ds_grid_get(deck,0,i)) + " " + string(ds_grid_get(deck,1,i)));
	}
	ds_grid_destroy(tempDeck); //destroy the temporary shuffle deck
}
function dealCard(_toPlayer,_faceUp){
	var tempTotal = 0; //calculate score
	var card;
	if (_toPlayer){ //if dealer deals to player
		total = 0;
		var height = ds_grid_height(hand); //add top card to hand
		ds_grid_resize(hand,4,height+1);
		ds_grid_set(hand,0,height,ds_grid_get(deck,0,ds_grid_height(deck)-1));
		ds_grid_set(hand,1,height,ds_grid_get(deck,1,ds_grid_height(deck)-1));
		ds_grid_set(hand,2,height,ds_grid_get(deck,2,ds_grid_height(deck)-1));
		ds_grid_set(hand,3,height,_faceUp); //face up or face down
		//calculate player's score
		for (var i = 0; i < ds_grid_height(hand); i++){
			card = ds_grid_get(hand,0,i);
			if (card != "A" && card != "J" && card != "Q" && card != "K") tempTotal += real(card);
			else if (card != "A") tempTotal += 10; //if card is a jack, queen, or king
			else if ((tempTotal + 11) < 21) tempTotal += 11; //high ace
			else tempTotal += 1; //low ace
		}
		total = tempTotal
	}
	else{ //dealer
		dealerTotal = 0; //unforunately can't pass ds_grids as arguments so have to copy function
		var height = ds_grid_height(dealerHand); //add top card to dealer's hand
		ds_grid_resize(dealerHand,4,height+1);
		ds_grid_set(dealerHand,0,height,ds_grid_get(deck,0,ds_grid_height(deck)-1));
		ds_grid_set(dealerHand,1,height,ds_grid_get(deck,1,ds_grid_height(deck)-1));
		ds_grid_set(dealerHand,2,height,ds_grid_get(deck,2,ds_grid_height(deck)-1));
		ds_grid_set(dealerHand,3,height,_faceUp);
		//calculate dealer's score
		for (var i = 0; i < ds_grid_height(dealerHand); i++){
			card = ds_grid_get(dealerHand,0,i);
			if (card != "A" && card != "J" && card != "Q" && card != "K") tempTotal += real(card)
			else if (card != "A") tempTotal += 10;
			else if ((tempTotal + 11) < 21) tempTotal += 11; //high ace
			else tempTotal += 1; //low ace
		}
		dealerTotal = tempTotal
	}
	ds_grid_resize(deck,3,ds_grid_height(deck)-1); //remove top card
}
function printHands(){
	var str = "";
	//player's hand
	if (ds_grid_height(hand) > 1) str = "Your cards are ";
	else str = "Your card is ";
	for (var i = 0; i < ds_grid_height(hand); i++){
		if (i != 0) str += ", ";
		str += ds_grid_get(hand,0,i);
		str += ds_grid_get(hand,1,i);
	}
	str += " (" + string(total) + ")";
	show_debug_message(str);
	//dealer's hand
	if (total > 21) exit; //bust, don't print out dealer's hand
	if (ds_grid_height(dealerHand) > 1) str = "The dealer's cards are ";
	else str = "The dealer's card is ";
	for (var i = 0; i < ds_grid_height(dealerHand); i++){
		if (i != 0) str += ", ";
		str += ds_grid_get(dealerHand,0,i);
		str += ds_grid_get(dealerHand,1,i);
	}
	str += " (" + string(dealerTotal) + ")";
	show_debug_message(str);
}
function gameState(_state){
	if (_state == "player"){ //player option
		printHands();
		if (total < 21){
			state = states.play;
			if (ds_grid_height(hand) > 2) show_debug_message("Left click to hit, Right click to stand");
			else show_debug_message("Left click to hit, Right click to stand, Space to double down");
		}
		else if (total == 21){
			show_debug_message("Blackjack!");
			gameState("dealer");
		}
		else{
			state = states.lose;
			show_debug_message("Bust! Left click to play again");	
		}
	}
	else if (_state == "dealer"){ //dealer option
		//while dealerhand is less or equal to playerhand, dealer keeps drawing cards until bust
		while (dealerTotal < total && dealerTotal < 21) dealCard(false, true);
		printHands();
		if (dealerTotal == total){
			state = states.tie;
			show_debug_message("You tied! Left click to play again");
		}
		else if (dealerTotal < 22){ //dealer beats you
			state = states.lose;
			show_debug_message("You lose! Left click to play again");	
		}
		else{ //dealer bust
			state = states.win;
			show_debug_message("The dealer busted! You win! Left click to play again");
		}
	}
	if (state != states.play){
		if (state == states.win) bet *= 2;
		else if (state == states.lose) bet *= -1;
		chips += bet;
		bet = 0;
	}
}
function startGame(_init){
	alarm[0] = 60;
	if (_init == false){
		total = 0;
		dealerTotal = 0;
		doubledown = false;
		ds_grid_destroy(hand);
		ds_grid_destroy(dealerHand);
		hand = ds_grid_create(4,0); //value, suit, sprite, faceup
		dealerHand = ds_grid_create(4,0);
		ds_grid_destroy(deck);
		deck = ds_grid_create(3,52); //value, suit, sprite
		if (chips < 1){
			show_debug_message("You ran out of chips! Restarting game...");
			chips = 100;
		}
	}
	var values = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];
	var suits = ["spades", "diamonds", "clubs", "hearts"];
	var index = 0;
	for (var i = 0; i < 4; i++){
		for (var c = 0; c < 13; c++){
			ds_grid_set(deck,0,index,values[c]);
			ds_grid_set(deck,1,index,suits[i]);
			//add sprite here
			index ++;
		}
	}
	shuffleDeck();
	state = states.bet;
	bet = 1;
	//chips --;
	show_debug_message("Left click to increase bet, right click to reduce bet, and space to finish betting");
}
startGame(true);

reswidth = display_get_gui_width();
resheight = display_get_gui_height();