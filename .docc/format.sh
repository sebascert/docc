#!/usr/bin/env bash

# Format sources
# Usage: format.sh

set -euo pipefail

command -v dprint > /dev/null 2>&1  || {
    echo "dprint is not installed"
    exit 1
} >&2

echo "formatting markdown sources"

dprint fmt
