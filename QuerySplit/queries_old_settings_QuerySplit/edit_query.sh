#!/bin/bash

# SQL settings to add to the beginning of each file
#settings="set effective_cache_size to '8 GB';\nset statement_timeout = '1000s';\n"
#settings="SET max_parallel_workers = 0;\nSET max_parallel_workers_per_gather = 0;\nSET parallel_leader_participation = off;\n"
settings="
SET parallel_leader_participation = off;
set max_parallel_workers_per_gather = '0';
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

