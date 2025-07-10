# === ACB: List All Files with Git Conflict Markers ===

# Find all files with unresolved merge/patch conflicts
echo "🔍 Searching for merge conflict markers in tracked files..."
grep -rl '<<<<<<<\|=======' . | while read -r file; do
  echo "---- $file ----"
  awk '/<<<<<<<|=======|>>>>>>>/ {print NR ": " $0}' "$file"
  echo
done

echo "📝 Review each file above. To resolve: keep the correct region, remove conflict markers, then 'git add' and commit."
