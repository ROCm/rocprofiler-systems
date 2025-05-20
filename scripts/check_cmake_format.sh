#!/usr/bin/env bash
# filepath: \home\rocm\rocprof-sys-source-public\test_clang_format.sh

if ! command -v cmake-format &> /dev/null; then
    echo "cmake-format could not be found. Please install it with 'pip install cmake-format' or 'sudo apt install cmake-format'."
    exit 1
fi

CONFIG_FILE=".cmake-format.yaml"

for file in "$@"; do
    cmake-format -i "$file"
done

exit 0