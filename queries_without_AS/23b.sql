set effective_cache_size to '8 GB';
set statement_timeout = '1000s';

SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(kind_type.kind) AS movie_kind,
       MIN(title.title) AS complete_nerdy_internet_movie
FROM complete_cast,
     comp_cast_type,
     company_name,
     company_type,
     info_type,
     keyword,
     kind_type,
     movie_companies,
     movie_info,
     movie_keyword,
     title
WHERE comp_cast_type.kind = 'complete+verified'
  AND company_name.country_code = '[us]'
  AND info_type.info = 'release dates'
  AND keyword.keyword IN ('nerd',
                    'loner',
                    'alienation',
                    'dignity')
  AND kind_type.kind IN ('movie')
  AND movie_info.note LIKE '%internet%'
  AND movie_info.info LIKE 'USA:% 200%'
  AND title.production_year > 2000
  AND kind_type.id = title.kind_id
  AND title.id = movie_info.movie_id
  AND title.id = movie_keyword.movie_id
  AND title.id = movie_companies.movie_id
  AND title.id = complete_cast.movie_id
  AND movie_keyword.movie_id = movie_info.movie_id
  AND movie_keyword.movie_id = movie_companies.movie_id
  AND movie_keyword.movie_id = complete_cast.movie_id
  AND movie_info.movie_id = movie_companies.movie_id
  AND movie_info.movie_id = complete_cast.movie_id
  AND movie_companies.movie_id = complete_cast.movie_id
  AND keyword.id = movie_keyword.keyword_id
  AND info_type.id = movie_info.info_type_id
  AND company_name.id = movie_companies.company_id
  AND company_type.id = movie_companies.company_type_id
  AND comp_cast_type.id = complete_cast.status_id;

