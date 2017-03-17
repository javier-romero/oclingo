% PROGRAM
:- not 1 { sense; a } 1.
x :- not u.
x :-     u.
:- not sense, not kw(x).
:-     sense,     kw(x).
query.

#show sense/0. #show a/0.

% EXISTS, FORALL, KNOWLEDGE
exists(sense).
exists(a).
forall(u).
knowledge(x).

% HOLDS
sense :- holds(sense).
a     :- holds(a).
u     :- holds(u).
holds(x) :- x.

