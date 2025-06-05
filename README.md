# join-order-benchmark

This package contains the Join Order Benchmark (JOB) queries from:  
"How Good Are Query Optimizers, Really?"  
by Viktor Leis, Andrey Gubichev, Atans Mirchev, Peter Boncz, Alfons Kemper, Thomas Neumann  
PVLDB Volume 9, No. 3, 2015  
[http://www.vldb.org/pvldb/vol9/p204-leis.pdf](http://www.vldb.org/pvldb/vol9/p204-leis.pdf)


```bash
wget http://event.cwi.nl/da/job/imdb.tgz # The dataset is from May 2013, based the original paper, 
tar -zxvf imdb.tgz
mkdir csv && mv *.csv csv/.
psql -U imdb -d imdb -f schema.sql
# first import data
psql -U imdb -d imdb -f import_csv.sql
# then add the foreign key constraints
psql -U imdb -d imdb -f fkeys.sql
# finally add foreign key index (optional)
psql -U imdb -d imdb -f fkindexes.sql
# analyze table (optional)
psql -U imdb -d imdb -f analyze_table.sql
```
