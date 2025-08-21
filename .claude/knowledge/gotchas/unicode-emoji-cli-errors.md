# Unicode Emoji CLI Errors
**Date**: 2025-08-21

## Problem
Emojis in git hook prompts and MultiEdit operations cause JSON encoding errors when passed to Claude CLI: 'no low surrogate in string'. This is a Unicode surrogate pair encoding issue where emojis get incorrectly split.

## Manifestations
1. **Git Hook Prompts**: Emojis in prompts passed to `claude` CLI cause immediate failure
2. **MultiEdit Operations**: When CLAUDE.md contains emojis and Claude tries to edit those sections via MultiEdit, the JSON-RPC request fails
3. **CLI Non-interactive Mode**: Claude Code CLI crashes with uncaught node error when processing emojis in MultiEdit operations during non-interactive mode (`claude -p`)

## Error Details
- Error message: "no low surrogate in string"
- Occurs during JSON encoding of the API request
- Shell/JSON encoding doesn't properly handle Unicode emojis
- In non-interactive mode, manifests as uncaught node exception in the Claude process
- Crash occurs during response serialization, not during actual work execution

## Solution
Remove all emojis from:
- Prompts passed to claude CLI in git hooks
- Content that will be edited via MultiEdit when possible

## Impact
Limits the use of visual elements in documentation and prompts when using Claude CLI automation.

## Post-commit Hook Resilience
Despite the Unicode crashes, post-commit hook approach still works because:
1. File edits complete before the crash
2. Hook exits 0 anyway so commits aren't blocked
3. Documentation updates happen successfully despite error messages
4. Crash occurs during response serialization, not during actual work

**Files**: `.git/hooks/post-commit`, `incantations/chronicler/git/hooks/post-commit`, `CLAUDE.md`, `claudelog.jsonl`