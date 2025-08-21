# Gather Knowledge Tool Availability Issue
**Date**: 2025-08-21

## Problem
Claude may forget to use `gather_knowledge` even with clear CLAUDE.md instructions. The MCP tool might not always be available in sessions.

## Potential Solutions
- Tool description might need more emphasis on immediate use
- Consider adding "use this IMMEDIATELY when you learn something"
- Include "MUST use when discovering patterns/architecture/workflows"
- Make the protocol more forceful in CLAUDE.md instructions

## Impact
Knowledge may not be captured during development sessions, requiring manual documentation updates or relying on git hooks for capture.