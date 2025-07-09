
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(4);
SELECT sum(pg_lip_bloom_add(0, ct.id)) FROM company_type AS ct WHERE ct.kind = 'production companies';
SELECT sum(pg_lip_bloom_add(1, mc.movie_id)) FROM movie_companies AS mc WHERE mc.note LIKE '%(VHS)%' AND mc.note LIKE '%(USA)%' AND mc.note LIKE '%(1994)%';
SELECT sum(pg_lip_bloom_add(2, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('USA', 'America');
SELECT sum(pg_lip_bloom_add(3, t.id)) FROM title AS t WHERE t.production_year > 2010;

/*+
NestLoop(ct mc t mi it)
NestLoop(ct mc t mi)
NestLoop(ct mc t)
NestLoop(ct mc)
SeqScan(ct)
SeqScan(mc)
IndexScan(t)
IndexScan(mi)
IndexScan(it)
Leading(((((ct mc) t) mi) it))*/
SELECT MIN(t.title) AS american_vhs_movie
 FROM 
company_type AS ct ,
info_type AS it ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.company_type_id)
	AND pg_lip_bloom_probe(2, mc.movie_id)
	AND pg_lip_bloom_probe(3, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(1, mi.movie_id)
	AND pg_lip_bloom_probe(3, mi.movie_id)
) AS mi ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(1, t.id)
	AND pg_lip_bloom_probe(2, t.id)
) AS t
WHERE
 ct.kind = 'production companies'
  AND mc.note LIKE '%(VHS)%'
  AND mc.note LIKE '%(USA)%'
  AND mc.note LIKE '%(1994)%'
  AND mi.info IN ('USA',
                  'America')
  AND t.production_year > 2010
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND mc.movie_id = mi.movie_id
  AND ct.id = mc.company_type_id
  AND it.id = mi.info_type_id;

