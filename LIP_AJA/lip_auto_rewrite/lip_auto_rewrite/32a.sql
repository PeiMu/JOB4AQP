
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(1);
SELECT sum(pg_lip_bloom_add(0, k.id)) FROM keyword AS k WHERE k.keyword ='10,000-mile-club';

/*+
NestLoop(k mk ml lt t1 t2)
NestLoop(k mk ml lt t1)
NestLoop(k mk ml lt)
NestLoop(k mk ml)
NestLoop(k mk)
SeqScan(k)
IndexScan(mk)
IndexScan(ml)
SeqScan(lt)
IndexScan(t1)
IndexScan(t2)
Leading((((((k mk) ml) lt) t1) t2))*/
SELECT MIN(lt.link) AS link_type,
       MIN(t1.title) AS first_movie,
       MIN(t2.title) AS second_movie
 FROM 
keyword AS k ,
link_type AS lt ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(0, mk.keyword_id)
) AS mk ,
movie_link AS ml ,
title AS t1 ,
title AS t2
WHERE
 k.keyword ='10,000-mile-club'
  AND mk.keyword_id = k.id
  AND t1.id = mk.movie_id
  AND ml.movie_id = t1.id
  AND ml.linked_movie_id = t2.id
  AND lt.id = ml.link_type_id
  AND mk.movie_id = t1.id;

