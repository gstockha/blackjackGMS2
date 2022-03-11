draw_set_halign(fa_center);
var bt = (state != states.bet) ? bet : tempbet;
var pot = (state != states.bet) ? chips : chips - tempbet;
draw_text(reswidth*.5,resheight*.65,"Bet: " + string(bt));
draw_text(reswidth*.5,resheight*.7,"Pot: " + string(pot));