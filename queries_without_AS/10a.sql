SELECT MIN(char_name.name) AS uncredited_voiced_character,
       MIN(title.title) AS russian_movie
FROM char_namechar_name,
     cast_info,
     company_name,
     company_type,
     movie_companies,
     role_type,
     title
WHERE cast_info.note LIKE '%(voice)%'
  AND cast_info.note LIKE '%(uncredited)%'
  AND company_name.country_code = '[ru]'
  AND role_type.role = 'actor'
  AND title.production_year > 2005
  AND title.id = movie_companies.movie_id
  AND title.id = cast_info.movie_id
  AND cast_info.movie_id = movie_companies.movie_id
  AND char_name.id = cast_info.person_role_id
  AND role_type.id = cast_info.role_id
  AND company_name.id = movie_companies.company_id
  AND company_type.id = movie_companies.company_type_id;

