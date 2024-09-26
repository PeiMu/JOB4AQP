SELECT MIN(company_name.name) AS producing_company,
       MIN(movie_info_idx.info) AS rating,
       MIN(title.title) AS movie
FROM company_name,
     company_type,
     info_typeinfo_type,
     info_type,
     kind_typet,
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

