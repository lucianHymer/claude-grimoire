# Chronicler System Architecture

## Post-commit Hook Design
Switched from pre-commit to post-commit hook for chronicler documentation processing. Post-commit is better because:
1. Documentation updates are in separate commits
2. Never blocks main commits even if chronicler fails
3. Cleaner separation of concerns

Hook explicitly specifies allowed tools with --tools flag (Read, Write, MultiEdit, Glob, Grep, LS, Bash) and instructs Claude to create a separate commit for documentation updates.

**Files**: `incantations/chronicler/git/hooks/post-commit`, `.git/hooks/post-commit`

## Git Hook Replacement Architecture
Replaced chronicler-quicken agent with git hook that calls Claude CLI directly with --prompt and --append-system-prompt. This eliminates RPC errors and ensures 100% execution reliability on commits. 

Hook structure:
- Checks for session.md
- Runs claude with full checklist prompt
- Stages changes
- Exits 0 to never block commits

**Files**: `incantations/chronicler/git/hooks/post-commit`

## Automated Documentation System
Git hook-based architecture components:
1. **MCP Server** (`chronicler.js`) - Provides `gather_knowledge` tool for capturing insights
2. **Git Post-commit Hook** - Direct Claude CLI calls for 100% execution reliability
3. **Session Memory** (`.knowledge/session.md`) - Temporary storage for current session's discoveries
4. **CLAUDE.md Sections** - Auto-maintained documentation sections
5. **Settings Integration** - Enables MCP server via `settings.local.json`

The system captures knowledge proactively during exploration and organizes it into permanent documentation during commits.

**Files**: `incantations/chronicler/claude/servers/chronicler.js`, `incantations/chronicler/git/hooks/post-commit`