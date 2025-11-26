SELECT MIN(movie_info.info) AS budget,
       MIN(title.title) AS unsuccsessful_movie
FROM company_name,
     company_type,
     info_type1,
     info_type2,
     movie_companies,
     movie_info,
     movie_info_idx,
     title
WHERE company_name.country_code ='[us]'
  AND company_type.kind IS NOT NULL
  AND (company_type.kind ='production companies'
       OR company_type.kind = 'distributors')
  AND info_type1.info ='budget'
  AND info_type2.info ='bottom 10 rank'
  AND title.production_year >2000
  AND (title.title LIKE 'Birdemic%'
       OR title.title LIKE '%Movie%')
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

