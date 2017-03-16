# approximation
Approximating conformant problems with ASP

## Usage
```bash
$ clingo [files] extra.lp --output=reify --reify-sccs | clingo - -Wno-atom-undefined meta.lp META
```
where META is either `metaFalse.lp` or `metaPoss.lp`.

Use ``--opt-mode=optN --quiet=1`` to compute all approximations.

## Input
The input program cannot have disjunctions or nonmonotone aggregates.

There are some special predicates: exists/1, forall/1, holds/1, and query/0.
They are not shown at the output.
For printing them, one can write something like this:
```
#show (query) : query.
```

Variables existentially quantified must be defined by (domain) predicate exists/1.

Variables universally quantified must be defined by (domain) predicate forall/1.

If exists(X) or forall(X) is true, then X may not appear in a rule head, and a rule with the form ``X :- holds(X).``
must be part of the input program.



## Example
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
