# 🧙 claude-grimoire

A book of spells to assist in summoning arcane, para-concious horrors with which to enact your will.

# Project Documentation

This file contains project-specific instructions and knowledge for Claude Code.

## ⚠️ IMPORTANT: Manual Chronicler Process
After making commits with significant gathered knowledge, **remind the user** to run:
```bash
./chronicler-quicken
```
This processes the `.knowledge/session.md` file into organized documentation. The chronicler cannot run automatically due to timeout issues in hooks/agents that crash Claude.

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
- **scripts/** - Standalone scripts (e.g., chronicler-quicken)
- **git/** - Git hooks and repository automation
  - **hooks/** - Pre-commit, post-commit, and other git hooks
- **README.md** - Incantation-specific documentation

This structure enables portable, independently versioned magical systems that can be summoned and installed. Components are organized by tool type (claude/, git/, scripts/) for cleaner separation of concerns.

### Chronicler Manual Script Architecture
The Chronicler now uses a manual script approach (`./chronicler-quicken`) instead of git hooks or agents due to timeout/crash issues:
- Script located in project root for easy access
- Runs in interactive mode without `-p` flag to avoid crashes
- Installation copies script from `incantations/chronicler/scripts/` to project root
- Users must run manually after commits with significant gathered knowledge
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

### Claude CLI Usage Patterns
**Interactive vs Non-Interactive Mode:**
- Use interactive mode (no `-p` flag) for long-running or complex tasks to avoid timeouts
- Non-interactive mode (`-p` or `--print`) only for quick, simple operations
- Interactive mode more stable for MultiEdit operations with emojis
- Complex documentation updates should use interactive mode

### Git Hook Claude CLI Integration
Git hooks can leverage Claude Code directly without API costs:
- Use `claude --prompt "..." --append-system-prompt "..."` in hooks
- System prompt defines AI identity and rules
- Regular prompt defines the specific task
- Multi-line prompts work with bash heredocs or quoted strings
- Enables automated code processing during git operations

### Stream-JSON Progress Monitoring
Using `--output-format stream-json` with Claude CLI for real-time progress:
- Parse JSON stream with jq to extract text messages and tool usage
- Shows real-time progress for long-running operations
- Must use `set -o pipefail` to preserve Claude's exit status through pipes
- Solves the silent waiting problem with non-interactive mode

### Aggressive Behavioral Tool Descriptions
For MCP tools requiring behavioral triggering (like gather_knowledge):
- Use **explicitly prescriptive** language with mandatory triggers
- Include **specific trigger phrases** ("for future reference", "turns out", etc.)
- Provide **concrete bad/good examples** to clarify usage
- Apply **aggressive formatting** (⚠️ MANDATORY, ❌ BAD, ✅ GOOD)
- List **common blind spots** where tool should be used

This unconventional verbose approach is necessary when tools require behavioral conditioning rather than obvious task mapping. The tool description itself becomes part of the behavioral reinforcement.
<!-- END CHRONICLER: key-patterns -->

<!-- BEGIN CHRONICLER: dependencies -->
## 📦 Dependencies

### Chronicler Documentation System
Manual documentation system with MCP server support:
1. **MCP Server** (`chronicler.js`) - Provides `gather_knowledge` tool for capturing insights
2. **Manual Script** (`./chronicler-quicken`) - Processes session.md into organized documentation
3. **Session Memory** (`.knowledge/session.md`) - Temporary storage for current session's discoveries
4. **Knowledge Structure** - Organized by category in `.knowledge/` directory
5. **CLAUDE.md Sections** - Auto-maintained documentation sections
6. **Settings Integration** - Enables MCP server via `settings.local.json`

The system captures knowledge proactively during exploration. Users must manually run chronicler-quicken after commits to organize documentation, avoiding timeout/crash issues from automated approaches.

### jq - JSON Processor
Required dependency for chronicler-quicken script:
- Used to parse Claude's stream-json output format
- Extracts text messages from `.message.content[0].text`
- Extracts tool names from `.message.content[0].name`
- Most systems have jq pre-installed
<!-- END CHRONICLER: dependencies -->

<!-- BEGIN CHRONICLER: development-workflows -->
## 🔄 Development Workflows

### Summoning Incantations
Install magical systems using the `summon [incantation-name]` command:
- **Example**: `summon chronicler` installs the chronicler documentation system
- **Process**: Runs install script, appends configuration fragments, enables MCP servers
- **Theme**: Aligns with grimoire's concept of summoning arcane entities

This thematic workflow makes the development experience more engaging while maintaining clear functionality.

### Manual Chronicler Workflow
Current chronicler workflow to avoid timeout/crash issues:
1. **Use gather_knowledge** during Claude sessions to capture discoveries
2. **Make commits as normal** (no automatic processing)
3. **Run `./chronicler-quicken` manually** after commits to process session.md
4. **Commit documentation updates** separately

This manual approach maintains documentation quality while avoiding Claude crashes.

### Installing Git Hooks from Incantations
Git hooks from incantations are installed by:
1. Copying hook files from `incantations/{name}/git/hooks/` to `.git/hooks/`
2. Making them executable with `chmod +x`
3. The incantation stores the template, the active repo uses the installed copy
4. Hooks can be updated by re-summoning the incantation
<!-- END CHRONICLER: development-workflows -->

<!-- BEGIN CHRONICLER: recent-discoveries -->
## 💡 Recent Discoveries

### Claude CLI Crash Issues (2025-08-21)
**Multiple failure modes discovered:**
1. **Emoji encoding crashes** - Unicode surrogate pair issues in non-interactive mode with emojis
2. **Timeout crashes** - Operations exceeding 120 seconds crash Claude in both modes
3. **Git hook mode failures** - `claude -p` particularly susceptible to both issues
4. **Agent mode failures** - Complex documentation updates trigger timeouts

Despite crashes, operations often complete before the error. Solution: Use manual chronicler-quicken script.

### Manual Chronicler Migration (2025-08-21)
Migrated from automated git hooks/agents to manual script due to persistent crash issues. The `./chronicler-quicken` script must be run manually after commits. This approach avoids timeouts while maintaining documentation quality.

### Gather Knowledge Tool Availability (2025-08-21)  
Claude may forget to use gather_knowledge even with clear CLAUDE.md instructions. The MCP tool might not always be available in sessions. The tool description might need more emphasis on 'use this IMMEDIATELY when you learn something' or 'MUST use when discovering patterns/architecture/workflows'.

### Pipe Exit Status Preservation (2025-08-21)
When piping Claude's output through a while loop for parsing, the exit status becomes the loop's status (always 0), not Claude's. Must use `set -o pipefail` in bash to preserve the original command's exit status through pipes. Critical for detecting Claude execution success/failure in scripts like chronicler-quicken.
<!-- END CHRONICLER: recent-discoveries -->
