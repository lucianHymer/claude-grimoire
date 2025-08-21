# Gitignore Configuration Requirements

## Chronicler System
The `.knowledge/session.md` file must be excluded from version control.

### Reason
This file contains temporary session-specific knowledge that shouldn't be committed. Only the organized documentation in CLAUDE.md should be tracked.

### Configuration
Add to `.gitignore`:
```
.knowledge/session.md
```

## Related Files
- `packages/chronicler/append-to-gitignore`