#!/usr/bin/env bash

# Install doc-compiler dependencies
# Usage: python_deps.sh <virtual env>

set -euo pipefail

pyvenv="$1"
pyrequirements="requirements.txt"

python3 -m venv "$pyvenv"
source "$pyvenv/bin/activate"

pip install -r "$pyrequirements"
