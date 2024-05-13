% CURRENT SCENE
time(day). % Day time, with less than 1 hour left in the day
time_until_end(1).

health(100, 150). % Current health is 100, max health is 150
hunger(50, 150). % Current hunger is 100, max hunger is 150
sanity(100, 100). % Current sanity is 100, max sanity is 150


% Sample inventory
item(carrot, 3).
item(berries, 3).
item(cooked_carrot, 3).
item(cooked_berries, 3).
item(axe, 1).
item(spear, 1).
item(twig, 2).
item(cutgrass, 2).
item(flint, 2).
item(rock, 2).
item(log, 2).

can_craft(axe) :- item(flint, X), X.>=.1, item(twig, Y), Y.>=.1.
-can_craft(spear).

%END OF CURRENT SCENE

% Hints for the agent

% 1. Items to be collected, or keep in inventory
good_item(axe).
good_item(spear).
good_item(cooked_carrot).
good_item(cooked_berries).
good_item(berries).
good_item(carrot).
good_item(twig).
good_item(cutgrass).
good_item(flint).
good_item(rock).
good_item(log).
good_item(petals).

% 2. Tiers of foods
good_food(carrot_cooked).
good_food(berries_cooked).
good_food(cookedmeat).
food(berries).
food(carrot).
bad_food(meat).
bad_food(monstermeat).

dont_drop(X) :- good_item(X).

% Cooked food is better than raw food







