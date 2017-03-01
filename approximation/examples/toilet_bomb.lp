%
% #program static.
%

#const n=2.
#const packages=2.
time(1..n). query(n).

% input
%toilet(1..toilet).
package(1..packages).

% domains
bool(true). bool(false).
fluent(activated(P))   :- package(P).
domain(activated(P),V) :- package(P), bool(V).
action(dunk(P))        :- package(P).


%
% #program init.
%

%%% DOMAIN DEPENDENT

%:- not 1 { holds(activated(P),true,0) : package(P) } 1.

holds(activated(P), true,0) :-      init(activated(P)).
holds(activated(P),false,0) :- not holds(activated(P),true,0), package(P).

%%% DOMAIN INDEPENDENT

%1 { holds(F,V,0) : domain(F,V) } 1 :- fluent(F).

%
% #program step(t).
%

%%% DOMAIN DEPENDENT

% actions theory
holds(activated(P),false,T) :- occ(dunk(P),T), time(T).

% query
query :- query(T), holds(activated(P),false,T): package(P).

%%% DOMAIN INDEPENDENT

% constrain actions
:- not 1 { occ(A,T) : action(A) } 1, time(T).

% inertia
%holds(F,V,T) :- holds(F,V,T-1), not holds(F,VV,T), VV!=V, domain(F,VV), time(T).
{ holds(F,V,T) } :- holds(F,V,T-1), time(T).

% uniqueness of value
:-not 1 { holds(F,V,T) : domain(F,V) } 1, fluent(F), time(T).


%
% display
%

%#show holds/3.
#show occ/2.

%
% exists, forall, and query
%

exists(occ(A,T)) :- action(A), time(T).
{ occ(A,T) : exists(occ(A,T)) }.
#show exists/1. #show occ/2.

forall(init(activated(P))) :- package(P).
{ init(activated(P)) : forall(init(activated(P))) }.
#show forall/1. #show init/1.

#show query/0.
