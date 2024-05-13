eat_good_food(A):- hunger(low), good_food(X), item(X, Y), Y.>=.1.

equip_torch(A):- item(torch, X).
build_torch(A):- item(cutgrass, X), item(twig, X), X.>=.2.

equip_axe(A):- item(axe, X).
build_axe(A):- item(flint, X), item(twig, X), X.>=.1.

build_campfire(A):- item(log, X), X.>=.2, item(cutgrass, Y), Y.>=.3.

build_garland(A):- item(petals, X), X.>=.12.
equip_garland(A):- item(garland, X).

%action(Action Name, Priority)
action(run_away, 1) :- hostile(X).
action(wander_flower, 2) :- -time(night), sanity(half).
action(eat_flower, 3) :- sanity(low).

?- action(A, N).