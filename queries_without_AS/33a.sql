SELECT MIN(company_name1.name) AS first_company,
       MIN(company_name2.name) AS second_company,
       MIN(movie_info_idx1.info) AS first_rating,
       MIN(movie_info_idx2.info) AS second_rating,
       MIN(title1.title) AS first_movie,
       MIN(title2.title) AS second_movie
FROM company_name1,
     company_name2,
     info_type1,
     info_type2,
     kind_type1,
     kind_type2,
     link_type,
     movie_companies1,
     movie_companies2,
     movie_info_idx1,
     movie_info_idx2,
     movie_link,
     title1,
     title2
WHERE company_name1.country_code = '[us]'
  AND info_type1.info = 'rating'
  AND info_type2.info = 'rating'
  AND kind_type1.kind IN ('tv series')
  AND kind_type2.kind IN ('tv series')
  AND link_type.link IN ('sequel',
                  'follows',
                  'followed by')
  AND movie_info_idx2.info < '3.0'
  AND title2.production_year BETWEEN 2005 AND 2008
  AND link_type.id = movie_link.link_type_id
  AND title1.id = movie_link.movie_id
  AND title2.id = movie_link.linked_movie_id
  AND info_type1.id = movie_info_idx.1info_type_id
  AND title1.id = movie_info_idx1.movie_id
  AND kind_type1.id = title1.kind_id
  AND company_name1.id = movie_companies1.company_id
  AND title1.id = movie_companies1.movie_id
  AND movie_link.movie_id = movie_info_idx1.movie_id
  AND movie_link.movie_id = movie_companies1.movie_id
  AND movie_info_idx1.movie_id = movie_companies1.movie_id
  AND info_type2.id = movie_info_idx2.info_type_id
  AND title2.id = movie_info_idx2.movie_id
  AND kind_type2.id = title2.kind_id
  AND company_name2.id = movie_companies2.company_id
  AND title2.id = movie_companies2.movie_id
  AND movie_link.linked_movie_id = movie_info_idx2.movie_id
  AND movie_link.linked_movie_id = movie_companies2.movie_id
  AND movie_info_idx2.movie_id = movie_companies2.movie_id;

