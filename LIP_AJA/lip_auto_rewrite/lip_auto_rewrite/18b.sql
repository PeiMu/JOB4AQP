
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(7);
SELECT sum(pg_lip_bloom_add(0, ci.movie_id)) FROM cast_info AS ci WHERE ci.note IN ('(writer)', '(head writer)', '(written by)', '(story)', '(story editor)');
SELECT sum(pg_lip_bloom_add(1, it1.id)) FROM info_type AS it1 WHERE it1.info = 'genres';
SELECT sum(pg_lip_bloom_add(2, it2.id)) FROM info_type AS it2 WHERE it2.info = 'rating';
SELECT sum(pg_lip_bloom_add(3, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('Horror', 'Thriller') AND mi.note IS NULL;
SELECT sum(pg_lip_bloom_add(4, mi_idx.movie_id)) FROM movie_info_idx AS mi_idx WHERE mi_idx.info > '8.0';
SELECT sum(pg_lip_bloom_add(5, n.id)) FROM name AS n WHERE n.gender IS NOT NULL AND n.gender = 'f';
SELECT sum(pg_lip_bloom_add(6, t.id)) FROM title AS t WHERE t.production_year between 2008 and 2014;

/*+
NestLoop(mi_idx it2 t mi it1 ci n)
NestLoop(mi_idx it2 t mi it1 ci)
NestLoop(mi_idx it2 t mi it1)
NestLoop(mi_idx it2 t mi)
NestLoop(mi_idx it2 t)
HashJoin(mi_idx it2)
SeqScan(mi_idx)
SeqScan(it2)
IndexScan(t)
IndexScan(mi)
IndexScan(it1)
IndexScan(ci)
IndexScan(n)
Leading(((((((mi_idx it2) t) mi) it1) ci) n))*/
SELECT MIN(mi.info) AS movie_budget,
       MIN(mi_idx.info) AS movie_votes,
       MIN(t.title) AS movie_title
 FROM 
(
	SELECT * FROM cast_info AS ci 
	 WHERE pg_lip_bloom_probe(3, ci.movie_id)
	AND pg_lip_bloom_probe(4, ci.movie_id)
	AND pg_lip_bloom_probe(5, ci.person_id)
	AND pg_lip_bloom_probe(6, ci.movie_id)
) AS ci ,
info_type AS it1 ,
info_type AS it2 ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(0, mi.movie_id)
	AND pg_lip_bloom_probe(1, mi.info_type_id)
	AND pg_lip_bloom_probe(4, mi.movie_id)
	AND pg_lip_bloom_probe(6, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_info_idx AS mi_idx 
	 WHERE pg_lip_bloom_probe(0, mi_idx.movie_id)
	AND pg_lip_bloom_probe(2, mi_idx.info_type_id)
	AND pg_lip_bloom_probe(3, mi_idx.movie_id)
	AND pg_lip_bloom_probe(6, mi_idx.movie_id)
) AS mi_idx ,
name AS n ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(0, t.id)
	AND pg_lip_bloom_probe(3, t.id)
	AND pg_lip_bloom_probe(4, t.id)
) AS t
WHERE
 ci.note IN ('(writer)',
                  '(head writer)',
                  '(written by)',
                  '(story)',
                  '(story editor)')
  AND it1.info = 'genres'
  AND it2.info = 'rating'
  AND mi.info IN ('Horror',
                  'Thriller')
  AND mi.note IS NULL
  AND mi_idx.info > '8.0'
  AND n.gender IS NOT NULL
  AND n.gender = 'f'
  AND t.production_year BETWEEN 2008 AND 2014
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it2.id = mi_idx.info_type_id;

