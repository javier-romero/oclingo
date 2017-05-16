%%% DOMAIN
#const t=3.
time(0..t).
#const r=2.
room(1..r).
door((R,R+1)) :- R=1..r-1.

% FLUENTS and ACTIONS
fluent(ball(R)) :- room(R).% NEW(4)
fluent(at(R))   :- room(R).
fluent(has_ball). % NEW(4)
action(go(R))   :- room(R).
action(wait).
action(get_ball). % NEW(4)

% INITIAL SITUATION
h(at(1),0).
h(ball(2),0) :- nh(ball(1),0).
nh(F,0) :- not h(F,0), fluent(F).

% GENERATE ACTIONS
% { occ(A,T) } :- action(A), time(T).

% SEQUENTIAL PLANS
:- not 1 { occ(A,T) } 1, time(T), T > 0.

% DIRECT EFFECTS
h(at(R),T)    :- occ(go(R),T).
h(has_ball,T) :- occ(get_ball,T), h(at(R),T-1), h(ball(R),T-1). % NEW(4)

% INDIRECT EFFECTS
nh(at(R),T) :- h(at(RR),T), room(R), RR!= R.

% INERTIA
 h(F,T) :-  h(F,T-1), not nh(F,T), time(T).
nh(F,T) :- nh(F,T-1), not  h(F,T), time(T).

% PRECONDITIONS
:- occ(A,T), not poss(A,T-1).
poss(get_ball,T) :- time(T). % NEW(4)
poss(wait,T)     :- time(T).
poss(go(R2),T)   :- h(at(R1),T), door((R1,R2)).

% GOAL
goal :- time(T), h(has_ball,T). % NEW(4)
:- not goal.

% DISPLAY
#show occ/2.

% EXISTS, FORALL and KNOWLEDGE
exists(occ(A,T))     :- action(A), time(T), T > 0.
forall(h(ball(1),0)). % NEW(4)

% HOLDS
occ(A,T)     :- holds(occ(A,T)).
h(ball(1),0) :- holds(h(ball(1),0)). % NEW(4)

