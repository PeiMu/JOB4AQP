#!/bin/bash

# SQL settings to add to the beginning of each file
#settings="set effective_cache_size to '8 GB';\nset statement_timeout = '1000s';\n"
#settings="SET max_parallel_workers = 0;\nSET max_parallel_workers_per_gather = 0;\nSET parallel_leader_participation = off;\n"
settings="
switch to c_r;
switch to relationshipcenter;

SET parallel_leader_participation = off;
set max_parallel_workers = '0';
set max_parallel_workers_per_gather = '0';
set shared_buffers = '512MB';
set temp_buffers = '2047MB';
set work_mem = '2047MB';
set effective_cache_size = '4 GB';
set statement_timeout = '1000s';
set default_statistics_target = 100;
"

# Loop through all SQL files in the current directory
for file in *.sql; do
  # Check if the file is a regular file (to avoid directories, symlinks, etc.)
  if [[ -f "$file" ]]; then
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Prepend the settings to the temporary file
    echo -e "$settings" | cat - "$file" > "$temp_file"
    
    # Move the temporary file back to the original SQL file
    mv "$temp_file" "$file"
    
    echo "Updated $file"
  fi
done

echo "All SQL files updated."

