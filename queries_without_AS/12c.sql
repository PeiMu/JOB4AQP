SELECT MIN(company_name.name) AS movie_company,
       MIN(movie_info_idx.info) AS rating,
       MIN(title.title) AS mainstream_movie
FROM company_name,
     company_type,
     info_type1,
     info_type2,
     movie_companies,
     movie_info,
     movie_info_idx,
     title
WHERE company_name.country_code = '[us]'
  AND company_type.kind = 'production companies'
  AND info_type1.info = 'genres'
  AND info_type2.info = 'rating'
  AND movie_info.info IN ('Drama',
                  'Horror',
                  'Western',
                  'Family')
  AND movie_info_idx.info > '7.0'
  AND title.production_year BETWEEN 2000 AND 2010
  AND title.id = movie_info.movie_id
  AND title.id = movie_info_idx.movie_id
  AND movie_info.info_type_id = info_type1.id
  AND movie_info_idx.info_type_id = info_type2.id
  AND title.id = movie_companies.movie_id
  AND company_type.id = movie_companies.company_type_id
  AND company_name.id = movie_companies.company_id
  AND movie_companies.movie_id = movie_info.movie_id
  AND movie_companies.movie_id = movie_info_idx.movie_id
  AND movie_info.movie_id = movie_info_idx.movie_id;

