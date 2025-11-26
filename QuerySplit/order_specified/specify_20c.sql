SET parallel_leader_participation = off;
set max_parallel_workers = '0';
set max_parallel_workers_per_gather = '0';
set shared_buffers = '512MB';
set temp_buffers = '2047MB';
set work_mem = '2047MB';
set effective_cache_size = '4 GB';
set statement_timeout = '1000s';
set default_statistics_target = 100;

--set join_collapse_limit = 1;

SELECT MIN(n.name) AS cast_member,
       MIN(t.title) AS complete_dynamic_hero_movie
FROM complete_cast AS cc,
     comp_cast_type AS cct1,
     comp_cast_type AS cct2,
     char_name AS chn,
     cast_info AS ci,
     keyword AS k,
     kind_type AS kt,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE n.id = ci.person_id
  AND chn.name IS NOT NULL
  AND (chn.name LIKE '%man%'
       OR chn.name LIKE '%Man%')
  AND chn.id = ci.person_role_id
  AND t.production_year > 2000
  AND t.id = ci.movie_id
  AND t.id = mk.movie_id
  AND k.keyword IN ('superhero',
                    'marvel-comics',
                    'based-on-comic',
                    'tv-special',
                    'fight',
                    'violence',
                    'magnet',
                    'web',
                    'claw',
                    'laser')
  AND k.id = mk.keyword_id
  AND kt.kind = 'movie'
  AND kt.id = t.kind_id
  AND t.id = cc.movie_id
  AND cct2.kind LIKE '%complete%'
  AND cct2.id = cc.status_id
  AND cct1.kind = 'cast'
  AND cct1.id = cc.subject_id;
