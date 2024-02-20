# join-order-benchmark

This package contains the Join Order Benchmark (JOB) queries from:  
"How Good Are Query Optimizers, Really?"  
by Viktor Leis, Andrey Gubichev, Atans Mirchev, Peter Boncz, Alfons Kemper, Thomas Neumann  
PVLDB Volume 9, No. 3, 2015  
[http://www.vldb.org/pvldb/vol9/p204-leis.pdf](http://www.vldb.org/pvldb/vol9/p204-leis.pdf)

## IMDB-S - 2013 May
The CSV files used in the paper, which are from May 2013, can be found at [imdb harvard dataset](https://dataverse.harvard.edu/file.xhtml?persistentId=doi:10.7910/DVN/2QYZBT/TGYUNU&version=1.1)

1. download dataset

  ```sh
  wget https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/2QYZBT/TGYUNU
  ```

2. use `pg_restore` to restore the dataset

  ```sh
  createuser imdb

  pg_restore -d [database] \:persistentId\?persistentId\=doi\:10.7910%2FDVN%2F2QYZBT%2FTGYUNU
  ## e.g. pg_restore -d pei \:persistentId\?persistentId\=doi\:10.7910%2FDVN%2F2QYZBT%2FTGYUNU

  bash ./switch_owner.sh
  ```

## IMDB-L - latest version
The CSV files with the latest version can be found at [http://homepages.cwi.nl/~boncz/job/imdb.tgz](http://homepages.cwi.nl/~boncz/job/imdb.tgz)

The license and links to the current version IMDB data set can be
found at [http://www.imdb.com/interfaces](http://www.imdb.com/interfaces)

### Step-by-step instructions
1. download `*gz` files (unpacking not necessary)

  ```sh
  wget ftp://ftp.fu-berlin.de/misc/movies/database/frozendata/*gz
  ```
  
2. get `imdbpy` and the `imdbpy2sql.py` script

  ```sh
  git clone git@github.com:cinemagoer/cinemagoer.git
  pip install cinemagoer
  pip install --force-reinstall "SQLAlchemy==1.4"
  pip install psycopg2-binary 

  cd cinemagoer/bin
  python imdbpy2sql.py /directory/with/PlainTextDataFiles/ -u scheme://[user[:password]@]host[:port]/database[?parameters]
  ## e.g. python imdbpy2sql.py -d /home/pei/Project/benckmarks/imdb_pg_dataset/dataset/ -u postgresql://pei@localhost/pei
  ```

Note that this database has some secondary indexes (but not
on all foreign key attributes). You can export all tables to CSV:

  ```sh
  psql < export_csv.sql
  ```

To import the CSV files to another database, create all tables (see
`schema.sql` and optionally `fkindexes.sql`) and run the same copy as
above statements but replace the keyword "to" by "from".

