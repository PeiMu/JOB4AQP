dir="/home/pei/Project/benchmarks/imdb_job-postgres/skinner_explained"
iteration=10

rm -f result/*
mkdir -p result/

for i in $(eval echo {1.."${iteration}"}); do
  for sql in "${dir}"/*; do
    echo "execute ${sql}";
    psql -U imdb -d imdb -f "${sql}" 2>&1|tee -a skinner_explained_imdb_${i}.txt;
    #psql -U imdb -d -f "${sql}";
  done
done

mv skinner_explained_imdb_* result/.
