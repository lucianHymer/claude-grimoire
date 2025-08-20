#!/bin/bash
# Auto-installs gum locally and manages Claude Code hooks

check_git_repo() {
  # Check if we're in a git repo at all
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "⚠️  Warning: Not in a git repository"
    echo ""
    echo "This script is designed to manage hooks at the root of a git repo."
    echo "Running it outside a repo means:"
    echo "  • No .gitignore management"
    echo "  • Hooks will be added to current directory"
    echo ""
    
    # Need to handle the case where gum isn't installed yet
    if command -v gum &> /dev/null || [ -f "./.gum" ]; then
      gum confirm "Continue anyway?" || exit 1
    else
      read -p "Continue anyway? [y/N] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
      fi
    fi
    return 1  # Not in a git repo
  fi
  
  # Check if we're at the root of the repo
  GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
  CURRENT_DIR=$(pwd)
  
  if [ "$GIT_ROOT" != "$CURRENT_DIR" ]; then
    echo "📍 Current directory: $(basename $CURRENT_DIR)"
    echo "📁 Git repo root: $GIT_ROOT"
    echo ""
    echo "You're in a subdirectory of your git repo."
    echo "Hooks are typically managed at the repo root."
    echo ""
    
    if command -v gum &> /dev/null || [ -f "./.gum" ]; then
      if gum confirm "Change to repo root and continue there?"; then
        cd "$GIT_ROOT"
        echo "📁 Changed to repo root: $GIT_ROOT"
        echo ""
      elif gum confirm "Continue in current subdirectory?"; then
        echo "⚠️  Continuing in subdirectory..."
        echo ""
      else
        exit 1
      fi
    else
      echo "Options:"
      echo "  1) Change to repo root and continue"
      echo "  2) Continue in current directory"
      echo "  3) Cancel"
      read -p "Choice [1-3]: " choice
      case "$choice" in
        1)
          cd "$GIT_ROOT"
          echo "📁 Changed to repo root: $GIT_ROOT"
          echo ""
          ;;
        2)
          echo "⚠️  Continuing in subdirectory..."
          echo ""
          ;;
        *)
          exit 1
          ;;
      esac
    fi
  fi
  
  return 0  # In a git repo
}

ensure_gum() {
  # Check if gum exists in PATH or local directory
  if command -v gum &> /dev/null; then
    return 0
  elif [ -f "./.gum" ]; then
    return 0
  fi
  
  # Detect platform
  OS=$(uname -s)
  ARCH=$(uname -m)
  
  case "${OS}_${ARCH}" in
    "Linux_x86_64")
      GUM_ARCHIVE="gum_0.16.2_Linux_x86_64.tar.gz"
      echo "📦 Setting up gum for Linux x86_64..."
      ;;
    "Darwin_arm64")
      GUM_ARCHIVE="gum_0.16.2_Darwin_arm64.tar.gz"
      echo "📦 Setting up gum for Apple Silicon..."
      ;;
    *)
      echo "⚠️  Auto-install not supported for ${OS} ${ARCH}"
      echo "Please install gum manually: https://github.com/charmbracelet/gum#installation"
      exit 1
      ;;
  esac
  
  # Download and extract
  GUM_VERSION="0.16.2"
  GUM_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/${GUM_ARCHIVE}"
  
  echo "📥 Downloading gum..."
  TMP_DIR=$(mktemp -d)
  
  if ! curl -L --fail --silent --show-error "$GUM_URL" -o "$TMP_DIR/gum.tar.gz"; then
    echo "❌ Failed to download gum"
    rm -rf "$TMP_DIR"
    exit 1
  fi
  
  tar -xzf "$TMP_DIR/gum.tar.gz" -C "$TMP_DIR"
  mv "$TMP_DIR/gum" "./.gum"
  chmod +x "./.gum"
  rm -rf "$TMP_DIR"
  
  echo "✅ gum installed locally!"
  
  # Only manage .gitignore if we're in a git repo
  if git rev-parse --git-dir > /dev/null 2>&1; then
    echo ""
    if [ -f ".gitignore" ]; then
      # Check if .gum is already in .gitignore
      if ! grep -q "^\\.gum$" .gitignore 2>/dev/null; then
        if ./.gum confirm "Add .gum to your existing .gitignore?"; then
          echo ".gum" >> .gitignore
          echo "📝 Added .gum to .gitignore"
        fi
      fi
    else
      if ./.gum confirm "Create .gitignore with .gum entry?"; then
        echo ".gum" > .gitignore
        echo "📝 Created .gitignore with .gum"
      fi
    fi
    
    # Also ask about the manifest file
    if [ -f ".gitignore" ] && ! grep -q "^\\.claude-hooks\\.json$" .gitignore 2>/dev/null; then
      if ./.gum confirm "Also add .claude-hooks.json (hooks manifest) to .gitignore?"; then
        echo ".claude-hooks.json" >> .gitignore
        echo "📝 Added .claude-hooks.json to .gitignore"
      fi
    fi
  else
    echo ""
    echo "💡 Tip: Run this in a git repo to auto-manage .gitignore"
  fi
}

