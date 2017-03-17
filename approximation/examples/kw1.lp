kw(c) :- a.
c     :- u.
query :- not kw(c).
:- not a.
#show a/0. #show c/0.

%c :- u.
%kw(c) :- a, not u.
%query :- not kw(c).
%:- a.
%#show a/0. #show c/0. 

% exists, forall and knowledge
exists(a).
forall(u).
knowledge(c).

% mapping 
a :- holds(a).
u :- holds(u).
holds(c) :- c.

