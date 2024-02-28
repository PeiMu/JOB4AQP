dir="/home/pei/benchmarks/imdb_job-postgres/skinner_explained"
iteration=10

rm -f result/*
mkdir -p result/

for i in $(eval echo {1.."${iteration}"}); do
  for sql in "${dir}"/*; do
    echo "execute ${sql}";
    psql -U imdb -f "${sql}" 2>&1|tee -a skinner_explained_tpch-3_${i}.txt;
    #psql -U imdb -f "${sql}";
  done
done

mv skinner_explained_tpch-3_* result/.
