#!/bin/bash
set -e

# Run go vet and go tests
if [ -f go.mod ]; then
  go vet ./...
  go test ./...
fi

# Run go vet for vault-agent if present
if [ -d vault-agent ] && [ -f vault-agent/go.mod ]; then
  (cd vault-agent && go vet ./... && go test ./...)
fi

# Python syntax check for simple scripts
python -m py_compile config.py logger.py scripts/agent_health.py
