# approximation
Approximating conformant problems with ASP

## Usage
```bash
$ clingo [files] extra.lp --output=reify --reify-sccs | clingo - -Wno-atom-undefined meta.lp META
```
where META is either `metaFalse.lp` or `metaPoss.lp`.

Use ``--opt-mode=optN --quiet=1`` to compute all approximations.

## Example
```
$ clingo examples/simple.lp extra.lp --output=reify --reify-sccs | clingo - -Wno-atom-undefined meta.lp metaFalse.lp
clingo version 5.1.0
Reading from - ...
Solving...
Answer: 1
b a assume(true(b))
Optimization: 1
OPTIMUM FOUND
```
