query :- a, b.
query :- a, not b.

%query :- not a.

%q :- x.
%p :- q, not a.
%q :- p, not a.
%query :- p.
%{ x }.
%#show x/0.

%{c} :- b. #show c/0. query.

%
% exists and forall
%

exists(a).
{ a : exists(a) }.
#show exists/1. #show a/0.

forall(b).
{ b : forall(b) }.
#show forall/1. #show b/0.

#show query/0.
