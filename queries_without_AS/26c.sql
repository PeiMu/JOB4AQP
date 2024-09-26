SELECT MIN(char_name.name) AS character_name,
       MIN(movie_info_idx.info) AS rating,
       MIN(title.title) AS complete_hero_movie
FROM complete_cast,
     comp_cast_type,
     comp_cast_type,
     char_namechar_name,
     cast_info,
     info_type,
     keyword,
     kind_typet,
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
                    'tv-special',
                    'fight',
                    'violence',
                    'magnet',
                    'web',
                    'claw',
                    'laser')
  AND title.kind = 'movie'
  AND title.production_year > 2000
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

