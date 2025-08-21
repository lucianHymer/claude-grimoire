# Tool Description Patterns

## Aggressive Behavioral Tool Descriptions

When creating MCP tools that require behavioral triggering (like gather_knowledge), conventional tool descriptions are insufficient. The tool description must be:

1. **Explicitly prescriptive** with mandatory trigger conditions
2. **Include specific trigger phrases** that commonly appear in conversation
3. **Provide concrete bad/good examples** to clarify usage
4. **Use aggressive language** (MUST, IMMEDIATELY, MANDATORY) to ensure compliance
5. **List common blind spots** where the tool should be used but might be forgotten

### Example: gather_knowledge Tool Enhancement

The gather_knowledge tool transformed from abstract "use when learning" to concrete behavioral triggers:
- Added mandatory trigger phrases: "for future reference", "turns out", "I discovered", etc.
- Specified exact situations requiring gathering (mistakes, discoveries, conventions)
- Included examples showing when NOT to use vs when to use
- Used emphatic formatting (⚠️ MANDATORY, ❌ BAD, ✅ GOOD) for clarity

This verbose, aggressive approach is unconventional for MCP tools but necessary when the tool requires behavioral triggering rather than obvious task mapping. The tool description itself becomes part of the behavioral conditioning.

**Implementation**: incantations/chronicler/claude/servers/chronicler.js