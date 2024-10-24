set effective_cache_size to '8 GB';
set statement_timeout = '1000s';

SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(movie_info.info) AS movie_budget,
       MIN(movie_info_idx.info) AS movie_votes,
       MIN(name.name) AS writer,
       MIN(title.title) AS complete_gore_movie
FROM complete_cast,
     comp_cast_type,
     comp_cast_type,
     cast_info,
     info_type,
     info_type,
     keyword,
     movie_info,
     movie_info_idx,
     movie_keyword,
     name,
     title
WHERE comp_cast_type.kind IN ('cast',
                    'crew')
  AND comp_cast_type.kind ='complete+verified'
  AND cast_info.note IN ('(writer)',
                  '(head writer)',
                  '(written by)',
                  '(story)',
                  '(story editor)')
  AND info_type.info = 'genres'
  AND info_type.info = 'votes'
  AND keyword.keyword IN ('murder',
                    'violence',
                    'blood',
                    'gore',
                    'death',
                    'female-nudity',
                    'hospital')
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
  AND title.id = complete_cast.movie_id
  AND cast_info.movie_id = movie_info.movie_id
  AND cast_info.movie_id = movie_info_idx.movie_id
  AND cast_info.movie_id = movie_keyword.movie_id
  AND cast_info.movie_id = complete_cast.movie_id
  AND movie_info.movie_id = movie_info_idx.movie_id
  AND movie_info.movie_id = movie_keyword.movie_id
  AND movie_info.movie_id = complete_cast.movie_id
  AND movie_info_idx.movie_id = movie_keyword.movie_id
  AND movie_info_idx.movie_id = complete_cast.movie_id
  AND movie_keyword.movie_id = complete_cast.movie_id
  AND name.id = cast_info.person_id
  AND info_type.id = movie_info.info_type_id
  AND info_type.id = movie_info_idx.info_type_id
  AND keyword.id = movie_keyword.keyword_id
  AND comp_cast_type.id = complete_cast.subject_id
  AND comp_cast_type.id = complete_cast.status_id;

