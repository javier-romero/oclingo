query :- a, b.
query :- a, not b.
:- not query.
#show a/0. #show b/0.

%q :- x.
%p :- q, not a.
%q :- p, not a.
%query :- p.
%{ x }.
%#show x/0.

%{c} :- b. #show c/0. query.

% exists and forall
exists(a).
forall(b).

% mapping 
a :- holds(a).
b :- holds(b).

