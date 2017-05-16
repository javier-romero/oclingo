% GENERATE
{ holds(X) :    exists(X) } :- not flag.
{ holds(X) :    forall(X) } :- not flag.
{    kw(X) : knowledge(X) } :- not flag.
{ flag }.

% DISPLAY
#show holds/1.
#show flag/0.
#show exists/1.
#show forall/1.
#show kw/1.

% AVOID WARNINGS
exists(X) :- exists(X).
forall(X) :- forall(X).
knowledge(X) :- knowledge(X).
