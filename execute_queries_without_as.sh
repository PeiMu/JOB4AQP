dir="/home/pei/Project/benchmarks/imdb_job-postgres/queries_without_AS"
iteration=1

rm -f result/*
mkdir -p result/

for i in $(eval echo {1.."${iteration}"}); do
  for sql in "${dir}"/*; do
    echo "execute ${sql}" 2>&1|tee -a query_without_as_${i}.txt;
    psql -U imdb -d imdb -h /tmp -f "${sql}" 2>&1|tee -a query_without_as_${i}.txt;
    #psql -U imdb -d -f "${sql}";
  done
done

mv query_without_as_* result/.
