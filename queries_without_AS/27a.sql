SELECT MIN(company_name.name) AS producing_company,
       MIN(link_type.link) AS link_type,
       MIN(title.title) AS complete_western_sequel
FROM complete_cast,
     comp_cast_type,
     comp_cast_type,
     company_name,
     company_type,
     keyword,
     link_type,
     movie_companies,
     movie_info,
     movie_keyword,
     movie_link,
     title
WHERE comp_cast_type.kind IN ('cast',
                    'crew')
  AND comp_cast_type.kind = 'complete'
  AND company_name.country_code !='[pl]'
  AND (company_name.name LIKE '%Film%'
       OR company_name.name LIKE '%Warner%')
  AND company_type.kind ='production companies'
  AND keyword.keyword ='sequel'
  AND link_type.link LIKE '%follow%'
  AND movie_companies.note IS NULL
  AND movie_info.info IN ('Sweden',
                  'Germany',
                  'Swedish',
                  'German')
  AND title.production_year BETWEEN 1950 AND 2000
  AND link_type.id = movie_link.link_type_id
  AND movie_link.movie_id = title.id
  AND title.id = movie_keyword.movie_id
  AND movie_keyword.keyword_id = keyword.id
  AND title.id = movie_companies.movie_id
  AND movie_companies.company_type_id = company_type.id
  AND movie_companies.company_id = company_name.id
  AND movie_info.movie_id = title.id
  AND title.id = complete_cast.movie_id
  AND comp_cast_type.id = complete_cast.subject_id
  AND comp_cast_type.id = complete_cast.status_id
  AND movie_link.movie_id = movie_keyword.movie_id
  AND movie_link.movie_id = movie_companies.movie_id
  AND movie_keyword.movie_id = movie_companies.movie_id
  AND movie_link.movie_id = movie_info.movie_id
  AND movie_keyword.movie_id = movie_info.movie_id
  AND movie_companies.movie_id = movie_info.movie_id
  AND movie_link.movie_id = complete_cast.movie_id
  AND movie_keyword.movie_id = complete_cast.movie_id
  AND movie_companies.movie_id = complete_cast.movie_id
  AND movie_info.movie_id = complete_cast.movie_id;

