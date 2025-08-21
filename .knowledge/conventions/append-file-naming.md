# Incantation Append File Naming Convention

## Convention
Incantation configuration files use the naming pattern: `append-to-[filename]`

## Purpose
- Clearly indicates files are fragments to be appended during installation
- Preserves proper file extensions for syntax highlighting
- Self-documenting intent

## Examples
- `append-to-CLAUDE.md` - Markdown sections (gets .md highlighting)
- `append-to-settings.local.json` - JSON configuration (gets JSON highlighting)
- `append-to-gitignore` - Gitignore entries (gets gitignore syntax)

## Benefits
- IDE/editor syntax highlighting works correctly
- Clear purpose from filename alone
- Consistent pattern across all incantations

## Implementation
Used throughout the incantations/ directory structure for all configuration fragments.