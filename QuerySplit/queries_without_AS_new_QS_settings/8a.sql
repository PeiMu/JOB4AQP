
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

SELECT MIN(aka_name.name) AS actress_pseudonym,
       MIN(title.title) AS japanese_movie_dubbed
FROM aka_name,
     cast_info,
     company_name,
     movie_companies,
     name,
     role_type,
     title
WHERE cast_info.note ='(voice: English version)'
  AND company_name.country_code ='[jp]'
  AND movie_companies.note LIKE '%(Japan)%'
  AND movie_companies.note NOT LIKE '%(USA)%'
  AND name.name LIKE '%Yo%'
  AND name.name NOT LIKE '%Yu%'
  AND role_type.role ='actress'
  AND aka_name.person_id = name.id
  AND name.id = cast_info.person_id
  AND cast_info.movie_id = title.id
  AND title.id = movie_companies.movie_id
  AND movie_companies.company_id = company_name.id
  AND cast_info.role_id = role_type.id
  AND aka_name.person_id = cast_info.person_id
  AND cast_info.movie_id = movie_companies.movie_id;

