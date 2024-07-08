item_on_screen(twigs, 103120).
diggable(103120).
workable(103120).
quantity(103120, 1).
pickable(103120).
item_on_screen(twigs, 103109).
diggable(103109).
workable(103109).
quantity(103109, 1).
pickable(103109).
item_on_screen(evergreen, 108683).
quantity(108683, 1).
workable(108683).
choppable(108683).
item_on_screen(cutgrass, 102024).
diggable(102024).
workable(102024).
quantity(102024, 1).
pickable(102024).
item_on_screen(twigs, 103118).
diggable(103118).
workable(103118).
quantity(103118, 1).
pickable(103118).
item_on_screen(butterfly, 110319).
quantity(110319, 1).
workable(110319).
item_on_screen(evergreen, 108672).
quantity(108672, 1).
workable(108672).
choppable(108672).
item_on_screen(evergreen, 108680).
quantity(108680, 1).
workable(108680).
choppable(108680).
item_on_screen(cutgrass, 102023).
diggable(102023).
workable(102023).
quantity(102023, 1).
pickable(102023).
item_on_screen(twigs, 103115).
diggable(103115).
workable(103115).
quantity(103115, 1).
pickable(103115).
item_on_screen(evergreen, 108676).
quantity(108676, 1).
workable(108676).
choppable(108676).
item_on_screen(berries, 103904).
diggable(103904).
workable(103904).
quantity(103904, 1).
pickable(103904).
item_on_screen(carrot, 100976).
quantity(100976, 1).
pickable(100976).
item_on_screen(twigs, 103113).
diggable(103113).
workable(103113).
quantity(103113, 1).
pickable(103113).
item_on_screen(cutgrass, 102026).
diggable(102026).
workable(102026).
quantity(102026, 1).
pickable(102026).
item_on_screen(butterfly, 110562).
quantity(110562, 1).
workable(110562).
item_on_screen(rabbithole, 100494).
quantity(100494, 1).
diggable(100494).
workable(100494).
item_on_screen(evergreen, 108678).
quantity(108678, 1).
workable(108678).
choppable(108678).
item_on_screen(twigs, 103110).
diggable(103110).
workable(103110).
quantity(103110, 1).
pickable(103110).
item_on_screen(cutgrass, 102031).
diggable(102031).
workable(102031).
quantity(102031, 1).
pickable(102031).
item_on_screen(twigs, 103112).
diggable(103112).
workable(103112).
quantity(103112, 1).
pickable(103112).
item_on_screen(twigs, 103117).
diggable(103117).
workable(103117).
quantity(103117, 1).
pickable(103117).
item_on_screen(flower, 109304).
quantity(109304, 1).
pickable(109304).
item_on_screen(twigs, 103119).
diggable(103119).
workable(103119).
quantity(103119, 1).
pickable(103119).
item_on_screen(evergreen, 108681).
quantity(108681, 1).
workable(108681).
choppable(108681).
item_on_screen(cutgrass, 102025).
diggable(102025).
workable(102025).
quantity(102025, 1).
pickable(102025).
slot_in_inventory(twigs, 110309).
fuel(twigs).
collectable(twigs).
slot_in_inventory(petals, 110322).
fuel(petals).
collectable(petals).
edible(petals).
slot_in_inventory(carrot, 110329).
edible(carrot).
collectable(carrot).
cookable(carrot).
slot_in_inventory(cutgrass, 110345).
fuel(cutgrass).
collectable(cutgrass).
slot_in_inventory(berries, 110365).
edible(berries).
collectable(berries).
cookable(berries).
slot_in_inventory(seeds, 110364).
edible(seeds).
collectable(seeds).
cookable(seeds).
slot_in_inventory(flint, 109468).
collectable(flint).
item_in_inventory(twigs, 9).
item_in_inventory(petals, 7).
item_in_inventory(carrot, 1).
item_in_inventory(cutgrass, 4).
item_in_inventory(berries, 1).
item_in_inventory(seeds, 2).
item_in_inventory(flint, 2).
sanity(high).
hunger(high).
health(high).
time(day, end).


good_item(carrot).
good_item(axe).
good_item(flint).
good_item(twigs).
good_item(log).
good_item(cutgrass).
good_item(berries).
good_item(sapling).

% collectable(GUID) :- pickable(GUID).
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
action(pick_anything, pick_entity, GUID) :- item_on_screen(X, GUID), pickable(GUID).
action(pick_up_entity, pick_up_entity, GUID) :- item_on_screen(X, GUID), collectable(GUID).
% action(wander, wander, nil) :- not only_time(night).

?- action(DESC, FUNC, ARGS).

% ?- item_on_screen(X, GUID), collectable(GUID).
?- action(DESC, FUNC, ARGS).