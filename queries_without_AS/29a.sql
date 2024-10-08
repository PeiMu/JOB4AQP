set effective_cache_size to '8 GB';
set statement_timeout = '1000s';

SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(char_name.name) AS voiced_char,
       MIN(name.name) AS voicing_actress,
       MIN(title.title) AS voiced_animation
FROM aka_name,
     complete_cast,
     comp_cast_type,
     comp_cast_type,
     char_name,
     cast_info,
     company_name,
     info_type,
     info_type,
     keyword,
     movie_companies,
     movie_info,
     movie_keyword,
     name,
     person_info,
     role_type,
     title
WHERE comp_cast_type.kind ='cast'
  AND comp_cast_type.kind ='complete+verified'
  AND char_name.name = 'Queen'
  AND cast_info.note IN ('(voice)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND company_name.country_code ='[us]'
  AND info_type.info = 'release dates'
  AND info_type.info = 'trivia'
  AND keyword.keyword = 'computer-animation'
  AND movie_info.info IS NOT NULL
  AND (movie_info.info LIKE 'Japan:%200%'
       OR movie_info.info LIKE 'USA:%200%')
  AND name.gender ='f'
  AND name.name LIKE '%An%'
  AND role_type.role ='actress'
  AND title.title = 'Shrek 2'
  AND title.production_year BETWEEN 2000 AND 2010
  AND title.id = movie_info.movie_id
  AND title.id = movie_companies.movie_id
  AND title.id = cast_info.movie_id
  AND title.id = movie_keyword.movie_id
  AND title.id = complete_cast.movie_id
  AND movie_companies.movie_id = cast_info.movie_id
  AND movie_companies.movie_id = movie_info.movie_id
  AND movie_companies.movie_id = movie_keyword.movie_id
  AND movie_companies.movie_id = complete_cast.movie_id
  AND movie_info.movie_id = cast_info.movie_id
  AND movie_info.movie_id = movie_keyword.movie_id
  AND movie_info.movie_id = complete_cast.movie_id
  AND cast_info.movie_id = movie_keyword.movie_id
  AND cast_info.movie_id = complete_cast.movie_id
  AND movie_keyword.movie_id = complete_cast.movie_id
  AND company_name.id = movie_companies.company_id
  AND info_type.id = movie_info.info_type_id
  AND name.id = cast_info.person_id
  AND role_type.id = cast_info.role_id
  AND name.id = aka_name.person_id
  AND cast_info.person_id = aka_name.person_id
  AND char_name.id = cast_info.person_role_id
  AND name.id = person_info.person_id
  AND cast_info.person_id = person_info.person_id
  AND info_type.id = person_info.info_type_id
  AND keyword.id = movie_keyword.keyword_id
  AND comp_cast_type.id = complete_cast.subject_id
  AND comp_cast_type.id = complete_cast.status_id;

