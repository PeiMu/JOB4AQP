
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(6);
SELECT sum(pg_lip_bloom_add(0, an.id)) FROM aka_name AS an WHERE an.name LIKE '%a%';
SELECT sum(pg_lip_bloom_add(1, it.id)) FROM info_type AS it WHERE it.info ='mini biography';
SELECT sum(pg_lip_bloom_add(2, lt.id)) FROM link_type AS lt WHERE lt.link ='features';
SELECT sum(pg_lip_bloom_add(3, n.id)) FROM name AS n WHERE n.name_pcode_cf between 'A' and 'F' AND (n.gender='m' OR (n.gender = 'f' AND n.name LIKE 'B%'));
SELECT sum(pg_lip_bloom_add(4, pi.id)) FROM person_info AS pi WHERE pi.note ='Volker Boehm';
SELECT sum(pg_lip_bloom_add(5, t.id)) FROM title AS t WHERE t.production_year between 1980 and 1995;

/*+
NestLoop(ml lt t ci n pi an it)
NestLoop(ml lt t ci n pi an)
NestLoop(ml lt t ci n pi)
NestLoop(ml lt t ci n)
NestLoop(ml lt t ci)
NestLoop(ml lt t)
HashJoin(ml lt)
SeqScan(ml)
SeqScan(lt)
IndexScan(t)
IndexScan(ci)
IndexScan(n)
IndexScan(pi)
IndexScan(an)
SeqScan(it)
Leading((((((((ml lt) t) ci) n) pi) an) it))*/
SELECT MIN(n.name) AS of_person,
       MIN(t.title) AS biography_movie
 FROM 
(
	SELECT * FROM aka_name AS an 
	 WHERE pg_lip_bloom_probe(3, an.person_id)
) AS an ,
(
	SELECT * FROM cast_info AS ci 
	 WHERE pg_lip_bloom_probe(3, ci.person_id)
	AND pg_lip_bloom_probe(5, ci.movie_id)
) AS ci ,
info_type AS it ,
link_type AS lt ,
(
	SELECT * FROM movie_link AS ml 
	 WHERE pg_lip_bloom_probe(2, ml.link_type_id)
	AND pg_lip_bloom_probe(5, ml.linked_movie_id)
) AS ml ,
name AS n ,
(
	SELECT * FROM person_info AS pi 
	 WHERE pg_lip_bloom_probe(1, pi.info_type_id)
	AND pg_lip_bloom_probe(3, pi.person_id)
) AS pi ,
title AS t
WHERE
 an.name LIKE '%a%'
  AND it.info ='mini biography'
  AND lt.link ='features'
  AND n.name_pcode_cf BETWEEN 'A' AND 'F'
  AND (n.gender='m'
       OR (n.gender = 'f'
           AND n.name LIKE 'B%'))
  AND pi.note ='Volker Boehm'
  AND t.production_year BETWEEN 1980 AND 1995
  AND n.id = an.person_id
  AND n.id = pi.person_id
  AND ci.person_id = n.id
  AND t.id = ci.movie_id
  AND ml.linked_movie_id = t.id
  AND lt.id = ml.link_type_id
  AND it.id = pi.info_type_id
  AND pi.person_id = an.person_id
  AND pi.person_id = ci.person_id
  AND an.person_id = ci.person_id
  AND ci.movie_id = ml.linked_movie_id;

--         of_person        | biography_movie
-- -------------------------+-----------------
--  Antonioni, Michelangelo | Dressed to Kill