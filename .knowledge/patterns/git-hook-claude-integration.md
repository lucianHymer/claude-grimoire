# Git Hook Claude CLI Integration Pattern

Git hooks can leverage Claude Code directly without API costs.

## Implementation Pattern
```bash
claude --prompt "..." --append-system-prompt "..."
```

## Key Components
- **System prompt** - Defines AI identity and rules
- **Regular prompt** - Defines the specific task
- **Multi-line prompts** - Work with bash heredocs or quoted strings
- **Tool specification** - Use --tools flag to specify allowed tools

## Benefits
- No API costs
- Direct integration with git workflows
- Enables automated code processing during git operations
- 100% execution reliability

**Files**: `incantations/chronicler/git/hooks/post-commit`, `.git/hooks/post-commit`