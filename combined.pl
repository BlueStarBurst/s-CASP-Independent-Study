item_on_screen(twigs, 106323).
diggable(106323).
workable(106323).
distance(106323, 0.52199021021968).
quantity(106323, 1).
item_on_screen(twigs, 106321).
diggable(106321).
workable(106321).
distance(106321, 4.3048237609389).
quantity(106321, 1).
pickable(106321).
item_on_screen(cutgrass, 101947).
diggable(101947).
workable(101947).
distance(101947, 5.2253494305039).
quantity(101947, 1).
pickable(101947).
item_on_screen(cutgrass, 101944).
diggable(101944).
workable(101944).
distance(101944, 6.4185930804513).
quantity(101944, 1).
pickable(101944).
item_on_screen(twigs, 106322).
diggable(106322).
workable(106322).
distance(106322, 8.6647818866152).
quantity(106322, 1).
pickable(106322).
item_on_screen(carrot, 101235).
quantity(101235, 1).
pickable(101235).
distance(101235, 8.7782664110665).
item_on_screen(cutgrass, 101952).
diggable(101952).
workable(101952).
distance(101952, 8.7876567919704).
quantity(101952, 1).
pickable(101952).
item_on_screen(berries, 105738).
diggable(105738).
workable(105738).
distance(105738, 9.1902136730229).
quantity(105738, 1).
pickable(105738).
item_on_screen(flower, 100991).
quantity(100991, 1).
pickable(100991).
distance(100991, 9.4970036201323).
item_on_screen(cutgrass, 101948).
diggable(101948).
workable(101948).
distance(101948, 10.453142573525).
quantity(101948, 1).
pickable(101948).
item_on_screen(twigs, 106319).
diggable(106319).
workable(106319).
distance(106319, 10.558158868246).
quantity(106319, 1).
pickable(106319).
item_on_screen(evergreen, 104788).
workable(104788).
choppable(104788).
distance(104788, 11.509433347791).
quantity(104788, 1).
item_on_screen(evergreen, 104794).
workable(104794).
choppable(104794).
distance(104794, 12.676182714507).
quantity(104794, 1).
item_on_screen(seeds, 107540).
edible(107540).
quantity(107540, 1).
collectable(107540).
cookable(107540).
distance(107540, 13.938589338225).
item_on_screen(robin, 107553).
quantity(107553, 1).
cookable(107553).
distance(107553, 13.938589338225).
item_on_screen(twigs, 106325).
diggable(106325).
workable(106325).
distance(106325, 14.383693896191).
quantity(106325, 1).
item_on_screen(flower, 100990).
quantity(100990, 1).
pickable(100990).
distance(100990, 16.637763287887).
item_on_screen(robin, 107502).
quantity(107502, 1).
cookable(107502).
distance(107502, 17.121639596918).
item_on_screen(cutgrass, 101946).
diggable(101946).
workable(101946).
distance(101946, 17.332518461273).
quantity(101946, 1).
item_on_screen(cutgrass, 101953).
diggable(101953).
workable(101953).
distance(101953, 17.546435358876).
quantity(101953, 1).
item_on_screen(twigs, 106320).
diggable(106320).
workable(106320).
distance(106320, 17.870868511681).
quantity(106320, 1).
item_on_screen(wormhole, 102149).
quantity(102149, 1).
distance(102149, 18.154860766248).
item_on_screen(cutgrass, 101949).
diggable(101949).
workable(101949).
distance(101949, 19.340910584236).
quantity(101949, 1).
pickable(101949).
item_on_screen(cutgrass, 101945).
diggable(101945).
workable(101945).
distance(101945, 19.768842101109).
quantity(101945, 1).
slot_in_inventory(cutgrass, 107453).
fuel(cutgrass).
collectable(cutgrass).
slot_in_inventory(carrot, 107487).
edible(carrot).
collectable(carrot).
cookable(carrot).
slot_in_inventory(twigs, 107495).
fuel(twigs).
collectable(twigs).
slot_in_inventory(flint, 100475).
collectable(flint).
item_in_inventory(cutgrass, 6).
item_in_inventory(carrot, 1).
item_in_inventory(twigs, 5).
item_in_inventory(flint, 1).
equipment(axe).
equipment_guid(axe, 107480).
quantity(107480, 1).
equippable(axe).
collectable(axe).
sanity(high).
hunger(high).
health(high).
time(day, early).


good_item(carrot).
good_item(axe).
good_item(flint).
good_item(twigs).
good_item(log).
good_item(cutgrass).
good_item(berries).
good_item(sapling).

% collectable(GUID) :- pickable(GUID).
good_collect(GUID) :- collectable(GUID), item_on_screen(X, GUID), good_item(X).
good_pick(GUID) :- pickable(GUID), item_on_screen(X, GUID), good_item(X).
% good_pick(GUID) :- collectable(GUID), item_on_screen(X, GUID), good_item(X), -item_in_inventory(X, N).
% good_pick(GUID) :- collectable(GUID), item_on_screen(X, GUID), good_item(X), item_in_inventory(X, N), N.<.8.

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
action(pick_anything, pick_up_entity, GUID) :- item_on_screen(X, GUID), good_collect(GUID).
action(pick_anything, pick_entity, GUID) :- item_on_screen(X, GUID), good_pick(GUID).
action(no_repeat_wander, wander, nil) :- not only_time(night).


?- action(pick_anything , pick_entity , 106323).