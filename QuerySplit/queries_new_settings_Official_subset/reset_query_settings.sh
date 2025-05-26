for x in *.sql; do
  tail -n +14 <"$x" >"$x.tmp";
  mv "$x.tmp" "$x";
done