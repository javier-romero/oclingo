
_result(A,B) :- _result(A,B).
_answer(A,B) :- _answer(A,B).
_obs(A,B)    :- _obs(A,B).
#show _run/1.
_run(stop) :- _result(_,3).
_run(print).
%_run(reset).
_run(sense).
_run(last).

#program step(t).
goal(t) :- occ(a,t).
    occ(a,t) :-     _obs(do_a,0).
not occ(a,t) :- not _obs(do_a,0).
#show goal/1.
