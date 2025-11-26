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
WITH 
subq1 AS MATERIALIZED (
  SELECT t.title AS title_title, t.kind_id AS title_kind_id, t.id AS title_id
     FROM title AS t,
          complete_cast AS cc,
          comp_cast_type AS cct1,
          comp_cast_type AS cct2
     WHERE t.production_year > 2000
       AND t.id = cc.movie_id
       AND cct2.kind LIKE '%complete%'
       AND cct2.id = cc.status_id
       AND cct1.kind = 'cast'
       AND cct1.id = cc.subject_id
),
subq2 AS MATERIALIZED (
  SELECT subq1.title_title AS subq2_title_title, subq1.title_id AS subq2_title_id
     FROM subq1,
          kind_type AS kt
     WHERE kt.kind = 'movie'
       AND subq1.title_kind_id = kt.id
),
subq3 AS MATERIALIZED (
  SELECT subq2.subq2_title_title AS subq3_title_title, subq2.subq2_title_id AS subq3_title_id
     FROM subq2,
          keyword AS k,
          movie_keyword AS mk
     WHERE k.keyword IN ('superhero',
                    'marvel-comics',
                    'based-on-comic',
                    'tv-special',
                    'fight',
                    'violence',
                    'magnet',
                    'web',
                    'claw',
                    'laser')
     AND subq2.subq2_title_id = mk.movie_id
     AND k.id = mk.keyword_id
)

SELECT MIN(n.name) AS cast_member,
       MIN(subq3.subq3_title_title) AS complete_dynamic_hero_movie
FROM subq3,
     cast_info AS ci,
     char_name AS chn,
     name AS n
WHERE n.id = ci.person_id
  AND chn.name IS NOT NULL
  AND (chn.name LIKE '%man%'
       OR chn.name LIKE '%Man%')
  AND chn.id = ci.person_role_id
  AND subq3.subq3_title_id = ci.movie_id;

