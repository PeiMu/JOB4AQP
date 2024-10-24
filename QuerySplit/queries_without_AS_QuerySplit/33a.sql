switch to c_r;
switch to relationshipcenter;

set effective_cache_size to '8 GB';
set statement_timeout = '1000s';
SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(company_name.name) AS first_company,
       MIN(company_name.name) AS second_company,
       MIN(movie_info_idx.info) AS first_rating,
       MIN(movie_info_idx.info) AS second_rating,
       MIN(title.title) AS first_movie,
       MIN(title.title) AS second_movie
FROM company_name,
     info_type,
     kind_type,
     link_type,
     movie_companies,
     movie_info_idx,
     movie_link,
     title
WHERE company_name.country_code = '[us]'
  AND info_type.info = 'rating'
  AND kind_type.kind IN ('tv series')
  AND link_type.link IN ('sequel',
                  'follows',
                  'followed by')
  AND movie_info_idx.info < '3.0'
  AND title.production_year BETWEEN 2005 AND 2008
  AND link_type.id = movie_link.link_type_id
  AND title.id = movie_link.movie_id
  AND title.id = movie_link.linked_movie_id
  AND info_type.id = movie_info_idx.info_type_id
  AND title.id = movie_info_idx.movie_id
  AND kind_type.id = title.kind_id
  AND company_name.id = movie_companies.company_id
  AND title.id = movie_companies.movie_id
  AND movie_link.movie_id = movie_info_idx.movie_id
  AND movie_link.movie_id = movie_companies.movie_id
  AND movie_info_idx.movie_id = movie_companies.movie_id
  AND info_type.id = movie_info_idx.info_type_id
  AND title.id = movie_info_idx.movie_id
  AND kind_type.id = title.kind_id
  AND company_name.id = movie_companies.company_id
  AND title.id = movie_companies.movie_id
  AND movie_link.linked_movie_id = movie_info_idx.movie_id
  AND movie_link.linked_movie_id = movie_companies.movie_id
  AND movie_info_idx.movie_id = movie_companies.movie_id;

