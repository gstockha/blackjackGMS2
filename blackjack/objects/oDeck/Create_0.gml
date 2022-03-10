deck = ds_grid_create(3,52); //value, suit, sprite
hand = ds_grid_create(4,0); //value, suit, sprite, faceup
dealerHand = ds_grid_create(4,0);
total = 0;
dealerTotal = 0;
state = states.play;
enum states{
	play,
	win,
	lose
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
		ds_grid_set(hand,0,height,ds_grid_get(deck,0,ds_grid_height(deck)-1));
		ds_grid_set(hand,1,height,ds_grid_get(deck,1,ds_grid_height(deck)-1));
		ds_grid_set(hand,2,height,ds_grid_get(deck,2,ds_grid_height(deck)-1));
		ds_grid_set(hand,3,height,_faceUp); //face up or face down
		//calculate player's score
		for (var i = 0; i < ds_grid_height(hand); i++){
			card = ds_grid_get(hand,0,i);
			if (card != "A" || card != "J" || card != "Q" || card != "K") tempTotal += real(card);
			else if (card != "A") tempTotal += 10; //if card is a jack, queen, or king
			else if ((tempTotal + 11) < 21) tempTotal += 11; //high ace
			else tempTotal += 1; //low ace
		}
		total = tempTotal
	}
	else{ //dealer
		dealerTotal = 0; //unforunately can't pass ds_grids as arguments so have to copy function
		var height = ds_grid_height(dealerHand); //add top card to dealer's hand
		ds_grid_set(dealerHand,0,height,ds_grid_get(deck,0,ds_grid_height(deck)-1));
		ds_grid_set(dealerHand,1,height,ds_grid_get(deck,1,ds_grid_height(deck)-1));
		ds_grid_set(dealerHand,2,height,ds_grid_get(deck,2,ds_grid_height(deck)-1));
		ds_grid_set(dealerHand,3,height,_faceUp);
		//calculate dealer's score
		for (var i = 0; i < ds_grid_height(dealerHand); i++){
			card = ds_grid_get(dealerHand,0,i);
			if (card != "A" || card != "J" || card != "Q" || card != "K") tempTotal += real(card);
			else if (card != "A") tempTotal += 10;
			else if ((tempTotal + 11) < 21) tempTotal += 11; //high ace
			else tempTotal += 1; //low ace
		}
		dealerTotal = tempTotal
	}
	ds_grid_resize(deck,3,ds_grid_height(deck)-1); //remove top card
}
function gameState(_state){
	if (_state == "player"){ //player option
		if (total > 21){ //lose
			state = states.lose;
			show_debug_message("Bust! Left click to play again");
		}
		else{
			if (ds_grid_height(hand) > 1) var str = "Your card(s) are ";
			else var str = "Your card is ";
			for (var i = 0; i < ds_grid_height(hand); i++){
				if (i != 0) str += ", ";
				str += ds_grid_get(hand,0,i);
			}
			str += "(" + string(total) + ")";
			show_debug_message(str);
			show_debug_message("The dealer's card is " + ds_grid_get(dealerHand,0,0));
			if (total != 21){
				state = states.play;
				show_debug_message("Left click to hit, Right click to stand");
			}
			else{
				show_debug_message("Blackjack!");
				gameState("dealer");
			}
		}
	}
	else if (_state == "dealer"){ //dealer option
		while (dealerTotal <= total && dealerTotal < 21) dealCard(false, true);
		if (dealerTotal < 22){
			if (dealerTotal != total){
				state = states.lose;
				show_debug_message("You lose! Left click to play again");	
			}
			else{
				state = states.win;
				show_debug_message("You win! Left click to play again");	
			}
		}
	}
}
function startGame(_fresh, _win){
	if (_fresh == false){
		total = 0;
		dealerTotal = 0;
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
	dealCard(true,true);
	dealCard(false,true);
	gameState("player");
}
startGame(true, false);

reswidth = display_get_gui_width();
resheight = display_get_gui_height();