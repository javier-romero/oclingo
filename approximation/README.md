# approximation
Approximating conformant problems with ASP

## Usage
```bash
$ clingo [files] --output=reify --reify-sccs | clingo - -Wno-atom-undefined META
```
where META is either `metaA.lp` or `metaA2.lp`.

## Example
```
$ clingo examples/simple.lp --output=reify --reify-sccs | clingo - -Wno-atom-undefined metaA.lp 
clingo version 5.1.0
Reading from - ...
Solving...
Answer: 1
a assume(false(b))
Optimization: 1
OPTIMUM FOUND
```
