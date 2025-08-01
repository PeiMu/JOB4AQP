
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(9);
SELECT sum(pg_lip_bloom_add(0, cct1.id)) FROM comp_cast_type AS cct1 WHERE cct1.kind IN ('cast', 'crew');
SELECT sum(pg_lip_bloom_add(1, cct2.id)) FROM comp_cast_type AS cct2 WHERE cct2.kind = 'complete';
SELECT sum(pg_lip_bloom_add(2, cn.id)) FROM company_name AS cn WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%');
SELECT sum(pg_lip_bloom_add(3, ct.id)) FROM company_type AS ct WHERE ct.kind ='production companies';
SELECT sum(pg_lip_bloom_add(4, k.id)) FROM keyword AS k WHERE k.keyword ='sequel';
SELECT sum(pg_lip_bloom_add(5, lt.id)) FROM link_type AS lt WHERE lt.link LIKE '%follow%';
SELECT sum(pg_lip_bloom_add(6, mc.movie_id)) FROM movie_companies AS mc WHERE mc.note IS NULL;
SELECT sum(pg_lip_bloom_add(7, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('Sweden', 'Germany', 'Swedish', 'German');
SELECT sum(pg_lip_bloom_add(8, t.id)) FROM title AS t WHERE t.production_year between 1950 and 2000;

/*+
NestLoop(cc ml lt cct2 cct1 mc ct cn t mi mk k)
NestLoop(cc ml lt cct2 cct1 mc ct cn t mi mk)
NestLoop(cc ml lt cct2 cct1 mc ct cn t mi)
NestLoop(cc ml lt cct2 cct1 mc ct cn t)
NestLoop(cc ml lt cct2 cct1 mc ct cn)
HashJoin(cc ml lt cct2 cct1 mc ct)
NestLoop(cc ml lt cct2 cct1 mc)
HashJoin(cc ml lt cct2 cct1)
HashJoin(cc ml lt cct2)
MergeJoin(cc ml lt)
HashJoin(ml lt)
IndexScan(cc)
SeqScan(ml)
SeqScan(lt)
SeqScan(cct2)
SeqScan(cct1)
IndexScan(mc)
SeqScan(ct)
IndexScan(cn)
IndexScan(t)
IndexScan(mi)
IndexScan(mk)
IndexScan(k)
Leading(((((((((((cc (ml lt)) cct2) cct1) mc) ct) cn) t) mi) mk) k))*/
SELECT MIN(cn.name) AS producing_company,
       MIN(lt.link) AS link_type,
       MIN(t.title) AS complete_western_sequel
 FROM 
(
	SELECT * FROM complete_cast AS cc 
	 WHERE pg_lip_bloom_probe(0, cc.subject_id)
	AND pg_lip_bloom_probe(1, cc.status_id)
	AND pg_lip_bloom_probe(6, cc.movie_id)
	AND pg_lip_bloom_probe(7, cc.movie_id)
	AND pg_lip_bloom_probe(8, cc.movie_id)
) AS cc ,
comp_cast_type AS cct1 ,
comp_cast_type AS cct2 ,
company_name AS cn ,
company_type AS ct ,
keyword AS k ,
link_type AS lt ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(2, mc.company_id)
	AND pg_lip_bloom_probe(3, mc.company_type_id)
	AND pg_lip_bloom_probe(7, mc.movie_id)
	AND pg_lip_bloom_probe(8, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(6, mi.movie_id)
	AND pg_lip_bloom_probe(8, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(4, mk.keyword_id)
	AND pg_lip_bloom_probe(6, mk.movie_id)
	AND pg_lip_bloom_probe(7, mk.movie_id)
	AND pg_lip_bloom_probe(8, mk.movie_id)
) AS mk ,
(
	SELECT * FROM movie_link AS ml 
	 WHERE pg_lip_bloom_probe(5, ml.link_type_id)
	AND pg_lip_bloom_probe(6, ml.movie_id)
	AND pg_lip_bloom_probe(7, ml.movie_id)
	AND pg_lip_bloom_probe(8, ml.movie_id)
) AS ml ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(6, t.id)
	AND pg_lip_bloom_probe(7, t.id)
) AS t
WHERE
 cct1.kind IN ('cast',
                    'crew')
  AND cct2.kind = 'complete'
  AND cn.country_code !='[pl]'
  AND (cn.name LIKE '%Film%'
       OR cn.name LIKE '%Warner%')
  AND ct.kind ='production companies'
  AND k.keyword ='sequel'
  AND lt.link LIKE '%follow%'
  AND mc.note IS NULL
  AND mi.info IN ('Sweden',
                  'Germany',
                  'Swedish',
                  'German')
  AND t.production_year BETWEEN 1950 AND 2000
  AND lt.id = ml.link_type_id
  AND ml.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_type_id = ct.id
  AND mc.company_id = cn.id
  AND mi.movie_id = t.id
  AND t.id = cc.movie_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id
  AND ml.movie_id = mk.movie_id
  AND ml.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id
  AND ml.movie_id = mi.movie_id
  AND mk.movie_id = mi.movie_id
  AND mc.movie_id = mi.movie_id
  AND ml.movie_id = cc.movie_id
  AND mk.movie_id = cc.movie_id
  AND mc.movie_id = cc.movie_id
  AND mi.movie_id = cc.movie_id;

