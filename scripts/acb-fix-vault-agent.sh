# === ACB: Fix vault-agent Go vet/test subshells and add setup script ===
#
# This Atomic Cat Block (ACB) automates two repairs:
#  1. Replace subshell invocations like `(cd vault-agent && go vet ./... && go test ./...)`
#     with pushd/popd sequences to avoid zsh parse errors.  It searches for the
#     problematic pattern in all `.sh` files under the repository and updates
#     them in place.
#  2. Create (or overwrite) `scripts/setup.sh` with a robust bootstrap script
#     that installs Python and Go dependencies and uses pushd/popd when
#     downloading modules for the optional `vault-agent` submodule.  The script
#     is marked executable.

set -euo pipefail

echo "==[ ACB: Fixing vault-agent Go vet/test and creating setup.sh ]=="

# 1. Replace problematic subshell usage in shell scripts
echo "🔍 Searching for 'cd vault-agent && go vet' patterns in shell scripts..."
while IFS= read -r -d '' file; do
  echo "🔧 Patching $file"
  # Use a temporary file for portability across sed implementations
  tmpfile="$(mktemp)"
  # Replace subshell invocation with pushd/popd sequence
  sed -E 's/\(cd vault-agent && go vet \.\/\.\. && go test \.\/\.\.\)/pushd vault-agent > \/dev\/null\n  go vet .\/...\n  go test .\/...\n  popd > \/dev\/null/g' "$file" > "$tmpfile"
  mv "$tmpfile" "$file"
done < <(find . -type f -name '*.sh' -print0 | xargs -0 grep -lF "cd vault-agent && go vet")

# 2. Write scripts/setup.sh
mkdir -p scripts
cat <<'SETUP' > scripts/setup.sh
#!/bin/bash
set -e

# Install Python dependencies if requirements.txt exists
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi

# Download Go module dependencies
if [ -f go.mod ]; then
  go mod download
fi

# Download Go modules for vault-agent if present
if [ -d vault-agent ] && [ -f vault-agent/go.mod ]; then
  # Use pushd/popd instead of a subshell to avoid zsh parse errors
  pushd vault-agent > /dev/null
  go mod download
  popd > /dev/null
fi
SETUP

chmod +x scripts/setup.sh

echo "✅ Replacement complete and setup.sh created. Stage and commit the changes."