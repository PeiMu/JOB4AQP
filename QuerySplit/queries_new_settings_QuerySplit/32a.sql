
switch to c_r;
switch to relationshipcenter;

SET parallel_leader_participation = off;
set max_parallel_workers = '0';
set max_parallel_workers_per_gather = '0';
set shared_buffers = '512MB';
set temp_buffers = '2047MB';
set work_mem = '2047MB';
set effective_cache_size = '4 GB';
set statement_timeout = '1000s';
set default_statistics_target = 100;

SELECT MIN(lt.link) AS link_type,
       MIN(t1.title) AS first_movie,
       MIN(t2.title) AS second_movie
FROM keyword AS k,
     link_type AS lt,
     movie_keyword AS mk,
     movie_link AS ml,
     title AS t1,
     title AS t2
WHERE k.keyword ='10,000-mile-club'
  AND mk.keyword_id = k.id
  AND t1.id = mk.movie_id
  AND ml.movie_id = t1.id
  AND ml.linked_movie_id = t2.id
  AND lt.id = ml.link_type_id
  AND mk.movie_id = t1.id;

