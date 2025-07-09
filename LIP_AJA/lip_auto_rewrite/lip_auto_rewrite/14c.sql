
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(7);
SELECT sum(pg_lip_bloom_add(0, it1.id)) FROM info_type AS it1 WHERE it1.info = 'countries';
SELECT sum(pg_lip_bloom_add(1, it2.id)) FROM info_type AS it2 WHERE it2.info = 'rating';
SELECT sum(pg_lip_bloom_add(2, k.id)) FROM keyword AS k WHERE k.keyword IS NOT NULL AND k.keyword IN ('murder', 'murder-in-title', 'blood', 'violence');
SELECT sum(pg_lip_bloom_add(3, kt.id)) FROM kind_type AS kt WHERE kt.kind IN ('movie', 'episode');
SELECT sum(pg_lip_bloom_add(4, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('Sweden', 'Norway', 'Germany', 'Denmark', 'Swedish', 'Danish', 'Norwegian', 'German', 'USA', 'American');
SELECT sum(pg_lip_bloom_add(5, mi_idx.movie_id)) FROM movie_info_idx AS mi_idx WHERE mi_idx.info < '8.5';
SELECT sum(pg_lip_bloom_add(6, t.id)) FROM title AS t WHERE t.production_year > 2005;

/*+
NestLoop(it2 k mk t kt mi_idx mi it1)
NestLoop(it2 k mk t kt mi_idx mi)
NestLoop(it2 k mk t kt mi_idx)
NestLoop(k mk t kt mi_idx)
NestLoop(k mk t kt)
NestLoop(k mk t)
NestLoop(k mk)
SeqScan(it2)
SeqScan(k)
IndexScan(mk)
IndexScan(t)
SeqScan(kt)
IndexScan(mi_idx)
IndexScan(mi)
SeqScan(it1)
Leading((((it2 ((((k mk) t) kt) mi_idx)) mi) it1))*/
SELECT MIN(mi_idx.info) AS rating,
       MIN(t.title) AS north_european_dark_production
 FROM 
info_type AS it1 ,
info_type AS it2 ,
keyword AS k ,
kind_type AS kt ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(0, mi.info_type_id)
	AND pg_lip_bloom_probe(5, mi.movie_id)
	AND pg_lip_bloom_probe(6, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_info_idx AS mi_idx 
	 WHERE pg_lip_bloom_probe(1, mi_idx.info_type_id)
	AND pg_lip_bloom_probe(4, mi_idx.movie_id)
	AND pg_lip_bloom_probe(6, mi_idx.movie_id)
) AS mi_idx ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(2, mk.keyword_id)
	AND pg_lip_bloom_probe(4, mk.movie_id)
	AND pg_lip_bloom_probe(5, mk.movie_id)
	AND pg_lip_bloom_probe(6, mk.movie_id)
) AS mk ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(3, t.kind_id)
	AND pg_lip_bloom_probe(4, t.id)
	AND pg_lip_bloom_probe(5, t.id)
) AS t
WHERE
 it1.info = 'countries'
  AND it2.info = 'rating'
  AND k.keyword IS NOT NULL
  AND k.keyword IN ('murder',
                    'murder-in-title',
                    'blood',
                    'violence')
  AND kt.kind IN ('movie',
                  'episode')
  AND mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Danish',
                  'Norwegian',
                  'German',
                  'USA',
                  'American')
  AND mi_idx.info < '8.5'
  AND t.production_year > 2005
  AND kt.id = t.kind_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mi_idx.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND it2.id = mi_idx.info_type_id;

