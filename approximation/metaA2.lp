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
%%%fail(atom(A)) :- atom(A), not supp(A).

% gather quantified atoms
quant(exists,E,A) :- output(exists(E),_), output(E,B), literal_tuple(B,A).
quant(forall,F,A) :- output(forall(F),_), output(F,B), literal_tuple(B,A).


%
% Nondeterministic Part
%

% guess exists/1
{ true(atom(A)) } :- quant(exists,_,A).

% guess as few as possible forall/1
#const _assumptions=1.
{ assume(A) } :- quant(forall,_,A), _assumptions=1.
#minimize { 1,A: assume(A),         _assumptions=1}.
{ true(atom(A)) } :- assume(A),     _assumptions=1.

% assumptions not assumed are possible
poss(atom(A)) :- quant(forall,_,A), not assume(A).

% make choices
#const _choices=1.
choice_body(A,B)  :- rule(choice(H),B), atom_tuple(H,A), _choices=1,
                     not quant(_,_,A).
{ true(atom(A)) } :- choice_body(A,B), true(B),          _choices=1.
{ poss(atom(A)) } :- choice_body(A,B), poss(B),          _choices=1.

% A is possible if it is true
poss(atom(A)) :- true(atom(A)).

% true and possible bodies
true(normal(B)) :- literal_tuple(B),
    true(atom(L)) : literal_tuple(B, L), L > 0;
    not poss(atom(L)) : literal_tuple(B,-L), L > 0.
poss(normal(B)) :- literal_tuple(B),
    poss(atom(L)) : literal_tuple(B, L), L > 0;
    not true(atom(L)) : literal_tuple(B,-L), L > 0.

true(sum(B,G)) :- sum(B,G,T),
    #sum { W,L : true(atom(L)), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : not poss(atom(L)), weighted_literal_tuple(B,-L,W), L > 0 } >= G.
poss(sum(B,G)) :- sum(B,G,T),
    #sum { W,L : poss(atom(L)), weighted_literal_tuple(B, L,W), L > 0 ;
           W,L : not true(atom(L)), weighted_literal_tuple(B,-L,W), L > 0 } >= G.

% constraints, with true and possible heads
              :- rule(disjunction(H),B), true(B), not atom_tuple(H,_).
true(atom(A)) :- rule(disjunction(H),B), true(B),     atom_tuple(H,A).
poss(atom(A)) :- rule(disjunction(H),B), poss(B),     atom_tuple(H,A).

% uncomment to forbid possible constraints
% :- rule(disjunction(H),B), poss(B), not atom_tuple(H,_).

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
#show T : output(T,B), true(normal(B)), not hide(T),                      not error(_,_).
#show assume(true(N))  : quant(forall,N,A), assume(A),     true(atom(A)), not error(_,_).
#show assume(false(N)) : quant(forall,N,A), assume(A), not poss(atom(A)), not error(_,_).

#show error/2.
error(Q,Name) :-  quant(Q,Name,A), quant(Q,Name,A2), A > A2.

