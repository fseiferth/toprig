# Handover Protocols — ${PROJECT_NAME}

## Purpose

Define what must be true before work transitions between SDLC phases. Each handover is enforced by `verify-handover-ready.sh`.

## PM → Designer

### Required
- [ ] PRD approved and versioned
- [ ] User stories with acceptance criteria
- [ ] Success metrics defined
- [ ] Feature ID assigned in registry

### Artifacts
- `product-docs/${FEATURE_ID}-*.md`

## Designer → Architect

### Required
- [ ] All screen states designed (default, loading, empty, error, success)
- [ ] Component specifications with props
- [ ] Accessibility annotations
- [ ] User journey documented

### Artifacts
- `design-documentation/features/${FEATURE_ID}-*/`

## Architect → Engineers

### Required
- [ ] API contracts with request/response schemas
- [ ] Data model with migrations
- [ ] Security considerations documented
- [ ] Performance requirements specified

### Artifacts
- `architecture/*.md` with `<!-- ${FEATURE_ID} -->` markers

## Engineers → QA

### Required
- [ ] All unit tests pass
- [ ] Implementation matches spec
- [ ] Test environment prepared and running
- [ ] Known limitations documented

### Pre-QA Command
```bash
./scripts/verify-handover-ready.sh backend-qa
```

## QA → Done

### Required
- [ ] Test plan executed
- [ ] All critical/high bugs resolved
- [ ] Regression tests added
- [ ] Cross-check passed (`/cross-check`)
