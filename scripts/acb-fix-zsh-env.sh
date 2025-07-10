#!/bin/bash
echo "==[ ACB: ZSH .env Loader Fix + Bootstrap ]=="

ZSHRC="$HOME/.zshrc"
ENV_FILE="$HOME/vaultborn/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ .env file not found at: $ENV_FILE"
  exit 1
fi

echo "🔍 Scrubbing .env for invalid lines..."

# Strip blank lines, Windows CRLF, and anything that’s not KEY=VALUE
VALID_ENV=$(grep -vE '^\s*#|^\s*$' "$ENV_FILE" | grep -E '^[A-Za-z_][A-Za-z0-9_]*=')

if [[ -z "$VALID_ENV" ]]; then
  echo "❌ No valid KEY=VALUE pairs found in .env"
  exit 1
fi

# Create a safe loader snippet
LOADER='
# ==[ ACB: Safe .env Loader for vaultborn ]==
if [ -f "$HOME/vaultborn/.env" ]; then
  export $(grep -vE "^#|^$" "$HOME/vaultborn/.env" | xargs)
fi
'

echo "💡 Adding safe .env loader to ~/.zshrc (if not present)..."
if ! grep -q 'ACB: Safe .env Loader' "$ZSHRC"; then
  echo "$LOADER" >> "$ZSHRC"
  echo "✅ .zshrc patched"
else
  echo "⚠️  Loader already exists in .zshrc — skipping"
fi

echo "🔁 Reloading ZSH config..."
source "$ZSHRC"

echo "✅ Done. Environment loaded cleanly."
