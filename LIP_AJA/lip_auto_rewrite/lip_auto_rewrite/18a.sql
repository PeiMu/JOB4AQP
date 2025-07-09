
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(4);
SELECT sum(pg_lip_bloom_add(0, ci.movie_id)) FROM cast_info AS ci WHERE ci.note IN ('(producer)', '(executive producer)');
SELECT sum(pg_lip_bloom_add(1, it1.id)) FROM info_type AS it1 WHERE it1.info = 'budget';
SELECT sum(pg_lip_bloom_add(2, it2.id)) FROM info_type AS it2 WHERE it2.info = 'votes';
SELECT sum(pg_lip_bloom_add(3, n.id)) FROM name AS n WHERE n.gender = 'm' AND n.name LIKE '%Tim%';

/*+
NestLoop(n ci mi_idx it2 t mi it1)
NestLoop(n ci mi_idx it2 t mi)
NestLoop(n ci mi_idx it2 t)
HashJoin(n ci mi_idx it2)
NestLoop(n ci mi_idx)
NestLoop(n ci)
SeqScan(n)
IndexScan(ci)
IndexScan(mi_idx)
SeqScan(it2)
IndexScan(t)
IndexScan(mi)
IndexScan(it1)
Leading(((((((n ci) mi_idx) it2) t) mi) it1))*/
SELECT MIN(mi.info) AS movie_budget,
       MIN(mi_idx.info) AS movie_votes,
       MIN(t.title) AS movie_title
 FROM 
(
	SELECT * FROM cast_info AS ci 
	 WHERE pg_lip_bloom_probe(3, ci.person_id)
) AS ci ,
info_type AS it1 ,
info_type AS it2 ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(0, mi.movie_id)
	AND pg_lip_bloom_probe(1, mi.info_type_id)
) AS mi ,
(
	SELECT * FROM movie_info_idx AS mi_idx 
	 WHERE pg_lip_bloom_probe(0, mi_idx.movie_id)
	AND pg_lip_bloom_probe(2, mi_idx.info_type_id)
) AS mi_idx ,
name AS n ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(0, t.id)
) AS t
WHERE
 ci.note IN ('(producer)',
                  '(executive producer)')
  AND it1.info = 'budget'
  AND it2.info = 'votes'
  AND n.gender = 'm'
  AND n.name LIKE '%Tim%'
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it2.id = mi_idx.info_type_id;

