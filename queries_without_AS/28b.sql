SELECT MIN(company_name.name) AS movie_company,
       MIN(movie_info_idx.info) AS rating,
       MIN(title.title) AS complete_euro_dark_movie
FROM complete_cast,
     comp_cast_type,
     comp_cast_type,
     company_name,
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
WHERE comp_cast_type.kind = 'crew'
  AND comp_cast_type.kind != 'complete+verified'
  AND company_name.country_code != '[us]'
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
  AND movie_info.info IN ('Sweden',
                  'Germany',
                  'Swedish',
                  'German')
  AND movie_info_idx.info > '6.5'
  AND title.production_year > 2005
  AND title.id = title.kind_id
  AND title.id = movie_info.movie_id
  AND title.id = movie_keyword.movie_id
  AND title.id = movie_info_idx.movie_id
  AND title.id = movie_companies.movie_id
  AND title.id = complete_cast.movie_id
  AND movie_keyword.movie_id = movie_info.movie_id
  AND movie_keyword.movie_id = movie_info_idx.movie_id
  AND movie_keyword.movie_id = movie_companies.movie_id
  AND movie_keyword.movie_id = complete_cast.movie_id
  AND movie_info.movie_id = movie_info_idx.movie_id
  AND movie_info.movie_id = movie_companies.movie_id
  AND movie_info.movie_id = complete_cast.movie_id
  AND movie_companies.movie_id = movie_info_idx.movie_id
  AND movie_companies.movie_id = complete_cast.movie_id
  AND movie_info_idx.movie_id = complete_cast.movie_id
  AND keyword.id = movie_keyword.keyword_id
  AND info_type.id = movie_info.info_type_id
  AND info_type.id = movie_info_idx.info_type_id
  AND company_type.id = movie_companies.company_type_id
  AND company_name.id = movie_companies.company_id
  AND comp_cast_type.id = complete_cast.subject_id
  AND comp_cast_type.id = complete_cast.status_id;

