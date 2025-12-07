/*
Topic: TextAdventure In Prolog
By: Sachin Kumar Jha.
*/

:- dynamic here/1, unlocked/2, locked/2, at/2, have/1, player/1.

/* Starting location */
here('The Crypt').

/* Rooms */
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

/* Items and their initial locations */
at('Torch','The Crypt').
at('Key Map','The Observatory').
at('Apple','The Kitchen').
at('Knife','The Kitchen').
at('Chemical','The Laboratory').
at('Shield','The Armory').
at('Gun','The Armory').
at('Teleport', 'The Temple').
at('The Armory Key','The Library').
at('The Treasury Key','The Ballroom').
at('Route Map', 'The Throne Room').

/* Door states */
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

/* Keys required for locked doors */
door_key('The Torture Chamber','The Armory','The Armory Key').
door_key('The Secret Garden','The Treasury','The Treasury Key').

requires_key(A, B, Key) :- door_key(A, B, Key).
requires_key(A, B, Key) :- door_key(B, A, Key).

/* Food facts */
edible('Apple').
inedible('Chemical').

/* Connections and door helpers */
path(A, B, unlocked) :- unlocked(A, B).
path(A, B, unlocked) :- unlocked(B, A).
path(A, B, locked)   :- locked(A, B).
path(A, B, locked)   :- locked(B, A).

connected(A, B) :- path(A, B, _).

locked_between(A, B) :- path(A, B, locked).

retract_locked(A, B) :-
  ( locked(A, B) -> retract(locked(A, B))
  ; locked(B, A) -> retract(locked(B, A))
  ).

unlock_path(A, B, Key) :-
  retract_locked(A, B),
  assertz(unlocked(A, B)),
  retract(have(Key)),
  format('You use "~w"; the door to ~w is now unlocked.', [Key, B]), nl, nl.

/* Movement */
forward(Place) :-
  possible_to_go(Place),
  key_required(Place),
  move(Place),
  status,
  look.

go(Place) :- forward(Place).

possible_to_go(Place) :-
  here(Place),
  write('You are already there.'), nl,
  fail.

possible_to_go(Place) :-
  here(Current),
  connected(Current, Place), !.

possible_to_go(Place) :-
  room(Place),
  write('Not possible from here.'), nl,
  fail.

possible_to_go(_) :-
  write('Place does not exist.'), nl,
  fail.

key_required(Place) :-
  here(Current),
  requires_key(Current, Place, Key),
  locked_between(Current, Place),
  ( have(Key) -> unlock_path(Current, Place, Key)
  ; write('The door is locked!'), nl, fail
  ),
  !.

key_required(_).

move(Place) :-
  retract(here(_)),
  assertz(here(Place)).

/* Status */
status :-
  here('The Treasury'),
  write('Congratulations, you have escaped the game. Please enter the halt. command.'), nl, !.

status :-
  player('Dead'),
  write('Defeat, you died'), nl,
  fail.

status.

/* World description */
look :-
  here(Place),
  format('Location : ~w', [Place]), nl,
  description(Place, Desc),
  write(Desc), nl,
  write('Items:'), nl,
  print_items(Place),
  write('Doors:'), nl,
  print_doors(Place).

print_items(Place) :-
  findall(Item, at(Item, Place), Items),
  ( Items = [] -> write('  (none)'), nl
  ; forall(member(Item, Items), (tab(2), write(Item), nl))
  ).

print_doors(Place) :-
  ( setof(exit(Next, Status), path(Place, Next, Status), Exits) ->
      forall(member(exit(Next, Status), Exits),
             (tab(2), format('~w (~w)', [Next, Status]), nl))
  ; write('  (none)'), nl
  ).

/* Inventory handling */
bag :-
  findall(Item, have(Item), Items),
  write('Your bag contains:'), nl,
  ( Items = [] -> write('  (empty)'), nl
  ; forall(member(Item, Items), (tab(2), write(Item), nl))
  ).

take(Item) :-
  here(Place),
  at(Item, Place),
  !,
  retract(at(Item, Place)),
  assertz(have(Item)),
  format('~w added to inventory.', [Item]), nl.

take(Item) :-
  format('There is no ~w at this location.', [Item]), nl,
  fail.

drop(Item) :-
  have(Item),
  !,
  retract(have(Item)),
  here(Place),
  assertz(at(Item, Place)),
  format('~w removed from inventory.', [Item]), nl.

drop(Item) :-
  format('You do not have ~w in inventory.', [Item]), nl,
  fail.

/* Teleport */
magic :-
  have('Teleport'),
  retract(here(_)),
  retract(have('Teleport')),
  assertz(at('Teleport', 'The Temple')),
  assertz(here('The Temple')),
  write('You have been teleported back to The Temple.'), nl,
  look.

magic :-
  write('You do not have the teleport in inventory.').

/* Instructions */
instruction :-
  nl,
  write('Enter command using standard syntax.'), nl,
  write('Available commands are:'), nl,
  write('start.               -- to start the game.'), nl,
  write('look.                -- to look around the room.'), nl,
  write('bag.                 -- to check your bag items.'), nl,
  write("take('Item').        -- to store items in your bag."), nl,
  write("drop('Item').        -- to drop items from your bag."), nl,
  write("go('Room').          -- move to an adjacent room (alias: forward/1)."), nl,
  write('halt.                -- to exit the game.'), nl,
  write('magic.               -- to teleport if you have the Teleport.'), nl,
  write("edible('Food').      -- check whether food is edible."), nl,
  write("inedible('Food').    -- check whether food is edible."), nl,
  nl.

start :-
  instruction,
  look.

/* Room descriptions */
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

