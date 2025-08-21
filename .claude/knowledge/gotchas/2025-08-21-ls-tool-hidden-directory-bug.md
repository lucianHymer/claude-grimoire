# LS Tool Hidden Directory Bug Workaround

**Date**: 2025-08-21
**Category**: Tool Limitations

## Discovery
The Claude Code LS tool has a bug where it cannot directly list hidden directories (starting with `.`). However, it works fine with nested paths.

## Solution
Migrated from `.knowledge/` to `.claude/knowledge/` structure to work around this bug while maintaining hidden directory benefits. This groups all Claude-related files together and fixes tool compatibility.

## Impact
- Changed project structure from `.knowledge/` to `.claude/knowledge/`
- All chronicler scripts updated to use new path
- Better organization with all Claude-related files under `.claude/`

## Related Files
- `incantations/chronicler/claude/servers/chronicler.js`
- `incantations/chronicler/scripts/chronicler-quicken`