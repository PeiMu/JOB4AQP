set effective_cache_size to '8 GB';
set statement_timeout = '1000s';

SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(char_name.name) AS character,
       MIN(title.title) AS russian_mov_with_actor_producer
FROM char_name,
     cast_info,
     company_name,
     company_type,
     movie_companies,
     role_type,
     title
WHERE cast_info.note LIKE '%(producer)%'
  AND company_name.country_code = '[ru]'
  AND role_type.role = 'actor'
  AND title.production_year > 2010
  AND title.id = movie_companies.movie_id
  AND title.id = cast_info.movie_id
  AND cast_info.movie_id = movie_companies.movie_id
  AND char_name.id = cast_info.person_role_id
  AND role_type.id = cast_info.role_id
  AND company_name.id = movie_companies.company_id
  AND company_type.id = movie_companies.company_type_id;

