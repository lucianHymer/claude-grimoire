# Claude CLI Crashes and Timeout Issues

## Emoji Crash in Non-Interactive Mode (2025-08-21)
Claude Code CLI crashes with 'no low surrogate in string' error when using MultiEdit on files containing emojis in non-interactive mode (claude -p). The crash happens during JSON-RPC response serialization, AFTER the file edits complete successfully. This affects git hooks and automation scripts.

**Workarounds attempted:**
- --output-format json (didn't help)
- timeout wrapper (kills claude but doesn't fix crash)
- simplifying task (reduces chance but doesn't eliminate)

The bug appears to be a Unicode surrogate pair encoding issue in the node process. Despite the crash, the chronicler updates complete before the error, so the hook technically works but kills the Claude session.

**Related files:** `.git/hooks/post-commit`, `claudelog.jsonl`

## Chronicler Timeout Crashes (2025-08-21)
The chronicler task takes too long (>120 seconds) when processing complex documentation updates, causing Claude to crash in both agent mode and git hook mode (claude -p). This isn't an emoji encoding issue but a timeout. The crash kills the Claude session even though the documentation updates may complete.

**Solution:** Run chronicler manually instead of as a hook/agent until timeout limits are increased or task is optimized.

**Related files:** `.git/hooks/post-commit`, `incantations/chronicler/`

## Two Different Failure Modes (2025-08-21)
Current hypothesis: The chronicler fails in two different ways:
1. **Git hook mode (claude -p):** Likely a 120-second timeout issue when processing complex documentation
2. **Agent mode (chronicler-quicken):** Likely a Unicode/emoji encoding issue in JSON-RPC when using MultiEdit on CLAUDE.md sections with emojis

Both crash Claude but for different reasons.

**Solution:** Use manual script execution until these issues are resolved.

**Related files:** `.git/hooks/post-commit`, `incantations/chronicler/agents/chronicler-quicken.md`

## Crashes Persist in Both Modes (2025-08-21)
Both interactive mode (without -p) and non-interactive mode (with -p/--print) can crash Claude when processing complex documentation with emojis. The crashes appear to be timeout-related (>120s) for complex operations and possibly emoji-encoding related for MultiEdit operations. The --print flag was added to chronicler-quicken script but doesn't solve the crash issue. Manual execution at least allows the user to see progress before any crash.

**Related files:** `incantations/chronicler/scripts/chronicler-quicken`