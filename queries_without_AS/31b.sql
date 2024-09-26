SELECT MIN(movie_info.info) AS movie_budget,
       MIN(movie_info_idx.info) AS movie_votes,
       MIN(name.name) AS writer,
       MIN(title.title) AS violent_liongate_movie
FROM cast_info,
     company_name,
     info_type,
     info_type,
     keyword,
     movie_companies,
     movie_info,
     movie_info_idx,
     movie_keyword,
     name,
     title
WHERE cast_info.note IN ('(writer)',
                  '(head writer)',
                  '(written by)',
                  '(story)',
                  '(story editor)')
  AND company_name.name LIKE 'Lionsgate%'
  AND info_type.info = 'genres'
  AND info_type.info = 'votes'
  AND keyword.keyword IN ('murder',
                    'violence',
                    'blood',
                    'gore',
                    'death',
                    'female-nudity',
                    'hospital')
  AND movie_companies.note LIKE '%(Blu-ray)%'
  AND movie_info.info IN ('Horror',
                  'Thriller')
  AND name.gender = 'm'
  AND title.production_year > 2000
  AND (title.title LIKE '%Freddy%'
       OR title.title LIKE '%Jason%'
       OR title.title LIKE 'Saw%')
  AND title.id = movie_info.movie_id
  AND title.id = movie_info_idx.movie_id
  AND title.id = cast_info.movie_id
  AND title.id = movie_keyword.movie_id
  AND title.id = movie_companies.movie_id
  AND cast_info.movie_id = movie_info.movie_id
  AND cast_info.movie_id = movie_info_idx.movie_id
  AND cast_info.movie_id = movie_keyword.movie_id
  AND cast_info.movie_id = movie_companies.movie_id
  AND movie_info.movie_id = movie_info_idx.movie_id
  AND movie_info.movie_id = movie_keyword.movie_id
  AND movie_info.movie_id = movie_companies.movie_id
  AND movie_info_idx.movie_id = movie_keyword.movie_id
  AND movie_info_idx.movie_id = movie_companies.movie_id
  AND movie_keyword.movie_id = movie_companies.movie_id
  AND name.id = cast_info.person_id
  AND info_type.id = movie_info.info_type_id
  AND info_type.id = movie_info_idx.info_type_id
  AND keyword.id = movie_keyword.keyword_id
  AND company_name.id = movie_companies.company_id;

