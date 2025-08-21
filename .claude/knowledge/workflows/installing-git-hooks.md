# Installing Git Hooks from Incantations

## Installation Process
1. Copy hook files from `incantations/{name}/git/hooks/` to `.git/hooks/`
2. Make them executable with `chmod +x`
3. The incantation stores the template, the active repo uses the installed copy
4. Hooks can be updated by re-summoning the incantation

## Key Points
- Incantations provide hook templates
- Active repository uses installed copies
- Updates require re-summoning
- Hooks must be executable to function

## Example
```bash
cp incantations/chronicler/git/hooks/post-commit .git/hooks/
chmod +x .git/hooks/post-commit
```

**Files**: `incantations/chronicler/git/hooks/post-commit`, `.git/hooks/post-commit`