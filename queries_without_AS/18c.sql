SELECT MIN(movie_info.info) AS movie_budget,
       MIN(movie_info_idx.info) AS movie_votes,
       MIN(title.title) AS movie_title
FROM cast_info,
     info_type,
     info_type,
     movie_info,
     movie_info_idx,
     name,
     title
WHERE cast_info.note IN ('(writer)',
                  '(head writer)',
                  '(written by)',
                  '(story)',
                  '(story editor)')
  AND info_type.info = 'genres'
  AND info_type.info = 'votes'
  AND movie_info.info IN ('Horror',
                  'Action',
                  'Sci-Fi',
                  'Thriller',
                  'Crime',
                  'War')
  AND name.gender = 'm'
  AND title.id = movie_info.movie_id
  AND title.id = movie_info_idx.movie_id
  AND title.id = cast_info.movie_id
  AND cast_info.movie_id = movie_info.movie_id
  AND cast_info.movie_id = movie_info_idx.movie_id
  AND movie_info.movie_id = movie_info_idx.movie_id
  AND name.id = cast_info.person_id
  AND info_type.id = movie_info.info_type_id
  AND info_type.id = movie_info_idx.info_type_id;

