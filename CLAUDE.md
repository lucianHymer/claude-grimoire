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
2. **Git Pre-commit Hook** (`pre-commit`) - Replaces agent with direct Claude CLI calls for 100% execution reliability
3. **Session Memory** (`.knowledge/session.md`) - Temporary storage for current session's discoveries
4. **CLAUDE.md Sections** - Auto-maintained documentation sections
5. **Settings Integration** - Enables MCP server via `settings.local.json`

The system captures knowledge proactively during exploration and organizes it into permanent documentation during commits. Git hook approach eliminates RPC errors and ensures complete task execution.
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

### Chronicler Git Hook Architecture (2025-08-21)
Replaced chronicler-quicken agent with git pre-commit hook that calls Claude CLI directly with --prompt and --append-system-prompt. Eliminates RPC errors and ensures 100% execution on commits. Hook structure: checks for session.md, runs claude with full checklist prompt, stages changes, exits 0 to never block commits.

### Gather Knowledge Tool Availability (2025-08-21)
Claude may forget to use gather_knowledge even with clear CLAUDE.md instructions. The MCP tool might not always be available in sessions. The tool description might need more emphasis on 'use this IMMEDIATELY when you learn something' or 'MUST use when discovering patterns/architecture/workflows'.

### Agent Checklist Compliance Issue (2025-08-21)
Agents may skip checklist items even when clearly specified. Solution: Use forceful imperative language with MUST statements, bold emphasis, explicit failure conditions, and verification checklists. Avoid passive voice or numbered lists without imperatives.

### Gitignore Requirements (2025-08-21)
The `.knowledge/session.md` file must be excluded from version control as it contains temporary session-specific knowledge. Only the organized documentation in CLAUDE.md should be tracked.
<!-- END CHRONICLER: recent-discoveries -->
