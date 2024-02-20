mkdir -p out/QuerySplit/

cp out/queries/* out/QuerySplit/.

split_algo="${1:-relationshipcenter}"
order_decision="${1:-c_r}"

for sql in out/QuerySplit/*; do
  sed -i "1s/^/switch to ${split_algo};\n/" ${sql}
  sed -i "1s/^/switch to ${order_decision};\n/" ${sql}
done


