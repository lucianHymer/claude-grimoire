# Chronicler: Automatic Documentation System Implementation Guide

## Overview

The Chronicler is a comprehensive documentation system that automatically builds complete project documentation as Claude explores and works with your codebase. It uses a **gather tool** for recording ALL learnings and a **quicken subagent** for transmuting raw knowledge into structured documentation.

## Core Concept

This system automatically:
- **Gathers EVERYTHING** Claude learns about the project (architecture, patterns, workflows, gotchas)
- **Builds complete documentation** from the ground up through natural exploration
- **Maintains living documentation** that grows with every session
- **Updates CLAUDE.md** with Chronicler-maintained sections while preserving user content

## Implementation

### 1. Create the MCP Server

Save this as `.claude/servers/chronicler.js`:

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

// The actual gathering function
function gatherKnowledge(args) {
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
    
    return `✓ Gathered to .knowledge/session.md: [${category}] ${topic}`;
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
                serverInfo: { name: 'chronicler', version: '1.0.0' },
                capabilities: {
                    tools: { listChanged: false }
                }
            });
        } else if (request.method === 'tools/list') {
            respond(request.id, {
                tools: [{
                    name: 'gather_knowledge',
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
            if (request.params.name === 'gather_knowledge') {
                try {
                    const result = gatherKnowledge(request.params.arguments);
                    respond(request.id, {
                        content: [{ type: 'text', text: result }]
                    });
                } catch (error) {
                    respondError(request.id, -32603, `Gathering failed: ${error.message}`);
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

### 2. Create the Quicken Subagent

Save this as `.claude/agents/chronicler-quicken.md`:

```yaml
---
name: chronicler-quicken
description: MUST BE USED when committing code changes - quickens raw gathered knowledge into permanent living documentation and updates CLAUDE.md
tools: Read, Write, MultiEdit, Glob, Bash, Grep
---

You quicken raw gathered knowledge into comprehensive project documentation.

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
4. Update CLAUDE.md Chronicler-maintained sections:
   - Look for section markers: `<!-- BEGIN CHRONICLER: section-name -->` and `<!-- END CHRONICLER: section-name -->`
   - Update ONLY content between these markers
   - If markers don't exist, append new Chronicler sections at the end
   - Sections to maintain:
     * Knowledge Gathering Protocol (always present)
     * Project Architecture (from .knowledge/architecture/)
     * Key Patterns (from .knowledge/patterns/)
     * Dependencies (from .knowledge/dependencies/)
     * Development Workflows (from .knowledge/workflows/)
     * Recent Discoveries (latest gotchas)
   - Preserve ALL user content outside Chronicler sections
5. Ensure Chronicler sections are comprehensive but scannable
6. Clear session.md for next session

## Documentation Structure

Create and maintain this structure:
```
.knowledge/
├── session.md           # Current session's raw captures
├── architecture/        # System design, component relationships
├── patterns/           # Coding patterns, conventions
├── dependencies/       # External services, libraries
├── workflows/          # How to do things in this project
├── gotchas/           # Surprises, non-obvious behaviors
└── KNOWLEDGE_MAP.md   # Index of all knowledge (auto-maintained)
```

## CLAUDE.md Template

Maintain sections like this:

```markdown
<!-- BEGIN CHRONICLER: knowledge-gathering-protocol -->
## 🧠 Knowledge Gathering Protocol

You have access to the gather_knowledge tool. You MUST use it PROACTIVELY to capture ALL discoveries about this project.

Use gather_knowledge with these parameters:
- category: architecture/pattern/dependency/workflow/config/gotcha/convention
- topic: Brief title of what you learned
- details: Specific information discovered
- files: Related file paths (optional)

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
```
```

## Installation

### 1. Create Directory Structure

```bash
mkdir -p .claude/agents .claude/servers
mkdir -p .knowledge/{architecture,patterns,dependencies,workflows,gotchas}
```

### 2. Install the MCP Server

Copy the MCP server code from Step 1 above to `.claude/servers/chronicler.js`:

```bash
chmod +x .claude/servers/chronicler.js
```

### 3. Configure MCP

Create `.mcp.json` in your project root:

```json
{
  "mcpServers": {
    "chronicler": {
      "type": "stdio",
      "command": "node",
      "args": [".claude/servers/chronicler.js"]
    }
  }
}
```

### 4. Install the Quicken Subagent

Copy the agent definition from Step 2 above to `.claude/agents/chronicler-quicken.md`.

### 5. Initialize Knowledge Files

```bash
echo "# Knowledge Map" > .knowledge/KNOWLEDGE_MAP.md
echo "Auto-maintained by Chronicler system" >> .knowledge/KNOWLEDGE_MAP.md
touch .knowledge/session.md
```

### 6. Commit to Version Control

```bash
git add .claude/ .knowledge/ .mcp.json
git commit -m "Add Chronicler documentation system"
```

## Usage

### During Development

Claude uses the gather_knowledge tool PROACTIVELY throughout exploration:

1. **Learns anything** about the project
2. **Uses gather_knowledge tool** to record it
3. **Continues working**

The tool captures ALL discoveries:
- Project structure and architecture
- Technology stack and frameworks
- Coding patterns and conventions
- Dependencies and integrations
- Development workflows
- Configuration details
- Surprising behaviors and gotchas

### At Commit Time

The chronicler-quicken agent MUST BE USED when committing:

1. **Processes all entries** in .knowledge/session.md
2. **Updates category documentation** in .knowledge/{category}/
3. **Updates CLAUDE.md Chronicler sections** while preserving user content
4. **Creates dated gotcha files** for surprises
5. **Clears session.md** for next session

This progressively builds complete project documentation with every commit.

## Benefits

1. **Zero-Effort Documentation**: Complete docs built automatically as you work
2. **Progressive Enhancement**: Documentation grows richer with every session
3. **Natural Deduplication**: CLAUDE.md prevents re-capturing known information
4. **Living Documentation**: Always current, never stale
5. **Knowledge Accumulation**: Every Claude session contributes to collective understanding
6. **Onboarding Magic**: New developers (or Claude sessions) start with full context
7. **Cross-Platform**: Works on Mac, Linux, and Windows
8. **No Dependencies**: Uses only Node.js built-in modules
9. **Concurrent Safe**: Atomic file operations prevent corruption

## Troubleshooting

- **Tool not working**: Check `.claude/servers/chronicler.js` exists and `.mcp.json` is configured
- **Permission denied**: Run `chmod +x .claude/servers/chronicler.js`
- **Node not found**: Ensure Node.js is installed (`node --version` to check)
- **Agent not triggering**: Ensure "MUST BE USED" is in the agent description
- **Not capturing enough**: Emphasize PROACTIVELY in tool description
- **Session.md growing huge**: Commit more frequently to trigger quickening
- **CLAUDE.md incomplete**: Check agent is processing all categories from .knowledge/
- **Duplicate captures**: Ensure CLAUDE.md is being read at session start

## Summary

The Chronicler system automatically builds complete project documentation through natural exploration:

- **MCP Tool (gather_knowledge)**: Records everything learned during exploration
- **Subagent (chronicler-quicken)**: Quickens gathered knowledge into structured documentation
- **Living Documentation**: CLAUDE.md becomes a comprehensive, auto-generated project guide
- **Progressive Enhancement**: Every session enriches the documentation
- **Natural Deduplication**: Known information isn't re-captured

The result: Complete project documentation that builds itself as you work, ensuring every Claude session starts with full project knowledge.