
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(6);
SELECT sum(pg_lip_bloom_add(0, cct1.id)) FROM comp_cast_type AS cct1 WHERE cct1.kind = 'complete+verified';
SELECT sum(pg_lip_bloom_add(1, cn.id)) FROM company_name AS cn WHERE cn.country_code = '[us]';
SELECT sum(pg_lip_bloom_add(2, it1.id)) FROM info_type AS it1 WHERE it1.info = 'release dates';
SELECT sum(pg_lip_bloom_add(3, kt.id)) FROM kind_type AS kt WHERE kt.kind IN ('movie');
SELECT sum(pg_lip_bloom_add(4, mi.movie_id)) FROM movie_info AS mi WHERE mi.note LIKE '%internet%' AND mi.info IS NOT NULL AND (mi.info LIKE 'USA:% 199%' OR mi.info LIKE 'USA:% 200%');
SELECT sum(pg_lip_bloom_add(5, t.id)) FROM title AS t WHERE t.production_year > 2000;

/*+
NestLoop(t cc cct1 kt mi it1 mk mc cn ct k)
NestLoop(t cc cct1 kt mi it1 mk mc cn ct)
NestLoop(t cc cct1 kt mi it1 mk mc cn)
NestLoop(t cc cct1 kt mi it1 mk mc)
NestLoop(t cc cct1 kt mi it1 mk)
NestLoop(t cc cct1 kt mi it1)
NestLoop(t cc cct1 kt mi)
HashJoin(t cc cct1 kt)
HashJoin(t cc cct1)
HashJoin(cc cct1)
SeqScan(t)
SeqScan(cc)
SeqScan(cct1)
SeqScan(kt)
IndexScan(mi)
IndexScan(it1)
IndexScan(mk)
IndexScan(mc)
IndexScan(cn)
IndexScan(ct)
IndexScan(k)
Leading((((((((((t (cc cct1)) kt) mi) it1) mk) mc) cn) ct) k))*/
SELECT MIN(kt.kind) AS movie_kind,
       MIN(t.title) AS complete_us_internet_movie
 FROM 
(
	SELECT * FROM complete_cast AS cc 
	 WHERE pg_lip_bloom_probe(0, cc.status_id)
	AND pg_lip_bloom_probe(4, cc.movie_id)
	AND pg_lip_bloom_probe(5, cc.movie_id)
) AS cc ,
comp_cast_type AS cct1 ,
company_name AS cn ,
company_type AS ct ,
info_type AS it1 ,
keyword AS k ,
kind_type AS kt ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(1, mc.company_id)
	AND pg_lip_bloom_probe(4, mc.movie_id)
	AND pg_lip_bloom_probe(5, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(2, mi.info_type_id)
	AND pg_lip_bloom_probe(5, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(4, mk.movie_id)
	AND pg_lip_bloom_probe(5, mk.movie_id)
) AS mk ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(3, t.kind_id)
	AND pg_lip_bloom_probe(4, t.id)
) AS t
WHERE
 cct1.kind = 'complete+verified'
  AND cn.country_code = '[us]'
  AND it1.info = 'release dates'
  AND kt.kind IN ('movie')
  AND mi.note LIKE '%internet%'
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'USA:% 199%'
       OR mi.info LIKE 'USA:% 200%')
  AND t.production_year > 2000
  AND kt.id = t.kind_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mc.movie_id
  AND t.id = cc.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mc.movie_id
  AND mk.movie_id = cc.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi.movie_id = cc.movie_id
  AND mc.movie_id = cc.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id
  AND cct1.id = cc.status_id;

