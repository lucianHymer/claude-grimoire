# Claude CLI Usage Patterns

## Interactive vs Non-Interactive Mode
Use interactive mode (no `-p` flag) for long-running or complex tasks to avoid timeouts and crashes. Use non-interactive mode (`-p` or `--print`) only for quick, simple operations.

**Key insights:**
- Interactive mode is more stable for operations involving MultiEdit with emojis
- Interactive mode handles large documentation updates better
- The `--print` flag was added to chronicler-quicken script by user/linter to attempt non-interactive mode despite known issues

**Related files:** `incantations/chronicler/scripts/chronicler-quicken`