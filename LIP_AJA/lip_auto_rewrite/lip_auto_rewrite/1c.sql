
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(4);
SELECT sum(pg_lip_bloom_add(0, ct.id)) FROM company_type AS ct WHERE ct.kind = 'production companies';
SELECT sum(pg_lip_bloom_add(1, it.id)) FROM info_type AS it WHERE it.info = 'top 250 rank';
SELECT sum(pg_lip_bloom_add(2, mc.movie_id)) FROM movie_companies AS mc WHERE mc.note NOT LIKE '%(as Metro-Goldwyn-Mayer Pictures)%' AND (mc.note LIKE '%(co-production)%');
SELECT sum(pg_lip_bloom_add(3, t.id)) FROM title AS t WHERE t.production_year >2010;

/*+
NestLoop(mi_idx it mc ct t)
HashJoin(mi_idx it mc ct)
NestLoop(mi_idx it mc)
HashJoin(mi_idx it)
SeqScan(mi_idx)
SeqScan(it)
IndexScan(mc)
SeqScan(ct)
IndexScan(t)
Leading(((((mi_idx it) mc) ct) t))*/
SELECT MIN(mc.note) AS production_note,
       MIN(t.title) AS movie_title,
       MIN(t.production_year) AS movie_year
 FROM 
company_type AS ct ,
info_type AS it ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.company_type_id)
	AND pg_lip_bloom_probe(3, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info_idx AS mi_idx 
	 WHERE pg_lip_bloom_probe(1, mi_idx.info_type_id)
	AND pg_lip_bloom_probe(2, mi_idx.movie_id)
	AND pg_lip_bloom_probe(3, mi_idx.movie_id)
) AS mi_idx ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(2, t.id)
) AS t
WHERE
 ct.kind = 'production companies'
  AND it.info = 'top 250 rank'
  AND mc.note NOT LIKE '%(as Metro-Goldwyn-Mayer Pictures)%'
  AND (mc.note LIKE '%(co-production)%')
  AND t.production_year >2010
  AND ct.id = mc.company_type_id
  AND t.id = mc.movie_id
  AND t.id = mi_idx.movie_id
  AND mc.movie_id = mi_idx.movie_id
  AND it.id = mi_idx.info_type_id;

