#!/usr/bin/env bash

# Retrieves key from config or prints error
# Usage: getkey.sh <optional|mandatory> KEY FILE TYPE
# Valid types:
#     bool
#     number
#     string
#     array

set -euo pipefail

[ $# -eq 4 ] || {
    exit 1
} >&2

optional_str=$1
expected_type=$2
key=$3
file=$4

case "$optional_str" in
    optional) optional=0 ;;
    mandatory) optional=1 ;;
    *)
        {
            echo "GetKey Error: invalid optional arg '$optional_str'"
        } >&2
        exit 1
        ;;
esac

command -v yq > /dev/null 2>&1  || {
    echo "yq is not installed"
    exit 1
} >&2

type="$(yq -r ".${key} | type" "$file")"

# Handle missing key
if [ "$type" == "null" ]; then
    [ $optional -eq 0 ] || {
        echo "Config Error: missing mandatory key '$key'"
        exit 1
    } >&2
    exit 0
fi

# Type check and output
case "$expected_type" in
    bool)
        [ "$type" == "!!bool" ] || {
            echo "Config Error: key '$key' is expected to be a boolean"
            echo "Received type: '$type'"
            exit 1
        } >&2
        if [ "$(yq -r ".${key}" "$file")" == "false" ];then
            echo 0
        else
            echo 1
        fi
        ;;
    number)
        [ "$type" == "!!int" ] || [ "$type" == "!!float" ] || {
            echo "Config Error: key '$key' is expected to be a number"
            echo "Received type: '$type'"
            exit 1
        } >&2
        yq -r ".${key}" "$file"
        ;;
    string)
        [ "$type" == "!!str" ] || {
            echo "Config Error: key '$key' is expected to be a string"
            echo "Received type: '$type'"
            exit 1
        } >&2
        yq -r ".${key}" "$file"
        ;;
    array)
        [ "$type" == "!!seq" ] || [ "$type" == "!!null" ] || {
            echo "Config Error: key '$key' is expected to be an array"
            echo "Received type: '$type'"
            exit 1
        } >&2
        # Output elements separated by nulls for safe reading
        # Usage: mapfile -d '' -t arr < <(./getkey.sh ...)
        yq -r ".${key}[]" "$file" | tr '\n' '\0'
        ;;
    *)
        {
            echo "GetKey Error: invalid type arg '$type'"
        } >&2
        exit 1
        ;;
esac

exit 0
