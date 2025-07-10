# === ACB: Open All Files With Git Conflict Markers in micro ===

# Find all files with unresolved merge/patch conflicts and open in micro, one after the other
for file in $(grep -rl '<<<<<<<\|=======' . | grep -v 'lazygit' | sort | uniq); do
  echo "===== Resolve conflicts in: $file ====="
  micro "$file"
  echo "✓ Finished editing $file. Moving to next..."
done

echo "🎉 All conflict files have been opened for resolution."
echo "When done, stage and commit with:"
echo "  git add .llmstate/notes.jsonl .llmstate/patch-pipeline.jsonl docker-compose.yml"
echo "  git commit -m '[AI Patch PXXXX] resolved patch merge conflicts'"
