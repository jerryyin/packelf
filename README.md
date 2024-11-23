# Packelf

PackElf is a simple Bash script that collects all shared libraries required by an executable into a designated directory and modifies the executable to use these bundled libraries. This makes the executable more portable and self-contained, ensuring it can run with the exact versions of the required libraries. Packelf is inspired by https://github.com/oufm/packelf.

## Features
- Automatically collects shared libraries listed by ldd.
- Optionally modifies the executable to use the bundled libraries with patchelf.

## Requirements
- ldd: Used to list the shared libraries of the executable.
- patchelf (optional): Required to modify the binary to use the new library path.

## Usage
Run the script with the path to your executable:

```bash
./packelf.sh <binary_path>
```

## Output
All required libraries are collected in the packelf directory located next to the binary.
The binary is modified (if patchelf is available) to use the new library path.
If patchelf is not installed, manually set the LD_LIBRARY_PATH to use the collected libraries:

```bash
export LD_LIBRARY_PATH="/path/to/packelf"
./your_executable
```

## Limitations
- This tool assumes that all libraries can be resolved using ldd. If your binary uses custom loaders or libraries that ldd cannot resolve, those may need to be handled manually.
- Requires patchelf for fully automated patching. Without it, you’ll need to set LD_LIBRARY_PATH manually.