#!/usr/bin/env bash

# Format sources
# Usage: format.sh <source dir> <config dir>

set -euo pipefail

source_dir="$1"
config_dir="$2"

cover="$source_dir/cover.md"
prettier_config="$config_dir/.prettierrc"

command -v prettier > /dev/null 2>&1  || {
    echo "prettier is not installed"
    exit 1
} >&2

echo "formatting markdown sources"

find "$source_dir" -name "*.md" ! -path "$cover" -exec \
    prettier --config "$prettier_config" --write {} \;
