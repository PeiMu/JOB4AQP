
SET parallel_leader_participation = off;
set max_parallel_workers = '0';
set max_parallel_workers_per_gather = '0';
set shared_buffers = '512MB';
set temp_buffers = '2047MB';
set work_mem = '2047MB';
set effective_cache_size = '4 GB';
set statement_timeout = '1000s';
set default_statistics_target = 100;

--EXPLAIN ANALYZE
WITH
subq1 AS MATERIALIZED (
  SELECT t.title AS subq1_title_title,
         t.id AS subq1_title_id
  FROM title AS t,
       movie_companies AS mc,
       company_name AS cn
  WHERE cn.country_code ='[us]'
    AND t.id = mc.movie_id
    AND mc.company_id = cn.id
),
subq2 AS MATERIALIZED (
  SELECT an1.name AS subq2_an1_name,
         n1.id AS subq2_n1_id
  FROM aka_name AS an1,
       name AS n1
  WHERE an1.person_id = n1.id
)

SELECT MIN(subq2.subq2_an1_name) AS costume_designer_pseudo,
       MIN(subq1.subq1_title_title) AS movie_with_costumes
FROM subq2,
     subq1,
     cast_info AS ci,
     role_type AS rt
WHERE rt.role ='costume designer'
  AND subq2.subq2_n1_id = ci.person_id
  AND subq1.subq1_title_id = ci.movie_id
  AND ci.role_id = rt.id;

