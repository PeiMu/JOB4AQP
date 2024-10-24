switch to c_r;
switch to relationshipcenter;

set effective_cache_size to '8 GB';
set statement_timeout = '1000s';
SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(char_name.name) AS voiced_char_name,
       MIN(name.name) AS voicing_actress_name,
       MIN(title.title) AS kung_fu_panda
FROM aka_name,
     char_name,
     cast_info,
     company_name,
     info_type,
     keyword,
     movie_companies,
     movie_info,
     movie_keyword,
     name,
     role_type,
     title
WHERE cast_info.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND company_name.country_code ='[us]'
  AND company_name.name = 'DreamWorks Animation'
  AND info_type.info = 'release dates'
  AND keyword.keyword IN ('hero',
                    'martial-arts',
                    'hand-to-hand-combat',
                    'computer-animated-movie')
  AND movie_info.info IS NOT NULL
  AND (movie_info.info LIKE 'Japan:%201%'
       OR movie_info.info LIKE 'USA:%201%')
  AND name.gender ='f'
  AND name.name LIKE '%An%'
  AND role_type.role ='actress'
  AND title.production_year > 2010
  AND title.title LIKE 'Kung Fu Panda%'
  AND title.id = movie_info.movie_id
  AND title.id = movie_companies.movie_id
  AND title.id = cast_info.movie_id
  AND title.id = movie_keyword.movie_id
  AND movie_companies.movie_id = cast_info.movie_id
  AND movie_companies.movie_id = movie_info.movie_id
  AND movie_companies.movie_id = movie_keyword.movie_id
  AND movie_info.movie_id = cast_info.movie_id
  AND movie_info.movie_id = movie_keyword.movie_id
  AND cast_info.movie_id = movie_keyword.movie_id
  AND company_name.id = movie_companies.company_id
  AND info_type.id = movie_info.info_type_id
  AND name.id = cast_info.person_id
  AND role_type.id = cast_info.role_id
  AND name.id = aka_name.person_id
  AND cast_info.person_id = aka_name.person_id
  AND char_name.id = cast_info.person_role_id
  AND keyword.id = movie_keyword.keyword_id;

