Route to claude-md-steward skill based on user intent.

## Routing

If the user provided arguments, route as follows:
- `add` or `new` -> Invoke Skill tool: `claude-md-steward` with args "mode=0" (Brainstorm + Cascade, then Mode 1)
- `audit` or `health` -> Invoke Skill tool: `claude-md-steward` with args "mode=2" (Health Audit)
- `scan` or `drift` or `ecosystem` -> Invoke Skill tool: `claude-md-steward` with args "mode=3" (Ecosystem Scan)
- `change` or `edit` or `modify` -> Invoke Skill tool: `claude-md-steward` with args "mode=1" (Pre-Change only)
- No arguments -> Default to Mode 2 (Audit)

## Before Invoking

Tell the user which mode you're routing to and why.
