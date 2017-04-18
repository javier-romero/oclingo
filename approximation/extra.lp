% GENERATE
{ holds(X) :    exists(X) } :- not flag.
{ holds(X) :    forall(X) } :- not flag.
{    kt(X) : knowledge(X) } :- not flag.
{    kf(X) : knowledge(X) } :- not flag.
%%%kt(X) :-     holds(X), knowledge(X), not flag.
%%%kf(X) :- not holds(X), knowledge(X), not flag.
{ flag }.

% QUERY
query(0)  :- query.
{ query } :- not flag.

% DISPLAY
#show holds/1.
#show flag/0. 
#show exists/1.
#show forall/1.
#show kt/1. 
#show kf/1.
#show query/1.

% AVOID WARNINGS
exists(X) :- exists(X).
forall(X) :- forall(X).
knowledge(X) :- knowledge(X).
