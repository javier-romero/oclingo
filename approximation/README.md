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

Use ``--opt-mode=optN --quiet=1`` to compute all approximations.

The system returns an approximation of the input program proving atom ``query``.
To avoid the need to prove this atom, add ``-c _query=0`` at the end of the call.

The constraints of the input program cannot be proved true.
To require them also to be proved false, add ``-c _constraints=1`` at the end of the call.

The system minimizes the assumptions on the universally quantified atoms.
To avoid the use of assumptions, add ``-c _assumptions=0`` at the end of the call.

## Input
The input program cannot have disjunctions or nonmonotone aggregates.

Atoms of the form ``kw(A)`` represent knowing whether ``A`` holds.

There are some special predicates: 
- ``exists/1``: domain predicate, defines the existentially quantified atoms
- ``forall/1``: domain predicate, defines the universally quantified atoms
- ``knowledge/1``: domain predicate, defines the atoms ``A`` for which ``kw(A)`` appears in the input program 
- ``holds/1``, ``flag/0``, ``kw/2``: used internally, should not appear in the input program

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


## Example (TO BE REFINED)
```
$ cat examples/simple.lp 
query :- a, b.
query :- a, not b.

#show a/0. #show b/0.

% exists and forall
exists(a).
forall(b).

% mapping 
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
```
