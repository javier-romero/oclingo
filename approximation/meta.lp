%
% Constants
%

#const _assumptions=1. % 1 = assumptions are activated


%
% Deterministic Part
%

sum(B,G,T) :- rule(_,sum(B,G)), T = #sum { W,L : weighted_literal_tuple(B,L,W) }.

% extract supports of atoms and facts

supp(A,B) :- rule(     choice(H),B), atom_tuple(H,A).
supp(A,B) :- rule(disjunction(H),B), atom_tuple(H,A).

supp(A) :- supp(A,_).

atom(|L|) :- weighted_literal_tuple(_,L,_).
atom(|L|) :- literal_tuple(_,L).
atom( A ) :- atom_tuple(_,A).

fact(A) :- rule(disjunction(H),normal(B)), atom_tuple(H,A), not literal_tuple(B,_).

% gather quantified atoms
quant(exists,E,A) :- output(exists(E),_), output(holds(E),B), literal_tuple(B,A).
quant(forall,F,A) :- output(forall(F),_), output(holds(F),B), literal_tuple(B,A).

% the choice support of A is B
choice_supp(A,B)  :- rule(choice(H),B), atom_tuple(H,A).

% add fact "flag." reified
rule(disjunction(flag),normal(flag)).
atom_tuple(flag,A) :- output(flag,B), literal_tuple(B,A).

% knowledge
kw(A,B) :- output(kw(K),KB), literal_tuple(KB,A),
           output(holds(K),B).
kw(A,o) :- output(kw(K),KB), literal_tuple(KB,A),
           not output(holds(K),_).
kw(A)   :- knowledge(A,_).


%
% Display
%

hide(holds(X))     :- output(holds(X),_).
hide(flag)         :- output(flag,_).
hide(exists(E))    :- output(exists(E),_).
hide(forall(A))    :- output(forall(A),_).
hide(kw(X))        :- output(kw(X),_).
hide(knowledge(X)) :- output(knowledge(X),_).

#show.
#show T : output(T,B), true(normal(B)), not hide(T),                      not error.
#show assume(true(N))  : quant(forall,N,A), assume(A),     true(atom(A)), not error.
#show assume(false(N)) : quant(forall,N,A), assume(A), not true(atom(A)), not error.

#show error/2.
error((twice,Q),Name)    :- quant(Q,Name,A), quant(Q,Name,A2), A > A2.
error((scc,Q),Name)      :- scc(C,A), quant(Q,Name,A).
error((scc,knowledge),A) :- scc(C,A), knowledge(A).
error(output,O)          :- output(O,B), 2 { literal_tuple(B,L) }.
error :- error(_,_).
