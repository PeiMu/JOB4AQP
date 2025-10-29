# compile the correct DuckDB version
#cd ../ && make clean && GEN=ninja VERBOSE=1 make 2>&1|tee -a compile.log && cd measure

rm -f ./imdb.db

# create schema
echo "create imdb schema"
echo -ne ".read imdb_schema.sql" | duckdb ./imdb.db

# load imdb
for table in name aka_name kind_type title aka_title char_name role_type cast_info comp_cast_type company_name company_type complete_cast info_type keyword link_type movie_companies movie_info movie_info_idx movie_keyword movie_link person_info
do
  echo "duckdb load table from ${table}.tbl"
  command="copy ${table} from '$JOB_PATH/csv/${table}.csv' (quote '\"', escape '\\');"
  echo $command
  echo -ne "${command}" | duckdb ./imdb.db
done
