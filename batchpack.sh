#!/usr/bin/env bash
set -e  # Exit immediately on error

SHARED_LIB_DIR="/usr/local/lib/packelf_shared"

# Create the shared library directory if it doesn't exist
mkdir -p "$SHARED_LIB_DIR"

for program in /usr/local/bin/*; do
    if file "$program" | grep -q "dynamically linked"; then
        echo "Processing: $program"

        # Pack the program using packelf.sh
        ./packelf.sh "$program" "$program.packed"

        # Unpack into a temporary directory to extract .res content
        TEMP_UNPACK_DIR=$(mktemp -d)
        PACKELF_UNPACK_DIR="$TEMP_UNPACK_DIR" "$program.packed"

        # Move libraries from the .res directory to the shared directory
        RES_DIR="$TEMP_UNPACK_DIR/$(basename "$program").res"
        for lib in "$RES_DIR"/*; do
            lib_name=$(basename "$lib")

            # Move or skip if the library already exists
            if [ ! -e "$SHARED_LIB_DIR/$lib_name" ]; then
                mv "$lib" "$SHARED_LIB_DIR/"
            else
                echo "Skipping duplicate library: $lib_name"
            fi
        done

        # Clean up temporary directory
        rm -rf "$TEMP_UNPACK_DIR"

        # Replace the original program with the packed version
        mv "$program.packed" "$program"
        chmod +x "$program"

        echo "Replaced original with packed binary: $program"
    else
        echo "Skipping static program: $program"
    fi
done

echo "All programs processed with consolidated libraries!"
