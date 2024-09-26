SELECT MIN(movie_info.info) AS release_date,
       MIN(title.title) AS youtube_movie
FROM aka_title,
     company_name,
     company_type,
     info_type,
     keyword,
     movie_companies,
     movie_info,
     movie_keyword,
     title
WHERE company_name.country_code = '[us]'
  AND company_name.name = 'YouTube'
  AND info_type.info = 'release dates'
  AND movie_companies.note LIKE '%(200%)%'
  AND movie_companies.note LIKE '%(worldwide)%'
  AND movie_info.note LIKE '%internet%'
  AND movie_info.info LIKE 'USA:% 200%'
  AND title.production_year BETWEEN 2005 AND 2010
  AND title.id = atitle.movie_id
  AND title.id = movie_info.movie_id
  AND title.id = movie_keyword.movie_id
  AND title.id = movie_companies.movie_id
  AND movie_keyword.movie_id = movie_info.movie_id
  AND movie_keyword.movie_id = movie_companies.movie_id
  AND movie_keyword.movie_id = atitle.movie_id
  AND movie_info.movie_id = movie_companies.movie_id
  AND movie_info.movie_id = atitle.movie_id
  AND movie_companies.movie_id = atitle.movie_id
  AND keyword.id = movie_keyword.keyword_id
  AND info_type.id = movie_info.info_type_id
  AND company_name.id = movie_companies.company_id
  AND company_type.id = movie_companies.company_type_id;

