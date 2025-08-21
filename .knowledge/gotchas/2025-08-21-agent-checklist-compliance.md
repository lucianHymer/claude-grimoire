# Agent Checklist Compliance Issue

**Date**: 2025-08-21

## Problem
Agents don't always complete all checklist items even when clearly specified. The chronicler-quicken agent had a detailed checklist but only partially completed tasks (updated CLAUDE.md but didn't clear session.md or create .knowledge files).

## Root Cause
Passive language and numbered lists without strong imperatives allow agents to treat steps as optional.

## Solution
Use more forceful, imperative language:
- **MUST** statements for every critical action
- **Bold emphasis** on key requirements
- Explicit **FAILURE** conditions stated upfront
- Verification checklist at the end
- Multiple warnings throughout about consequences of skipping steps

## Example
Changed from passive numbered list to aggressive "MUST COMPLETE" format with warnings about task failure if any step is skipped.

## Related Files
- `packages/chronicler/agents/chronicler-quicken.md`