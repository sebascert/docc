#!/usr/bin/env bash

# Compiles document with given configurations

set -euo pipefail

# constants
script_dir=$(readlink -f "$0" | xargs dirname)

cd "$script_dir" || {
    echo "Error: unable to enter scritp's directory"
    echo "Error: script dir: $script_dir"
    exit 1
} >&2

source_dir=$(realpath src)
config_dir=$(realpath config)
output_dir=$(realpath out)

cd .docc || {
    echo "Error: unable to enter .docc dir"
    exit 1
} >&2

./compile.sh "$source_dir" "$output_dir" "$config_dir"
