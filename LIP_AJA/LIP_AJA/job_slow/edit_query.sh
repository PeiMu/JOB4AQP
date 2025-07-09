#!/bin/bash

settings="
DROP EXTENSION IF EXISTS pg_lip_bloom;
CREATE EXTENSION pg_lip_bloom;
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

