# === ACB: Rehydrate Cloudflare Credentials to .env and Save Git Patch ===

# Define env and patch paths
ENV_FILE="$HOME/vaultborn/.env"
PATCH_OUT="$HOME/ai-agents/restore_cloudflare.patch"

# Ensure the file exists
touch "$ENV_FILE"

# Add Cloudflare token block if missing
if ! grep -q "CLOUDFLARE_API_TOKEN" "$ENV_FILE"; then
  echo "🔧 Inserting Cloudflare token block into .env..."
  cat <<EOF > /tmp/.env.inject
# Patch P0005: Cloudflare DNS challenge credentials
# Populate these values with your Cloudflare API token and Zone ID
CLOUDFLARE_API_TOKEN=<your_cloudflare_api_token>
CLOUDFLARE_ZONE_ID=<your_cloudflare_zone_id>

EOF

  cat /tmp/.env.inject "$ENV_FILE" > /tmp/.env.new
  mv /tmp/.env.new "$ENV_FILE"
else
  echo "✅ .env already contains CLOUDFLARE_API_TOKEN"
fi

# Stage .env for diff
cd "$HOME/vaultborn"
git add .env

# Generate patch based on current diff
mkdir -p "$(dirname "$PATCH_OUT")"
git diff --cached > "$PATCH_OUT"

# Clean up staging
git reset .env

echo "✅ Patch saved to $PATCH_OUT"
echo "👉 To re-apply it later: git apply $PATCH_OUT"
