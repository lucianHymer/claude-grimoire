# Manual Chronicler Workflow

## Current Workflow (Manual Script)
New chronicler workflow to avoid timeout/crash issues:

1. **Use gather_knowledge during Claude sessions** to capture discoveries
2. **Make commits as normal** (no hook runs automatically)
3. **Run `./chronicler-quicken` manually** after commits to process session.md into documentation
4. **Commit the documentation updates separately**

This avoids timeout crashes while maintaining documentation quality.

**Related files:**
- `./chronicler-quicken` - Manual script in project root
- `CLAUDE.md` - Contains reminder instructions