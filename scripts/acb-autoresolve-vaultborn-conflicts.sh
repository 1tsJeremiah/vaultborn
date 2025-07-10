#!/bin/bash
# === ACB: Auto-resolve all JSONL/YAML conflicts in vaultborn repo ===

echo "🔧 Auto-resolving .llmstate/*.jsonl protocol logs..."
for file in .llmstate/*.jsonl; do
  if grep -q '<<<<<<<\|=======\|>>>>>>>' "$file"; then
    # Remove conflict markers, dedupe, and keep only valid JSON
    grep -v '<<<<<<<\|=======\|>>>>>>>' "$file" | grep -v '^\s*$' | jq -s '.' > "$file.clean.json"
    jq -c '.[]' "$file.clean.json" | sort | uniq > "$file"
    rm "$file.clean.json"
    echo "  - Cleaned $file"
  fi
done

echo "🔧 Auto-resolving YAML conflicts (traefik/traefik.yml)..."
YAML=traefik/traefik.yml
if grep -q '<<<<<<<\|=======\|>>>>>>>' "$YAML"; then
  awk '/<<<<<<<|=======|>>>>>>>/ {next} {print}' "$YAML" > "$YAML.tmp"
  mv "$YAML.tmp" "$YAML"
  echo "  - Cleaned $YAML"
fi

echo "✅ All detected conflicts auto-resolved!"
echo "Now stage and commit with:"
echo "  git add .llmstate/*.jsonl $YAML"
echo "  git commit -m '[AI Patch] auto-resolve patch merge conflicts'"
