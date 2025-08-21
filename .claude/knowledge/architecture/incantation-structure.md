# Incantation-based Project Organization

The project uses a modular `incantations/` directory structure where each magical system/tool is self-contained.

## Directory Structure
```
incantations/
├── {incantation-name}/
│   ├── claude/              # MCP servers and Claude Code configuration
│   │   ├── servers/         # MCP server implementations
│   │   └── append-to-*      # Configuration fragments to append during installation
│   ├── git/                 # Git hooks and repository automation
│   │   └── hooks/           # Pre-commit, post-commit, and other git hooks
│   └── README.md            # Incantation-specific documentation
```

## Key Characteristics
- Each incantation is self-contained and portable
- Components are organized by tool type (claude/, git/) for cleaner separation of concerns
- Enables independently versioned magical systems that can be summoned and installed
- Append-to-* files preserve proper syntax highlighting while indicating purpose

**Files**: `incantations/chronicler/claude/`, `incantations/chronicler/git/`