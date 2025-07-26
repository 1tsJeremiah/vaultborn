#!/bin/bash
set -e

# Install Python dependencies if requirements.txt exists
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi

# Download Go module dependencies
if [ -f go.mod ]; then
  go mod download
fi

# Download Go modules for vault-agent if present
if [ -d vault-agent ] && [ -f vault-agent/go.mod ]; then
  # Use pushd/popd instead of a subshell to avoid zsh parse errors
  pushd vault-agent > /dev/null
  go mod download
  popd > /dev/null
fi
