switch to c_r;
switch to relationshipcenter;

set max_parallel_workers = 0;
set effective_cache_size to '8 GB';
set statement_timeout = '1000s';


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
perform MIN(an1.name) AS actress_pseudonym,
       MIN(t.title) AS japanese_movie_dubbed
FROM aka_name AS an1,
     cast_info AS ci,
     company_name AS cn,
     movie_companies AS mc,
     name AS n1,
     role_type AS rt,
     title AS t
WHERE ci.note ='(voice: English version)'
  AND cn.country_code ='[jp]'
  AND mc.note LIKE '%(Japan)%'
  AND mc.note NOT LIKE '%(USA)%'
  AND n1.name LIKE '%Yo%'
  AND n1.name NOT LIKE '%Yu%'
  AND rt.role ='actress'
  AND an1.person_id = n1.id
  AND n1.id = ci.person_id
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND an1.person_id = ci.person_id
  AND ci.movie_id = mc.movie_id;


   _end_ts   := clock_timestamp();
   
-- RAISE NOTICE 'Timing overhead in ms = %', _overhead;
   RAISE NOTICE 'Execution time in ms = %', 1000 * (extract(epoch FROM _end_ts - _start_ts)) - _overhead;
END
$do$;

