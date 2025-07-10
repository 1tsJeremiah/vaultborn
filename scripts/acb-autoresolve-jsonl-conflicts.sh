# === ACB: Auto-Resolve JSONL Merge Conflicts in .llmstate ===

for file in .llmstate/*.jsonl; do
  echo "🔧 Resolving $file"
  # Remove all git conflict markers and blank lines
  grep -v '<<<<<<<\|=======\|>>>>>>>' "$file" | grep -v '^\s*$' > "$file.clean"
  # Deduplicate lines, sort for readability
  sort "$file.clean" | uniq > "$file.resolved"
  mv "$file.resolved" "$file"
  rm "$file.clean"
done

echo "✅ All .llmstate/*.jsonl files auto-cleaned!"
echo "Stage and commit:"
echo "  git add .llmstate/*.jsonl"
echo "  git commit -m '[AI Patch] auto-resolve .llmstate jsonl conflicts'"
