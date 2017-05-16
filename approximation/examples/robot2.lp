%%% DOMAIN
#const t=4.
time(0..t).
#const r=2.
room(1..r).
door((R,R+1)) :- R=1..r-1.

% FLUENTS and ACTIONS
fluent(clean(R)) :- room(R).
fluent(at(R))    :- room(R).
action(sweep).
action(go(R)) :- room(R).
action(wait).
% NEW(2)
fluent(locked(D)) :- door(D).
action(flip(D))   :- door(D).

% INITIAL SITUATION
h(at(1),0).
nh(F,0) :- not h(F,0), fluent(F). % complete

% GENERATE ACTIONS
% { occ(A,T) } :- action(A), time(T).

% SEQUENTIAL PLANS
:- not 1 { occ(A,T) } 1, time(T), T > 0.

% DIRECT EFFECTS
h(clean(R),T) :- occ(sweep,T), h(at(R),T-1).
h(at(R),T)    :- occ(go(R),T).
% NEW(2)
nh(locked(D),T) :- occ(flip(D),T),  h(locked(D),T-1).
 h(locked(D),T) :- occ(flip(D),T), nh(locked(D),T-1).

% INDIRECT EFFECTS
nh(at(R),T) :- h(at(RR),T), room(R), RR!= R.

% INERTIA
 h(F,T) :-  h(F,T-1), not nh(F,T), time(T).
nh(F,T) :- nh(F,T-1), not  h(F,T), time(T).

% PRECONDITIONS
:- occ(A,T), not poss(A,T-1).
poss(sweep,T)  :- time(T).
poss(wait,T)   :- time(T).
% NEW(2)
%poss(go(R2),T) :- h(at(R1),T-1), door((R1,R2)), time(T).
poss(go(R2),T) :- h(at(R1),T), door((R1,R2)), time(T),
                  nh(locked((R1,R2)),T).
poss(flip((R1,R2)),T) :- h(at(R1),T), door((R1,R2)).

% GOAL
goal :- time(T), h(clean(R),T) : room(R).
:- not goal.


% DISPLAY
#show occ/2.

% EXISTS, FORALL and KNOWLEDGE
exists(occ(A,T))      :- action(A), time(T), T > 0.
forall(h(clean(R),0)) :- room(R).
% NEW(2)
forall(h(locked(D),0)):- door(D).

% HOLDS
occ(A,T)      :- holds(occ(A,T)).
h(clean(R),0) :- holds(h(clean(R),0)).
% NEW(2)
h(locked(D),0) :- holds(h(locked(D),0)).

% RELAXED CONSTRAINTS
relaxed_false :- occ(sweep,T), h(at(R),T-1), h(clean(R),T-1).
relaxed_false :- not occ(wait,T), occ(wait,T-1),            time(T).
relaxed_false :- not occ(go(R2),T), occ(flip((R1,R2)),T-1), time(T).

%% HANDLING relaxed_false 
:- kw(relaxed_false), relaxed_false. %     good
%:- relaxed_false.                   % not good
knowledge(relaxed_false).
holds(relaxed_false) :- relaxed_false.

