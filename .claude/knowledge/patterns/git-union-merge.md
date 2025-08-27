# Git Union Merge Strategy Pattern

## Overview
Implemented git merge=union strategy for `.claude/knowledge/session.md` files to prevent merge conflicts when multiple team members gather knowledge simultaneously.

## Implementation
Uses `.gitattributes` file with the rule:
```
session.md merge=union
```

This tells git to automatically combine both versions during merges instead of creating conflicts.

## Benefits
- Prevents merge conflicts in session files
- Preserves all gathered knowledge from all contributors
- Enables collaborative knowledge gathering
- No manual conflict resolution needed
- Allows session.md to be committed and shared

## Distribution
The pattern is:
1. Distributed via `append-to-gitattributes` file in the incantation
2. Installed by `install.sh` script
3. Applied to `.claude/knowledge/.gitattributes`

## Important Note
With this strategy, session.md is **no longer gitignored** - it can be safely committed and merged.

**Files:** `.claude/knowledge/.gitattributes`, `incantations/chronicler/append-to-gitattributes`, `incantations/chronicler/install.sh`