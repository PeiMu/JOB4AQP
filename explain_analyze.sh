#!/bin/bash
dst_dir="/home/pei/benchmarks/imdb_job-postgres/skinner_explained"
rm -f "$dst_dir"/*

mkdir -p "${dst_dir}"

src_dir="/home/pei/benchmarks/imdb_job-postgres/skinnerdb_queries"

for sql in "${src_dir}"/*; do
  output_file="${sql}_explained.sql"
  # Read input file line by line
  while IFS= read -r line; do
    # Check if line contains "select" statement
    if [[ $line == select* ]]; then
      # Add "explain analyze" before "select" statement
      echo "explain analyze $line" >> "$output_file"
    elif [[ $line == SELECT* ]]; then
      # Add "EXPLAIN ANALYZE " before "SELECT" statement
      echo "EXPLAIN ANALYZE $line" >> "$output_file"
    else
      # Copy other lines as they are
      echo "$line" >> "$output_file"
    fi
  done < "${sql}"
done

mv "$src_dir"/*.sql_explained.sql "$dst_dir"/
