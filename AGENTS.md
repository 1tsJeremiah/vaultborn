# Project Agents: LLM-Aware Automation

This project uses append-only, always-synced state docs. All agents (Codex, GPT, containers, GitHub Actions, etc) must read `.llmstate/*.jsonl` and `AGENTS.md` on every startup or task.

- State and intent are append-only JSONL files.
- Never overwrite; always append.
- All state changes must be logged before/after each action.

For more: see `.llmstate/patch-pipeline.jsonl`.

## Agent Registry

| Agent      | Health Check Command |
|------------|---------------------|
| vaultd     | curl -fsS http://localhost:8080/healthz |
| vault-agent| ./vault-agent/vault-agent --help >/dev/null |
| traefik    | curl -fsS https://traefik.pegasuswingman.com/dashboard/ |
| weaviate   | curl -fsS -k https://vector.pegasuswingman.com/v1/.well-known/ready |
| minio      | curl -fsS https://storage.pegasuswingman.com/minio/health/live |
