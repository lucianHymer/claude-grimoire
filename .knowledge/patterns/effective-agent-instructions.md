# Effective Agent Instruction Patterns

## Key Principles
For agents to reliably complete all required steps, use:

### 1. MUST Language
Every critical action should use "MUST" rather than "should" or "will"

### 2. Bold Emphasis
**Bold** key requirements to draw attention

### 3. Explicit Failure Conditions
State upfront: "FAILURE TO COMPLETE ANY STEP MEANS THE ENTIRE TASK HAS FAILED"

### 4. Verification Checklist
End with a checklist that must be completed:
```markdown
**VERIFICATION CHECKLIST - ALL MUST BE TRUE:**
- [ ] Step 1 completed
- [ ] Step 2 completed
- [ ] All requirements met
```

### 5. Multiple Warnings
Include warnings throughout:
- "IF YOU SKIP ANY STEP, YOU HAVE FAILED THE TASK"
- "ALL steps are MANDATORY"

## Avoid
- Passive voice
- Optional-sounding language ("should", "can", "may")
- Numbered lists without imperatives
- Ambiguous success criteria

## Example Implementation
See `packages/chronicler/agents/chronicler-quicken.md` for a complete example of these patterns in action.