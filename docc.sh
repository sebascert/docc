#!/usr/bin/env bash

# Compiles document with given configurations

set -euo pipefail

Usage(){
    cat <<EOF
Usage: docc.sh
  or:  docc.sh [-f|--format]

 modes:
  -f, --format               Format markdown sources in src.

  -h, --help                 Give this help list
  -V, --version              Print program version

See the README.md for more details.
EOF
}

Version(){
    DOCC_VERSION="0.2"
    echo "docc version: $DOCC_VERSION"
}

script_dir=$(readlink -f "$0" | xargs dirname)

cd "$script_dir" || {
    echo "Error: unable to enter scritp's directory"
    echo "Error: script dir: $script_dir"
    exit 1
} >&2

docc_dir=".docc"
source_dir=$(realpath src)
config_dir=$(realpath config)
output_dir=$(realpath out)

# Argument parsing

format_mode=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--format)
            format_mode=true
            shift
            ;;
        -h|--help)
            Usage
            exit 0
            ;;
        -V|--version)
            Version
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            Usage
            exit 1
            ;;
        *)
            echo "Unexpected argument: $1" >&2
            Usage
            exit 1
            ;;
    esac
done

if $format_mode; then
    ./"$docc_dir/format.sh"
else
    cd "$docc_dir" || {
        echo "Error: unable to enter .docc dir"
        exit 1
    } >&2

    ./compile.sh "$source_dir" "$output_dir" "$config_dir"
fi
