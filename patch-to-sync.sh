#!/bin/bash

# Patch-to-sync: micro-based git patch pipeline with enhanced dev UX
# Requirements: micro, git, installed plugins: filemanager, quickopen, clipboard, jump

set -euo pipefail

PATCH_FILE="/tmp/incoming.patch"

function ensure_tools() {
  for cmd in micro git; do
    command -v "$cmd" &>/dev/null || { echo "❌ Missing required tool: $cmd"; exit 1; }
  done
  git rev-parse --is-inside-work-tree &>/dev/null || { echo "❌ Not in a git repo!"; exit 1; }
}

function reset_state() {
  rm -f "$PATCH_FILE"
  trap 'rm -f "$PATCH_FILE"' EXIT
}

function launch_patch_editor() {
  echo "📝 Opening micro for patch input ($PATCH_FILE)..."
  sleep 0.5
  micro -filetype patch "$PATCH_FILE"
}

function sanitize_patch() {
  echo "🧼 Sanitizing patch file…"
  command -v dos2unix &>/dev/null && dos2unix "$PATCH_FILE" &>/dev/null
  sed -i 's/[“”]/"/g; s/[‘’]/'\''/g' "$PATCH_FILE"
  tr -cd '\11\12\15\40-\176' < "$PATCH_FILE" > "$PATCH_FILE.tmp" && mv "$PATCH_FILE.tmp" "$PATCH_FILE"
  sed -i 's/[ \t]*$//' "$PATCH_FILE"
}

function preview_patch() {
  if [[ -s "$PATCH_FILE" ]]; then
    echo -e "\n--- Preview of incoming patch ---"
    head -40 "$PATCH_FILE" | tee /dev/tty
    echo "--- End preview ---"
  else
    echo "❌ No patch content detected. Aborting."
    exit 1
  fi
}

function apply_patch() {
  echo "🛠 Applying patch with 3-way merge if possible..."
  if git apply --3way "$PATCH_FILE"; then
    echo "✅ Patch applied successfully."
    return 0
  else
    echo "❌ Patch failed. Opening conflicted files in micro for manual fix."
    CONFLICTS=$(git status --porcelain | awk '/^UU/ {print $2}')
    if [[ -n "$CONFLICTS" ]]; then
      micro $CONFLICTS
      echo -e "\n💡 After fixing conflicts, stage files and commit manually:"
      echo "   git add <fixed files> && git commit -m 'fix: manual conflict resolution'"
    fi
    return 1
  fi
}

function summary() {
  echo -e "\n--- Git status after patch ---"
  git status -sb
  echo -e "\nIf staged, commit with:\n  git commit -am '[PATCH] <desc>' && git push"
  echo -e "\nMicro nav tips: Ctrl-e filemanager | Ctrl-p quickopen | Alt-g jump | Ctrl-/ comment toggle"
}

# Uncomment to set up alias in ~/.bashrc automatically (run once)
# if ! grep -q "alias run-patch=" ~/.bashrc; then
#   echo "alias run-patch='\$HOME/vaultborn/patch-to-sync.sh'" >> ~/.bashrc
#   echo "✨ Added alias 'run-patch' to ~/.bashrc. Reload your shell to use."
# fi

ensure_tools
reset_state
launch_patch_editor
sanitize_patch
preview_patch
apply_patch
summary

# TEST PATCH EXAMPLE (paste this when micro opens):
# diff --git a/vaultd/main.go b/vaultd/main.go
# index 14064e4..c6b1e5b 100644
# --- a/vaultd/main.go
# +++ b/vaultd/main.go
# @@ -1,6 +1,8 @@
# +// PTEST-1: Patch test - added for sync system verification
# +
#  package main
#  import (
#         "encoding/json"
#         "errors"
#         "fmt"
# ... (rest of file unchanged)
