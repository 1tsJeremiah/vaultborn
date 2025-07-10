#!/bin/bash
set -euo pipefail
echo "==[ Codex API Key Bootstrap ACB ]=="

ENV_FILE="$HOME/vaultborn/.env"
ZSHRC="$HOME/.zshrc"

# 1. Ensure .env file exists
mkdir -p "$HOME/vaultborn"
touch "$ENV_FILE"

# 2. Add OPENAI_API_KEY= if missing
if ! grep -q '^OPENAI_API_KEY=' "$ENV_FILE"; then
  echo -e "\n# Codex CLI API key" >> "$ENV_FILE"
  echo 'OPENAI_API_KEY=' >> "$ENV_FILE"
fi

# 3. Add auto-source to .zshrc if not already present
if ! grep -q 'vaultborn/.env' "$ZSHRC"; then
  echo -e "\n# Auto-load Codex API key from Vaultborn project" >> "$ZSHRC"
  echo 'if [ -f "$HOME/vaultborn/.env" ]; then' >> "$ZSHRC"
  echo '  set -a' >> "$ZSHRC"
  echo '  source "$HOME/vaultborn/.env"' >> "$ZSHRC"
  echo '  set +a' >> "$ZSHRC"
  echo 'fi' >> "$ZSHRC"
fi

# 4. Open .env in micro for manual key paste
echo
echo "📝 Opening .env in micro — paste your OPENAI_API_KEY after '='"
read -p "Press enter to continue..."
micro "$ENV_FILE"

# 5. Source the .env
set -a
source "$ENV_FILE"
set +a

echo -e "\n✅ .env loaded and Codex CLI should now pick up your API key."
echo "You can test with: codex 'print hello world'"
