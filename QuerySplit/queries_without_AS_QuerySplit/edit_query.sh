#!/bin/bash

# SQL settings to add to the beginning of each file
settings="switch to c_r;
switch to relationshipcenter;

set effective_cache_size to '8 GB';
set statement_timeout = '1000s';"

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

