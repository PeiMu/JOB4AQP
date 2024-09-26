SELECT MIN(title.title) AS complete_downey_ironman_movie
FROM complete_cast,
     comp_cast_type,
     comp_cast_type,
     char_namechar_name,
     cast_info,
     keyword,
     kind_typet,
     movie_keyword,
     name,
     title
WHERE comp_cast_type.kind = 'cast'
  AND comp_cast_type.kind LIKE '%complete%'
  AND char_name.name NOT LIKE '%Sherlock%'
  AND (char_name.name LIKE '%Tony%Stark%'
       OR char_name.name LIKE '%Iron%Man%')
  AND keyword.keyword IN ('superhero',
                    'sequel',
                    'second-part',
                    'marvel-comics',
                    'based-on-comic',
                    'tv-special',
                    'fight',
                    'violence')
  AND title.kind = 'movie'
  AND title.production_year > 1950
  AND title.id = title.kind_id
  AND title.id = movie_keyword.movie_id
  AND title.id = cast_info.movie_id
  AND title.id = complete_cast.movie_id
  AND movie_keyword.movie_id = cast_info.movie_id
  AND movie_keyword.movie_id = complete_cast.movie_id
  AND cast_info.movie_id = complete_cast.movie_id
  AND char_name.id = cast_info.person_role_id
  AND name.id = cast_info.person_id
  AND keyword.id = movie_keyword.keyword_id
  AND comp_cast_type.id = complete_cast.subject_id
  AND comp_cast_type.id = complete_cast.status_id;

