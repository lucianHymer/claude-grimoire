# Doc-Observer: Automatic Documentation System Implementation Guide

## Overview

The Doc-Observer is a comprehensive documentation system that automatically builds complete project documentation as Claude explores and works with your codebase. It uses a **capture tool** for recording ALL learnings and an **organize subagent** for building structured documentation.

## Core Concept

This system automatically:
- **Captures EVERYTHING** Claude learns about the project (architecture, patterns, workflows, gotchas)
- **Builds complete documentation** from the ground up through natural exploration
- **Maintains living documentation** that grows with every session
- **Updates CLAUDE.md** with observer-maintained sections while preserving user content

## Implementation

### 1. Create the MCP Server for Knowledge Capture

We'll create a minimal MCP server that provides the capture_knowledge tool. Save this as `.claude/servers/knowledge-capture.js`:

```javascript
#!/usr/bin/env node
const readline = require('readline');
const fs = require('fs');
const path = require('path');

// Helper to send JSON-RPC responses
function respond(id, result) {
    const response = { jsonrpc: '2.0', id, result };
    console.log(JSON.stringify(response));
}

function respondError(id, code, message) {
    const response = { jsonrpc: '2.0', id, error: { code, message } };
    console.log(JSON.stringify(response));
}

// The actual capture function
function captureKnowledge(args) {
    const { category, topic, details, files } = args;
    
    // Ensure knowledge directory exists
    const knowledgeDir = path.join(process.cwd(), '.knowledge');
    if (!fs.existsSync(knowledgeDir)) {
        fs.mkdirSync(knowledgeDir, { recursive: true });
    }
    
    const sessionFile = path.join(knowledgeDir, 'session.md');
    
    // Create session file header if it doesn't exist
    if (!fs.existsSync(sessionFile)) {
        const date = new Date().toISOString().split('T')[0];
        fs.writeFileSync(sessionFile, `# Knowledge Capture Session - ${date}\n\n`);
    }
    
    // Format the entry
    const time = new Date().toTimeString().slice(0, 5);
    let entry = `### [${time}] [${category}] ${topic}\n`;
    entry += `**Details**: ${details}\n`;
    if (files) {
        entry += `**Files**: ${files}\n`;
    }
    entry += `---\n\n`;
    
    // Atomic append
    fs.appendFileSync(sessionFile, entry);
    
    return `✓ Captured to .knowledge/session.md: [${category}] ${topic}`;
}

// Set up stdin reader for JSON-RPC
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

// Handle incoming JSON-RPC requests
rl.on('line', (line) => {
    try {
        const request = JSON.parse(line);
        
        if (request.method === 'initialize') {
            respond(request.id, {
                protocolVersion: '1.0',
                serverInfo: { name: 'knowledge-capture', version: '1.0.0' },
                capabilities: {
                    tools: { listChanged: false }
                }
            });
        } else if (request.method === 'tools/list') {
            respond(request.id, {
                tools: [{
                    name: 'capture_knowledge',
                    description: 'PROACTIVELY capture any learned information about the project - architecture, patterns, dependencies, workflows, configurations, or surprising behaviors. This builds automatic documentation.',
                    inputSchema: {
                        type: 'object',
                        properties: {
                            category: {
                                type: 'string',
                                enum: ['architecture', 'pattern', 'dependency', 'workflow', 'config', 'gotcha', 'convention'],
                                description: 'Type of knowledge being captured'
                            },
                            topic: {
                                type: 'string',
                                description: 'Brief topic/title of what was learned'
                            },
                            details: {
                                type: 'string',
                                description: 'The specific information learned'
                            },
                            files: {
                                type: 'string',
                                description: 'Related files/paths (optional)'
                            }
                        },
                        required: ['category', 'topic', 'details']
                    }
                }]
            });
        } else if (request.method === 'tools/call') {
            if (request.params.name === 'capture_knowledge') {
                try {
                    const result = captureKnowledge(request.params.arguments);
                    respond(request.id, {
                        content: [{ type: 'text', text: result }]
                    });
                } catch (error) {
                    respondError(request.id, -32603, `Capture failed: ${error.message}`);
                }
            } else {
                respondError(request.id, -32601, `Unknown tool: ${request.params.name}`);
            }
        } else if (request.method === 'shutdown') {
            respond(request.id, {});
            process.exit(0);
        } else {
            respondError(request.id, -32601, `Method not found: ${request.method}`);
        }
    } catch (error) {
        // Invalid JSON or other parsing errors
        console.error('Error processing request:', error);
    }
});

