# Claude Code File Linking Architecture

## File Import Depth
Claude Code supports recursive file imports up to **5 hops deep**. This means CLAUDE.md can link to files, which can link to other files, up to 5 levels total.

## Benefits
- Enables sophisticated knowledge organization
- Avoids inline content duplication  
- Maintains single source of truth
- Supports modular documentation structure

## Implementation Strategy
The Chronicler system leverages this capability through a dual-reference approach:
- **CLAUDE.md** contains critical instructions and @ references to knowledge maps
- **KNOWLEDGE_MAP_CLAUDE.md** uses @ references for Claude to load linked files
- **KNOWLEDGE_MAP.md** uses markdown links for human readability

This architecture reduced CLAUDE.md from 189 to 49 lines while maintaining 633+ lines of detailed documentation in organized knowledge files.

## @ Reference Format
Claude Code uses @ references (not markdown links) to load files:
- Format: `@path/to/file.md` loads the file content
- Relative paths from the current file's directory
- Works recursively up to 5 levels deep

**Related files:** `CLAUDE.md`, `.claude/knowledge/KNOWLEDGE_MAP_CLAUDE.md`