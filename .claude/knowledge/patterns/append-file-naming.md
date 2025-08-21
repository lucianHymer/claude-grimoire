# Append File Naming Convention

Incantation configuration files use `append-to-[filename]` naming pattern.

## Common Examples
- `append-to-CLAUDE.md` - Documentation sections to add
- `append-to-settings.local.json` - Settings configuration
- `append-to-gitignore` - Gitignore entries

## Benefits
- Preserves proper syntax highlighting in editors
- Clearly indicates the file's purpose
- Prevents accidental execution as standalone files
- Makes installation scripts more readable

This convention is used throughout the incantation system for configuration fragments that get appended to existing files during installation.