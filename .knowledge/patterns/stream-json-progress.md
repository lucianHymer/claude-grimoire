# Stream-JSON Output for Progress Monitoring

## Pattern
Using `--output-format stream-json` with Claude CLI provides real-time progress updates for long-running tasks.

## Implementation
```bash
claude --output-format stream-json [command] | while IFS= read -r line; do
    # Parse JSON stream with jq
    text=$(echo "$line" | jq -r '.message.content[0].text // empty' 2>/dev/null)
    tool=$(echo "$line" | jq -r '.message.content[0].name // empty' 2>/dev/null)
    
    # Display progress
    [ -n "$text" ] && echo "$text"
    [ -n "$tool" ] && echo "Using tool: $tool"
done
```

## Key Benefits
- Solves the silent waiting problem with non-interactive mode
- Shows real-time progress for long operations
- Allows parsing of tool usage and text output separately

## Important Notes
- Must use `set -o pipefail` to preserve Claude's exit status through pipes
- Requires jq for JSON parsing

## Files Using This Pattern
- `chronicler-quicken`
- `incantations/chronicler/scripts/chronicler-quicken`