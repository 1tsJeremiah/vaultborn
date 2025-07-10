#!/bin/bash
set -euo pipefail
SESSION="pegasus"
PROJECT_DIR="$HOME/vaultborn"

echo "==[ ACB: Pegasus Dev Panel with Codex + Lazygit ]=="

# Start new tmux session detached
tmux new-session -d -s "$SESSION" -c "$PROJECT_DIR"

# Left Pane (default): already in $PROJECT_DIR

# Split right vertically and run codex in top right
tmux split-window -h -t "$SESSION:0.0" -c "$PROJECT_DIR"
tmux send-keys -t "$SESSION:0.1" "codex" C-m

# Split bottom right for lazygit (install first if not found)
tmux split-window -v -t "$SESSION:0.1" -c "$PROJECT_DIR"
if ! command -v lazygit &>/dev/null; then
  tmux send-keys -t "$SESSION:0.2" \
    "echo 'Installing lazygit...'" C-m
  tmux send-keys -t "$SESSION:0.2" \
    "sudo apt update && sudo apt install -y lazygit" C-m
  tmux send-keys -t "$SESSION:0.2" "clear && lazygit" C-m
else
  tmux send-keys -t "$SESSION:0.2" "lazygit" C-m
fi

# Attach session
tmux attach-session -t "$SESSION"
