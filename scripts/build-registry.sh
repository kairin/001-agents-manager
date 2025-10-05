#!/usr/bin/env bash
# Build agents-registry.json from agent markdown files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="$APP_ROOT/agents"
MCP_CONFIG_DIR="$HOME/.config/mcp-manager"
OUTPUT="$MCP_CONFIG_DIR/claude-agents.json"

echo "🔨 Building agent registry from: $AGENTS_DIR"

# Initialize JSON
cat > "$OUTPUT" <<EOF
{
  "version": "1.0",
  "last_updated": "$(date -Iseconds)",
  "source_app": "$APP_ROOT",
  "agent_count": 0,
  "agents": {}
}
EOF

# Find all agent markdown files and build registry
AGENT_COUNT=0
while IFS= read -r file; do
    # Extract frontmatter using awk (YAML-style)
    name=$(awk '/^name:/ {$1=""; print substr($0,2); exit}' "$file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    desc=$(awk '/^description:/ {$1=""; print substr($0,2); exit}' "$file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    tools=$(awk '/^tools:/ {$1=""; print substr($0,2); exit}' "$file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Skip if no name
    [ -z "$name" ] && continue

    # Determine department from path
    dept=$(echo "$file" | sed "s|$AGENTS_DIR/||" | cut -d'/' -f1)
    spec=$(echo "$file" | sed "s|$AGENTS_DIR/||" | cut -d'/' -f2-)
    spec="${spec%/*}"

    # Add to registry using jq
    jq --arg name "$name" \
       --arg desc "$desc" \
       --arg dept "$dept" \
       --arg spec "$spec" \
       --arg path "$file" \
       --arg tools "$tools" \
       '.agents[$name] = {
           name: $name,
           description: $desc,
           department: $dept,
           specialization: $spec,
           file_path: $path,
           tools: (if $tools == "" then [] else ($tools | split(",") | map(gsub("^\\s+|\\s+$";""))) end),
           status: "active"
       }' "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"

    ((AGENT_COUNT++)) || true
done < <(find "$AGENTS_DIR" -name "*.md" -type f)

# Update agent count in registry
jq --arg count "$AGENT_COUNT" '.agent_count = ($count | tonumber)' "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"

echo "✅ Registry built successfully!"
echo "   📊 Total agents: $AGENT_COUNT"
echo "   📍 Location: $OUTPUT"
