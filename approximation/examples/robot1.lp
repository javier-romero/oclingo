%%% DOMAIN
#const t=3.
time(1..t).
#const r=2.
room(1..r).
door((R,R+1)) :- R=1..r-1.

% FLUENTS and ACTIONS
fluent(clean(R)) :- room(R).
fluent(at(R))    :- room(R).
action(brush).
action(go(R)) :- room(R).
action(wait).

% INITIAL SITUATION
h(at(1),0).
h(clean(R),0) :- not nh(clean(R),0), room(R).

% GENERATE ACTIONS
% { occ(A,T) } :- action(A), time(T).

% SEQUENTIAL PLANS
:- not 1 { occ(A,T) } 1, time(T).

% DIRECT EFFECTS
h(clean(R),T) :- occ(brush,T), h(at(R),T).
h(at(R),T) :- occ(go(R),T).

% INDIRECT EFFECTS
nh(at(R),T) :- h(at(RR),T), room(R), RR!= R.

% INERTIA
 h(F,T) :-  h(F,T-1), not nh(F,T), time(T).
nh(F,T) :- nh(F,T-1), not  h(F,T), time(T).

% PRECONDITIONS
:- occ(A,T), not poss(A,T).
poss(brush,T) :- time(T).
poss(wait,T) :- time(T).
poss(go(R),T) :- h(at(RR),T-1), door((RR,R)), time(T).

% GOAL
goal :- time(T), h(clean(R),T) : room(R).
:- not goal.

% DISPLAY
#show occ/2.

% EXISTS, FORALL and KNOWLEDGE
exists(occ(A,T)) :- action(A), time(T).
%{ occ(A,T) : exists(occ(A,T)) }.

forall(nh(clean(R),0)) :- room(R).

% HOLDS
occ(A,T) :- holds(occ(A,T)).
nh(clean(R),0) :- holds(nh(clean(R),0)).

