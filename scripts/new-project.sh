#!/bin/bash
# WebForge New Project Script
# Creates a new directory with WebForge agent system ready to use
# Usage: bash scripts/new-project.sh my-app-name

set -e

PROJECT_NAME=${1:-"my-app"}
WEBFORGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔨 WebForge — New Project"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Project name: $PROJECT_NAME"
echo "WebForge dir: $WEBFORGE_DIR"
echo ""

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Copy WebForge agent system
echo "📋 Copying WebForge agent system..."
cp -r "$WEBFORGE_DIR/.opencode" .
cp "$WEBFORGE_DIR/opencode.json" .
mkdir -p docs scripts

echo ""
echo "✅ WebForge agent system installed!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo ""
echo "  1. cd $PROJECT_NAME"
echo "  2. Edit opencode.json — add your Brave Search API key"
echo "  3. opencode"
echo "  4. In OpenCode, run:"
echo "     /new-app \"[describe your app here]\""
echo ""
echo "Available commands once in OpenCode:"
echo "  /new-app [description]     — Full pipeline"
echo "  /spec [description]        — Spec only"
echo "  /scaffold-ui               — UI from spec"
echo "  /implement-feature [name]  — Logic for a feature"
echo "  /deploy-setup [platform]   — Deployment config"
echo "  /qa-check                  — QA audit"
echo "  /research [topic]          — Research mode"
