#!/bin/bash
set -e
python3 -m venv ~/.venvs/s10tools
~/.venvs/s10tools/bin/pip install -q lz4
~/.venvs/s10tools/bin/python -c "import lz4.frame; print('lz4 ok', lz4.__version__)"
