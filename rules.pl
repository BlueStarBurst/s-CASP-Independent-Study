eat_good_food(A):- hunger(low), good_food(X), item(X, Y).

torch_ingredients(A):- item(cutgrass, X), item(twig, X), X.>=.2.

axe_ingredients(A):- item(flint, X), item(twig, X), X.>=.1.

campfire_ingredients(A):- item(log, X), X.>=.2, item(cutgrass, Y), Y.>=.3.

garland_ingredients(A):- item(petals, X), X.>=.12.

%action(Action Name, Priority)
action(equip_torch_night_hostile, 1) :- time(night), -equipment(torch), item(torch, X).
action(run_away_from_enemy, 2) :- hostile(X).
action(eat_maybe_food, 3) :- hunger(low), item(X, N), not good_food(X).
action(eat_edible_food, 4) :- hunger(low), edible(X), item(X, N).
action(pick_flower, 5) :- -time(night), sanity(low), on_screen(flower, X).
action(wander_flower, 6) :- -time(night), sanity(low).
action(run_to_campfire, 7) :- time(night), on_screen(X, N), fueled(X), X=campfire, X=firepit.
action(fuel_campfire, 8) :- time(night), on_screen(X, N), fueled(X), X=campfire, X=firepit, fuel(Y), item(Y, N), fuel(Y).
action(build_campfire, 9) :- time(night_soon), campfire_ingredients(X), -on_screen(campfire, X).
action(equip_torch_night, 10) :- time(night), item(torch, X), -equipment(torch).
action(build_torch_night, 11) :- time(night), torch_ingredients(X), -on_screen(campfire, X).
action(cook_food, 12) :- cookable(X), item(X, N), time(night).
action(pick_anything, 13) :- on_screen(X, N), good_pick(X).
action(build_axe, 14) :- axe_ingredients(X), -equipment(axe), -item(axe, N).
action(build_torch, 15) :- torch_ingredients(X), -equipment(torch), -item(torch, N).
action(equip_axe, 16) :- -equipment(axe), item(axe, N).
action(chop_tree, 17) :- on_screen(X, N), choppable(X).

?- action(A, P).