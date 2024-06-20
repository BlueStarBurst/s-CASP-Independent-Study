item_on_screen(evergreen, 103815).
quantity(103815, 1).
workable(evergreen, 103815).
choppable(evergreen, 103815).
item_on_screen(flower, 100671).
quantity(100671, 1).
pickable(flower, 100671).
item_on_screen(evergreen, 106345).
quantity(106345, 1).
workable(evergreen, 106345).
choppable(evergreen, 106345).
item_on_screen(grass, 101071).
diggable(grass, 101071).
workable(grass, 101071).
quantity(101071, 1).
item_on_screen(sapling, 102488).
diggable(sapling, 102488).
workable(sapling, 102488).
quantity(102488, 1).
pickable(sapling, 102488).
item_on_screen(sapling, 102486).
diggable(sapling, 102486).
workable(sapling, 102486).
quantity(102486, 1).
pickable(sapling, 102486).
item_on_screen(rabbit, 102019).
quantity(102019, 1).
cookable(rabbit, 102019).
item_on_screen(flower, 100672).
quantity(100672, 1).
pickable(flower, 100672).
item_on_screen(butterfly, 108066).
quantity(108066, 1).
workable(butterfly, 108066).
item_on_screen(rabbithole, 107335).
quantity(107335, 1).
diggable(rabbithole, 107335).
workable(rabbithole, 107335).
item_on_screen(rabbit, 102138).
quantity(102138, 1).
cookable(rabbit, 102138).
item_on_screen(rabbithole, 107334).
quantity(107334, 1).
diggable(rabbithole, 107334).
workable(rabbithole, 107334).
item_on_screen(wormhole, 101809).
quantity(101809, 1).
item_on_screen(grass, 101411).
diggable(grass, 101411).
workable(grass, 101411).
quantity(101411, 1).
pickable(grass, 101411).
item_on_screen(grass, 101395).
diggable(grass, 101395).
workable(grass, 101395).
quantity(101395, 1).
pickable(grass, 101395).
item_on_screen(sapling, 102490).
diggable(sapling, 102490).
workable(sapling, 102490).
quantity(102490, 1).
pickable(sapling, 102490).
item_on_screen(evergreen, 104589).
quantity(104589, 1).
workable(evergreen, 104589).
choppable(evergreen, 104589).
slot_in_inventory(log, 100025).
fuel(log).
collectable(log).
slot_in_inventory(carrot, 100026).
edible(carrot).
collectable(carrot).
cookable(carrot).
slot_in_inventory(carrot_cooked, 100027).
edible(carrot_cooked).
collectable(carrot_cooked).
slot_in_inventory(pinecone, 100028).
fuel(pinecone).
collectable(pinecone).
slot_in_inventory(flint, 100029).
collectable(flint).
slot_in_inventory(meat, 100030).
edible(meat).
collectable(meat).
cookable(meat).
slot_in_inventory(monstermeat, 100031).
edible(monstermeat).
collectable(monstermeat).
cookable(monstermeat).
slot_in_inventory(cookedmeat, 100032).
edible(cookedmeat).
collectable(cookedmeat).
slot_in_inventory(cutgrass, 100033).
fuel(cutgrass).
collectable(cutgrass).
item_in_inventory(log, 13).
item_in_inventory(carrot, 5).
item_in_inventory(carrot_cooked, 7).
item_in_inventory(pinecone, 11).
item_in_inventory(flint, 4).
item_in_inventory(meat, 4).
item_in_inventory(monstermeat, 2).
item_in_inventory(cookedmeat, 15).
item_in_inventory(cutgrass, 1).
equipment(axe).
equipment_guid(axe, 100034).
quantity(100034, 1).
equippable(axe).
collectable(axe).
sanity(high).
hunger(high).
health(high).
time(day, end).


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