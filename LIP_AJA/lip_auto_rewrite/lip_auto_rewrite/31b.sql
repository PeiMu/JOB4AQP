
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(9);
SELECT sum(pg_lip_bloom_add(0, ci.movie_id)) FROM cast_info AS ci WHERE ci.note IN ('(writer)', '(head writer)', '(written by)', '(story)', '(story editor)');
SELECT sum(pg_lip_bloom_add(1, cn.id)) FROM company_name AS cn WHERE cn.name LIKE 'Lionsgate%';
SELECT sum(pg_lip_bloom_add(2, it1.id)) FROM info_type AS it1 WHERE it1.info = 'genres';
SELECT sum(pg_lip_bloom_add(3, it2.id)) FROM info_type AS it2 WHERE it2.info = 'votes';
SELECT sum(pg_lip_bloom_add(4, k.id)) FROM keyword AS k WHERE k.keyword IN ('murder', 'violence', 'blood', 'gore', 'death', 'female-nudity', 'hospital');
SELECT sum(pg_lip_bloom_add(5, mc.movie_id)) FROM movie_companies AS mc WHERE mc.note LIKE '%(Blu-ray)%';
SELECT sum(pg_lip_bloom_add(6, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IN ('Horror', 'Thriller');
SELECT sum(pg_lip_bloom_add(7, n.id)) FROM name AS n WHERE n.gender = 'm';
SELECT sum(pg_lip_bloom_add(8, t.id)) FROM title AS t WHERE t.production_year > 2000 AND (t.title LIKE '%Freddy%' OR t.title LIKE '%Jason%' OR t.title LIKE 'Saw%');

/*+
NestLoop(k mk t ci mc cn mi it1 mi_idx it2 n)
NestLoop(k mk t ci mc cn mi it1 mi_idx it2)
NestLoop(k mk t ci mc cn mi it1 mi_idx)
NestLoop(k mk t ci mc cn mi it1)
NestLoop(k mk t ci mc cn mi)
NestLoop(k mk t ci mc cn)
NestLoop(k mk t ci mc)
NestLoop(k mk t ci)
NestLoop(k mk t)
NestLoop(k mk)
IndexScan(k)
IndexScan(mk)
IndexScan(t)
IndexScan(ci)
IndexScan(mc)
IndexScan(cn)
IndexScan(mi)
IndexScan(it1)
IndexScan(mi_idx)
IndexScan(it2)
IndexScan(n)
Leading(((((((((((k mk) t) ci) mc) cn) mi) it1) mi_idx) it2) n))*/
SELECT MIN(mi.info) AS movie_budget,
       MIN(mi_idx.info) AS movie_votes,
       MIN(n.name) AS writer,
       MIN(t.title) AS violent_liongate_movie
 FROM 
(
	SELECT * FROM cast_info AS ci 
	 WHERE pg_lip_bloom_probe(5, ci.movie_id)
	AND pg_lip_bloom_probe(6, ci.movie_id)
	AND pg_lip_bloom_probe(7, ci.person_id)
	AND pg_lip_bloom_probe(8, ci.movie_id)
) AS ci ,
company_name AS cn ,
info_type AS it1 ,
info_type AS it2 ,
keyword AS k ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.movie_id)
	AND pg_lip_bloom_probe(1, mc.company_id)
	AND pg_lip_bloom_probe(6, mc.movie_id)
	AND pg_lip_bloom_probe(8, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(0, mi.movie_id)
	AND pg_lip_bloom_probe(2, mi.info_type_id)
	AND pg_lip_bloom_probe(5, mi.movie_id)
	AND pg_lip_bloom_probe(8, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_info_idx AS mi_idx 
	 WHERE pg_lip_bloom_probe(0, mi_idx.movie_id)
	AND pg_lip_bloom_probe(3, mi_idx.info_type_id)
	AND pg_lip_bloom_probe(5, mi_idx.movie_id)
	AND pg_lip_bloom_probe(6, mi_idx.movie_id)
	AND pg_lip_bloom_probe(8, mi_idx.movie_id)
) AS mi_idx ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(0, mk.movie_id)
	AND pg_lip_bloom_probe(4, mk.keyword_id)
	AND pg_lip_bloom_probe(5, mk.movie_id)
	AND pg_lip_bloom_probe(6, mk.movie_id)
	AND pg_lip_bloom_probe(8, mk.movie_id)
) AS mk ,
name AS n ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(0, t.id)
	AND pg_lip_bloom_probe(5, t.id)
	AND pg_lip_bloom_probe(6, t.id)
) AS t
WHERE
 ci.note IN ('(writer)',
                  '(head writer)',
                  '(written by)',
                  '(story)',
                  '(story editor)')
  AND cn.name LIKE 'Lionsgate%'
  AND it1.info = 'genres'
  AND it2.info = 'votes'
  AND k.keyword IN ('murder',
                    'violence',
                    'blood',
                    'gore',
                    'death',
                    'female-nudity',
                    'hospital')
  AND mc.note LIKE '%(Blu-ray)%'
  AND mi.info IN ('Horror',
                  'Thriller')
  AND n.gender = 'm'
  AND t.production_year > 2000
  AND (t.title LIKE '%Freddy%'
       OR t.title LIKE '%Jason%'
       OR t.title LIKE 'Saw%')
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = ci.movie_id
  AND t.id = mk.movie_id
  AND t.id = mc.movie_id
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND ci.movie_id = mk.movie_id
  AND ci.movie_id = mc.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mk.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi_idx.movie_id = mk.movie_id
  AND mi_idx.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it2.id = mi_idx.info_type_id
  AND k.id = mk.keyword_id
  AND cn.id = mc.company_id;

