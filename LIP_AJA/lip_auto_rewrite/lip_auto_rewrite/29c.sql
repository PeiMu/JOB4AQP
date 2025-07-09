
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;

SELECT pg_lip_bloom_set_dynamic(2);
SELECT pg_lip_bloom_init(11);
SELECT sum(pg_lip_bloom_add(0, cct1.id)) FROM comp_cast_type AS cct1 WHERE cct1.kind ='cast';
SELECT sum(pg_lip_bloom_add(1, cct2.id)) FROM comp_cast_type AS cct2 WHERE cct2.kind ='complete+verified';
SELECT sum(pg_lip_bloom_add(2, ci.movie_id)) FROM cast_info AS ci WHERE ci.note IN ('(voice)', '(voice: Japanese version)', '(voice) (uncredited)', '(voice: English version)');
SELECT sum(pg_lip_bloom_add(3, cn.id)) FROM company_name AS cn WHERE cn.country_code ='[us]';
SELECT sum(pg_lip_bloom_add(4, it.id)) FROM info_type AS it WHERE it.info = 'release dates';
SELECT sum(pg_lip_bloom_add(5, it3.id)) FROM info_type AS it3 WHERE it3.info = 'trivia';
SELECT sum(pg_lip_bloom_add(6, k.id)) FROM keyword AS k WHERE k.keyword = 'computer-animation';
SELECT sum(pg_lip_bloom_add(7, mi.movie_id)) FROM movie_info AS mi WHERE mi.info IS NOT NULL AND (mi.info LIKE 'Japan:%200%' OR mi.info LIKE 'USA:%200%');
SELECT sum(pg_lip_bloom_add(8, n.id)) FROM name AS n WHERE n.gender ='f' AND n.name LIKE '%An%';
SELECT sum(pg_lip_bloom_add(9, rt.id)) FROM role_type AS rt WHERE rt.role ='actress';
SELECT sum(pg_lip_bloom_add(10, t.id)) FROM title AS t WHERE t.production_year between 2000 and 2010;

/*+
NestLoop(cct2 cct1 k mk cc t ci mc cn rt pi an chn mi it n it3)
NestLoop(cct2 cct1 k mk cc t ci mc cn rt pi an chn mi it n)
NestLoop(cct2 cct1 k mk cc t ci mc cn rt pi an chn mi it)
NestLoop(cct2 cct1 k mk cc t ci mc cn rt pi an chn mi)
NestLoop(cct2 cct1 k mk cc t ci mc cn rt pi an chn)
NestLoop(cct2 cct1 k mk cc t ci mc cn rt pi an)
NestLoop(cct2 cct1 k mk cc t ci mc cn rt pi)
NestLoop(cct2 cct1 k mk cc t ci mc cn rt)
NestLoop(cct2 cct1 k mk cc t ci mc cn)
NestLoop(cct2 cct1 k mk cc t ci mc)
NestLoop(cct2 cct1 k mk cc t ci)
NestLoop(cct2 cct1 k mk cc t)
NestLoop(cct2 cct1 k mk cc)
NestLoop(cct1 k mk cc)
NestLoop(k mk cc)
NestLoop(k mk)
SeqScan(cct2)
SeqScan(cct1)
SeqScan(k)
IndexScan(mk)
IndexScan(cc)
IndexScan(t)
IndexScan(ci)
IndexScan(mc)
IndexScan(cn)
SeqScan(rt)
IndexScan(pi)
IndexScan(an)
IndexScan(chn)
IndexScan(mi)
SeqScan(it)
IndexScan(n)
SeqScan(it3)
Leading((((((((((((((cct2 (cct1 ((k mk) cc))) t) ci) mc) cn) rt) pi) an) chn) mi) it) n) it3))*/
SELECT MIN(chn.name) AS voiced_char,
       MIN(n.name) AS voicing_actress,
       MIN(t.title) AS voiced_animation
 FROM 
(
	SELECT * FROM aka_name AS an 
	 WHERE pg_lip_bloom_probe(8, an.person_id)
) AS an ,
(
	SELECT * FROM complete_cast AS cc 
	 WHERE pg_lip_bloom_probe(0, cc.subject_id)
	AND pg_lip_bloom_probe(1, cc.status_id)
	AND pg_lip_bloom_probe(2, cc.movie_id)
	AND pg_lip_bloom_probe(7, cc.movie_id)
	AND pg_lip_bloom_probe(10, cc.movie_id)
) AS cc ,
comp_cast_type AS cct1 ,
comp_cast_type AS cct2 ,
char_name AS chn ,
(
	SELECT * FROM cast_info AS ci 
	 WHERE pg_lip_bloom_probe(7, ci.movie_id)
	AND pg_lip_bloom_probe(8, ci.person_id)
	AND pg_lip_bloom_probe(9, ci.role_id)
	AND pg_lip_bloom_probe(10, ci.movie_id)
) AS ci ,
company_name AS cn ,
info_type AS it ,
info_type AS it3 ,
keyword AS k ,
(
	SELECT * FROM movie_companies AS mc 
	 WHERE pg_lip_bloom_probe(2, mc.movie_id)
	AND pg_lip_bloom_probe(3, mc.company_id)
	AND pg_lip_bloom_probe(7, mc.movie_id)
	AND pg_lip_bloom_probe(10, mc.movie_id)
) AS mc ,
(
	SELECT * FROM movie_info AS mi 
	 WHERE pg_lip_bloom_probe(2, mi.movie_id)
	AND pg_lip_bloom_probe(4, mi.info_type_id)
	AND pg_lip_bloom_probe(10, mi.movie_id)
) AS mi ,
(
	SELECT * FROM movie_keyword AS mk 
	 WHERE pg_lip_bloom_probe(2, mk.movie_id)
	AND pg_lip_bloom_probe(6, mk.keyword_id)
	AND pg_lip_bloom_probe(7, mk.movie_id)
	AND pg_lip_bloom_probe(10, mk.movie_id)
) AS mk ,
name AS n ,
(
	SELECT * FROM person_info AS pi 
	 WHERE pg_lip_bloom_probe(5, pi.info_type_id)
	AND pg_lip_bloom_probe(8, pi.person_id)
) AS pi ,
role_type AS rt ,
(
	SELECT * FROM title AS t 
	 WHERE pg_lip_bloom_probe(2, t.id)
	AND pg_lip_bloom_probe(7, t.id)
) AS t
WHERE
 cct1.kind ='cast'
  AND cct2.kind ='complete+verified'
  AND ci.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code ='[us]'
  AND it.info = 'release dates'
  AND it3.info = 'trivia'
  AND k.keyword = 'computer-animation'
  AND mi.info IS NOT NULL
  AND (mi.info LIKE 'Japan:%200%'
       OR mi.info LIKE 'USA:%200%')
  AND n.gender ='f'
  AND n.name LIKE '%An%'
  AND rt.role ='actress'
  AND t.production_year BETWEEN 2000 AND 2010
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

