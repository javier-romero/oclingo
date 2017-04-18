%%% DOMAIN
#const t=3.
time(1..t).
#const r=2.
room(1..r).
door((R,R+1)) :- R=1..r-1.

% FLUENTS and ACTIONS
fluent(clean(R)) :- room(R).
fluent(at(R))    :- room(R).
action(sweep).
action(go(R)) :- room(R).
action(wait).

% INITIAL SITUATION
h(at(1),0).
nh(F,0) :- not h(F,0), fluent(F).

% GENERATE ACTIONS
% { occ(A,T) } :- action(A), time(T).

% SEQUENTIAL PLANS
:- not 1 { occ(A,T) } 1, time(T).

% DIRECT EFFECTS
h(clean(R),T) :- occ(sweep,T), h(at(R),T).
h(at(R),T)    :- occ(go(R),T).

% INDIRECT EFFECTS
nh(at(R),T) :- h(at(RR),T), room(R), RR!= R.

% INERTIA
 h(F,T) :-  h(F,T-1), not nh(F,T), time(T).
nh(F,T) :- nh(F,T-1), not  h(F,T), time(T).

% PRECONDITIONS
:- occ(A,T), not poss(A,T).
poss(sweep,T)  :- time(T).
poss(wait,T)   :- time(T).
poss(go(R2),T) :- h(at(R1),T-1), door((R1,R2)), time(T).

% GOAL
goal :- T=0..t, h(clean(R),T) : room(R).
:- not goal.

% DISPLAY
#show occ/2.

% EXISTS, FORALL and KNOWLEDGE
exists(occ(A,T))      :- action(A), time(T).
forall(h(clean(R),0)) :- room(R).

% HOLDS
occ(A,T)      :- holds(occ(A,T)).
h(clean(R),0) :- holds(h(clean(R),0)).

