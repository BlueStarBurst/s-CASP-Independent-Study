time(night, early).
current_time(early).

time(A, T) :- time(A, T), current_time(T).


test(right) :- time(night).
test(wrong) :- not time(night).

% ?- test(A).
?- 