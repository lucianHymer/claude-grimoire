# Chronicler Documentation System

Automated documentation system with git hook-based architecture.

## Components

### 1. MCP Server (`chronicler.js`)
Provides the `gather_knowledge` tool for capturing project insights during exploration.

### 2. Git Post-commit Hook
Direct Claude CLI calls for 100% execution reliability, creates separate commits for documentation.

### 3. Session Memory
Temporary knowledge storage in `.knowledge/session.md` for the current session.

### 4. CLAUDE.md Sections
Auto-maintained documentation sections:
- Knowledge Gathering Protocol
- Project Architecture
- Key Patterns
- Dependencies
- Development Workflows
- Recent Discoveries

### 5. Settings Integration
Enables the MCP server via `settings.local.json` configuration.

## Workflow
1. Claude proactively gathers knowledge during exploration using the `gather_knowledge` tool
2. Knowledge accumulates in `.knowledge/session.md`
3. Post-commit hook processes and organizes it into permanent documentation during commits
4. CLAUDE.md sections are updated with the organized knowledge
5. Documentation updates are committed separately
6. Session file is cleared for the next session

## Benefits
- Post-commit hook eliminates RPC errors
- Ensures complete task execution
- Keeps documentation updates separate from main commits
- Never blocks main commits even if chronicler fails

## Files
- `incantations/chronicler/claude/servers/chronicler.js`
- `incantations/chronicler/git/hooks/post-commit`
- `incantations/chronicler/append-to-CLAUDE.md`
- `incantations/chronicler/append-to-settings.local.json`