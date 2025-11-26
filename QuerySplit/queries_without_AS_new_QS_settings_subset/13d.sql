
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

SELECT MIN(company_name.name) AS producing_company,
       MIN(movie_info_idx.info) AS rating,
       MIN(title.title) AS movie
FROM company_name,
     company_type,
     info_type,
     info_type,
     kind_type,
     movie_companies,
     movie_info,
     movie_info_idx,
     title
WHERE company_name.country_code ='[us]'
  AND company_type.kind ='production companies'
  AND info_type.info ='rating'
  AND info_type.info ='release dates'
  AND title.kind ='movie'
  AND movie_info.movie_id = title.id
  AND info_type.id = movie_info.info_type_id
  AND title.id = title.kind_id
  AND movie_companies.movie_id = title.id
  AND company_name.id = movie_companies.company_id
  AND company_type.id = movie_companies.company_type_id
  AND movie_info_idx.movie_id = title.id
  AND info_type.id = movie_info_idx.info_type_id
  AND movie_info.movie_id = movie_info_idx.movie_id
  AND movie_info.movie_id = movie_companies.movie_id
  AND movie_info_idx.movie_id = movie_companies.movie_id;

