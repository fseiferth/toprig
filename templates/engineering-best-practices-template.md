# Engineering Best Practices — ${PROJECT_NAME}

## Coding Standards

### Naming Conventions
- Files: 
- Functions: 
- Variables: 
- Constants: 

### Code Organization
- Directory structure overview
- Module boundaries
- Import conventions

## Testing

### Test Strategy
- Unit tests: [framework, coverage target]
- Integration tests: [scope, fixtures]
- E2E tests: [framework, scenarios]

### Test Email Convention
- Pattern: `${TEST_EMAIL_PATTERN}`
- Purpose: Prevent real emails during testing

### Running Tests
```bash
# Unit tests
[command]

# Integration tests
[command]

# E2E tests
[command]
```

## Debugging

### Common Issues
| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| | | |

### Logging
- Log levels: DEBUG, INFO, WARN, ERROR
- Structured logging format
- Sensitive data: never log credentials, PII, or tokens

## QA Handoff

Before invoking QA agent:
- [ ] All tests pass locally
- [ ] Feature matches spec (verify against PRD/design/architecture)
- [ ] No hardcoded values
- [ ] Error handling covers edge cases
- [ ] Environment prepared for QA

## Deployment

### Environment Setup
```bash
# Development
[commands]

# Staging
[commands]
```

### Pre-Deploy Checklist
- [ ] Tests pass in CI
- [ ] Database migrations reviewed
- [ ] Environment variables set
- [ ] Rollback procedure documented

## Git Conventions

### Branch Naming
- `feature/[description]`
- `fix/[description]`
- `chore/[description]`

### Commit Messages
- Imperative mood: "Add feature" not "Added feature"
- Reference feature ID: `feat(scope): description [${FEATURE_ID_FORMAT}]`
