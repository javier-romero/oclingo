% GENERATE
{ holds(X)    :    exists(X) } :- not flag.
{ holds(X)    :    forall(X) } :- not flag.
{ kw(true, X) : knowledge(X) } :- not flag.
{ kw(false,X) : knowledge(X) } :- not flag.
{ flag }.

% KNOWLEDGE WHETHER
kw(X) :-     holds(X), kw(true, X).
kw(X) :- not holds(X), kw(false,X).

% KNOWLEDGE WHETHER, TRUE, AND FALSE
%kt(X) :-     holds(X), kw(true,X).
%kf(X) :- not holds(X), kw(false,X).
%kw(X) :- kt(X). kw(X) :- kf(X).

% QUERY
query(0) :- query.
query    :- not flag.

% DISPLAY
#show holds/1.
#show flag/0. 
#show exists/1.
#show forall/1.
#show kw/2.
#show query/1.

% AVOID WARNINGS
exists(X) :- exists(X).
forall(X) :- forall(X).
knowledge(X) :- knowledge(X).
