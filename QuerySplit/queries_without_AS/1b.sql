set effective_cache_size to '8 GB';
set statement_timeout = '1000s';

SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(movie_companies.note) AS production_note,
       MIN(title.title) AS movie_title,
       MIN(title.production_year) AS movie_year
FROM company_type,
     info_type,
     movie_companies,
     movie_info_idx,
     title
WHERE company_type.kind = 'production companies'
  AND info_type.info = 'bottom 10 rank'
  AND movie_companies.note NOT LIKE '%(as Metro-Goldwyn-Mayer Pictures)%'
  AND title.production_year BETWEEN 2005 AND 2010
  AND company_type.id = movie_companies.company_type_id
  AND title.id = movie_companies.movie_id
  AND title.id = movie_info_idx.movie_id
  AND movie_companies.movie_id = movie_info_idx.movie_id
  AND info_type.id = movie_info_idx.info_type_id;

