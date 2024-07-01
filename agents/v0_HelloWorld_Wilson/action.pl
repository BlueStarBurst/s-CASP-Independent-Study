
good_item(carrot).
good_item(axe).
good_item(flint).
good_item(twigs).
good_item(log).
good_item(cutgrass).
good_item(berries).
good_item(sapling).

collectable(GUID) :- pickable(GUID).
good_pick(GUID) :- collectable(GUID), item_on_screen(X, GUID), good_item(X), -item_in_inventory(X, N).
good_pick(GUID) :- collectable(GUID), item_on_screen(X, GUID), good_item(X), item_in_inventory(X, N), N.<.8.

torch_ingredients:- item_in_inventory(cutgrass, X), X.>=.2, item_in_inventory(twigs, Y), Y.>=.2.

axe_ingredients:- item_in_inventory(flint, X), X.>=.1, item_in_inventory(twigs, Y), Y.>=.1.

campfire_ingredients:- item_in_inventory(log, X), X.>=.2, item_in_inventory(cutgrass, Y), Y.>=.3.

garland_ingredients:- item_in_inventory(petals, X), X.>=.12.

only_time(A) :- time(A, T), T=early, T=mid, T=end.


% action(short_description, functionToUseInLua, FunctionArguments)
action(equip_torch_night_hostile, equip, GUID) :- only_time(night), not equipment(torch), item_in_inventory(torch, X), hostile(E), slot_in_inventory(torch, GUID).
action(run_away_from_enemy, run_away, GUID) :- hostile(GUID).
action(eat_food_low, eat_food, GUID) :- hunger(low), item_in_inventory(X, N), edible(X), slot_in_inventory(X, GUID).
action(pick_flower, pick_entity, GUID) :- -only_time(night), sanity(low), item_on_screen(flower, GUID).
action(wander_flower, wander, nil) :- -only_time(night), sanity(low).
action(walk_to_fueled_campfire, walk_to_entity, GUID) :- only_time(night), item_on_screen(X, GUID), fueled(GUID), isinlight(plr), X=campfire, X=firepit.
action(build_campfire, build, campfire) :- time(dusk, end), campfire_ingredients(X), -item_on_screen(campfire, X).
action(equip_torch_night_no_campfire, equip, GUID) :- only_time(night), item_in_inventory(torch, X), not equipment(torch), slot_in_inventory(torch, GUID).
action(build_torch_night, build, torch) :- time(night), torch_ingredients(X), not item_in_inventory(torch, X).
action(cook_food, cook, GUID) :- cookable(GUID), slot_in_inventory(X, GUID), time(night).
action(build_axe, build, axe) :- axe_ingredients, not equipment(axe), not item_in_inventory(axe, N).
action(build_torch, build, torch) :- torch_ingredients(X), not equipment(torch), not item_in_inventory(torch, N).
action(equip_axe, equip, axe) :- not equipment(axe), item_in_inventory(axe, N), -only_time(night).
action(pick_log, pick_entity, GUID) :- item_on_screen(log, GUID).
action(chop_tree, chop_tree, GUID) :- item_on_screen(X, GUID), choppable(X), equipment(axe).
action(pick_anything, pick_entity, GUID) :- item_on_screen(X, GUID), good_pick(GUID).
action(wander, wander, nil) :- not only_time(night).

?- good_pick(GUID) .
