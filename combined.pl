item_on_screen(sapling, 102432).
diggable(sapling).
workable(sapling).
quantity(102432, 1).
item_on_screen(evergreen, 107114).
quantity(107114, 1).
workable(evergreen).
choppable(evergreen).
item_on_screen(robin, 109618).
quantity(109618, 1).
cookable(robin).
item_on_screen(grass, 101408).
diggable(grass).
workable(grass).
quantity(101408, 1).
pickable(grass).
item_on_screen(evergreen, 107126).
quantity(107126, 1).
item_on_screen(robin, 109619).
quantity(109619, 1).
item_on_screen(grass, 101417).
quantity(101417, 1).
item_on_screen(grass, 101387).
quantity(101387, 1).
item_on_screen(flint, 108068).
quantity(108068, 1).
collectable(flint).
item_on_screen(sapling, 102419).
quantity(102419, 1).
pickable(sapling).
item_on_screen(evergreen, 107102).
quantity(107102, 1).
item_on_screen(flower, 107834).
quantity(107834, 1).
pickable(flower).
item_on_screen(sapling, 102409).
quantity(102409, 1).
item_on_screen(sapling, 102413).
quantity(102413, 1).
item_on_screen(grass, 101396).
quantity(101396, 1).
item_on_screen(grass, 101394).
quantity(101394, 1).
item_on_screen(evergreen, 107091).
quantity(107091, 1).
item_on_screen(grass, 101412).
quantity(101412, 1).
item_on_screen(evergreen, 107097).
quantity(107097, 1).
item_on_screen(evergreen, 107107).
quantity(107107, 1).
item_on_screen(evergreen, 107132).
quantity(107132, 1).
item_on_screen(evergreen, 107133).
quantity(107133, 1).
item_on_screen(evergreen, 107095).
quantity(107095, 1).
slot_in_inventory(twigs, 109513).
fuel(twigs).
collectable(twigs).
slot_in_inventory(cutgrass, 109611).
fuel(cutgrass).
collectable(cutgrass).
item_in_inventory(twigs, 3).
item_in_inventory(cutgrass, 1).
sanity(high).
hunger(high).
health(high).
time(day, mid).


good_pick(planted_carrot).
good_pick(carrot).
good_pick(axe).
good_pick(twigs).
good_pick(flint).
good_pick(log).
good_pick(cutgrass).
good_pick(berrybush).
good_pick(berries).
good_pick(sapling).


torch_ingredients(A):- item_in_inventory(cutgrass, X), item_in_inventory(twigs, X), X.>=.2.

axe_ingredients(A):- item_in_inventory(flint, X), item_in_inventory(twigs, X), X.>=.1.

campfire_ingredients(A):- item_in_inventory(log, X), X.>=.2, item_in_inventory(cutgrass, Y), Y.>=.3.

garland_ingredients(A):- item_in_inventory(petals, X), X.>=.12.

% action(short_description, functionToUseInLua, FunctionArguments)
action(equip_torch_night_hostile, equip, GUID) :- time(night, T), not equipment(torch), item_in_inventory(torch, X), hostile(E), slot_in_inventory(torch, GUID).
action(run_away_from_enemy, run_away, GUID) :- hostile(GUID).
action(eat_food_low, eat_food, GUID) :- hunger(low), item_in_inventory(X, N), edible(X), slot_in_inventory(X, GUID).
action(pick_flower, pick_entity, GUID) :- -time(night, T), sanity(low), item_on_screen(flower, GUID).
action(wander_flower, wander, nil) :- -time(night, T), sanity(low).
action(walk_to_fueled_campfire, walk_to_entity, GUID) :- time(night, T), item_on_screen(X, GUID), fueled(GUID), isinlight(plr), X=campfire, X=firepit.
action(build_campfire, build, campfire) :- time(dusk, end), campfire_ingredients(X), -item_on_screen(campfire, X).
action(equip_torch_night_no_campfire, equip, GUID) :- time(night, T), item_in_inventory(torch, X), not equipment(torch), slot_in_inventory(torch, GUID).
action(build_torch_night, build, torch) :- time(night), torch_ingredients(X), not item_in_inventory(torch, X).
action(cook_food, cook, GUID) :- cookable(GUID), slot_in_inventory(X, GUID), time(night).
action(build_axe, build, axe) :- axe_ingredients(X), not equipment(axe), not item_in_inventory(axe, N).
action(build_torch, build, torch) :- torch_ingredients(X), not equipment(torch), not item_in_inventory(torch, N).
action(equip_axe, equip, axe) :- not equipment(axe), item_in_inventory(axe, N), -time(night, T).
action(pick_log, pick_entity, GUID) :- item_on_screen(log, GUID).
action(chop_tree, chop_tree, GUID) :- item_on_screen(X, GUID), choppable(X), equipment(axe).
action(pick_anything, pick_entity, GUID) :- item_on_screen(X, GUID), good_pick(X).
action(wander, wander, nil) :- -time(night, T).

% ?- action(DESC, FUNC, ARGS).

?- action(DESC, FUNC, ARGS).