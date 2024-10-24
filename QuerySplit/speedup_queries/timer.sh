#!/bin/bash

log_name=$1_timer_log.txt

rm -rf ${log_name}

dir=$1

for sql in "${dir}"/*.sql; do
  echo "time psql -U imdb -d imdb -f ${sql}" 2>&1|tee -a ${log_name}
  time psql -U imdb -d imdb -f ${sql} 2>&1|tee -a ${log_name}
done

