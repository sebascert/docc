#!/usr/bin/env bash

# Compiles document with given configurations
# Usage: compile.sh <source dir> <output dir> <config dir>

set -euo pipefail

source_dir="$1"
output_dir="$2"
config_dir="$3"

pyvenv=".venv"

source "$pyvenv/bin/activate" 2>/dev/null || {
    ./python_deps.sh "$pyvenv" || {
        echo "failed to install python dependencies"
        exit 1
    } >&2
    echo
    source "$pyvenv/bin/activate"
}

config="$config_dir/config.yaml"
metadata="$config_dir/metadata.yaml"
defaults="$config_dir/defaults.yaml"

coverpage_path="$source_dir/cover.md"

# Missing file checks
[ -r "$metadata" ] || {
    echo "Error: unable to access $metadata"
    exit 1
} >&2

[ -r "$config" ] || {
    echo "Error: unable to access $config"
    exit 1
} >&2

# Retrieve configurations

# Output filename
output_filename=$(./yq_getkey.sh mandatory string output-filename "$config") || exit 1
[ -z "$output_filename" ] && {
    echo "Error: output_filename is empty"
    exit 1
} >&2

# Cover page
coverpage_key=$(./yq_getkey.sh mandatory bool cover-page "$config") || exit 1
if [ "$coverpage_key" -eq 1 ]; then
    [ -r "$coverpage_path" ] || {
        echo "Error: unable to access $coverpage_path"
        exit 1
    } >&2
    coverpage="$coverpage_path"
else
    coverpage=""
fi

# sources
./yq_getkey.sh optional array sources "$config" | mapfile -d '' -t listed_sources || exit 1

# Append source dir to listed sources
for i in "${!listed_sources[@]}"; do
    source="$source_dir/${listed_sources[$i]}"
    listed_sources[i]="$source"
done

# Validate listed sources
declare -A listed_sources_set
for source in "${listed_sources[@]}"; do
    [ -n "${listed_sources_set["$source"]-}" ] && {
        echo "Warning: repeated listed source '$source'"
        continue
    }
    [ -r "$source" ] || {
        echo "Warning: unable to access listed source '$source'"
        listed_sources_set["$source"]=1
        continue
    } >&2
    listed_sources_set["$source"]=0
done

# Include all sources
include_all_sources_key=$(./yq_getkey.sh mandatory bool include-all-sources "$config") || exit 1
if [ "$include_all_sources_key" -eq 1 ]; then
    # shellcheck disable=SC2207
    listed_sources=($(find "$source_dir" -name '*.md' ! -path "$coverpage_path"))
else
    for source in "${listed_sources[@]}"; do
        [ "${listed_sources_set["$source"]}" -eq 0 ] || {
            echo "Error: unable to access listed source '$source'"
            exit 1
        } >&2
    done
fi

# Insert coverpage into listed sources
[ -n "$coverpage" ] && listed_sources=("$coverpage" "${listed_sources[@]}")

# Status feedback
[ "${#listed_sources[@]}" -eq 0 ] && {
    echo "nothing to do"
    exit 2
} >&2

{
    echo "compiling sources:"
    for src in "${listed_sources[@]}"; do
        echo "${src#"${source_dir}/"}"
    done
} >&2

# Compile document
mkdir -p "$output_dir"

output="$output_dir/$output_filename"
pandoc_options=("--metadata-file=$metadata" "--defaults=$defaults")

# Enable pandoc include
enable_pandoc_include=$(./yq_getkey.sh optional bool enable-pandoc-include "$config") || exit 1
if [ "$enable_pandoc_include" -eq 1 ]; then
    pandoc_options+=("--filter" "pandoc-include")
fi

cd "$source_dir" || {
    echo "Error: unable to enter .docc dir"
    exit 1
} >&2

pandoc "${pandoc_options[@]}" "${listed_sources[@]}" -o "$output"
