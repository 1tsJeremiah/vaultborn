# Project Agents: LLM-Aware Automation

This project uses append-only, always-synced state docs. All agents (Codex, GPT, containers, GitHub Actions, etc) must read `.llmstate/*.jsonl` and `AGENTS.md` on every startup or task.

- State and intent are append-only JSONL files.
- Never overwrite; always append.
- All state changes must be logged before/after each action.

For more: see `.llmstate/patch-pipeline.jsonl`.

Additional guidance for running OpenAI Agent and Codex together is in
`docs/openai-agent-cicd.md`.

## Agent Registry

| Agent      | Health Check Command |
|------------|---------------------|
| vaultd     | curl -fsS http://localhost:8080/healthz |
| vault-agent| ./vault-agent/vault-agent --help >/dev/null |
| traefik    | curl -fsS https://traefik.pegasuswingman.com/dashboard/ |
| weaviate   | curl -fsS -k https://vector.pegasuswingman.com/v1/.well-known/ready |
| minio      | curl -fsS https://storage.pegasuswingman.com/minio/health/live |

## PATCH INTEGRITY & CLEAN PATCH PROTOCOL

**Rule:**
All patches—whether agent-generated, Codex, or manual—**MUST** be produced and applied only against a clean, non-conflicted working copy.
This guarantees traceability, prevents merge artifacts, and ensures agent-driven GitOps at scale.

**Protocol:**

- Never generate, edit, or apply a patch to any file containing Git conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
- If conflict markers are present, resolve all conflicts (manually or with an approved conflict-resolve script) before generating or applying a new patch.
- Agent and Codex workflows **MUST** verify the workspace is clean before producing a patch.
- If a conflict is detected, agents should halt and request resolution, rather than producing an ambiguous or partial patch.
- All unified diff patches must be able to apply cleanly with `git apply` or `patch` with zero manual intervention.
- For append-only log files (e.g., `.llmstate/*.jsonl`), always deduplicate and remove conflict markers before applying or generating new protocol lines.

**Failure to follow this protocol may result in lost data, corrupted audit trails, or agent downtime.**
_This rule is law for all automated and manual patch/merge actions in Vaultborn._


## Codex Environment

This repository ships a `codex.yaml` file that defines the default container image and task commands for OpenAI Codex. The setup script installs Go modules and optional Python dependencies via `scripts/setup.sh`. Linting and tests are run through `scripts/run_tests.sh` which runs `go vet`, `go test`, and a basic Python syntax check. Agents should run these tasks before committing any changes.
