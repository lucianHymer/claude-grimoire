# Pipe Exit Status Preservation Issue

**Date**: 2025-08-21 20:42

## Problem
When piping Claude's output through a while loop for parsing, the exit status becomes the loop's status (always 0), not Claude's. This means the script can't detect if Claude failed or succeeded.

## Solution
Use `set -o pipefail` in bash to preserve the original command's exit status through pipes.

```bash
set -o pipefail  # Must be set before the pipe command

claude [command] | while read line; do
    # Process output
done

# Now $? contains Claude's exit status, not the while loop's
```

## Affected Files
- `chronicler-quicken` - Required for detecting Claude execution success/failure