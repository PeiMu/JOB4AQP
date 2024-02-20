for sql in out/queries/*; do
  echo "${sql}"
  psql < "${sql}"
done
