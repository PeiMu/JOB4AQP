
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(5);
SELECT sum(pg_lip_bloom_add(0, cn.id)) FROM company_name AS cn WHERE cn.country_code !='[pl]' AND (cn.name LIKE '20th Century Fox%' OR cn.name LIKE 'Twentieth Century Fox%');
SELECT sum(pg_lip_bloom_add(1, ct.id)) FROM company_type AS ct WHERE ct.kind != 'production companies' AND ct.kind IS NOT NULL;
SELECT sum(pg_lip_bloom_add(2, k.id)) FROM keyword AS k WHERE k.keyword IN ('sequel', 'revenge', 'based-on-novel');
SELECT sum(pg_lip_bloom_add(3, mc.movie_id)) FROM movie_companies AS mc WHERE mc.note IS NOT NULL;
SELECT sum(pg_lip_bloom_add(4, t.id)) FROM title AS t WHERE t.production_year > 1950;

/*+
NestLoop(k mk ml mc ct cn lt t)
NestLoop(k mk ml mc ct cn lt)
NestLoop(k mk ml mc ct cn)
NestLoop(k mk ml mc ct)
NestLoop(k mk ml mc)
NestLoop(k mk ml)
NestLoop(k mk)
SeqScan(k)
IndexScan(mk)
IndexScan(ml)
IndexScan(mc)
SeqScan(ct)
IndexScan(cn)
SeqScan(lt)
IndexScan(t)
Leading((((((((k mk) ml) mc) ct) cn) lt) t))*/
SELECT MIN(cn.name) AS from_company,
       MIN(mc.note) AS production_note,
       MIN(t.title) AS movie_based_on_book
 FROM 
company_name AS cn ,
company_type AS ct ,
keyword AS k ,
link_type AS lt ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.company_id)
	AND pg_lip_bloom_probe(1, mc.company_type_id)
	AND pg_lip_bloom_probe(4, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(2, mk.keyword_id)
	AND pg_lip_bloom_probe(3, mk.movie_id)
	AND pg_lip_bloom_probe(4, mk.movie_id)
) AS mk ,
(
	SELECT * FROM movie_link AS ml 
	 WHERE pg_lip_bloom_probe(3, ml.movie_id)
	AND pg_lip_bloom_probe(4, ml.movie_id)
) AS ml ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(3, t.id)
) AS t
WHERE
 cn.country_code !='[pl]'
  AND (cn.name LIKE '20th Century Fox%'
       OR cn.name LIKE 'Twentieth Century Fox%')
  AND ct.kind != 'production companies'
  AND ct.kind IS NOT NULL
  AND k.keyword IN ('sequel',
                    'revenge',
                    'based-on-novel')
  AND mc.note IS NOT NULL
  AND t.production_year > 1950
  AND lt.id = ml.link_type_id
  AND ml.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_type_id = ct.id
  AND mc.company_id = cn.id
  AND ml.movie_id = mk.movie_id
  AND ml.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id;

