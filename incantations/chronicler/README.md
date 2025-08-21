# Chronicler - Documentation System for Claude Code

Chronicler is a documentation system that helps Claude Code capture and organize knowledge about your project as it explores and works with your codebase.

## Features

- **Knowledge Capture**: Uses the `gather_knowledge` MCP tool to document discoveries
- **Living Documentation**: Updates CLAUDE.md with categorized knowledge sections
- **Session Memory**: Maintains session-specific knowledge in `.knowledge/session.md`
- **Manual Processing**: Run `./chronicler-quicken` to organize gathered knowledge into documentation

## Components

### MCP Server (`claude/servers/chronicler.js`)
Provides the `gather_knowledge` tool for capturing project insights during Claude sessions.

### Manual Script (`scripts/chronicler-quicken`)
Processes raw gathered knowledge and updates CLAUDE.md with organized documentation. Must be run manually after commits.

### Configuration
- `claude/append-to-CLAUDE.md` - Documentation sections and reminder to add to CLAUDE.md
- `claude/append-to-settings.local.json` - Settings to enable the chronicler MCP server

## Why Manual Execution?

The chronicler was initially attempted as:
1. **Agent (chronicler-quicken)**: Failed due to Unicode/emoji encoding issues in JSON-RPC when using MultiEdit on CLAUDE.md sections with emojis
2. **Git hook (post-commit)**: Failed due to 120+ second timeout when processing complex documentation

Both approaches would crash Claude, making automated execution unreliable. The manual script approach allows the chronicler to run in a stable environment.

## Installation

Run the install script:
```bash
./incantations/chronicler/install.sh
```

This will:
- Copy the `chronicler-quicken` script to your project root
- Set up the MCP server configuration
- Add documentation sections to CLAUDE.md

## Usage

1. **During Claude sessions**: Claude will automatically use `gather_knowledge` to capture discoveries
2. **After commits**: Run `./chronicler-quicken` manually to process the gathered knowledge
3. **Commit documentation**: After chronicler runs, commit the updated documentation

## Important Notes

- Claude will remind you to run `./chronicler-quicken` when appropriate
- The chronicler may take several minutes for complex documentation updates
- All gathered knowledge is preserved in `.knowledge/session.md` until processed