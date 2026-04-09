#!/bin/bash

# sync-partner installation script
# Downloads and installs the sync-partner Claude Code skill

set -e

SKILL_NAME="sync-partner"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
GITHUB_RAW="https://raw.githubusercontent.com/rixav77/sync-partner/main"

echo "🔄 Installing $SKILL_NAME skill..."

# Create skill directory
mkdir -p "$SKILL_DIR"

# Download SKILL.md
echo "📥 Downloading SKILL.md..."
curl -fsSL "$GITHUB_RAW/sync-partner/SKILL.md" -o "$SKILL_DIR/SKILL.md"

# Verify installation
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    echo "✅ Installation complete!"
    echo ""
    echo "🚀 Ready to use:"
    echo "   /sync-partner <partner-username>"
    echo ""
    echo "📖 First time? See README:"
    echo "   https://github.com/rixav77/sync-partner#setup-one-time"
else
    echo "❌ Installation failed"
    exit 1
fi
