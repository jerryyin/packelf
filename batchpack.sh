#!/usr/bin/env bash
set -e  # Exit immediately on error

SHARED_LIB_DIR="/usr/local/lib/packelf_shared"

# Create the shared library directory if it doesn't exist
mkdir -p "$SHARED_LIB_DIR"

for program in /usr/local/bin/*; do
  if file "$program" | grep -q "dynamically linked"; then
    # Pack the program using packelf.sh
    ./packelf.sh "$program"
  else
    echo "Skipping static program: $program"
  fi
done

echo "All programs processed with consolidated libraries!"