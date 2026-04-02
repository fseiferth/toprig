# SDLC Role Mapping — ${PROJECT_NAME}

## Agent → Document Mapping

| Agent | Produces | Consumes |
|-------|----------|----------|
| Product Manager | PRD, User Stories | Business requirements |
| UX/UI Designer | Design Specs, Prototypes | PRD |
| System Architect | Architecture Docs, API Contracts | PRD, Design Specs |
| Backend Engineer | Implementation, Migrations | Architecture, API Contracts |
| Frontend Engineer | UI Components, Screens | Architecture, Design Specs |
| QA Engineer | Test Plans, Bug Reports | All specs |
| Security Analyst | Security Review, Threat Model | Architecture |
| DevOps Engineer | CI/CD, Infrastructure | Architecture |
| Governance | Compliance Reviews | All docs |

## Handover Protocols

| From → To | Validation Script | Required Docs |
|-----------|------------------|---------------|
| PM → Designer | `verify-handover-ready.sh pm-designer` | PRD approved |
| Designer → Architect | `verify-handover-ready.sh designer-architect` | Design spec complete |
| Architect → Backend | `verify-handover-ready.sh architect-backend` | API contracts defined |
| Architect → Frontend | `verify-handover-ready.sh architect-frontend` | Component specs ready |
| Backend → QA | `verify-handover-ready.sh backend-qa` | Tests pass, env prepared |
| Frontend → QA | `verify-handover-ready.sh frontend-qa` | Tests pass, env prepared |

## Governance Rules

- All handovers validated by scripts (Type 1 enforcement)
- Feature IDs required in all documents and code
- QA bugs go back to accountable engineer, not self-fixed
- Epic closure only via governance agent
