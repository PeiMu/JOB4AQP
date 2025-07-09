
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(6);
SELECT sum(pg_lip_bloom_add(0, cn.id)) FROM company_name AS cn WHERE cn.country_code ='[us]';
SELECT sum(pg_lip_bloom_add(1, ct.id)) FROM company_type AS ct WHERE ct.kind ='production companies';
SELECT sum(pg_lip_bloom_add(2, it.id)) FROM info_type AS it WHERE it.info ='rating';
SELECT sum(pg_lip_bloom_add(3, it2.id)) FROM info_type AS it2 WHERE it2.info ='release dates';
SELECT sum(pg_lip_bloom_add(4, kt.id)) FROM kind_type AS kt WHERE kt.kind ='movie';
SELECT sum(pg_lip_bloom_add(5, t.id)) FROM title AS t WHERE t.title != '' AND (t.title LIKE 'Champion%' OR t.title LIKE 'Loser%');

/*+
NestLoop(miidx it t kt mc cn ct mi it2)
NestLoop(miidx it t kt mc cn ct mi)
NestLoop(miidx it t kt mc cn ct)
NestLoop(miidx it t kt mc cn)
NestLoop(miidx it t kt mc)
NestLoop(miidx it t kt)
NestLoop(miidx it t)
HashJoin(miidx it)
SeqScan(miidx)
SeqScan(it)
IndexScan(t)
IndexScan(kt)
IndexScan(mc)
IndexScan(cn)
IndexScan(ct)
IndexScan(mi)
IndexScan(it2)
Leading(((((((((miidx it) t) kt) mc) cn) ct) mi) it2))*/
SELECT MIN(cn.name) AS producing_company,
       MIN(miidx.info) AS rating,
       MIN(t.title) AS movie_about_winning
 FROM 
company_name AS cn ,
company_type AS ct ,
info_type AS it ,
info_type AS it2 ,
kind_type AS kt ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.company_id)
	AND pg_lip_bloom_probe(1, mc.company_type_id)
	AND pg_lip_bloom_probe(5, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(3, mi.info_type_id)
	AND pg_lip_bloom_probe(5, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_info_idx AS miidx 
	 WHERE pg_lip_bloom_probe(2, miidx.info_type_id)
	AND pg_lip_bloom_probe(5, miidx.movie_id)
) AS miidx ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(4, t.kind_id)
) AS t
WHERE
 cn.country_code ='[us]'
  AND ct.kind ='production companies'
  AND it.info ='rating'
  AND it2.info ='release dates'
  AND kt.kind ='movie'
  AND t.title != ''
  AND (t.title LIKE 'Champion%'
       OR t.title LIKE 'Loser%')
  AND mi.movie_id = t.id
  AND it2.id = mi.info_type_id
  AND kt.id = t.kind_id
  AND mc.movie_id = t.id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id
  AND miidx.movie_id = t.id
  AND it.id = miidx.info_type_id
  AND mi.movie_id = miidx.movie_id
  AND mi.movie_id = mc.movie_id
  AND miidx.movie_id = mc.movie_id;

