
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(5);
SELECT sum(pg_lip_bloom_add(0, cn.id)) FROM company_name AS cn WHERE cn.country_code ='[de]';
SELECT sum(pg_lip_bloom_add(1, ct.id)) FROM company_type AS ct WHERE ct.kind ='production companies';
SELECT sum(pg_lip_bloom_add(2, it1.id)) FROM info_type AS it1 WHERE it1.info ='rating';
SELECT sum(pg_lip_bloom_add(3, it2.id)) FROM info_type AS it2 WHERE it2.info ='release dates';
SELECT sum(pg_lip_bloom_add(4, kt.id)) FROM kind_type AS kt WHERE kt.kind ='movie';

/*+
HashJoin(mi_idx it1 t kt mc ct cn mi it2)
NestLoop(mi_idx it1 t kt mc ct cn mi)
NestLoop(mi_idx it1 t kt mc ct cn)
HashJoin(mi_idx it1 t kt mc ct)
NestLoop(mi_idx it1 t kt mc)
HashJoin(mi_idx it1 t kt)
NestLoop(mi_idx it1 t)
HashJoin(mi_idx it1)
SeqScan(mi_idx)
SeqScan(it1)
IndexScan(t)
SeqScan(kt)
IndexScan(mc)
SeqScan(ct)
IndexScan(cn)
IndexScan(mi)
SeqScan(it2)
Leading(((((((((mi_idx it1) t) kt) mc) ct) cn) mi) it2))*/
SELECT MIN(mi.info) AS release_date,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS german_movie
 FROM 
company_name AS cn ,
company_type AS ct ,
info_type AS it1 ,
info_type AS it2 ,
kind_type AS kt ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.company_id)
	AND pg_lip_bloom_probe(1, mc.company_type_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(3, mi.info_type_id)
) AS mi ,
(
	SELECT * FROM movie_info_idx AS mi_idx 
	 WHERE pg_lip_bloom_probe(2, mi_idx.info_type_id)
) AS mi_idx ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(4, t.kind_id)
) AS t
WHERE
 cn.country_code ='[de]'
  AND ct.kind ='production companies'
  AND it1.info ='rating'
  AND it2.info ='release dates'
  AND kt.kind ='movie'
  AND mi.movie_id = t.id
  AND it2.id = mi.info_type_id
  AND kt.id = t.kind_id
  AND mc.movie_id = t.id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id
  AND mi_idx.movie_id = t.id
  AND it1.id = mi_idx.info_type_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi_idx.movie_id = mc.movie_id;