// Handle clean shutdown
process.on('SIGTERM', () => process.exit(0));
process.on('SIGINT', () => process.exit(0));
```

### 2. Create the Organize Subagent

Create `.claude/agents/doc-organize.md` in your project:

```yaml
---
name: doc-organize
description: MUST BE USED when committing code changes - consolidates discoveries into permanent documentation and updates CLAUDE.md
tools: Read, Write, MultiEdit, Glob, Bash, Grep
---

You maintain comprehensive project documentation by organizing all captured knowledge.

## Process

1. Read .knowledge/session.md
2. For each entry:
   - Determine category and if it updates existing knowledge or is new
   - Update or create appropriate file in .knowledge/{category}/
   - Keep dated entries only for gotchas
3. Update KNOWLEDGE_MAP.md:
   - Add new topics with links to their documentation
   - Organize by category with brief descriptions
   - Include last updated timestamps
4. Update CLAUDE.md observer-maintained sections:
   - Look for section markers: `<!-- BEGIN OBSERVER: section-name -->` and `<!-- END OBSERVER: section-name -->`
   - Update ONLY content between these markers
   - If markers don't exist, append new observer sections at the end
   - Sections to maintain:
     * Knowledge Capture Protocol (always present)
     * Project Architecture (from .knowledge/architecture/)
     * Key Patterns (from .knowledge/patterns/)
     * Dependencies (from .knowledge/dependencies/)
     * Development Workflows (from .knowledge/workflows/)
     * Recent Discoveries (latest gotchas)
   - Preserve ALL user content outside observer sections
5. Ensure observer sections are comprehensive but scannable
6. Clear session.md for next session

## Documentation Structure

Create and maintain this structure:
```
.knowledge/
├── session.md           # Current session's raw captures
├── architecture/        # System design, component relationships
│   ├── overview.md     # High-level architecture
│   ├── database.md     # Data models, schemas
│   ├── api.md          # API structure, endpoints
│   └── frontend.md     # UI architecture, components
├── patterns/           # Coding patterns, conventions
│   ├── error-handling.md
│   ├── state-management.md
│   └── testing.md
├── dependencies/       # External services, libraries
│   ├── npm-packages.md
│   └── external-apis.md
├── workflows/          # How to do things in this project
│   ├── deployment.md
│   ├── debugging.md
│   └── local-setup.md
├── gotchas/           # Surprises, non-obvious behaviors
│   └── [dated entries]
└── KNOWLEDGE_MAP.md   # Index of all knowledge (auto-maintained)

### Example KNOWLEDGE_MAP.md Structure:
```markdown
# Knowledge Map

## Architecture
- [Database Architecture](.knowledge/architecture/database.md) - PostgreSQL, Prisma ORM setup
- [API Structure](.knowledge/architecture/api.md) - REST endpoints, middleware
- [Frontend Components](.knowledge/architecture/frontend.md) - React component hierarchy

## Patterns  
- [Error Handling](.knowledge/patterns/error-handling.md) - AppError class pattern
- [State Management](.knowledge/patterns/state-management.md) - Zustand stores

## Dependencies
- [NPM Packages](.knowledge/dependencies/npm-packages.md) - Core libraries and versions
- [External APIs](.knowledge/dependencies/external-apis.md) - Stripe, SendGrid integrations

## Recent Gotchas
- [2025-01-21: Auth Tokens](.knowledge/gotchas/2025-01-21-auth-tokens.md) - Dev mode token expiry

Last updated: 2025-01-21 14:30
```
```

## Output Formats

### Session Capture (via CaptureKnowledge tool)
Automatically appended to `.knowledge/session.md`:
```markdown
### [HH:MM] [category] {topic}
**Details**: {what was learned}
**Files**: {related files if applicable}
---
```

### Organized Documentation (via doc-organize agent)

#### Category Files
In `.knowledge/{category}/{topic}.md`:
```markdown
# {Topic}

## Overview
{Brief description}

## Details
{Comprehensive information discovered}

## Examples
{Code snippets, configurations, commands}

## References
{Related files with line numbers}
```

#### Gotchas
In `.knowledge/gotchas/YYYY-MM-DD-{topic}.md`:
```markdown
# {Clear Problem Statement}

## Issue
{What the surprising behavior was}

## Solution
{How to handle it correctly}

## Root Cause
{Why it happens this way}
```

## CLAUDE.md Structure

The doc-organize agent maintains specific sections while preserving user content:

