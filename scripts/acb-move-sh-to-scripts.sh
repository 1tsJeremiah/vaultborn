#!/usr/bin/env bash
set -euo pipefail

# Get to project root (assumes you run this from project root)
project_root="$(dirname "$0")"
cd "$project_root"

# Make sure scripts dir exists
[ -d scripts ] || mkdir scripts

# Move or delete duplicates
for f in *.sh; do
    # Skip if no matches (i.e., no .sh files in root)
    [ -e "$f" ] || continue

    if [ -e "scripts/$f" ]; then
        echo "Duplicate found: $f already exists in scripts/. Deleting $f from root."
        rm -v -- "$f"
    else
        echo "Moving $f to scripts/"
        mv -v -- "$f" scripts/
    fi
done

echo "Done. Remember to update references in your code if needed."
