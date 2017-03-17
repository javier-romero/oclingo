%
% Constants
%

#const _assumptions=1. % 1 = assumptions are activated
#const _constraints=0. % 1 = constraints are required to be proved false
#const _query=1.       % 1 = query atom   is required to be proved true

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
knowledge(true, A,AA) :- output(tkw(K),B),    literal_tuple(B,A),
                         output(holds(K),BB), literal_tuple(BB,AA).
knowledge(false,A,AA) :- output(fkw(K),B),    literal_tuple(B,A),
                         output(holds(K),BB), literal_tuple(BB,AA).
knowledge(A)    :- knowledge(_,A,AA).

%
% Nondeterministic Part
%

% query must be known true
:- output(query,B), not true(normal(B)), _query=1.


%
% Display
%

hide(holds(X))     :- output(holds(X),_).
hide(flag)         :- output(flag,_).
hide(exists(E))    :- output(exists(E),_).
hide(forall(A))    :- output(forall(A),_).
hide(kw(X))        :- output(kw(X),_).
hide(knowledge(X)) :- output(knowledge(X),_).
hide(query)        :- output(query,_).

#show.
#show T : output(T,B), true(normal(B)), not hide(T),                  not error(_,_).
#show assume(true(N))  : quant(forall,N,A), assume(A), true(atom(A)), not error(_,_).
#show assume(false(N)) : quant(forall,N,A), assume(A), fail(atom(A)), not error(_,_).

#show error/2.
error((twice,Q),Name) :- quant(Q,Name,A), quant(Q,Name,A2), A > A2.
error((scc,Q),Name)   :- scc(C,A), exists(Q,Name,A).
