
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(11);
SELECT sum(pg_lip_bloom_add(0, cct1.id)) FROM comp_cast_type AS cct1 WHERE cct1.kind = 'crew';
SELECT sum(pg_lip_bloom_add(1, cct2.id)) FROM comp_cast_type AS cct2 WHERE cct2.kind != 'complete+verified';
SELECT sum(pg_lip_bloom_add(2, cn.id)) FROM company_name AS cn WHERE cn.country_code != '[us]';
SELECT sum(pg_lip_bloom_add(3, it1.id)) FROM info_type AS it1 WHERE it1.info = 'countries';
SELECT sum(pg_lip_bloom_add(4, it2.id)) FROM info_type AS it2 WHERE it2.info = 'rating';
SELECT sum(pg_lip_bloom_add(5, k.id)) FROM keyword AS k WHERE k.keyword IN ('murder', 'murder-in-title', 'blood', 'violence');
SELECT sum(pg_lip_bloom_add(6, kt.id)) FROM kind_type AS kt WHERE kt.kind IN ('movie', 'episode');
SELECT sum(pg_lip_bloom_add(7, mc.movie_id)) FROM movie_companies AS mc WHERE mc.note NOT LIKE '%(USA)%' AND mc.note LIKE '%(200%)%';
SELECT sum(pg_lip_bloom_add(8, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('Sweden', 'Norway', 'Germany', 'Denmark', 'Swedish', 'Danish', 'Norwegian', 'German', 'USA', 'American');
SELECT sum(pg_lip_bloom_add(9, mi_idx.movie_id)) FROM movie_info_idx AS mi_idx WHERE mi_idx.info < '8.5';
SELECT sum(pg_lip_bloom_add(10, t.id)) FROM title AS t WHERE t.production_year > 2000;

/*+
NestLoop(it2 k mk mi_idx cc cct1 cct2 mc cn ct t mi it1 kt)
NestLoop(it2 k mk mi_idx cc cct1 cct2 mc cn ct t mi it1)
NestLoop(it2 k mk mi_idx cc cct1 cct2 mc cn ct t mi)
NestLoop(it2 k mk mi_idx cc cct1 cct2 mc cn ct t)
NestLoop(it2 k mk mi_idx cc cct1 cct2 mc cn ct)
NestLoop(it2 k mk mi_idx cc cct1 cct2 mc cn)
NestLoop(it2 k mk mi_idx cc cct1 cct2 mc)
NestLoop(it2 k mk mi_idx cc cct1 cct2)
NestLoop(it2 k mk mi_idx cc cct1)
NestLoop(it2 k mk mi_idx cc)
NestLoop(it2 k mk mi_idx)
NestLoop(k mk mi_idx)
NestLoop(k mk)
SeqScan(it2)
SeqScan(k)
IndexScan(mk)
IndexScan(mi_idx)
IndexScan(cc)
SeqScan(cct1)
SeqScan(cct2)
IndexScan(mc)
IndexScan(cn)
SeqScan(ct)
IndexScan(t)
IndexScan(mi)
SeqScan(it1)
SeqScan(kt)
Leading((((((((((((it2 ((k mk) mi_idx)) cc) cct1) cct2) mc) cn) ct) t) mi) it1) kt))*/
SELECT MIN(cn.name) AS movie_company,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS complete_euro_dark_movie
 FROM 
(
	SELECT * FROM complete_cast AS cc 
	 WHERE pg_lip_bloom_probe(0, cc.subject_id)
	AND pg_lip_bloom_probe(1, cc.status_id)
	AND pg_lip_bloom_probe(7, cc.movie_id)
	AND pg_lip_bloom_probe(8, cc.movie_id)
	AND pg_lip_bloom_probe(9, cc.movie_id)
	AND pg_lip_bloom_probe(10, cc.movie_id)
) AS cc ,
comp_cast_type AS cct1 ,
comp_cast_type AS cct2 ,
company_name AS cn ,
company_type AS ct ,
info_type AS it1 ,
info_type AS it2 ,
keyword AS k ,
kind_type AS kt ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(2, mc.company_id)
	AND pg_lip_bloom_probe(8, mc.movie_id)
	AND pg_lip_bloom_probe(9, mc.movie_id)
	AND pg_lip_bloom_probe(10, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(3, mi.info_type_id)
	AND pg_lip_bloom_probe(7, mi.movie_id)
	AND pg_lip_bloom_probe(9, mi.movie_id)
	AND pg_lip_bloom_probe(10, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_info_idx AS mi_idx 
	 WHERE pg_lip_bloom_probe(4, mi_idx.info_type_id)
	AND pg_lip_bloom_probe(7, mi_idx.movie_id)
	AND pg_lip_bloom_probe(8, mi_idx.movie_id)
	AND pg_lip_bloom_probe(10, mi_idx.movie_id)
) AS mi_idx ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(5, mk.keyword_id)
	AND pg_lip_bloom_probe(7, mk.movie_id)
	AND pg_lip_bloom_probe(8, mk.movie_id)
	AND pg_lip_bloom_probe(9, mk.movie_id)
	AND pg_lip_bloom_probe(10, mk.movie_id)
) AS mk ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(6, t.kind_id)
	AND pg_lip_bloom_probe(7, t.id)
	AND pg_lip_bloom_probe(8, t.id)
	AND pg_lip_bloom_probe(9, t.id)
) AS t
WHERE
 cct1.kind = 'crew'
  AND cct2.kind != 'complete+verified'
  AND cn.country_code != '[us]'
  AND it1.info = 'countries'
  AND it2.info = 'rating'
  AND k.keyword IN ('murder',
                    'murder-in-title',
                    'blood',
                    'violence')
  AND kt.kind IN ('movie',
                  'episode')
  AND mc.note NOT LIKE '%(USA)%'
  AND mc.note LIKE '%(200%)%'
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
  AND t.production_year > 2000
  AND kt.id = t.kind_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = mc.movie_id
  AND t.id = cc.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mi_idx.movie_id
  AND mk.movie_id = mc.movie_id
  AND mk.movie_id = cc.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi.movie_id = cc.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND mc.movie_id = cc.movie_id
  AND mi_idx.movie_id = cc.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND it2.id = mi_idx.info_type_id
  AND ct.id = mc.company_type_id
  AND cn.id = mc.company_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id;

