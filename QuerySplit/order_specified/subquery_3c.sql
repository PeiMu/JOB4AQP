
SET parallel_leader_participation = off;
set max_parallel_workers = '0';
set max_parallel_workers_per_gather = '0';
set shared_buffers = '512MB';
set temp_buffers = '2047MB';
set work_mem = '2047MB';
set effective_cache_size = '4 GB';
set statement_timeout = '1000s';
set default_statistics_target = 100;

EXPLAIN ANALYZE
SELECT MIN(subq1.title_title) AS movie_title
FROM (SELECT t.title AS title_title,
	     t.id AS title_id
      FROM keyword AS k,
           movie_keyword AS mk,
           title AS t
      WHERE k.keyword LIKE '%sequel%'
        AND t.production_year > 1990
	AND t.id = mk.movie_id
	AND k.id = mk.keyword_id
     OFFSET 0) AS subq1,
     movie_info AS mi
WHERE mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Denish',
                  'Norwegian',
                  'German',
                  'USA',
                  'American')
  AND subq1.title_id = mi.movie_id;

