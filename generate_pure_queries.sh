mkdir -p out/pure_queries
cp queries/* out/pure_queries/.

QuerySplit_settings='
set max_parallel_workers = 0;
set effective_cache_size to '\''8 GB'\'';
set statement_timeout = '\''1000s'\'';
'

# Convert newlines in insert_code to literal "\n" for sed
insert_code=$(echo "${QuerySplit_settings}" | sed ':a;N;$!ba;s/\n/\\n/g')


for sql in out/pure_queries/*; do
  ### add timer_begin
  sed -i "1s/^/${insert_code}/" ${sql}
done