# Wrapper function to always use local gum if it exists
gum() {
  if [ -f "./.gum" ]; then
    ./.gum "$@"
  else
    command gum "$@"
  fi
}

# ==== Main Script Starts Here ====

echo "🪝 Claude Code Hooks Manager"
echo "============================"
echo ""

# Check git repo status first
IN_GIT_REPO=true
check_git_repo || IN_GIT_REPO=false

# Now ensure gum is available
ensure_gum

REPO="lucianhymer/claude-grimoire"
BRANCH="main"
MANIFEST=".claude-hooks.json"

echo ""
echo "🔍 Fetching available hooks from $REPO..."

# Get hooks with their SHA from GitHub
hooks_data=$(curl -s "https://api.github.com/repos/$REPO/contents?ref=$BRANCH")

if [ -z "$hooks_data" ] || [ "$hooks_data" = "null" ]; then
  echo "❌ Could not fetch hooks from $REPO"
  echo "   Please check your internet connection and repo name"
  exit 1
fi

hooks=$(echo "$hooks_data" | jq -r '.[] | select(.type=="file") | .name')

if [ -z "$hooks" ]; then
  echo "❌ No hooks found in repository"
  exit 1
fi

# Check for updates and build pre-selection
selected_args=""
updates_available=""

while IFS= read -r hook; do
  if [ -f "$hook" ]; then
    # Get upstream SHA
    upstream_sha=$(echo "$hooks_data" | jq -r ".[] | select(.name==\\"$hook\\") | .sha")
    
    # Check stored SHA from last sync
    if [ -f "$MANIFEST" ]; then
      stored_sha=$(jq -r ".\\"$hook\\".sha // \\"\\"" "$MANIFEST" 2>/dev/null)
      
      if [ -n "$stored_sha" ] && [ "$stored_sha" != "$upstream_sha" ]; then
        updates_available="${updates_available}  • $hook\\n"
      fi
    fi
    
    selected_args="$selected_args --selected=$hook"
  fi
done <<< "$hooks"

# Show updates if any
if [ -n "$updates_available" ]; then
  echo "📦 Updates available for:"
  echo -e "$updates_available"
  echo ""
fi

# Let user select with gum
selected=$(echo "$hooks" | gum choose --no-limit $selected_args \\
  --header="Select hooks to sync (space=toggle, enter=confirm):" \\
  --cursor-prefix="[ ] " \\
  --selected-prefix="[✓] " \\
  --unselected-prefix="[ ] ")

# Initialize manifest if needed
[ ! -f "$MANIFEST" ] && echo "{}" > "$MANIFEST"

# Track what changed
installed_count=0
updated_count=0
removed_count=0

# Sync selected hooks
while IFS= read -r hook; do
  [ -z "$hook" ] && continue
  
  upstream_sha=$(echo "$hooks_data" | jq -r ".[] | select(.name==\\"$hook\\") | .sha")
  stored_sha=$(jq -r ".\\"$hook\\".sha // \\"\\"" "$MANIFEST" 2>/dev/null)
  
  if [ ! -f "$hook" ]; then
    echo "📥 Installing $hook..."
    curl -sO "https://raw.githubusercontent.com/$REPO/$BRANCH/$hook"
    ((installed_count++))
  elif [ "$stored_sha" != "$upstream_sha" ]; then
    echo "🔄 Updating $hook..."
    curl -sO "https://raw.githubusercontent.com/$REPO/$BRANCH/$hook"
    ((updated_count++))
  fi
  
  # Update manifest with new SHA
  if [ ! -f "$hook" ] || [ "$stored_sha" != "$upstream_sha" ]; then
    jq ". + {\\"$hook\\": {\\"sha\\": \\"$upstream_sha\\"}}" "$MANIFEST" > "$MANIFEST.tmp" && \\
      mv "$MANIFEST.tmp" "$MANIFEST"
  fi
done <<< "$selected"

# Remove deselected hooks
while IFS= read -r hook; do
  if [ -f "$hook" ] && ! echo "$selected" | grep -q "^$hook$"; then
    echo "🗑️  Removing $hook..."
    rm -f "$hook"
    jq "del(.\\"$hook\\")" "$MANIFEST" > "$MANIFEST.tmp" && \\
      mv "$MANIFEST.tmp" "$MANIFEST"
    ((removed_count++))
  fi
done <<< "$hooks"

# Clean up empty manifest
if [ -f "$MANIFEST" ] && [ "$(jq -r 'keys | length' "$MANIFEST")" = "0" ]; then
  rm "$MANIFEST"
fi

# Summary
echo ""
if [ $installed_count -gt 0 ] || [ $updated_count -gt 0 ] || [ $removed_count -gt 0 ]; then
  echo "✅ Sync complete!"
  [ $installed_count -gt 0 ] && echo "   📥 Installed: $installed_count"
  [ $updated_count -gt 0 ] && echo "   🔄 Updated: $updated_count"
  [ $removed_count -gt 0 ] && echo "   🗑️  Removed: $removed_count"
else
  echo "✅ Everything up to date!"
fi

# Show git status hint if in repo
if [ "$IN_GIT_REPO" = true ] && [ $installed_count -gt 0 ]; then
  echo ""
  echo "💡 Don't forget to commit your new hooks!"
fi
