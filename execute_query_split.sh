for sql in out/QuerySplit/*; do
  echo "${sql}"
  psql < "${sql}"
done
