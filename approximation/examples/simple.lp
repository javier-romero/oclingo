query :- a, b.
query :- a, not b.

#show a/0. #show b/0.

% exists and forall
exists(a).
forall(b).

% mapping 
a :- holds(a).
b :- holds(b).

