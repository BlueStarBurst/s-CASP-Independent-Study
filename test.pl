% default all items to not on screen
guid(109761).
guid(109762).
guid(109763).

item_on_screen(other, 109761).
item_on_screen(other, 109762).
item_on_screen(campfire, 109763).
quantity(109761, 1).

% item_on_screen(campfire, 109761).
time(dusk, end).
campfire_ingredients.


campfire_exists :- item_on_screen(campfire, X), guid(X).

action(build_campfire_dusk, build, campfire) :- time(dusk, end), campfire_ingredients, not item_on_screen(campfire, X), guid(X).

?- action(DESC, FUNC, ARGS).