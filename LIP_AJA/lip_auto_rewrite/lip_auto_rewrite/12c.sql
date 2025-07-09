
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(7);
SELECT sum(pg_lip_bloom_add(0, cn.id)) FROM company_name AS cn WHERE cn.country_code = '[us]';
SELECT sum(pg_lip_bloom_add(1, ct.id)) FROM company_type AS ct WHERE ct.kind = 'production companies';
SELECT sum(pg_lip_bloom_add(2, it1.id)) FROM info_type AS it1 WHERE it1.info = 'genres';
SELECT sum(pg_lip_bloom_add(3, it2.id)) FROM info_type AS it2 WHERE it2.info = 'rating';
SELECT sum(pg_lip_bloom_add(4, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('Drama', 'Horror', 'Western', 'Family');
SELECT sum(pg_lip_bloom_add(5, mi_idx.movie_id)) FROM movie_info_idx AS mi_idx WHERE mi_idx.info > '7.0';
SELECT sum(pg_lip_bloom_add(6, t.id)) FROM title AS t WHERE t.production_year between 2000 and 2010;

/*+
HashJoin(mi_idx it2 t mc ct cn mi it1)
NestLoop(mi_idx it2 t mc ct cn mi)
NestLoop(mi_idx it2 t mc ct cn)
HashJoin(mi_idx it2 t mc ct)
NestLoop(mi_idx it2 t mc)
NestLoop(mi_idx it2 t)
HashJoin(mi_idx it2)
SeqScan(mi_idx)
SeqScan(it2)
IndexScan(t)
IndexScan(mc)
SeqScan(ct)
IndexScan(cn)
IndexScan(mi)
SeqScan(it1)
Leading((((((((mi_idx it2) t) mc) ct) cn) mi) it1))*/
SELECT MIN(cn.name) AS movie_company,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS mainstream_movie
 FROM 
company_name AS cn ,
company_type AS ct ,
info_type AS it1 ,
info_type AS it2 ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.company_id)
	AND pg_lip_bloom_probe(1, mc.company_type_id)
	AND pg_lip_bloom_probe(4, mc.movie_id)
	AND pg_lip_bloom_probe(5, mc.movie_id)
	AND pg_lip_bloom_probe(6, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(2, mi.info_type_id)
	AND pg_lip_bloom_probe(5, mi.movie_id)
	AND pg_lip_bloom_probe(6, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_info_idx AS mi_idx 
	 WHERE pg_lip_bloom_probe(3, mi_idx.info_type_id)
	AND pg_lip_bloom_probe(4, mi_idx.movie_id)
	AND pg_lip_bloom_probe(6, mi_idx.movie_id)
) AS mi_idx ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(4, t.id)
	AND pg_lip_bloom_probe(5, t.id)
) AS t
WHERE
 cn.country_code = '[us]'
  AND ct.kind = 'production companies'
  AND it1.info = 'genres'
  AND it2.info = 'rating'
  AND mi.info IN ('Drama',
                  'Horror',
                  'Western',
                  'Family')
  AND mi_idx.info > '7.0'
  AND t.production_year BETWEEN 2000 AND 2010
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND mi.info_type_id = it1.id
  AND mi_idx.info_type_id = it2.id
  AND t.id = mc.movie_id
  AND ct.id = mc.company_type_id
  AND cn.id = mc.company_id
  AND mc.movie_id = mi.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id;

