mkdir -p out/queries
cp queries/* out/queries/.

timer_begin='
set max_parallel_workers = 0;
set effective_cache_size to '\''8 GB'\'';
set statement_timeout = '\''1000s'\'';


DO
$do$
DECLARE
   _timing1  timestamptz;
   _start_ts timestamptz;
   _end_ts   timestamptz;
   _overhead numeric;     -- in ms
   _timing   numeric;     -- in ms
BEGIN
   _timing1  := clock_timestamp();
   _start_ts := clock_timestamp();
   _end_ts   := clock_timestamp();
   -- take minimum duration as conservative estimate
   _overhead := 1000 * extract(epoch FROM LEAST(_start_ts - _timing1 , _end_ts - _start_ts));
   _start_ts := clock_timestamp();
'

timer_end='
   _end_ts   := clock_timestamp();
   
-- RAISE NOTICE '\''Timing overhead in ms = %'\'', _overhead;
   RAISE NOTICE '\''Execution time in ms = %'\'', 1000 * (extract(epoch FROM _end_ts - _start_ts)) - _overhead;
END
$do$;
'

# Convert newlines in insert_code to literal "\n" for sed
insert_code_begin=$(echo "${timer_begin}" | sed ':a;N;$!ba;s/\n/\\n/g')

# Escape special characters in insert_code
insert_code_end=$(echo "${timer_end}" | sed "s/'/\\\\'/g")


for sql in out/queries/*; do
  ### add timer_begin
  #./qgen -v -c -d -s 3 ${i} > out/queries/${i}.sql
  sed -i "1s/^/${insert_code_begin}/" ${sql}
#  echo -e "${timer_begin}" | cat - out/queries/${i}.sql > temp && mv temp out/queries/${i}.sql

  ### add timer_end
#  sed -i -e "\$a\\${insert_code_end}" out/queries/${i}.sql
  echo "${timer_end}" >> ${sql}

  ### replace `select` by `perform`
  sed -i '0,/SELECT/{s//perform/}' ${sql}
done

