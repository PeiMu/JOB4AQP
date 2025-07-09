
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(12);
SELECT sum(pg_lip_bloom_add(0, cct1.id)) FROM comp_cast_type AS cct1 WHERE cct1.kind ='cast';
SELECT sum(pg_lip_bloom_add(1, cct2.id)) FROM comp_cast_type AS cct2 WHERE cct2.kind ='complete+verified';
SELECT sum(pg_lip_bloom_add(2, chn.id)) FROM char_name AS chn WHERE chn.name = 'Queen';
SELECT sum(pg_lip_bloom_add(3, ci.movie_id)) FROM cast_info AS ci WHERE ci.note IN ('(voice)', '(voice) (uncredited)', '(voice: English version)');
SELECT sum(pg_lip_bloom_add(4, cn.id)) FROM company_name AS cn WHERE cn.country_code ='[us]';
SELECT sum(pg_lip_bloom_add(5, it.id)) FROM info_type AS it WHERE it.info = 'release dates';
SELECT sum(pg_lip_bloom_add(6, it3.id)) FROM info_type AS it3 WHERE it3.info = 'height';
SELECT sum(pg_lip_bloom_add(7, k.id)) FROM keyword AS k WHERE k.keyword = 'computer-animation';
SELECT sum(pg_lip_bloom_add(8, mi.movie_id)) FROM movie_info AS mi WHERE mi.info LIKE 'USA:%200%';
SELECT sum(pg_lip_bloom_add(9, n.id)) FROM name AS n WHERE n.gender ='f' AND n.name LIKE '%An%';
SELECT sum(pg_lip_bloom_add(10, rt.id)) FROM role_type AS rt WHERE rt.role ='actress';
SELECT sum(pg_lip_bloom_add(11, t.id)) FROM title AS t WHERE t.title = 'Shrek 2' AND t.production_year between 2000 and 2005;

/*+
NestLoop(k mk t ci pi an cc cct1 cct2 chn mc cn mi it n it3 rt)
NestLoop(k mk t ci pi an cc cct1 cct2 chn mc cn mi it n it3)
NestLoop(k mk t ci pi an cc cct1 cct2 chn mc cn mi it n)
NestLoop(k mk t ci pi an cc cct1 cct2 chn mc cn mi it)
NestLoop(k mk t ci pi an cc cct1 cct2 chn mc cn mi)
NestLoop(k mk t ci pi an cc cct1 cct2 chn mc cn)
NestLoop(k mk t ci pi an cc cct1 cct2 chn mc)
NestLoop(k mk t ci pi an cc cct1 cct2 chn)
NestLoop(k mk t ci pi an cc cct1 cct2)
NestLoop(k mk t ci pi an cc cct1)
NestLoop(k mk t ci pi an cc)
NestLoop(k mk t ci pi an)
NestLoop(k mk t ci pi)
NestLoop(k mk t ci)
NestLoop(k mk t)
NestLoop(k mk)
SeqScan(k)
IndexScan(mk)
IndexScan(t)
IndexScan(ci)
IndexScan(pi)
IndexScan(an)
IndexScan(cc)
SeqScan(cct1)
SeqScan(cct2)
IndexScan(chn)
IndexScan(mc)
IndexScan(cn)
IndexScan(mi)
SeqScan(it)
IndexScan(n)
SeqScan(it3)
SeqScan(rt)
Leading(((((((((((((((((k mk) t) ci) pi) an) cc) cct1) cct2) chn) mc) cn) mi) it) n) it3) rt))*/
SELECT MIN(chn.name) AS voiced_char,
       MIN(n.name) AS voicing_actress,
       MIN(t.title) AS voiced_animation
 FROM 
(
	SELECT * FROM aka_name AS an 
	 WHERE pg_lip_bloom_probe(9, an.person_id)
) AS an ,
(
	SELECT * FROM complete_cast AS cc 
	 WHERE pg_lip_bloom_probe(0, cc.subject_id)
	AND pg_lip_bloom_probe(1, cc.status_id)
	AND pg_lip_bloom_probe(3, cc.movie_id)
	AND pg_lip_bloom_probe(8, cc.movie_id)
	AND pg_lip_bloom_probe(11, cc.movie_id)
) AS cc ,
comp_cast_type AS cct1 ,
comp_cast_type AS cct2 ,
char_name AS chn ,
(
	SELECT * FROM cast_info AS ci 
	 WHERE pg_lip_bloom_probe(2, ci.person_role_id)
	AND pg_lip_bloom_probe(8, ci.movie_id)
	AND pg_lip_bloom_probe(9, ci.person_id)
	AND pg_lip_bloom_probe(10, ci.role_id)
	AND pg_lip_bloom_probe(11, ci.movie_id)
) AS ci ,
company_name AS cn ,
info_type AS it ,
info_type AS it3 ,
keyword AS k ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(3, mc.movie_id)
	AND pg_lip_bloom_probe(4, mc.company_id)
	AND pg_lip_bloom_probe(8, mc.movie_id)
	AND pg_lip_bloom_probe(11, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(3, mi.movie_id)
	AND pg_lip_bloom_probe(5, mi.info_type_id)
	AND pg_lip_bloom_probe(11, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(3, mk.movie_id)
	AND pg_lip_bloom_probe(7, mk.keyword_id)
	AND pg_lip_bloom_probe(8, mk.movie_id)
	AND pg_lip_bloom_probe(11, mk.movie_id)
) AS mk ,
name AS n ,
(
	SELECT * FROM person_info AS pi 
	 WHERE pg_lip_bloom_probe(6, pi.info_type_id)
	AND pg_lip_bloom_probe(9, pi.person_id)
) AS pi ,
role_type AS rt ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(3, t.id)
	AND pg_lip_bloom_probe(8, t.id)
) AS t
WHERE
 cct1.kind ='cast'
  AND cct2.kind ='complete+verified'
  AND chn.name = 'Queen'
  AND ci.note IN ('(voice)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code ='[us]'
  AND it.info = 'release dates'
  AND it3.info = 'height'
  AND k.keyword = 'computer-animation'
  AND mi.info LIKE 'USA:%200%'
  AND n.gender ='f'
  AND n.name LIKE '%An%'
  AND rt.role ='actress'
  AND t.title = 'Shrek 2'
  AND t.production_year BETWEEN 2000 AND 2005
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND t.id = mk.movie_id
  AND t.id = cc.movie_id
  AND mc.movie_id = ci.movie_id
  AND mc.movie_id = mi.movie_id
  AND mc.movie_id = mk.movie_id
  AND mc.movie_id = cc.movie_id
  AND mi.movie_id = ci.movie_id
  AND mi.movie_id = mk.movie_id
  AND mi.movie_id = cc.movie_id
  AND ci.movie_id = mk.movie_id
  AND ci.movie_id = cc.movie_id
  AND mk.movie_id = cc.movie_id
  AND cn.id = mc.company_id
  AND it.id = mi.info_type_id
  AND n.id = ci.person_id
  AND rt.id = ci.role_id
  AND n.id = an.person_id
  AND ci.person_id = an.person_id
  AND chn.id = ci.person_role_id
  AND n.id = pi.person_id
  AND ci.person_id = pi.person_id
  AND it3.id = pi.info_type_id
  AND k.id = mk.keyword_id
  AND cct1.id = cc.subject_id
  AND cct2.id = cc.status_id;

