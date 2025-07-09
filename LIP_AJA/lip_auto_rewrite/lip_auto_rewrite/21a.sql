
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(7);
SELECT sum(pg_lip_bloom_add(0, cn.id)) FROM company_name AS cn WHERE cn.country_code !='[pl]' AND (cn.name LIKE '%Film%' OR cn.name LIKE '%Warner%');
SELECT sum(pg_lip_bloom_add(1, ct.id)) FROM company_type AS ct WHERE ct.kind ='production companies';
SELECT sum(pg_lip_bloom_add(2, k.id)) FROM keyword AS k WHERE k.keyword ='sequel';
SELECT sum(pg_lip_bloom_add(3, lt.id)) FROM link_type AS lt WHERE lt.link LIKE '%follow%';
SELECT sum(pg_lip_bloom_add(4, mc.movie_id)) FROM movie_companies AS mc WHERE mc.note IS NULL;
SELECT sum(pg_lip_bloom_add(5, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('Sweden', 'Norway', 'Germany', 'Denmark', 'Swedish', 'Denish', 'Norwegian', 'German');
SELECT sum(pg_lip_bloom_add(6, t.id)) FROM title AS t WHERE t.production_year between 1950 and 2000;

/*+
NestLoop(lt k mk ml mc cn ct mi t)
NestLoop(lt k mk ml mc cn ct mi)
NestLoop(lt k mk ml mc cn ct)
NestLoop(lt k mk ml mc cn)
NestLoop(lt k mk ml mc)
NestLoop(lt k mk ml)
NestLoop(k mk ml)
NestLoop(k mk)
SeqScan(lt)
SeqScan(k)
IndexScan(mk)
IndexScan(ml)
IndexScan(mc)
IndexScan(cn)
SeqScan(ct)
IndexScan(mi)
IndexScan(t)
Leading(((((((lt ((k mk) ml)) mc) cn) ct) mi) t))*/
SELECT MIN(cn.name) AS company_name,
       MIN(lt.link) AS link_type,
       MIN(t.title) AS western_follow_up
 FROM 
company_name AS cn ,
company_type AS ct ,
keyword AS k ,
link_type AS lt ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.company_id)
	AND pg_lip_bloom_probe(1, mc.company_type_id)
	AND pg_lip_bloom_probe(5, mc.movie_id)
	AND pg_lip_bloom_probe(6, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(4, mi.movie_id)
	AND pg_lip_bloom_probe(6, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(2, mk.keyword_id)
	AND pg_lip_bloom_probe(4, mk.movie_id)
	AND pg_lip_bloom_probe(5, mk.movie_id)
	AND pg_lip_bloom_probe(6, mk.movie_id)
) AS mk ,
(
	SELECT * FROM movie_link AS ml 
	 WHERE pg_lip_bloom_probe(3, ml.link_type_id)
	AND pg_lip_bloom_probe(4, ml.movie_id)
	AND pg_lip_bloom_probe(5, ml.movie_id)
	AND pg_lip_bloom_probe(6, ml.movie_id)
) AS ml ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(4, t.id)
	AND pg_lip_bloom_probe(5, t.id)
) AS t
WHERE
 cn.country_code !='[pl]'
  AND (cn.name LIKE '%Film%'
       OR cn.name LIKE '%Warner%')
  AND ct.kind ='production companies'
  AND k.keyword ='sequel'
  AND lt.link LIKE '%follow%'
  AND mc.note IS NULL
  AND mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Denish',
                  'Norwegian',
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
  AND ml.movie_id = mk.movie_id
  AND ml.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id
  AND ml.movie_id = mi.movie_id
  AND mk.movie_id = mi.movie_id
  AND mc.movie_id = mi.movie_id;

