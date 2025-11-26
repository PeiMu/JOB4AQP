
SET parallel_leader_participation = off;
set max_parallel_workers = '0';
set max_parallel_workers_per_gather = '0';
set shared_buffers = '512MB';
set temp_buffers = '2047MB';
set work_mem = '2047MB';
set effective_cache_size = '4 GB';
set statement_timeout = '1000s';
set default_statistics_target = 100;

EXPLAIN
SELECT MIN(subq3.an_name) AS cool_actor_pseudonym,
       MIN(subq2.subq1_title_title) AS series_named_after_char
FROM (SELECT subq1.title_title AS subq1_title_title,
             subq1.title_id AS subq1_title_id
      FROM (SELECT t.title AS title_title,
                   t.id AS title_id
	    FROM keyword AS k,
	         movie_keyword AS mk,
	         title AS t
	    WHERE k.keyword ='character-name-in-title'
	      AND t.id = mk.movie_id
	      AND mk.keyword_id = k.id
	    OFFSET 0) AS subq1,
           movie_companies AS mc,
           company_name AS cn
      WHERE cn.country_code ='[us]'
        AND subq1.title_id = mc.movie_id
        AND mc.company_id = cn.id
      OFFSET 0) AS subq2,
      (SELECT an.name AS an_name,
	      n.id AS name_id
       FROM aka_name AS an,
            name AS n
       WHERE an.person_id = n.id
       OFFSET 0) AS subq3,
      cast_info AS ci
WHERE subq3.name_id = ci.person_id
  AND ci.movie_id = subq2.subq1_title_id;

