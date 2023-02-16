/* 
Topic: A Text Adventure Game
By: Sachin Kumar Jha.
Motivation: Sliacky, Jan
*/

:- dynamic here/1, unlocked/2, locked/2, at/2, have/1, player/1.

/* This defines my current location. */

here('The Crypt').

/* These facts shows the rooms, based on the game map. */

room('The Crypt').
room('The Observatory').
room('The Temple').
room('The Secret Garden').
room('The Torture Chamber').
room('The Treasury').
room('The Library').
room('The Laboratory').
room('The Throne Room').
room('The Armory').
room('The Dungeon').
room('The Ballroom').
room('The Kitchen').

/* These facts tells where the various object located in the game. */

at('Torch','The Crypt').
at('Key Map','The Observatory').
at('Apple','The Kitchen').
at('Knife','Kitchen').
at('Chemical','The Laboratory').
at('Shield','The Armory').
at('Gun','The Armory').
at('Teleport', 'The Temple').
at('The Armory Key','The Library').
at('The Treasury Key','The Ballroom').
at('Route Map', 'The Throne Room').

/* These facts describe how the rooms are connected. */

unlocked('The Crypt','The Temple').
unlocked('The Crypt','The Torture Chamber').
unlocked('The Temple','The Secret Garden').
unlocked('The Secret Garden','The Observatory').
unlocked('The Observatory','The Library').
unlocked('The Laboratory','The Throne Room').
unlocked('The Throne Room','The Dungeon').
unlocked('The Dungeon','The Kitchen').
unlocked('The Armory','The Ballroom').
unlocked('The Ballroom','The Kitchen').
unlocked('The Library','The Laboratory').

locked('The Torture Chamber','The Armory').
locked('The Secret Garden','The Treasury').

/* This rule connect door from both side. */

connect(X, Y) :- unlocked(X, Y).
connect(X, Y) :- unlocked(Y, X).

connect(X, Y) :- locked(X, Y).
connect(X, Y) :- locked(Y, X).

/* This facts tells food are edible or inedible. */

edible('Apple').
inedible('Chemical').

/* This rule tells about name of the items available in current location, and number of possilbe rooms to move forward. */

things(Place) :-
	at(X, Place), tab(2), write(X), nl, fail.
        things(_).

options(Place) :-
	connect(Place, X), tab(2), write(X), nl, fail.
	options(_).



/* This rule tells about the present location. */

look :-
  here(Place),
  write('Location : '), write(Place), nl,
  description(Place, Y), write(Y), nl,
  write('Items:'), nl,
  things(Place),
  write('Door:'), nl,
  options(Place).

/* This rule tells the instruction of the game. */

instruction :-
	nl,
	write('Enter command using standard syntax.'), nl,
	write('Available commands are:'), nl,
	write('start.          -- to start the game.'), nl,
	write('look.           -- to look around the room,'), nl,
	write('bag.            -- to check your bag items.'), nl,
	write("take('item').   -- to store items in your bag."), nl,
	write("drop('item').   -- to drop items from your bag."), nl,
	write('halt.	       -- to exit the game.'), nl,
	write('magic.	       -- to teleport.'), nl,
	write('inedible.       -- tells food is edible or inedible.'), nl,
	write('edible.	       -- tells food is edible or inedible.'), nl,
	write('forward.	       -- to move in different room.'), nl,
	nl,
	!.

/* This rule helps in moving. */

'The Crypt' :-
	forward('The Crypt').
'The Temple' :-
	forward('The Temple').
'The Secret Garden' :-
	forward('The Secret Garden').
'The Treasury' :-
	forward('The Treasury').
'The Observatory' :-
	forward('The Observatory').
'The Library' :-
	forward('The Library').
'The Laboratory' :-
	forward('The Laboratory').
'The Throne Room' :-
	forward('The Throne Room').
'The Dungeon' :-
	forward('The Dungeon').
'The Kitchen' :-
	forward('The Kitchen').
'The Ballroom' :-
	forward('The Ballroom').
'The Armory' :-
	forward('The Armory').
'The Torture Room' :-
	forward('The Torture Room').

/* This rules tells user, can or can't move forward . */

forward(Place):-
  possible_to_go(Place),
  key_required(Place),
  move(Place),
  status(),
  look.

/* This rule check the possiblity for moving.*/

possible_to_go(Place):-
  here(X),
  connect(X, Place), !.

possible_to_go(Place):-
	here(Place),
	write('You are already there.'), nl, !.

possible_to_go(Place) :-
	room(Place),!,
	write('Not possible from here.'), nl,
	fail.

possible_to_go(_) :-
	write('Place does not exist.'), nl,
	fail.

/* This rule check user have key for this room or not. */

