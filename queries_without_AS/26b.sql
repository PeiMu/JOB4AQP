set effective_cache_size to '8 GB';
set statement_timeout = '1000s';

SET max_parallel_workers = 0;
SET max_parallel_workers_per_gather = 0;
SET parallel_leader_participation = off;

SELECT MIN(char_name.name) AS character_name,
       MIN(movie_info_idx.info) AS rating,
       MIN(title.title) AS complete_hero_movie
FROM complete_cast,
     comp_cast_type,
     comp_cast_type,
     char_name,
     cast_info,
     info_type,
     keyword,
     kind_type,
     movie_info_idx,
     movie_keyword,
     name,
     title
WHERE comp_cast_type.kind = 'cast'
  AND comp_cast_type.kind LIKE '%complete%'
  AND char_name.name IS NOT NULL
  AND (char_name.name LIKE '%man%'
       OR char_name.name LIKE '%Man%')
  AND info_type.info = 'rating'
  AND keyword.keyword IN ('superhero',
                    'marvel-comics',
                    'based-on-comic',
                    'fight')
  AND title.kind = 'movie'
  AND movie_info_idx.info > '8.0'
  AND title.production_year > 2005
  AND title.id = title.kind_id
  AND title.id = movie_keyword.movie_id
  AND title.id = cast_info.movie_id
  AND title.id = complete_cast.movie_id
  AND title.id = movie_info_idx.movie_id
  AND movie_keyword.movie_id = cast_info.movie_id
  AND movie_keyword.movie_id = complete_cast.movie_id
  AND movie_keyword.movie_id = movie_info_idx.movie_id
  AND cast_info.movie_id = complete_cast.movie_id
  AND cast_info.movie_id = movie_info_idx.movie_id
  AND complete_cast.movie_id = movie_info_idx.movie_id
  AND char_name.id = cast_info.person_role_id
  AND name.id = cast_info.person_id
  AND keyword.id = movie_keyword.keyword_id
  AND comp_cast_type.id = complete_cast.subject_id
  AND comp_cast_type.id = complete_cast.status_id
  AND info_type.id = movie_info_idx.info_type_id;

