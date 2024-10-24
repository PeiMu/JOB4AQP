switch to c_r;
switch to relationshipcenter;

set effective_cache_size to '8 GB';
set statement_timeout = '1000s';
SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(movie_info.info) AS budget,
       MIN(title.title) AS unsuccsessful_movie
FROM company_name,
     company_type,
     info_type,
     info_type,
     movie_companies,
     movie_info,
     movie_info_idx,
     title
WHERE company_name.country_code ='[us]'
  AND company_type.kind IS NOT NULL
  AND (company_type.kind ='production companies'
       OR company_type.kind = 'distributors')
  AND info_type.info ='budget'
  AND info_type.info ='bottom 10 rank'
  AND title.production_year >2000
  AND (title.title LIKE 'Birdemic%'
       OR title.title LIKE '%Movie%')
  AND title.id = movie_info.movie_id
  AND title.id = movie_info_idx.movie_id
  AND movie_info.info_type_id = info_type.id
  AND movie_info_idx.info_type_id = info_type.id
  AND title.id = movie_companies.movie_id
  AND company_type.id = movie_companies.company_type_id
  AND company_name.id = movie_companies.company_id
  AND movie_companies.movie_id = movie_info.movie_id
  AND movie_companies.movie_id = movie_info_idx.movie_id
  AND movie_info.movie_id = movie_info_idx.movie_id;

