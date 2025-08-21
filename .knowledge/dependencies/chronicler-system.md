# Chronicler Documentation System

## Components

### 1. MCP Server (`chronicler.js`)
Provides the `gather_knowledge` tool for capturing project insights during exploration.

### 2. Quicken Agent (`chronicler-quicken.md`)
Processes raw knowledge from session memory and updates project documentation.

### 3. CLAUDE.md Sections
Auto-maintained documentation sections:
- Knowledge Gathering Protocol
- Project Architecture
- Key Patterns
- Dependencies
- Development Workflows
- Recent Discoveries

### 4. Session Memory
Temporary knowledge storage in `.knowledge/session.md` for the current session.

### 5. Settings Integration
Enables the MCP server via `settings.local.json` configuration.

## Workflow
1. Claude proactively gathers knowledge during exploration using the `gather_knowledge` tool
2. Knowledge accumulates in `.knowledge/session.md`
3. The quicken agent processes and organizes it into permanent documentation
4. CLAUDE.md sections are updated with the organized knowledge
5. Session file is cleared for the next session

## Files
- `incantations/chronicler/servers/chronicler.js`
- `incantations/chronicler/agents/chronicler-quicken.md`
- `incantations/chronicler/append-to-CLAUDE.md`
- `incantations/chronicler/append-to-settings.local.json`