
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(6);
SELECT sum(pg_lip_bloom_add(0, ci.movie_id)) FROM cast_info AS ci WHERE ci.note ='(voice: English version)';
SELECT sum(pg_lip_bloom_add(1, cn.id)) FROM company_name AS cn WHERE cn.country_code ='[jp]';
SELECT sum(pg_lip_bloom_add(2, mc.movie_id)) FROM movie_companies AS mc WHERE mc.note LIKE '%(Japan)%' AND mc.note NOT LIKE '%(USA)%' AND (mc.note LIKE '%(2006)%' OR mc.note LIKE '%(2007)%');
SELECT sum(pg_lip_bloom_add(3, n.id)) FROM name AS n WHERE n.name LIKE '%Yo%' AND n.name NOT LIKE '%Yu%';
SELECT sum(pg_lip_bloom_add(4, rt.id)) FROM role_type AS rt WHERE rt.role ='actress';
SELECT sum(pg_lip_bloom_add(5, t.id)) FROM title AS t WHERE t.production_year between 2006 and 2007 AND (t.title LIKE 'One Piece%' OR t.title LIKE 'Dragon Ball Z%');

/*+
NestLoop(mc cn t ci an n rt)
NestLoop(mc cn t ci an n)
NestLoop(mc cn t ci an)
NestLoop(mc cn t ci)
NestLoop(mc cn t)
NestLoop(mc cn)
SeqScan(mc)
IndexScan(cn)
IndexScan(t)
IndexScan(ci)
IndexScan(an)
IndexScan(n)
IndexScan(rt)
Leading(((((((mc cn) t) ci) an) n) rt))*/
SELECT MIN(an.name) AS acress_pseudonym,
       MIN(t.title) AS japanese_anime_movie
 FROM 
(
	SELECT * FROM aka_name AS an 
	 WHERE pg_lip_bloom_probe(3, an.person_id)
) AS an ,
(
	SELECT * FROM cast_info AS ci 
	 WHERE pg_lip_bloom_probe(2, ci.movie_id)
	AND pg_lip_bloom_probe(3, ci.person_id)
	AND pg_lip_bloom_probe(4, ci.role_id)
	AND pg_lip_bloom_probe(5, ci.movie_id)
) AS ci ,
company_name AS cn ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(0, mc.movie_id)
	AND pg_lip_bloom_probe(1, mc.company_id)
	AND pg_lip_bloom_probe(5, mc.movie_id)
) AS mc ,
name AS n ,
role_type AS rt ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(0, t.id)
	AND pg_lip_bloom_probe(2, t.id)
) AS t
WHERE
 ci.note ='(voice: English version)'
  AND cn.country_code ='[jp]'
  AND mc.note LIKE '%(Japan)%'
  AND mc.note NOT LIKE '%(USA)%'
  AND (mc.note LIKE '%(2006)%'
       OR mc.note LIKE '%(2007)%')
  AND n.name LIKE '%Yo%'
  AND n.name NOT LIKE '%Yu%'
  AND rt.role ='actress'
  AND t.production_year BETWEEN 2006 AND 2007
  AND (t.title LIKE 'One Piece%'
       OR t.title LIKE 'Dragon Ball Z%')
  AND an.person_id = n.id
  AND n.id = ci.person_id
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND an.person_id = ci.person_id
  AND ci.movie_id = mc.movie_id;

