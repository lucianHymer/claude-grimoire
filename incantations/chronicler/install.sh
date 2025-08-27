#!/bin/bash
# Chronicler installation script

echo "📜 Installing Chronicler documentation system..."

# Create .claude/knowledge directory structure if it doesn't exist
mkdir -p .claude/knowledge

# Copy the INSTRUCTIONS.md file to .claude/knowledge/
if [ -f incantations/chronicler/claude/knowledge/INSTRUCTIONS.md ]; then
    cp incantations/chronicler/claude/knowledge/INSTRUCTIONS.md .claude/knowledge/INSTRUCTIONS.md
    echo "✅ Installed knowledge gathering instructions"
fi

# Copy the manual quickening script to project root
cp incantations/chronicler/scripts/chronicler-quicken ./chronicler-quicken
chmod +x ./chronicler-quicken

# Configure git merge strategy for session files
if [ -f incantations/chronicler/claude/knowledge/append-to-gitattributes ]; then
    # Create .gitattributes if it doesn't exist
    touch .gitattributes
    
    # Check if the merge rules are already present
    if ! grep -q "\.claude/knowledge/session\.md merge=union" .gitattributes; then
        echo "" >> .gitattributes
        cat incantations/chronicler/claude/knowledge/append-to-gitattributes >> .gitattributes
        echo "✅ Configured git merge strategy for session files"
    fi
fi

echo "✅ Chronicler installed!"
echo "📝 Run ./chronicler-quicken after commits to process gathered knowledge"