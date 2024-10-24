
set shared_buffers = '512MB';
set temp_buffers = '2047MB';
set work_mem = '2047MB';
set default_statistics_target = 100;
switch to c_r;
switch to relationshipcenter;

set effective_cache_size to '8 GB';
set statement_timeout = '1000s';
SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(aka_name.name) AS writer_pseudo_name,
       MIN(title.title) AS movie_title
FROM aka_name,
     cast_info,
     company_name,
     movie_companies,
     name,
     role_type,
     title
WHERE company_name.country_code ='[us]'
  AND role_type.role ='writer'
  AND aka_name.person_id = name.id
  AND name.id = cast_info.person_id
  AND cast_info.movie_id = title.id
  AND title.id = movie_companies.movie_id
  AND movie_companies.company_id = company_name.id
  AND cast_info.role_id = role_type.id
  AND aka_name.person_id = cast_info.person_id
  AND cast_info.movie_id = movie_companies.movie_id;

