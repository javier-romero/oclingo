% GENERATE
{ holds(X) :    exists(X) } :- not flag.
{ holds(X) :    forall(X) } :- not flag.
{   tkw(X) : knowledge(X) } :- not flag.
{   fkw(X) : knowledge(X) } :- not flag.
{ flag }.

% KNOWLEDGE
kw(X) :-     holds(X), tkw(X).
kw(X) :- not holds(X), fkw(X).

% DISPLAY
#show holds/1.
#show flag/0. 
#show exists/1.
#show forall/1.
#show kw/1. #show tkw/1. #show fkw/1.
#show query/0.

