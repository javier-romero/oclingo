% PROGRAM
query :- not a, u.
query :- a, not u.
#show a/0.

% EXISTS, FORALL, KNOWLEDGE
exists(a).
forall(u).

% HOLDS
a :- holds(a).
u :- holds(u).
