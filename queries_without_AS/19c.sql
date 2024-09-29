SELECT MIN(name.name) AS voicing_actress,
       MIN(title.title) AS jap_engl_voiced_movie
FROM aka_name,
     char_name,
     cast_info,
     company_name,
     info_type,
     movie_companies,
     movie_info,
     name,
     role_type,
     title
WHERE cast_info.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND company_name.country_code ='[us]'
  AND info_type.info = 'release dates'
  AND movie_info.info IS NOT NULL
  AND (movie_info.info LIKE 'Japan:%200%'
       OR movie_info.info LIKE 'USA:%200%')
  AND name.gender ='f'
  AND name.name LIKE '%An%'
  AND role_type.role ='actress'
  AND title.production_year > 2000
  AND title.id = movie_info.movie_id
  AND title.id = movie_companies.movie_id
  AND title.id = cast_info.movie_id
  AND movie_companies.movie_id = cast_info.movie_id
  AND movie_companies.movie_id = movie_info.movie_id
  AND movie_info.movie_id = cast_info.movie_id
  AND company_name.id = movie_companies.company_id
  AND info_type.id = movie_info.info_type_id
  AND name.id = cast_info.person_id
  AND role_type.id = cast_info.role_id
  AND name.id = aka_name.person_id
  AND cast_info.person_id = aka_name.person_id
  AND char_name.id = cast_info.person_role_id;

