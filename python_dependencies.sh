#!/usr/bin/env bash

# Install doc-compiler dependencies

set -euo pipefail

pyvenv=".venv"
pyrequirements="requirements.txt"

python3 -m venv "$pyvenv"
source "$pyvenv/bin/activate"

pip install -r "$pyrequirements"
