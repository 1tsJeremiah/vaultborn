# OpenAI Agent + Codex CI/CD Integration

This guide describes how to run OpenAI Agent and OpenAI Codex together to manage Vaultborn's infrastructure.

## Overview

The workflow pairs the Codex code assistant with the Agent runtime so that code changes produced by Codex can be validated and deployed automatically.

1. **Codex Planning** – Codex analyses `.llmstate/*.jsonl` and `AGENTS.md` to plan a patch.
2. **Agent Execution** – The Agent runs tasks described by Codex and updates state logs.
3. **CI Pipeline** – GitHub Actions executes the Agent inside a container to verify and deploy infrastructure.

## Requirements

- `OPENAI_API_KEY` available in repository secrets.
- Docker and GitHub Actions runners.

## Running Locally

```bash
# PATCH-P0009: example invocation
scripts/agent-bootstrap.sh --task "deploy-stack"
```

## CI/CD Workflow

The `openai-codex-ci.yml` workflow runs on every push and provides the Agent with context from `AGENTS.md` and `.llmstate`.
