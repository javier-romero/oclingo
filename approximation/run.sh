mode=$1
shift
if [ $mode -eq 0 ]
then
  cat /dev/stdin | clingo-banane - extra.lp --output=reify --reify-sccs | clingo-banane - -Wno-atom-undefined meta.lp metaFalse.lp $@
else
  cat /dev/stdin | clingo-banane - extra.lp --output=reify | clingo-banane - -Wno-atom-undefined meta.lp metaPoss.lp $@
fi
