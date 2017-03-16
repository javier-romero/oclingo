
For computing all approximations, run:
  clingo examples/simple.lp extra.lp --output=reify --reify-sccs | clingo - -Wno-atom-undefined meta.lp metaFalse.lp --opt-mode=optN --quiet=1

For reifying possible, replace metaFalse.lp by metaPoss.lp

