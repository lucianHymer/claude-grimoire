# Chronicler - Documentation System for Claude Code

Chronicler is an automated documentation system that helps Claude Code capture and organize knowledge about your project as it explores and works with your codebase.

## Features

- **Automatic Knowledge Capture**: Uses the `gather_knowledge` MCP tool to proactively document discoveries
- **Living Documentation**: Updates CLAUDE.md with categorized knowledge sections
- **Session Memory**: Maintains session-specific knowledge in `.knowledge/session.md`
- **Smart Organization**: The chronicler-quicken agent organizes gathered knowledge into permanent documentation

## Components

### MCP Server (`servers/chronicler.js`)
Provides the `gather_knowledge` tool for capturing project insights.

### Agent (`agents/chronicler-quicken.md`)
Specialized agent that processes raw gathered knowledge and updates CLAUDE.md with organized documentation.

### Configuration
- `CLAUDE.md.append` - Documentation sections to add to your project's CLAUDE.md
- `settings.local.json.append` - Settings to enable the chronicler MCP server

## Installation

Manual installation (automated installer coming soon):

1. Copy agent file to `.claude/agents/`:
   ```bash
   cp agents/chronicler-quicken.md .claude/agents/
   ```

2. Copy MCP server to `.claude/servers/`:
   ```bash
   cp servers/chronicler.js .claude/servers/
   ```

3. Append settings to `.claude/settings.local.json`
4. Append documentation sections to `CLAUDE.md`

## Usage

Once installed, Claude Code will automatically:
- Use `gather_knowledge` to capture discoveries about your project
- Organize knowledge into categories (architecture, patterns, dependencies, etc.)
- Update CLAUDE.md when committing changes using the chronicler-quicken agent