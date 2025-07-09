
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(8);
SELECT sum(pg_lip_bloom_add(0, cn1.id)) FROM company_name AS cn1 WHERE cn1.country_code = '[us]';
SELECT sum(pg_lip_bloom_add(1, it1.id)) FROM info_type AS it1 WHERE it1.info = 'rating';
SELECT sum(pg_lip_bloom_add(2, it2.id)) FROM info_type AS it2 WHERE it2.info = 'rating';
SELECT sum(pg_lip_bloom_add(3, kt1.id)) FROM kind_type AS kt1 WHERE kt1.kind IN ('tv series');
SELECT sum(pg_lip_bloom_add(4, kt2.id)) FROM kind_type AS kt2 WHERE kt2.kind IN ('tv series');
SELECT sum(pg_lip_bloom_add(5, lt.id)) FROM link_type AS lt WHERE lt.link IN ('sequel', 'follows', 'followed by');
SELECT sum(pg_lip_bloom_add(6, mi_idx2.id)) FROM movie_info_idx AS mi_idx2 WHERE mi_idx2.info < '3.0';
SELECT sum(pg_lip_bloom_add(7, t2.id)) FROM title AS t2 WHERE t2.production_year between 2005 and 2008;

/*+
NestLoop(mi_idx1 ml lt it1 t1 kt1 mi_idx2 it2 mc2 t2 mc1 cn1 cn2 kt2)
NestLoop(mi_idx1 ml lt it1 t1 kt1 mi_idx2 it2 mc2 t2 mc1 cn1 cn2)
NestLoop(mi_idx1 ml lt it1 t1 kt1 mi_idx2 it2 mc2 t2 mc1 cn1)
NestLoop(mi_idx1 ml lt it1 t1 kt1 mi_idx2 it2 mc2 t2 mc1)
NestLoop(mi_idx1 ml lt it1 t1 kt1 mi_idx2 it2 mc2 t2)
NestLoop(mi_idx1 ml lt it1 t1 kt1 mi_idx2 it2 mc2)
HashJoin(mi_idx1 ml lt it1 t1 kt1 mi_idx2 it2)
NestLoop(mi_idx1 ml lt it1 t1 kt1 mi_idx2)
HashJoin(mi_idx1 ml lt it1 t1 kt1)
NestLoop(mi_idx1 ml lt it1 t1)
HashJoin(mi_idx1 ml lt it1)
MergeJoin(mi_idx1 ml lt)
HashJoin(ml lt)
IndexScan(mi_idx1)
SeqScan(ml)
SeqScan(lt)
SeqScan(it1)
IndexScan(t1)
SeqScan(kt1)
IndexScan(mi_idx2)
SeqScan(it2)
IndexScan(mc2)
IndexScan(t2)
IndexScan(mc1)
IndexScan(cn1)
IndexScan(cn2)
IndexScan(kt2)
Leading(((((((((((((mi_idx1 (ml lt)) it1) t1) kt1) mi_idx2) it2) mc2) t2) mc1) cn1) cn2) kt2))*/
SELECT MIN(cn1.name) AS first_company,
       MIN(cn2.name) AS second_company,
       MIN(mi_idx1.info) AS first_rating,
       MIN(mi_idx2.info) AS second_rating,
       MIN(t1.title) AS first_movie,
       MIN(t2.title) AS second_movie
 FROM 
company_name AS cn1 ,
company_name AS cn2 ,
info_type AS it1 ,
info_type AS it2 ,
kind_type AS kt1 ,
kind_type AS kt2 ,
link_type AS lt ,
(
	SELECT * FROM movie_companies AS mc1 
	 WHERE pg_lip_bloom_probe(0, mc1.company_id)
) AS mc1 ,
(
	SELECT * FROM movie_companies AS mc2 
	 WHERE pg_lip_bloom_probe(7, mc2.movie_id)
) AS mc2 ,
(
	SELECT * FROM movie_info_idx AS mi_idx1 
	 WHERE pg_lip_bloom_probe(1, mi_idx1.info_type_id)
) AS mi_idx1 ,
(
	SELECT * FROM movie_info_idx AS mi_idx2 
	 WHERE pg_lip_bloom_probe(2, mi_idx2.info_type_id)
	AND pg_lip_bloom_probe(7, mi_idx2.movie_id)
) AS mi_idx2 ,
(
	SELECT * FROM movie_link AS ml 
	 WHERE pg_lip_bloom_probe(5, ml.link_type_id)
	AND pg_lip_bloom_probe(7, ml.linked_movie_id)
) AS ml ,
(
	SELECT * FROM title AS t1 
	 WHERE pg_lip_bloom_probe(3, t1.kind_id)
) AS t1 ,
(
	SELECT * FROM title AS t2 
	 WHERE pg_lip_bloom_probe(4, t2.kind_id)
) AS t2
WHERE
 cn1.country_code = '[us]'
  AND it1.info = 'rating'
  AND it2.info = 'rating'
  AND kt1.kind IN ('tv series')
  AND kt2.kind IN ('tv series')
  AND lt.link IN ('sequel',
                  'follows',
                  'followed by')
  AND mi_idx2.info < '3.0'
  AND t2.production_year BETWEEN 2005 AND 2008
  AND lt.id = ml.link_type_id
  AND t1.id = ml.movie_id
  AND t2.id = ml.linked_movie_id
  AND it1.id = mi_idx1.info_type_id
  AND t1.id = mi_idx1.movie_id
  AND kt1.id = t1.kind_id
  AND cn1.id = mc1.company_id
  AND t1.id = mc1.movie_id
  AND ml.movie_id = mi_idx1.movie_id
  AND ml.movie_id = mc1.movie_id
  AND mi_idx1.movie_id = mc1.movie_id
  AND it2.id = mi_idx2.info_type_id
  AND t2.id = mi_idx2.movie_id
  AND kt2.id = t2.kind_id
  AND cn2.id = mc2.company_id
  AND t2.id = mc2.movie_id
  AND ml.linked_movie_id = mi_idx2.movie_id
  AND ml.linked_movie_id = mc2.movie_id
  AND mi_idx2.movie_id = mc2.movie_id;

