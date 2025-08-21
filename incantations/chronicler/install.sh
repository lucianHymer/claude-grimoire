#!/bin/bash
# Chronicler installation script

echo "📜 Installing Chronicler documentation system..."

# Copy the manual quickening script to project root
cp incantations/chronicler/scripts/chronicler-quicken ./chronicler-quicken
chmod +x ./chronicler-quicken

echo "✅ Chronicler installed!"
echo "📝 Run ./chronicler-quicken after commits to process gathered knowledge"