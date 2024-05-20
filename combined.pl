item_on_screen(sapling, 101789).
diggable(sapling).
workable(sapling).
quantity(101789, 1).
item_on_screen(beehive, 100419).
quantity(100419, 1).
item_on_screen(grass, 101136).
diggable(grass).
workable(grass).
quantity(101136, 1).
pickable(grass).
item_on_screen(butterfly, 106453).
quantity(106453, 1).
workable(butterfly).
item_on_screen(grass, 101080).
quantity(101080, 1).
item_on_screen(evergreen, 103457).
quantity(103457, 1).
workable(evergreen).
choppable(evergreen).
item_on_screen(robin, 106500).
quantity(106500, 1).
cookable(robin).
item_on_screen(bee, 106503).
quantity(106503, 1).
workable(bee).
item_on_screen(sapling, 101790).
quantity(101790, 1).
pickable(sapling).
item_on_screen(crow, 106493).
quantity(106493, 1).
cookable(crow).
item_on_screen(seeds, 106502).
edible(seeds).
quantity(106502, 1).
collectable(seeds).
cookable(seeds).
item_on_screen(evergreen, 103484).
quantity(103484, 1).
item_on_screen(evergreen, 103474).
quantity(103474, 1).
item_on_screen(grass, 101134).
quantity(101134, 1).
item_on_screen(rock1, 102594).
quantity(102594, 1).
workable(rock1).
mineable(rock1).
item_on_screen(butterfly, 106458).
quantity(106458, 1).
item_on_screen(evergreen, 103473).
quantity(103473, 1).
item_on_screen(grass, 101087).
quantity(101087, 1).
slot_in_inventory(flint, 105458).
collectable(flint).
slot_in_inventory(twigs, 106439).
fuel(twigs).
collectable(twigs).
item_in_inventory(flint, 1).
item_in_inventory(twigs, 1).
sanity(high).
hunger(high).
health(high).
time(day, end).


good_pick(planted_carrot).
good_pick(carrot).
good_pick(axe).
good_pick(twigs).
good_pick(flint).
good_pick(log).
good_pick(cutgrass).
good_pick(berrybush).
good_pick(berries).


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
action(pick_log, pickup_entity, GUID) :- item_on_screen(log, GUID).
action(chop_tree, chop_tree, GUID) :- item_on_screen(X, GUID), choppable(X), equipment(axe).
action(pick_anything, pickup_entity, GUID) :- item_on_screen(X, GUID), good_pick(X).

% ?- action(DESC, FUNC, ARGS).

?- action(DESC, FUNC, ARGS).