
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(3);
SELECT sum(pg_lip_bloom_add(0, k.id)) FROM keyword AS k WHERE k.keyword LIKE '%sequel%';
SELECT sum(pg_lip_bloom_add(1, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('Sweden', 'Norway', 'Germany', 'Denmark', 'Swedish', 'Denish', 'Norwegian', 'German', 'USA', 'American');
SELECT sum(pg_lip_bloom_add(2, t.id)) FROM title AS t WHERE t.production_year > 1990;

/*+
NestLoop(k mk t mi)
NestLoop(k mk t)
NestLoop(k mk)
SeqScan(k)
IndexScan(mk)
IndexScan(t)
IndexScan(mi)
Leading((((k mk) t) mi))*/
SELECT MIN(t.title) AS movie_title
 FROM 
keyword AS k ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(2, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(0, mk.keyword_id)
	AND pg_lip_bloom_probe(1, mk.movie_id)
	AND pg_lip_bloom_probe(2, mk.movie_id)
) AS mk ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(1, t.id)
) AS t
WHERE
 k.keyword LIKE '%sequel%'
  AND mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Denish',
                  'Norwegian',
                  'German',
                  'USA',
                  'American')
  AND t.production_year > 1990
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND mk.movie_id = mi.movie_id
  AND k.id = mk.keyword_id;

