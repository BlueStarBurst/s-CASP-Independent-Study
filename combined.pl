item_on_screen(grass, 101191).
diggable(grass, 101191).
workable(grass, 101191).
quantity(101191, 1).
item_on_screen(rabbithole, 100253).
quantity(100253, 1).
diggable(rabbithole, 100253).
workable(rabbithole, 100253).
item_on_screen(rabbithole, 100257).
quantity(100257, 1).
diggable(rabbithole, 100257).
workable(rabbithole, 100257).
item_on_screen(rabbithole, 100258).
quantity(100258, 1).
diggable(rabbithole, 100258).
workable(rabbithole, 100258).
item_on_screen(grass, 101151).
diggable(grass, 101151).
workable(grass, 101151).
quantity(101151, 1).
item_on_screen(robin, 106538).
quantity(106538, 1).
cookable(robin, 106538).
item_on_screen(rabbithole, 100260).
quantity(100260, 1).
diggable(rabbithole, 100260).
workable(rabbithole, 100260).
item_on_screen(grass, 101199).
diggable(grass, 101199).
workable(grass, 101199).
quantity(101199, 1).
item_on_screen(grass, 101159).
diggable(grass, 101159).
workable(grass, 101159).
quantity(101159, 1).
item_on_screen(grass, 101135).
diggable(grass, 101135).
workable(grass, 101135).
quantity(101135, 1).
item_on_screen(rabbithole, 100259).
quantity(100259, 1).
diggable(rabbithole, 100259).
workable(rabbithole, 100259).
item_on_screen(grass, 101239).
diggable(grass, 101239).
workable(grass, 101239).
quantity(101239, 1).
item_on_screen(rabbithole, 100254).
quantity(100254, 1).
diggable(rabbithole, 100254).
workable(rabbithole, 100254).
item_on_screen(evergreen, 103408).
quantity(103408, 1).
workable(evergreen, 103408).
choppable(evergreen, 103408).
slot_in_inventory(seeds, 100025).
edible(seeds).
collectable(seeds).
cookable(seeds).
slot_in_inventory(twigs, 100026).
fuel(twigs).
collectable(twigs).
slot_in_inventory(flint, 100027).
collectable(flint).
slot_in_inventory(carrot, 100028).
edible(carrot).
collectable(carrot).
cookable(carrot).
slot_in_inventory(petals, 100029).
fuel(petals).
collectable(petals).
edible(petals).
slot_in_inventory(cutgrass, 100030).
fuel(cutgrass).
collectable(cutgrass).
slot_in_inventory(berries, 100031).
edible(berries).
collectable(berries).
cookable(berries).
slot_in_inventory(cutgrass, 106564).
item_in_inventory(seeds, 4).
item_in_inventory(twigs, 18).
item_in_inventory(flint, 2).
item_in_inventory(carrot, 5).
item_in_inventory(petals, 2).
item_in_inventory(cutgrass, 41).
item_in_inventory(berries, 2).
sanity(high).
hunger(half).
health(low).
time(night, early).


good_pick(planted_carrot).
good_pick(carrot).
good_pick(axe).
good_pickup(twigs).
good_pickup(flint).
good_pickup(log).
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
action(chop_tree, chop_tree, GUID) :- item_on_screen(X, GUID), choppable(X, GUID), equipment(axe).
action(pick_anything, pick_entity, GUID) :- item_on_screen(X, GUID), pickable(X, GUID).
action(pick_anything, pickup_entity, GUID) :- item_on_screen(X, GUID), collectable(X, GUID).



% ?- action(DESC, FUNC, ARGS).

?- action(DESC, FUNC, ARGS).