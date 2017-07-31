# approximation
Approximating problems with incomplete information in ASP

## Usage
Run either 
```bash
$ clingo [files] extra.lp --output=reify --reify-sccs | clingo - -Wno-atom-undefined meta.lp metaFalse.lp
```
or
```bash
$ clingo [files] extra.lp --output=reify | clingo - -Wno-atom-undefined meta.lp metaPoss.lp
```

Use ``--opt-mode=optN --quiet=1,0 0`` to compute all approximations.

The system minimizes the assumptions on the universally quantified atoms.
To avoid the use of assumptions, add ``-c _assumptions=0`` at the end of the call.

## Input
The input program cannot have disjunctions or nonmonotone aggregates.

Atoms of the form ``kw(A)`` represent knowing whether ``A`` holds.

There are some special predicates: 
- ``exists/1``: domain predicate, defines the existentially quantified atoms
- ``forall/1``: domain predicate, defines the universally quantified atoms
- ``knowledge/1``: domain predicate, defines the atoms ``A`` for which ``kw(A)`` appears in the input program 
- ``holds/1``, ``flag/0``, ``kw/1``: used internally, should not appear in the input program

The special predicates are not shown at the output (even when ``#show``n).
For printing them, one can write something like this:
```
#show _holds(X) : holds(X).
```

If ``exists(A)`` or ``forall(A)`` is true, 
then ``A`` may not appear in a rule head, 
and a rule with the form ``A :- holds(A).``
must be part of the input program.

If ``kw(A)`` appears in the input program, 
then ``knowledge(A)`` must be defined, 
and a rule with the form ``holds(A) :- A.``
must be part of the input program.


## Example 
```
$ cat examples/simple.lp 
% PROGRAM 
query :- a, b.
query :- a, not b.

#show a/0. #show b/0.

% EXISTS, FORALL, KNOWLEDGE
exists(a).
forall(b).

% HOLDS
a :- holds(a).
b :- holds(b).

$ clingo examples/simple.lp extra.lp --output=reify --reify-sccs | clingo - -Wno-atom-undefined meta.lp metaFalse.lp
clingo version 5.1.0
Reading from - ...
Solving...
Answer: 1
b a assume(true(b))
Optimization: 1
OPTIMUM FOUND

$ cat examples/sense.lp 
% PROGRAM
:- not 1 { sense; a } 1.
x :- not u.
x :-     u.
:- not sense, not kw(x).
:-     sense,     kw(x).

#show sense/0. #show a/0.

% EXISTS, FORALL, KNOWLEDGE
exists(sense).
exists(a).
forall(u).
knowledge(x).

% HOLDS
sense :- holds(sense).
a     :- holds(a).
u     :- holds(u).
holds(x) :- x.

$ clingo examples/sense.lp extra.lp --output=reify | clingo - -Wno-atom-undefined meta.lp metaPoss.lp
clingo version 5.1.0
Reading from - ...
Solving...
Answer: 1
a assume(false(u))
Optimization: 1
Answer: 2
sense
Optimization: 0
OPTIMUM FOUND
```
