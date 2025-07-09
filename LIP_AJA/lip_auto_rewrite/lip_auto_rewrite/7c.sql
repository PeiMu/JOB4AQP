
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(6);
SELECT sum(pg_lip_bloom_add(0, an.id)) FROM aka_name AS an WHERE an.name IS NOT NULL AND (an.name LIKE '%a%' OR an.name LIKE 'A%');
SELECT sum(pg_lip_bloom_add(1, it.id)) FROM info_type AS it WHERE it.info ='mini biography';
SELECT sum(pg_lip_bloom_add(2, lt.id)) FROM link_type AS lt WHERE lt.link IN ('references', 'referenced in', 'features', 'featured in');
SELECT sum(pg_lip_bloom_add(3, n.id)) FROM name AS n WHERE n.name_pcode_cf between 'A' and 'F' AND (n.gender='m' OR (n.gender = 'f' AND n.name LIKE 'A%'));
SELECT sum(pg_lip_bloom_add(4, pi.id)) FROM person_info AS pi WHERE pi.note IS NOT NULL;
SELECT sum(pg_lip_bloom_add(5, t.id)) FROM title AS t WHERE t.production_year between 1980 and 2010;

/*+
NestLoop(pi it an n ci ml lt t)
HashJoin(pi it an n ci ml lt)
NestLoop(pi it an n ci ml)
NestLoop(pi it an n ci)
NestLoop(pi it an n)
NestLoop(pi it an)
HashJoin(pi it)
SeqScan(pi)
SeqScan(it)
IndexScan(an)
IndexScan(n)
IndexScan(ci)
IndexScan(ml)
SeqScan(lt)
IndexScan(t)
Leading((((((((pi it) an) n) ci) ml) lt) t))*/
SELECT MIN(n.name) AS cast_member_name,
       MIN(pi.info) AS cast_member_info
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
 an.name IS NOT NULL
  AND (an.name LIKE '%a%'
       OR an.name LIKE 'A%')
  AND it.info ='mini biography'
  AND lt.link IN ('references',
                  'referenced in',
                  'features',
                  'featured in')
  AND n.name_pcode_cf BETWEEN 'A' AND 'F'
  AND (n.gender='m'
       OR (n.gender = 'f'
           AND n.name LIKE 'A%'))
  AND pi.note IS NOT NULL
  AND t.production_year BETWEEN 1980 AND 2010
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

