
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(7);
SELECT sum(pg_lip_bloom_add(0, cct1.id)) FROM comp_cast_type AS cct1 WHERE cct1.kind = 'complete+verified';
SELECT sum(pg_lip_bloom_add(1, cn.id)) FROM company_name AS cn WHERE cn.country_code = '[us]';
SELECT sum(pg_lip_bloom_add(2, it1.id)) FROM info_type AS it1 WHERE it1.info = 'release dates';
SELECT sum(pg_lip_bloom_add(3, k.id)) FROM keyword AS k WHERE k.keyword IN ('nerd', 'loner', 'alienation', 'dignity');
SELECT sum(pg_lip_bloom_add(4, kt.id)) FROM kind_type AS kt WHERE kt.kind IN ('movie');
SELECT sum(pg_lip_bloom_add(5, mi.movie_id)) FROM movie_info AS mi WHERE mi.note LIKE '%internet%' AND mi.info LIKE 'USA:% 200%';
SELECT sum(pg_lip_bloom_add(6, t.id)) FROM title AS t WHERE t.production_year > 2000;

/*+
NestLoop(cct1 kt k mk t cc mc cn ct mi it1)
NestLoop(cct1 kt k mk t cc mc cn ct mi)
NestLoop(cct1 kt k mk t cc mc cn ct)
NestLoop(cct1 kt k mk t cc mc cn)
NestLoop(cct1 kt k mk t cc mc)
NestLoop(cct1 kt k mk t cc)
NestLoop(kt k mk t cc)
NestLoop(kt k mk t)
NestLoop(k mk t)
NestLoop(k mk)
SeqScan(cct1)
SeqScan(kt)
SeqScan(k)
IndexScan(mk)
IndexScan(t)
IndexScan(cc)
IndexScan(mc)
IndexScan(cn)
SeqScan(ct)
IndexScan(mi)
SeqScan(it1)
Leading(((((((cct1 ((kt ((k mk) t)) cc)) mc) cn) ct) mi) it1))*/
SELECT MIN(kt.kind) AS movie_kind,
       MIN(t.title) AS complete_nerdy_internet_movie
 FROM 
(
	SELECT * FROM complete_cast AS cc 
	 WHERE pg_lip_bloom_probe(0, cc.status_id)
	AND pg_lip_bloom_probe(5, cc.movie_id)
	AND pg_lip_bloom_probe(6, cc.movie_id)
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
	AND pg_lip_bloom_probe(5, mc.movie_id)
	AND pg_lip_bloom_probe(6, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(2, mi.info_type_id)
	AND pg_lip_bloom_probe(6, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(3, mk.keyword_id)
	AND pg_lip_bloom_probe(5, mk.movie_id)
	AND pg_lip_bloom_probe(6, mk.movie_id)
) AS mk ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(4, t.kind_id)
	AND pg_lip_bloom_probe(5, t.id)
) AS t
WHERE
 cct1.kind = 'complete+verified'
  AND cn.country_code = '[us]'
  AND it1.info = 'release dates'
  AND k.keyword IN ('nerd',
                    'loner',
                    'alienation',
                    'dignity')
  AND kt.kind IN ('movie')
  AND mi.note LIKE '%internet%'
  AND mi.info LIKE 'USA:% 200%'
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