```markdown
# CLAUDE.md

## My Custom Section
This is user content that won't be touched by the observer.

<!-- BEGIN OBSERVER: knowledge-capture-protocol -->
## 🧠 Knowledge Capture Protocol

You MUST capture ALL discoveries about this project...
[Auto-maintained content about how to use capture]
<!-- END OBSERVER: knowledge-capture-protocol -->

## Another User Section
More user content preserved between observer sections.

<!-- BEGIN OBSERVER: project-architecture -->
## Architecture
- **Frontend**: Next.js with App Router, TailwindCSS
- **State**: Zustand stores in `/stores`
- **API**: REST endpoints at `/api/*`
[→ Full details](.knowledge/architecture/)
<!-- END OBSERVER: project-architecture -->

<!-- BEGIN OBSERVER: key-patterns -->
## Key Patterns  
- **Error Handling**: All errors wrapped in AppError class
- **Auth**: JWT tokens with refresh mechanism
[→ All patterns](.knowledge/patterns/)
<!-- END OBSERVER: key-patterns -->

<!-- BEGIN OBSERVER: recent-discoveries -->
## Recent Discoveries
- 2025-01-21: OAuth tokens expire immediately in dev mode
- 2025-01-20: Database migrations need SEQUENTIAL=true
[→ All discoveries](.knowledge/gotchas/)
<!-- END OBSERVER: recent-discoveries -->

## User's Quick Reference
User's own notes stay here untouched.
```

This ensures:
- Observer maintains its sections without touching user content
- User can add custom documentation anywhere
- Clear separation with HTML comment markers
- Knowledge Capture Protocol section is always maintained

## Training Main Claude

Add to your CLAUDE.md to train Main Claude to use the capture tool:

```markdown
## Development Workflow

Use CaptureKnowledge tool PROACTIVELY whenever you learn ANYTHING about the project:

- **Architecture**: "This app uses Next.js App Router" → capture as architecture
- **Pattern**: "All API calls go through apiClient" → capture as pattern
- **Dependency**: "This uses Stripe for payments" → capture as dependency
- **Workflow**: "Deploy by pushing to main" → capture as workflow
- **Config**: "Environment vars are in .env.local" → capture as config
- **Gotcha**: "This breaks in unexpected way" → capture as gotcha
- **Convention**: "Team uses snake_case for database" → capture as convention

Capture even obvious things - we're building complete documentation automatically!
Every piece of knowledge contributes to the project's living documentation.
```

## Installation Instructions

To install the doc-observer system in any project:

### 1. Create the Directory Structure

```bash
# Create Claude directories
mkdir -p .claude/agents .claude/servers

# Create knowledge directories
mkdir -p .knowledge/{architecture,patterns,dependencies,workflows,gotchas}

# Initialize knowledge files
echo "# Knowledge Map" > .knowledge/KNOWLEDGE_MAP.md
echo "Auto-maintained by doc-observer system" >> .knowledge/KNOWLEDGE_MAP.md
touch .knowledge/session.md
```

### 2. Install the MCP Server

Copy the MCP server code from **Step 1 of the Implementation section** above to `.claude/servers/knowledge-capture.js`:

```bash
# Copy the complete MCP server code from Implementation Step 1 to this file:
# .claude/servers/knowledge-capture.js

# Then make it executable
chmod +x .claude/servers/knowledge-capture.js
```

### 3. Configure the MCP Server

Create `.mcp.json` in your project root to register the knowledge capture server:

```json
{
  "mcpServers": {
    "knowledge-capture": {
      "type": "stdio",
      "command": "node",
      "args": [".claude/servers/knowledge-capture.js"]
    }
  }
}
```

The doc-organize agent will automatically add/update this section in CLAUDE.md:

```markdown
<!-- BEGIN OBSERVER: knowledge-capture-protocol -->
## 🧠 Knowledge Capture Protocol

You have access to the capture_knowledge tool. You MUST use it PROACTIVELY to capture ALL discoveries about this project. This builds automatic documentation.

### How to Use the Tool

Use the capture_knowledge tool with these parameters:
- category: architecture/pattern/dependency/workflow/config/gotcha/convention
- topic: Brief title of what you learned
- details: Specific information discovered
- files: Related file paths (optional)

### Categories
- **architecture**: System design, component structure, data flow
- **pattern**: Coding patterns, conventions, repeated approaches  
- **dependency**: External libraries, APIs, services
- **workflow**: How to accomplish tasks, build/deploy processes
- **config**: Environment setup, configuration files, settings
- **gotcha**: Surprising behaviors, non-obvious issues, warnings
- **convention**: Team standards, naming conventions, style guides

### Examples of When to Capture

✅ ALWAYS capture when you:
- Understand how something works → capture_knowledge(architecture, "Database Setup", "Uses PostgreSQL...")
- Find configuration details → capture_knowledge(config, "Environment Variables", "Stored in .env.local...")
- Discover a pattern → capture_knowledge(pattern, "Error Handling", "All errors wrapped in AppError...")
- Hit surprising behavior → capture_knowledge(gotcha, "Token Expiry", "Tokens expire immediately in dev...")
- Learn about dependencies → capture_knowledge(dependency, "Payment Processing", "Stripe SDK v12.5...")
- Figure out a workflow → capture_knowledge(workflow, "Local Development", "Run npm run dev...")

❌ DON'T capture:
- Syntax errors or typos
- Temporary debugging info
- Personal TODOs (use TodoWrite instead)

Remember: You're building permanent documentation. Every capture makes future sessions smarter!
<!-- END OBSERVER: knowledge-capture-protocol -->
```

### How This Works (Real MCP Tool!):

1. **Claude sees capture_knowledge** in its available tools list
2. **Claude calls the tool** with structured parameters when it learns something
3. **MCP server validates** parameters and appends to `.knowledge/session.md`
4. **Tool returns confirmation** to Claude
5. **No bash scripts or env vars needed** - it's a proper tool!

This is a real MCP tool that Claude can discover and use naturally, just like Edit, Read, etc.

### 4. Install the doc-organize Subagent

Copy the agent definition from Step 2 to `.claude/agents/doc-organize.md`.

### 5. Initial CLAUDE.md Setup

The doc-organize agent will automatically add the Knowledge Capture Protocol section to your CLAUDE.md. You can also add any custom sections you want - they'll be preserved.

### 6. Commit to Version Control

```bash
git add .claude/ .knowledge/
git commit -m "Add doc-observer documentation system"
```

## Quick Install Script

Save this as `install-doc-observer.sh` and run it in any project:

```bash
#!/bin/bash
# Doc-Observer Quick Install Script

echo "Installing Doc-Observer System..."

# Create directories
mkdir -p .claude/agents .claude/servers .knowledge/{architecture,patterns,dependencies,workflows,gotchas}

# Download/create the capture script
curl -o .claude/servers/knowledge-capture.js https://raw.githubusercontent.com/your-repo/doc-observer/main/knowledge-capture.js
chmod +x .claude/servers/knowledge-capture.js

# Download/create the bash helper
curl -o .claude/capture-helper.sh https://raw.githubusercontent.com/your-repo/doc-observer/main/capture-helper.sh
chmod +x .claude/capture-helper.sh

# Download/create the agent
curl -o .claude/agents/doc-organize.md https://raw.githubusercontent.com/your-repo/doc-observer/main/doc-organize.md

# Initialize knowledge files
echo "# Knowledge Map" > .knowledge/KNOWLEDGE_MAP.md
echo "Auto-maintained by doc-observer system" >> .knowledge/KNOWLEDGE_MAP.md
touch .knowledge/session.md

echo "✅ Doc-Observer installed successfully!"
echo "📝 Run 'doc-organize' agent to initialize CLAUDE.md with capture instructions"
```

## Usage Patterns

### During Development (Capture)

Claude uses the bash helper PROACTIVELY throughout exploration:

1. **Learns anything about the project**
2. **Runs capture command** to record it: `source .claude/capture-helper.sh && capture category "topic" "details"`
3. **Continues working**

The system captures ALL discoveries:
- Project structure and architecture
- Technology stack and frameworks
- Coding patterns and conventions
- Dependencies and integrations
- Development workflows
- Configuration details
- Surprising behaviors and gotchas

### At Commit Time (Organize Agent)

The doc-organize agent MUST BE USED when committing:

1. **Processes all entries** in .knowledge/session.md
2. **Updates category documentation** in .knowledge/{category}/
3. **Updates CLAUDE.md observer sections** while preserving user content
4. **Creates dated gotcha files** for surprises
5. **Clears session.md** for next session

This progressively builds complete project documentation with every commit.

## Deduplication Strategy

Since CLAUDE.md contains the Discovery Index:

1. **Natural deduplication**: Claude sees previous discoveries at session start
2. **Won't re-capture**: Known issues are already visible in CLAUDE.md
3. **Progressive detail**: One-line in index, full details in linked files

The system prevents re-capturing because:
- Main Claude reads CLAUDE.md and knows what's already documented
- The capture command is only used for NEW discoveries
- The organize agent can merge related discoveries

## Benefits

1. **Zero-Effort Documentation**: Complete docs built automatically as you work
2. **Progressive Enhancement**: Documentation grows richer with every session
3. **Natural Deduplication**: CLAUDE.md prevents re-capturing known information
4. **Living Documentation**: Always current, never stale
5. **Knowledge Accumulation**: Every Claude session contributes to collective understanding
6. **Onboarding Magic**: New developers (or Claude sessions) start with full context
7. **Cross-Platform**: Node.js solution works on Mac, Linux, and Windows
8. **No Dependencies**: Uses only Node.js built-in modules, no npm packages needed
9. **Concurrent Safe**: `fs.appendFileSync` handles multiple writes atomically

## Tips for Success

1. **Capture Everything**: Even "obvious" things - you're building complete docs
2. **Use Categories**: Proper categorization helps organization
3. **Commit Regularly**: Each commit enriches the documentation
4. **Don't Perfect**: Raw captures are valuable, organization happens later
5. **Trust Accumulation**: Documentation quality improves organically over time
6. **Review Periodically**: Check CLAUDE.md remains accurate and useful

## Example Evolution

### Session 1: Initial Exploration
```
Claude explores new codebase:
→ "This is a Next.js 14 app" → CaptureKnowledge(architecture)
→ "Uses PostgreSQL database" → CaptureKnowledge(architecture)
→ "JWT auth with refresh tokens" → CaptureKnowledge(pattern)
→ "npm run dev starts the server" → CaptureKnowledge(workflow)
→ "Stripe for payments" → CaptureKnowledge(dependency)

Commit time:
→ doc-organize builds initial CLAUDE.md with basic project overview
```

### Session 2: Deeper Discovery
```
Claude reads CLAUDE.md, knows basics, continues exploring:
→ "Zustand for state management" → CaptureKnowledge(architecture)
→ "Custom useAuth hook pattern" → CaptureKnowledge(pattern)
→ "Weird: tokens expire immediately in dev" → CaptureKnowledge(gotcha)
→ No re-capture of Next.js, PostgreSQL, etc. (already in CLAUDE.md)

Commit time:
→ doc-organize enriches CLAUDE.md with new discoveries
```

### Session 10: Mature Documentation
```
CLAUDE.md now contains:
- Complete architecture documentation
- All coding patterns and conventions
- Full dependency list with purposes
- Comprehensive workflow guides
- Collection of gotchas and solutions

New Claude sessions start with complete project knowledge!
```

## Troubleshooting

- **Tool not working**: Check `.claude/servers/knowledge-capture.js` exists and `.mcp.json` is configured
- **Permission denied**: Run `chmod +x .claude/servers/knowledge-capture.js` to make the script executable
- **Node not found**: Ensure Node.js is installed (`node --version` to check)
- **Agent not triggering**: Ensure "MUST BE USED" is in the agent description
- **Not capturing enough**: Emphasize PROACTIVELY in tool description and CLAUDE.md training
- **Session.md growing huge**: Commit more frequently to trigger organization
- **CLAUDE.md incomplete**: Check agent is processing all categories from .knowledge/
- **Duplicate captures**: Ensure CLAUDE.md is being read at session start

## Summary

This system automatically builds complete project documentation through natural exploration:

- **Bash Helper (capture)**: Simple function Claude calls to record discoveries
- **Node.js Script**: Handles atomic file writes to prevent corruption
- **Subagent (doc-organize)**: Organizes knowledge and updates CLAUDE.md observer sections
- **Preserved User Content**: CLAUDE.md maintains both auto-generated and user sections
- **Progressive Enhancement**: Every session enriches the documentation
- **Natural Deduplication**: Known information isn't re-captured

The architecture uses:
- **NO MCP complexity** - just bash helpers and Node.js scripts
- **Subagent** in `.claude/agents/` for the organization logic  
- **Observer sections** in CLAUDE.md that coexist with user content
- **Atomic file operations** to handle concurrent captures safely

The result: Complete project documentation that builds itself as you work, ensuring every Claude session starts with full project knowledge.

---

*This implementation guide creates an automatic documentation system that builds comprehensive project knowledge from the ground up. By capturing everything and organizing intelligently, it ensures no knowledge is lost and every session contributes to a richer understanding of the codebase.*