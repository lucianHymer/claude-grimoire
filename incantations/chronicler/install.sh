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

echo "✅ Chronicler installed!"
echo "📝 Run ./chronicler-quicken after commits to process gathered knowledge"