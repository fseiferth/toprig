# Agent Roster

TopRig ships 13 SDLC agent definitions. Each agent is a markdown file in `agents/` that defines the agent's role, responsibilities, and behavioral rules.

## Workflow Order

```
Product Manager → UX/UI Designer → System Architect
    → Senior Backend Engineer + Senior Frontend Engineer
    → QA Test Automation Engineer + Security Analyst
    → DevOps Deployment Engineer → Respect-the-Spec
```

## Agents

### Product Manager (`product-manager`)
**Model:** opus | Transforms ideas into structured PRDs, user stories, and requirements.

### UX/UI Designer (`ux-ui-designer`)
**Model:** opus | Designs user experiences, visual interfaces, and accessibility.

### System Architect (`system-architect`)
**Model:** opus | Technical architecture, API contracts, data models, tech stack decisions.

### Senior Backend Engineer (`senior-backend-engineer`)
**Model:** sonnet | APIs, business logic, database operations, migrations.

### Senior Frontend Engineer (`senior-frontend-engineer`)
**Model:** sonnet | UI implementation, components, state management.

### QA Test Automation Engineer (`qa-test-automation-engineer`)
**Model:** sonnet | Unit, integration, and E2E testing. Test plans and automation.

### Security Analyst (`security-analyst`)
**Model:** opus | Vulnerability assessment, threat modeling, code security review.

### DevOps Deployment Engineer (`devops-deployment-engineer`)
**Model:** sonnet | CI/CD, Docker, deployment, infrastructure.

### Governance (`governance`)
**Model:** opus | SDLC compliance, epic closure, workflow integrity.

### Research (`research`)
**Model:** opus | Codebase exploration, evidence validation, technical research.

### Competitive Market Research (`competitive-market-research`)
**Model:** opus | Market analysis, competitive intelligence, strategic insights.

### Legal Contract Analyst (`legal-contract-analyst`)
**Model:** opus | Contract review, risk assessment, IP/licensing analysis.

### Respect-the-Spec (`respect-the-spec`)
**Model:** sonnet | Validates implementation against specifications.

## Model Selection

- **opus**: Complex reasoning, architecture, security, research
- **sonnet**: Implementation, testing, deployment (faster, cheaper)

Override per-project in `project-config.yml` under `agent_models`.
