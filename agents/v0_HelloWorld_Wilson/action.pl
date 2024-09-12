
good_item(carrot).
good_item(axe).
good_item(flint).
good_item(twigs).
good_item(log).
good_item(cutgrass).
good_item(berries).
good_item(sapling).

item_present(X) :- item_in_inventory(X,N), N .>. 0.

good_amount(X, MAX) :- not item_present(X).
good_amount(X, MAX) :- item_in_inventory(X, N), N .>. 0, N .<. MAX.

torch_ingredients:- item_in_inventory(cutgrass, X), X.>=.2, item_in_inventory(twigs, Y), Y.>=.2.

axe_ingredients:- item_in_inventory(flint, X), X.>=.1, item_in_inventory(twigs, Y), Y.>=.1.

campfire_ingredients:- item_in_inventory(log, X), X.>=.2, item_in_inventory(cutgrass, Y), Y.>=.3.

garland_ingredients:- item_in_inventory(petals, X), X.>=.12.

time(A) :- time(A, T).


campfire_exists :- item_on_screen(campfire, X), guid(X).
torch_exists :- slot_in_inventory(torch, X), guid(X).

hunger(half) :- hunger(low).
sanity(half) :- sanity(low).

% action(short_description, functionToUseInLua, FunctionArguments)
action(equip_torch_night_hostile, equip, GUID) :- time(night), hostile(E), not equipment(torch), item_in_inventory(torch, X),  slot_in_inventory(torch, GUID).
action(run_away_from_enemy, run_away, GUID) :- hostile(GUID).
action(eat_food_low, eat_food, GUID) :- hunger(half), item_in_inventory(X, N), edible(X), slot_in_inventory(X, GUID).
action(equip_torch_night_no_campfire, equip, GUID) :- time(night), not campfire_exists, item_in_inventory(torch, X), not equipment(torch), slot_in_inventory(torch, GUID).
action(unequip_torch_day, unequip, GUID) :- time(day), equipment(torch), equipment_guid(torch, GUID).

action(ended_emergency_action, nil, nil).

action(pick_flower, pick_entity, GUID) :- not time(night), sanity(half), item_on_screen(flower, GUID).
% action(no_repeat_wander_flower, wander, nil) :- not time(night), sanity(half).

action(cook_food, cook, GUID) :- cookable(X), slot_in_inventory(X, GUID), time(night), item_on_screen(campfire, Y).
action(no_repeat_refuel_campfire, add_fuel, GUID) :- time(night), item_in_inventory(log, N), N.>.0, item_on_screen(campfire, GUID), guid(GUID), fueled(GUID), fueledpercent(GUID, X), X.<.0.3.
action(no_repeat_walk_to_fueled_campfire, stay_near, GUID) :- time(night), fueled(GUID), item_on_screen(campfire, GUID), guid(GUID), distance(GUID, X), X.>.1.
action(no_repeat_walk_to_fueled_campfire, stay_near, GUID) :- time(dusk, end), fueled(GUID), item_on_screen(campfire, GUID), guid(GUID), distance(GUID, X), X.>.15.
action(build_campfire_dark, build, campfire) :- time(night), campfire_ingredients, not campfire_exists.
%action(build_campfire_dusk, build, campfire) :- time(dusk, end), campfire_ingredients, not campfire_exists.

action(build_torch_night, build, torch) :- time(night), torch_ingredients, not torch_exists.
action(build_axe, build, axe) :- axe_ingredients, not equipment(axe), good_amount(axe, 1).
action(build_torch, build, torch) :- torch_ingredients, not torch_exists.
action(equip_axe, equip, axe) :- not equipment(axe), item_in_inventory(axe, N), not time(night).
action(collect_log, collect_entity, GUID) :- item_on_screen(log, GUID).
action(chop_tree, chop_tree, GUID) :- choppable(GUID), equipment(axe), good_amount(log, 8).
action(collect_anything, collect_entity, GUID) :- item_on_screen(X, GUID), good_amount(X, 8), good_item(X), collectable(GUID).
action(pick_anything, pick_entity, GUID) :- item_on_screen(X, GUID), good_amount(X, 8), good_item(X), pickable(GUID).
action(no_repeat_wander, wander, nil) :- not time(night).
action(do_nothing, nil, nil).


