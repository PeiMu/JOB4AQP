SELECT MIN(company_name.name) AS first_company,
       MIN(company_name.name) AS second_company,
       MIN(movie_info_idx.info) AS first_rating,
       MIN(movie_info_idx.info) AS second_rating,
       MIN(title.title) AS first_movie,
       MIN(title.title) AS second_movie
FROM company_name,
     info_type,
     kind_typet,
     link_type,
     movie_companies,
     movie_info_idx,
     movie_link,
     title
WHERE company_name.country_code != '[us]'
  AND info_type.info = 'rating'
  AND info_type.info = 'rating'
  AND title.kind IN ('tv series',
                   'episode')
  AND title.kind IN ('tv series',
                   'episode')
  AND link_type.link IN ('sequel',
                  'follows',
                  'followed by')
  AND movie_info_idx.info < '3.5'
  AND title.production_year BETWEEN 2000 AND 2010
  AND link_type.id = movie_link.link_type_id
  AND title.id = movie_link.movie_id
  AND title.id = movie_link.linked_movie_id
  AND info_type.id = movie_info_idx.info_type_id
  AND title.id = movie_info_idx.movie_id
  AND title.id = title.kind_id
  AND company_name.id = company_name.company_id
  AND title.id = company_name.movie_id
  AND movie_link.movie_id = movie_info_idx.movie_id
  AND movie_link.movie_id = company_name.movie_id
  AND movie_info_idx.movie_id = company_name.movie_id
  AND info_type.id = movie_info_idx.info_type_id
  AND title.id = movie_info_idx.movie_id
  AND title.id = title.kind_id
  AND company_name.id = company_name.company_id
  AND title.id = company_name.movie_id
  AND movie_link.linked_movie_id = movie_info_idx.movie_id
  AND movie_link.linked_movie_id = company_name.movie_id
  AND movie_info_idx.movie_id = company_name.movie_id;

