#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <binary_path>"
  exit 1
fi

BINARY_PATH="$1"
PACKELF_DIR="$(dirname "$BINARY_PATH")/packelf"

# Ensure the binary exists
if [ ! -f "$BINARY_PATH" ]; then
  echo "Error: Binary '$BINARY_PATH' not found."
  exit 1
fi

# Create the packelf directory
mkdir -p "$PACKELF_DIR"

echo "Collecting shared libraries for '$BINARY_PATH'..."

# Use ldd to list shared libraries and copy them to packelf directory if not already present
ldd "$BINARY_PATH" | awk '/=>/ { print $3 }' | while read -r LIB_PATH; do
  if [ -n "$LIB_PATH" ] && [ -f "$LIB_PATH" ]; then
    LIB_NAME="$(basename "$LIB_PATH")"
    if [ -f "$PACKELF_DIR/$LIB_NAME" ]; then
      echo "Library '$LIB_NAME' already exists in '$PACKELF_DIR', skipping."
    else
      cp -v "$LIB_PATH" "$PACKELF_DIR/"
    fi
  fi
done

# Also copy the dynamic linker if listed by ldd
LINKER=$(ldd "$BINARY_PATH" | awk '/ld-linux/ { print $1 }')
if [ -n "$LINKER" ] && [ -f "$LINKER" ]; then
  LINKER_NAME="$(basename "$LINKER")"
  if [ -f "$PACKELF_DIR/$LINKER_NAME" ]; then
    echo "Dynamic linker '$LINKER_NAME' already exists in '$PACKELF_DIR', skipping."
  else
    cp -v "$LINKER" "$PACKELF_DIR/"
  fi
fi

echo "Libraries collected in '$PACKELF_DIR'."

# Modify the binary to use the new library path with patchelf
if command -v patchelf &> /dev/null; then
  echo "Modifying binary to use new library path..."
  patchelf --set-rpath "$PACKELF_DIR" "$BINARY_PATH"
  echo "Binary modified successfully."
else
  echo "Warning: 'patchelf' is not installed. Cannot modify binary."
  echo "Manually set LD_LIBRARY_PATH to use the new library path:"
  echo "  export LD_LIBRARY_PATH=\"$PACKELF_DIR\""
fi

echo "Done."