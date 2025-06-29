#!/bin/bash
set -e

mkdir -p "$HOME/vaultborn/.llmstate"

# 1. Canonical agent doc (AGENTS.md)
cat <<'DOC' > "$HOME/vaultborn/AGENTS.md"
# Project Agents: LLM-Aware Automation

This project uses append-only, always-synced state docs. All agents (Codex, GPT, containers, GitHub Actions, etc) must read `.llmstate/*.jsonl` and `AGENTS.md` on every startup or task.

- State and intent are append-only JSONL files.
- Never overwrite; always append.
- All state changes must be logged before/after each action.

For more: see `.llmstate/patch-pipeline.jsonl`.
DOC

# 2. Example state JSONL (update/merge as needed)
cat <<'JSONL' > "$HOME/vaultborn/.llmstate/patch-pipeline.jsonl"
{ "id": 1, "goal": "Trace every patch with a unique tracking tag", "status": "done" }
JSONL

# 3. Symlink docs for container/dev agent discovery
[ -e "$HOME/AGENTS.md" ] || ln -s "$HOME/vaultborn/AGENTS.md" "$HOME/AGENTS.md"
[ -e "$HOME/.llmstate" ]  || ln -s "$HOME/vaultborn/.llmstate" "$HOME/.llmstate"

# 4. Optional: Add a badge to README
if [[ -f "$HOME/vaultborn/README.md" ]] && ! grep -q 'AGENTS.md' "$HOME/vaultborn/README.md"; then
  echo -e "\n[Agent Protocol](./AGENTS.md) | [Patch Pipeline State](.llmstate/patch-pipeline.jsonl)\n" >> "$HOME/vaultborn/README.md"
fi

# 5. Optional: GitHub Actions/CI context sync
gitdir="$HOME/vaultborn/.github/workflows"
mkdir -p "$gitdir"
cat <<'YAML' > "$gitdir/agentstate-context.yml"
name: Agent State Bootstrap
on: [push]
jobs:
  context:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Print Agent State
        run: |
          cat AGENTS.md
          cat .llmstate/patch-pipeline.jsonl
YAML

# 6. Optional: Codex/env/LLM path reference
grep -q "LLMSTATE_PATH" "$HOME/vaultborn/.env" 2>/dev/null || echo "LLMSTATE_PATH=.llmstate/patch-pipeline.jsonl" >> "$HOME/vaultborn/.env"

# 7. Final nudge
cat <<MSG
>> Review, commit, and push to ALL BRANCHES for world peace.
   - Use: 'run-patch' or equivalent to update state
   - AGENTS.md and .llmstate/ must never diverge
   - Codex/.env LLMSTATE_PATH set
MSG
