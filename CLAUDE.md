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

### Package-based Organization
The project uses a modular `packages/` directory structure where each system/tool is self-contained:
- **agents/** - Agent markdown files for specialized tasks
- **servers/** - MCP server implementations
- **append-to-* files** - Configuration fragments to append during installation
- **README.md** - Package-specific documentation

This structure enables portable, independently versioned systems that can be easily distributed and installed.
<!-- END CHRONICLER: project-architecture -->

<!-- BEGIN CHRONICLER: key-patterns -->
## 🎯 Key Patterns

### Append File Naming Convention
Package configuration files use `append-to-[filename]` naming:
- `append-to-CLAUDE.md` - Documentation sections to add
- `append-to-settings.local.json` - Settings configuration
- `append-to-gitignore` - Gitignore entries

This convention preserves proper syntax highlighting while clearly indicating the file's purpose.
<!-- END CHRONICLER: key-patterns -->

<!-- BEGIN CHRONICLER: dependencies -->
## 📦 Dependencies

### Chronicler Documentation System
Automated documentation system with these components:
1. **MCP Server** (`chronicler.js`) - Provides `gather_knowledge` tool for capturing insights
2. **Quicken Agent** (`chronicler-quicken.md`) - Processes raw knowledge into organized documentation
3. **Session Memory** (`.knowledge/session.md`) - Temporary storage for current session's discoveries
4. **CLAUDE.md Sections** - Auto-maintained documentation sections
5. **Settings Integration** - Enables MCP server via `settings.local.json`

The system captures knowledge proactively during exploration and organizes it into permanent documentation during commits.
<!-- END CHRONICLER: dependencies -->

<!-- BEGIN CHRONICLER: development-workflows -->
## 🔄 Development Workflows

_Workflows will be auto-populated here as they are discovered_
<!-- END CHRONICLER: development-workflows -->

<!-- BEGIN CHRONICLER: recent-discoveries -->
## 💡 Recent Discoveries

### Gitignore Requirements (2025-08-21)
The `.knowledge/session.md` file must be excluded from version control as it contains temporary session-specific knowledge. Only the organized documentation in CLAUDE.md should be tracked.
<!-- END CHRONICLER: recent-discoveries -->