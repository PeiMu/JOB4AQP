SELECT MIN(title.title) AS movie_title
FROM company_name,
     keyword,
     movie_companies,
     movie_keyword,
     title
WHERE company_name.country_code ='[sm]'
  AND keyword.keyword ='character-name-in-title'
  AND company_name.id = movie_companies.company_id
  AND movie_companies.movie_id = title.id
  AND title.id = movie_keyword.movie_id
  AND movie_keyword.keyword_id = keyword.id
  AND movie_companies.movie_id = movie_keyword.movie_id;

