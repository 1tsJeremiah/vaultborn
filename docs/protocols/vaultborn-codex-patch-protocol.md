# Codex Patch Protocol Framework (Vaultborn)

This document defines the required steps and conventions for all Codex (or LLM agent)-powered development tasks in the Vaultborn repository.

---

## 1. Patch Lifecycle & Tracking
- **Every code or documentation task MUST have a unique Patch ID**
  - Format: `PXXXX` (incrementing) or another consistent scheme.
  - Patch IDs are assigned by incrementing the last `id` in `.llmstate/patch-pipeline.jsonl`.
- **Patch protocol for Codex/agents:**
  1. **Before starting any patch,** read `AGENTS.md` and the latest entries in `.llmstate/patch-pipeline.jsonl` and `.llmstate/notes.jsonl`.
  2. **Log the new task:**
     - Append an entry to `.llmstate/patch-pipeline.jsonl` with status `"started"` (including ID, timestamp, description).
  3. **Code changes:**
     - Add a comment in code referencing the patch ID (e.g., `// PATCH-P0042: ...`).
  4. **Commit and Branching:**
     - The commit message MUST include the patch ID (e.g., `[PATCH-P0042]`), along with a short description.
     - If creating a branch/PR, include the patch ID in the branch name and PR description.
  5. **Post-commit logging:**
     - After a successful commit (and push), append another entry to `.llmstate/patch-pipeline.jsonl` for this patch with status `"committed"`, including the commit SHA.
     - Append a summary note to `.llmstate/notes.jsonl` for agent cross-reference.
---

## 2. State and Notes Conventions
- `.llmstate/patch-pipeline.jsonl` is append-only and the single source of truth for patch/task history.
- `.llmstate/notes.jsonl` stores short, freeform notes about patch intent, coordination, or extra context.
- **Never overwrite or edit existing JSONL entries—always append.**
- Agents/LLMs/CI must re-read these files before any action.
---

## 3. AGENTS.md Protocol
- AGENTS.md contains the full protocol and must be referenced by Codex/LLMs on every task start.
- Update AGENTS.md as needed to reflect new automation standards or task tracking changes.
---

## 4. Example Prompt Template (for Codex/LLM tasks)
"""
Apply the following change: [describe change/task].
- Assign a unique Patch ID by incrementing from .llmstate/patch-pipeline.jsonl.
- Log 'started' and 'committed' entries in .llmstate/patch-pipeline.jsonl with ID, status, timestamp, and commit SHA.
- Add a code comment with the Patch ID.
- Use the Patch ID in all commit messages, branch names, and PR descriptions.
- Append a summary note to .llmstate/notes.jsonl after push.
- Always follow the protocols in AGENTS.md and never overwrite state logs.
"""
---

This is a living document—refer to it before constructing any Codex or LLM-powered prompt for Vaultborn.
