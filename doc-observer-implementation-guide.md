# Doc-Observer: Automatic Documentation System Implementation Guide

## Overview

The Doc-Observer is a comprehensive documentation system that automatically builds complete project documentation as Claude explores and works with your codebase. It uses a **capture tool** for recording ALL learnings and an **organize subagent** for building structured documentation.

## Core Concept

This system automatically:
- **Captures EVERYTHING** Claude learns about the project (architecture, patterns, workflows, gotchas)
- **Builds complete documentation** from the ground up through natural exploration
- **Maintains living documentation** that grows with every session
- **Synthesizes knowledge** into a comprehensive CLAUDE.md at commit time

## Implementation

### 1. Create the Capture Tool

Create `.claude/tools/capture-knowledge.md` in your project:

```yaml
---
name: CaptureKnowledge
description: PROACTIVELY records any learned information about the project - architecture, patterns, dependencies, workflows, configurations, or surprising behaviors
parameters:
  category:
    type: string
    enum: ["architecture", "pattern", "dependency", "workflow", "config", "gotcha", "convention"]
    description: Type of knowledge being captured
  topic:
    type: string
    description: Brief topic/title of what was learned
  details:
    type: string
    description: The specific information learned
  files:
    type: string
    description: Related files/paths (optional)
---

#!/usr/bin/env bash
# Tool implementation for capturing knowledge

set -e

# Ensure knowledge directory exists
mkdir -p .knowledge

# Create session file if it doesn't exist
SESSION_FILE=".knowledge/session.md"
if [ ! -f "$SESSION_FILE" ]; then
    echo "# Knowledge Capture Session - $(date +%Y-%m-%d)" > "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"
fi

# Append the knowledge
echo "### [$(date +%H:%M)] [$1] $2" >> "$SESSION_FILE"
echo "**Details**: $3" >> "$SESSION_FILE"
if [ -n "$4" ]; then
    echo "**Files**: $4" >> "$SESSION_FILE"
fi
echo "---" >> "$SESSION_FILE"
echo "" >> "$SESSION_FILE"

echo "✓ Knowledge captured to $SESSION_FILE"
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
3. Rebuild CLAUDE.md as comprehensive project guide:
   - Synthesize Project Overview from discoveries
   - Build Architecture section from .knowledge/architecture/
   - Summarize Key Patterns from .knowledge/patterns/
   - List Dependencies from .knowledge/dependencies/
   - Document Workflows from .knowledge/workflows/
   - Include Recent Discoveries (gotchas)
   - Add Quick Reference for critical info
4. Ensure CLAUDE.md is comprehensive but scannable
5. Clear session.md for next session

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
└── KNOWLEDGE_MAP.md   # Index of all knowledge
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

## CLAUDE.md as Living Document

The doc-organize agent maintains CLAUDE.md as a comprehensive, auto-generated project guide:

```markdown
# CLAUDE.md
<!-- Auto-maintained by doc-organize agent -->

## Project Overview
<!-- Discovered from package.json, main files, etc -->
This is a React/TypeScript application using Next.js 14 with...

## Architecture
<!-- Synthesized from .knowledge/architecture/ -->
- **Frontend**: Next.js with App Router, TailwindCSS
- **State**: Zustand stores in `/stores`
- **API**: REST endpoints at `/api/*`
- **Database**: PostgreSQL with Prisma ORM
[→ Full details](.knowledge/architecture/overview.md)

## Key Patterns
<!-- Discovered from code exploration -->
- **Error Handling**: All errors wrapped in AppError class
- **Auth**: JWT tokens with refresh mechanism
- **Data Fetching**: TanStack Query with custom hooks
[→ All patterns](.knowledge/patterns/)

## Dependencies & Integrations
<!-- From package.json and imports -->
- **Core**: React 18.2, Next.js 14.1
- **External APIs**: Stripe, SendGrid, AWS S3
- **Dev Tools**: Vitest, ESLint with custom rules
[→ Full list](.knowledge/dependencies/)

## Development Workflows
<!-- Learned from scripts, configs -->
- **Run locally**: `npm run dev` (port 3000)
- **Testing**: `npm test` (Vitest with MSW mocks)
- **Deploy**: Vercel auto-deploys from main
[→ All workflows](.knowledge/workflows/)

## Recent Discoveries
<!-- Latest gotchas and learnings -->
- 2025-01-21: OAuth tokens expire immediately in dev mode
- 2025-01-20: Database migrations need SEQUENTIAL=true
[→ All discoveries](.knowledge/gotchas/)

## Quick Reference
<!-- Most important things to know -->
⚠️ Never commit .env.local
⚠️ Always run migrations before starting dev server
📝 Use conventional commits for auto-changelog
🔧 Run `npm run check` before committing
```

This structure ensures:
- Complete project documentation built automatically
- Natural deduplication (Claude won't re-capture what's already documented)
- Progressive enhancement with each session
- Both high-level overview and detailed documentation

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

### 3. Set Up Directory Structure

```bash
mkdir -p .claude/tools .claude/agents
mkdir -p .knowledge/{architecture,patterns,dependencies,workflows,gotchas}
echo "# Knowledge Map" > .knowledge/KNOWLEDGE_MAP.md
echo "Auto-maintained by doc-observer system" >> .knowledge/KNOWLEDGE_MAP.md
touch .knowledge/session.md
```

## Usage Patterns

### During Development (Capture Tool)

Main Claude uses the CaptureKnowledge tool PROACTIVELY throughout exploration:

1. **Learns anything about the project**
2. **Uses CaptureKnowledge tool** to record it
3. **Continues working**

The tool captures ALL discoveries:
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
3. **Rebuilds entire CLAUDE.md** from accumulated knowledge
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
- The capture tool is only used for NEW discoveries
- The organize agent can merge related discoveries

## Benefits

1. **Zero-Effort Documentation**: Complete docs built automatically as you work
2. **Progressive Enhancement**: Documentation grows richer with every session
3. **Natural Deduplication**: CLAUDE.md prevents re-capturing known information
4. **Living Documentation**: Always current, never stale
5. **Knowledge Accumulation**: Every Claude session contributes to collective understanding
6. **Onboarding Magic**: New developers (or Claude sessions) start with full context

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

- **Tool not working**: Check `.claude/tools/capture-knowledge.md` exists with correct format
- **Agent not triggering**: Ensure "MUST BE USED" is in the agent description
- **Not capturing enough**: Emphasize PROACTIVELY in tool description and CLAUDE.md training
- **Session.md growing huge**: Commit more frequently to trigger organization
- **CLAUDE.md incomplete**: Check agent is processing all categories from .knowledge/
- **Duplicate captures**: Ensure CLAUDE.md is being read at session start

## Summary

This system automatically builds complete project documentation through natural exploration:

- **Comprehensive Capture**: CaptureKnowledge tool records EVERYTHING learned
- **Smart Organization**: doc-organize agent builds structured documentation
- **Living Documentation**: CLAUDE.md becomes a complete, auto-generated project guide
- **Progressive Enhancement**: Every session enriches the documentation
- **Natural Deduplication**: Known information isn't re-captured

The result: Complete project documentation that builds itself as you work, ensuring every Claude session starts with full project knowledge.

---

*This implementation guide creates an automatic documentation system that builds comprehensive project knowledge from the ground up. By capturing everything and organizing intelligently, it ensures no knowledge is lost and every session contributes to a richer understanding of the codebase.*