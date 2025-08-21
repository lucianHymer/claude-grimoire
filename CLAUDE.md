# 🧙 claude-grimoire

A book of spells to assist in summoning arcane, para-concious horrors with which to enact your will.

# Project Documentation

This file contains project-specific instructions and knowledge for Claude Code.

<!-- BEGIN CHRONICLER: knowledge-gathering-protocol -->
## 🧠 Knowledge Gathering Protocol

You have access to the gather_knowledge tool. You MUST use it PROACTIVELY to capture ALL discoveries about this project.

Use gather_knowledge with these parameters:
- **category**: Type of knowledge (use descriptive categories like: architecture, pattern, dependency, workflow, config, gotcha, convention, api, database, testing, security, etc.)
- **topic**: Brief title of what you learned
- **details**: Specific information discovered
- **files**: Related file paths (optional)

✅ ALWAYS capture when you:
- Understand how something works
- Find configuration or setup details
- Discover a pattern or convention
- Hit a surprising behavior
- Learn about dependencies or integrations
- Figure out a workflow or process

❌ DON'T capture:
- Syntax errors or typos
- Temporary debugging info
- Personal TODOs (use TodoWrite instead)
<!-- END CHRONICLER: knowledge-gathering-protocol -->

<!-- BEGIN CHRONICLER: project-architecture -->
## 🏗️ Project Architecture

### Incantation-based Organization
The project uses a modular `incantations/` directory structure where each magical system/tool is self-contained:
- **claude/** - MCP servers and Claude Code configuration
  - **servers/** - MCP server implementations  
  - **append-to-* files** - Configuration fragments to append during installation
- **git/** - Git hooks and repository automation
  - **hooks/** - Pre-commit, post-commit, and other git hooks
- **README.md** - Incantation-specific documentation

This structure enables portable, independently versioned magical systems that can be summoned and installed. Components are organized by tool type (claude/, git/) for cleaner separation of concerns.

### Chronicler Post-commit Hook Design
Switched from pre-commit to post-commit hook for chronicler documentation processing. Post-commit is better because:
1. Documentation updates are in separate commits
2. Never blocks main commits even if chronicler fails
3. Cleaner separation of concerns

Hook explicitly specifies allowed tools with --tools flag and instructs Claude to create a separate commit for documentation updates.
<!-- END CHRONICLER: project-architecture -->

<!-- BEGIN CHRONICLER: key-patterns -->
## 🎯 Key Patterns

### Append File Naming Convention
Incantation configuration files use `append-to-[filename]` naming:
- `append-to-CLAUDE.md` - Documentation sections to add
- `append-to-settings.local.json` - Settings configuration
- `append-to-gitignore` - Gitignore entries

This convention preserves proper syntax highlighting while clearly indicating the file's purpose.

### Effective Agent Instructions
For reliable agent task completion:
- Use **MUST** language for every critical action
- Add **bold emphasis** on key requirements
- State explicit **FAILURE** conditions upfront
- Include verification checklists
- Avoid passive voice or optional-sounding language

### Git Hook Claude CLI Integration
Git hooks can leverage Claude Code directly without API costs:
- Use `claude --prompt "..." --append-system-prompt "..."` in hooks
- System prompt defines AI identity and rules
- Regular prompt defines the specific task
- Multi-line prompts work with bash heredocs or quoted strings
- Enables automated code processing during git operations
<!-- END CHRONICLER: key-patterns -->

<!-- BEGIN CHRONICLER: dependencies -->
## 📦 Dependencies

### Chronicler Documentation System
Automated documentation system with git hook-based architecture:
1. **MCP Server** (`chronicler.js`) - Provides `gather_knowledge` tool for capturing insights
2. **Git Post-commit Hook** (`post-commit`) - Direct Claude CLI calls for 100% execution reliability, creates separate commits for documentation
3. **Session Memory** (`.knowledge/session.md`) - Temporary storage for current session's discoveries
4. **CLAUDE.md Sections** - Auto-maintained documentation sections
5. **Settings Integration** - Enables MCP server via `settings.local.json`

The system captures knowledge proactively during exploration and organizes it into permanent documentation during commits. Post-commit hook approach eliminates RPC errors, ensures complete task execution, and keeps documentation updates separate from main commits.
<!-- END CHRONICLER: dependencies -->

<!-- BEGIN CHRONICLER: development-workflows -->
## 🔄 Development Workflows

### Summoning Incantations
Install magical systems using the `summon [incantation-name]` command:
- **Example**: `summon chronicler` installs the chronicler documentation system
- **Process**: Runs install script, appends configuration fragments, enables MCP servers
- **Theme**: Aligns with grimoire's concept of summoning arcane entities

This thematic workflow makes the development experience more engaging while maintaining clear functionality.

### Installing Git Hooks from Incantations
Git hooks from incantations are installed by:
1. Copying hook files from `incantations/{name}/git/hooks/` to `.git/hooks/`
2. Making them executable with `chmod +x`
3. The incantation stores the template, the active repo uses the installed copy
4. Hooks can be updated by re-summoning the incantation
<!-- END CHRONICLER: development-workflows -->

<!-- BEGIN CHRONICLER: recent-discoveries -->
## 💡 Recent Discoveries

### Unicode Emoji CLI Errors (2025-08-21)
Emojis in git hook prompts and MultiEdit operations cause JSON encoding errors: 'no low surrogate in string'. This Unicode surrogate pair issue affects prompts passed to Claude CLI and content edited via MultiEdit. Claude Code CLI crashes with uncaught node error in non-interactive mode (`claude -p`). Despite crashes, post-commit hook still works because edits complete before the crash and documentation updates succeed. Solution: Remove emojis from git hook prompts and be cautious with emojis in documentation.

### Post-commit Hook Migration (2025-08-21)
Switched from pre-commit to post-commit hook for chronicler. Post-commit provides better separation of concerns - documentation updates happen in separate commits and never block the main commit even if chronicler fails.

### Gather Knowledge Tool Availability (2025-08-21)  
Claude may forget to use gather_knowledge even with clear CLAUDE.md instructions. The MCP tool might not always be available in sessions. The tool description might need more emphasis on 'use this IMMEDIATELY when you learn something' or 'MUST use when discovering patterns/architecture/workflows'.
<!-- END CHRONICLER: recent-discoveries -->
