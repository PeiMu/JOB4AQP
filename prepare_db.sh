createuser imdb
createdb imdb

psql -U imdb -d imdb -f schema.sql
# first import data
psql -U imdb -d imdb -f import_csv.sql
# then add the foreign key constraints
psql -U imdb -d imdb -f fkeys.sql
# finally add foreign key index (optional)
psql -U imdb -d imdb -f fkindexes.sql
# analyze table (optional)
#psql -U imdb -d imdb -f analyze_table.sql
