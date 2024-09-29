SELECT MIN(company_name.name) AS movie_company,
       MIN(movie_info_idx.info) AS rating,
       MIN(title.title) AS western_violent_movie
FROM company_name,
     company_type,
     info_type,
     info_type,
     keyword,
     kind_type,
     movie_companies,
     movie_info,
     movie_info_idx,
     movie_keyword,
     title
WHERE company_name.country_code != '[us]'
  AND info_type.info = 'countries'
  AND info_type.info = 'rating'
  AND keyword.keyword IN ('murder',
                    'murder-in-title',
                    'blood',
                    'violence')
  AND title.kind IN ('movie',
                  'episode')
  AND movie_companies.note NOT LIKE '%(USA)%'
  AND movie_companies.note LIKE '%(200%)%'
  AND movie_info.info IN ('Germany',
                  'German',
                  'USA',
                  'American')
  AND movie_info_idx.info < '7.0'
  AND title.production_year > 2008
  AND title.id = title.kind_id
  AND title.id = movie_info.movie_id
  AND title.id = movie_keyword.movie_id
  AND title.id = movie_info_idx.movie_id
  AND title.id = movie_companies.movie_id
  AND movie_keyword.movie_id = movie_info.movie_id
  AND movie_keyword.movie_id = movie_info_idx.movie_id
  AND movie_keyword.movie_id = movie_companies.movie_id
  AND movie_info.movie_id = movie_info_idx.movie_id
  AND movie_info.movie_id = movie_companies.movie_id
  AND movie_companies.movie_id = movie_info_idx.movie_id
  AND keyword.id = movie_keyword.keyword_id
  AND info_type.id = movie_info.info_type_id
  AND info_type.id = movie_info_idx.info_type_id
  AND company_type.id = movie_companies.company_type_id
  AND company_name.id = movie_companies.company_id;

