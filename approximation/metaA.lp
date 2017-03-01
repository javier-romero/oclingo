%
% Deterministic Part
%

% NOTE: assumes that a rule has no more than one head

sum(B,G,T) :- rule(_,sum(B,G)), T = #sum { W,L : weighted_literal_tuple(B,L,W) }.

% extract supports of atoms and facts

supp(A,B) :- rule(     choice(H),B), atom_tuple(H,A).
supp(A,B) :- rule(disjunction(H),B), atom_tuple(H,A).

supp(A) :- supp(A,_).

atom(|L|) :- weighted_literal_tuple(_,L,_).
atom(|L|) :- literal_tuple(_,L).
atom( A ) :- atom_tuple(_,A).

fact(A) :- rule(disjunction(H),normal(B)), atom_tuple(H,A), not literal_tuple(B,_).

% facts are true, and atoms not appearing in heads fail
true(atom(A)) :- fact(A).
fail(atom(A)) :- atom(A), not supp(A).

% gather quantified atoms
quant(exists,E,A) :- output(exists(E),_), output(E,B), literal_tuple(B,A).
quant(forall,F,A) :- output(forall(F),_), output(F,B), literal_tuple(B,A).


%
% Nondeterministic Part
%

% guess exists/1
1 { true(atom(A)); fail(atom(A)) } 1 :- quant(exists,_,A).

% guess as few as possible forall/1
#const _assumptions=1.
{ assume(A) } :- quant(forall,_,A),                _assumptions=1.
#minimize { 1,A: assume(A),                        _assumptions=1}.
1 { true(atom(A)); fail(atom(A)) } 1 :- assume(A), _assumptions=1.

% make choices
#const _choices=1.
choice_body(A,B)  :- rule(choice(H),B), atom_tuple(H,A), _choices=1,
                     not quant(_,_,A).
choice(atom(A))   :- choice_body(A,B), true(B),          _choices=1.
{ true(atom(A)) } :- choice(atom(A)),                    _choices=1.
  fail(atom(A))   :- choice(atom(A)), not true(atom(A)), _choices=1,
                     fail(B) : supp(A,B), not choice_body(A,B). 

% Fitting operator
true(normal(B)) :- literal_tuple(B),
    true(atom(L)) : literal_tuple(B, L), L > 0;
    fail(atom(L)) : literal_tuple(B,-L), L > 0.
fail(normal(B)) :- literal_tuple(B, L), fail(atom(L)), L > 0.
fail(normal(B)) :- literal_tuple(B,-L), true(atom(L)), L > 0.

true(sum(B,G)) :- sum(B,G,T),
    #sum { W,L : true(atom(L)), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : fail(atom(L)), weighted_literal_tuple(B,-L,W), L > 0 } >= G.
fail(sum(B,G)) :- sum(B,G,T),
    #sum { W,L : fail(atom(L)), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : true(atom(L)), weighted_literal_tuple(B,-L,W), L > 0 } >= T-G+1.

              :- rule(disjunction(H),B), true(B), not atom_tuple(H,_).
true(atom(A)) :- rule(disjunction(H),B), true(B),     atom_tuple(H,A).
fail(atom(A)) :- supp(A), fail(B) : supp(A,B).

% uncomment to forbid unknown constraints
%              :- rule(disjunction(H),B), not fail(B), not atom_tuple(H,_).

% Extension to well founded
internal(C,normal(B)) :- scc(C,A), supp(A,normal(B)), scc(C,A'), literal_tuple(B,A').
internal(C,sum(B,G))  :- scc(C,A), supp(A,sum(B,G)),  scc(C,A'), weighted_literal_tuple(B,A',W).

external(C,normal(B)) :- scc(C,A), supp(A,normal(B)), not internal(C,normal(B)).
external(C,sum(B,G))  :- scc(C,A), supp(A,sum(B,G)),  not internal(C,sum(B,G)).

steps(C,Z) :- scc(C,_), Z = { scc(C,A) : not fact(A) }.

wait(C,atom(A),0)   :- scc(C,A), fail(B) : external(C,B).
wait(C,normal(B),I) :- internal(C,normal(B)), literal_tuple(B,A), wait(C,atom(A),I), steps(C,Z), I < Z.
wait(C,sum(B,G),I)  :- internal(C,sum(B,G)), steps(C,Z), I = 0..Z-1, sum(B,G,T),
    #sum { W,L :   fail(atom(L)),   weighted_literal_tuple(B, L,W), L > 0, not scc(C,L) ;
           W,L : wait(C,atom(L),I), weighted_literal_tuple(B, L,W), L > 0,     scc(C,L) ;
           W,L :   true(atom(L)),   weighted_literal_tuple(B,-L,W), L > 0               } >= T-G+1.
wait(C,atom(A),I)   :- wait(C,atom(A),0), steps(C,Z), I = 1..Z, wait(C,B,I-1) : supp(A,B), internal(C,B).

fail(atom(A)) :- scc(C,A), wait(C,atom(A),Z), steps(C,Z).

% query must be known true
:- output(query,B), not true(normal(B)).


%
% Display
%

hide(_criteria(J,W,Q)) :- output(_criteria(J,W,Q),_).
hide(_query)           :- output(_query,_).
hide(_optimize(J,W,Q)) :- output(_optimize(J,W,Q),_).
hide(exists(E))        :- output(exists(E),_).
hide(forall(A))        :- output(forall(A),_).
hide(query).

#show.
#show T : output(T,B), true(normal(B)), not hide(T),                  not error(_,_).
#show assume(true(N))  : quant(forall,N,A), assume(A), true(atom(A)), not error(_,_).
#show assume(false(N)) : quant(forall,N,A), assume(A), fail(atom(A)), not error(_,_).

#show error/2.
error(Q,Name) :-  quant(Q,Name,A), quant(Q,Name,A2), A > A2.