key_required(Place) :-
	locked(Place, 'The Treasury'),
	have('The Treasury Key'),
	retract(locked(Place, 'The Treasury')),
	asserta(unlocked(Place, 'The Treasury')),
	retract(have('The Treasury Key')),
	write('You have the "The Treasury Key" in inventory, "The Treasury" Door Unlocked!'),nl,nl,!.

key_required(Place) :-
	locked(Place, 'The Armory'),
	have('The Armory Key'),
	retract(locked(Place, 'The Armory')),
	asserta(unlocked(Place, 'The Armory')),
	retract(have('The Armory Key')),
	write('You have "The Armoury Keys" in inventory, "The Armory" Door Unlocked!'),nl,nl,!.

key_required(Place) :-
	locked(_, Place),
	write('The Door is Locked!'),nl,
	!, fail.

key_required(_).

/* This rule help in moving from one room to another. */

move(Place):-
  retract(here(_)),
  asserta(here(Place)).

/* This rule tells status of the game wheather the user is alive or dead. */

status() :-
	here('The Treasury'),
	write('Congratulation, you have escaped the game. Please enter the halt. command.'), nl.

status() :-
	player('Dead'),
	write('Defeat, you died'), nl,
	false.
status() :-
	true.

/* This rule help in taking items. */

take(X) :-
	can_take(X),!,
	take_object(X),!,
	true.

can_take(Thing) :-
	here(Place),
	at(Thing, Place),!.

can_take(Thing) :-
	write('There is no '), write(Thing), write(' at this location.'),
	nl.

take_object(Thing) :-
	here(X),
	retract(at(Thing,X)),
	asserta(have(Thing)),
	write(Thing), write(' added to Inventory.'),!,
	nl.


/* This rule help in dropping items. */

drop(X) :-
	list(X),
	drop_object(X),
	true.

list(X) :-
	have(X),!.

list(X) :-
	write('You don not have '), write(X), write(' in inventory.'), nl,
	fail.

drop_object(X) :-
	here(Place),
	retract(have(X)),
	asserta(at(X, Place)),
	write(X), write(' removed from Inventory.'), nl.


/* This rule helps in storing the items. */

bag :-
	write("Your bag conatians: "),
	nl, (have(X), tab(2), write(X), nl,
	fail).

start :-
	instruction,
	look.

/* These facts describe the various rooms. */

description('The Crypt', 'A dark and damp room filled with cobwebs and ancient tombs, skeletons, old relics, dusty artifacts, moldy scrolls, crumbling statues, there is "The Temple" door toward West side and "The torture Chamber" door toward East side. We need to look for torch to continue.').
description('The Observatory', 'A room with a large telescope and other scientific instruments used to study the stars and planets and there is maps which shows the location of the keys and there is "The Library" door toward South side.').
description('The Temple', 'A grand room with intricate carvings and statues of gods and goddesses, incense burners, altar candles, holy water, a censer, a relic or holy objectc and there is "The Secret Garden" door toward South side.').
description('The Secret Garden','A hidden room filled with lush plants and a small pond, a bench, a sundial, there is "The Treasury" locked door toward West side, you need "The Treasury Key" for entry and "The Observatory" door toward South side.').
description('The Torture Chamber', 'A gruesome room with various instruments of torture on display and there is "The Armory" locked door toward South side, you need "The Armory Key" for entry, you should check your Inventory for key.').
description('The Treasury', 'A room filled with gold, jewels, and Congratulations, you have completed the "Adventure Game"').
description('The Library', 'A room filled with rows and rows of books on every subject imaginable and according to the "Key Map" there should be "The Armory Key" and there is "The Laboratory" door toward East side.').
description('The Laboratory', 'A room filled with scientific equipment and experiments in progress and especially stay away from the chemical and there is "The Throne Room" door toward East side.').
description('The Throne Room', 'A grand room with a throne at the end, where the ruler of the kingdom holds court and there is "Route Map" which shows the direction of the destination and there is "The Dungeon" door toward East side.').
description('The Armory', 'A room filled with weapons and armor for the use of the kingdom soldiers and there is "The Ballroom" door toward East Side.').
description('The Dungeon', 'A dark and dank room used to hold prisoners and according to the "Key Map" there should be "The Treasury Key", we need torch for finding the key In dark room and there is "The Kitchen" door toward North side.').
description('The Ballroom', 'A grand room used for dancing and other social events and there is "The Kitchen" door toward South side.').
description('The Kitchen', 'A room filled with cooking equipment and ingredients for preparing meals, you can eat fruits.').

/* This rule helps in teleport around the map. */

magic :-
	have('Teleport'),
	retract(here(_)),
	retract(have('Teleport')),
	asserta(at('Teleport', 'The Temple')),
	asserta(here('The Temple')),
	write('You have been teleported back to The Temple.'), nl,
	look.

magic :-
	write('You do not have the teleport in inventory.').


