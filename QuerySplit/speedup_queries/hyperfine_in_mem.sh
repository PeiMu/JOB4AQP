#!/bin/bash

log_name=$1_hyperfine_log.txt

rm -rf ${log_name}

dir=$1
iteration=10

for sql in "${dir}"/*.sql; do
  echo "hyperfine --warmup 1 --runs ${iteration} \"psql -U imdb -d imdb -f ${sql}\"" 2>&1|tee -a ${log_name}
  hyperfine --warmup 1 --runs ${iteration} "psql -U imdb -d imdb -f ${sql}" 2>&1|tee -a ${log_name}
done

