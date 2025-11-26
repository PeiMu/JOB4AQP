SELECT MIN(char_name.name) AS character,
       MIN(title.title) AS movie_with_american_producer
FROM char_name,
     cast_info,
     company_name,
     company_type,
     movie_companies,
     role_type,
     title
WHERE cast_info.note LIKE '%(producer)%'
  AND company_name.country_code = '[us]'
  AND title.production_year > 1990
  AND title.id = movie_companies.movie_id
  AND title.id = cast_info.movie_id
  AND cast_info.movie_id = movie_companies.movie_id
  AND char_name.id = cast_info.person_role_id
  AND role_type.id = cast_info.role_id
  AND company_name.id = movie_companies.company_id
  AND company_type.id = movie_companies.company_type_id;
