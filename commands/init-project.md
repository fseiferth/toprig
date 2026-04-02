Initialize a new project from the blueprint template at ~/workspace/project-blueprint/

You are helping the user set up a complete new project with governance, SDLC, testing, CI/CD, and operational infrastructure.

## Your Task

1. **Run the progressive questionnaire** (25+ questions) to gather project configuration
2. **Generate project configuration JSON** from answers
3. **Invoke the adapter.py script** to create project structure
4. **Provide post-initialization checklist** for manual steps

## Progressive Questionnaire

Ask these questions **one at a time** in a conversational way. Group related questions together when it makes sense.

### Phase 1: Project Basics (3 questions)
1. What's the project name? (e.g., "TaskMaster", "ItemShare")
2. One-line description of what it does?
3. Where should I create it? (default: ~/workspace/projects/{{PROJECT_NAME}})

### Phase 2: Platform (1-2 questions)
4. What type of project is this?
   - Mobile app (iOS/Android)
   - Web app
   - Desktop app
   - API/Backend only
   - CLI tool
   - Full-stack (Web + Mobile)

5. **[If Mobile]** Mobile framework?
   - React Native (Expo)
   - React Native (bare workflow)
   - Flutter
   - Native (Swift/Kotlin)

   **[If Web]** Frontend framework?
   - Next.js
   - React (SPA)
   - Vue
   - Svelte
   - Vanilla JS

### Phase 3: Tech Stack - Backend (4 questions)
6. Backend language?
   - TypeScript/Node.js
   - Python
   - Go
   - Java/Kotlin
   - Ruby
   - No backend (frontend only)

7. **[If backend exists]** Backend framework?
   - **Python:** FastAPI | Django | Flask
   - **Node:** Express | NestJS | Fastify | Next.js API routes
   - **Go:** Gin | Echo | Chi

8. Database?
   - PostgreSQL
   - MongoDB
   - MySQL
   - SQLite
   - Supabase
   - Firebase
   - None (stateless)

9. Need caching or queues?
   - Redis
   - Memcached
   - RabbitMQ
   - None

### Phase 4: Infrastructure (2 questions)
10. Where will you host the frontend? (or skip if no frontend)
    - Vercel
    - Netlify
    - AWS
    - Google Cloud
    - Self-hosted
    - TBD

11. Where will you host the backend? (or skip if no backend)
    - Railway
    - AWS (ECS/Lambda)
    - Google Cloud Run
    - Vercel (Next.js API)
    - Self-hosted
    - TBD

### Phase 5: Git & Repository (2 questions)
12. Git repository URL? (leave blank if creating new repo)
    - Example: https://github.com/yourorg/project-name.git

13. Initialize git now?
    - Yes, create new repo and push to remote
    - Yes, create local repo only (push later)
    - No, I'll handle git separately

### Phase 6: External Integrations (4 questions)
14. Which external services will you use? (multi-select)
    - Bitwarden (secret management)
    - Supabase (database + optional auth)
    - Linear (project management)
    - OpenAI API
    - Anthropic API
    - SendGrid (email)
    - Stripe (payments)
    - None yet

15. **[If Bitwarden selected]** Which Bitwarden server?
    - EU (vault.bitwarden.eu) - like ${PROJECT_NAME}
    - US (vault.bitwarden.com)

16. **[If Supabase or database selected]** Authentication approach?
    - Custom JWT (full control, like ${PROJECT_NAME})
    - Supabase Auth (managed service)
    - Auth0
    - Firebase Auth
    - Clerk
    - Build from scratch

17. **[If Supabase selected]** Database provider for Supabase?
    - Supabase Cloud (managed PostgreSQL)
    - Self-hosted PostgreSQL with Supabase client libraries

### Phase 7: Testing & Quality (2 questions)
18. Testing approach? (multi-select)
    - Unit tests (copy ${PROJECT_NAME} testing structure)
    - Integration tests
    - E2E tests (Playwright/Cypress)
    - Manual testing only (for now)

19. Code quality tools? (multi-select)
    - ESLint/Prettier (JavaScript/TypeScript)
    - Ruff/Black (Python)
    - Golangci-lint (Go)
    - Pre-commit hooks (keep Gitleaks security scanning)
    - Security scanning (Bandit for Python, ESLint security for JS)

### Phase 8: Team & Workflow (3 questions)
20. Team size?
    - Solo developer
    - Small team (2-5)
    - Medium team (6-15)
    - Large team (15+)

21. SDLC governance level?
    - Full (all ${PROJECT_NAME} governance - quality gates, audits, handoffs)
    - Medium (core quality gates only, simplified reports)
    - Light (basic code reviews and testing)
    - Minimal (essential checks only)

22. Use development diary automation?
    - Yes (copy /daily-report and /weekly-report commands, dashboard)
    - No

### Phase 9: CI/CD (1 question)
23. CI/CD platform?
    - GitHub Actions (keep ${PROJECT_NAME} workflows)
    - GitLab CI
    - CircleCI
    - None yet

### Phase 10: Special Requirements (3 questions)
24. Offline-first architecture?
    - Yes (affects state management and sync strategy)
    - No

25. Real-time features?
    - Yes (need WebSockets or polling)
    - No

26. Internationalization (i18n)?
    - Yes (multi-language support)
    - No

27. Anything else I should know about this project? (free text)

---

## After Gathering Answers

1. **Summarize the configuration** and confirm with user:

```
Based on your answers, I'll create:

Project: {{PROJECT_NAME}}
Location: {{PROJECT_ROOT}}
Platform: {{PLATFORM_TYPE}} ({{FRAMEWORK}})
Backend: {{BACKEND_LANG}} ({{BACKEND_FRAMEWORK}})
Database: {{DATABASE}}
Hosting: {{HOSTING}}

Governance Level: {{GOVERNANCE_LEVEL}}
Dev Diary: {{USE_DEV_DIARY}}
Dashboard: {{USE_DASHBOARD}}

External Integrations:
- {{LIST_OF_INTEGRATIONS}}

Does this look correct? (y/n)
```

2. **Generate config.json**:

Create a JSON file with all parameters:

```json
{
  "project": {
    "name": "TaskMaster",
    "name_lower": "taskmaster",
    "name_snake": "task_master",
    "description": "AI-powered task management",
    "workspace_path": "${HOME}/workspace/projects/",
    "project_root": "${HOME}/workspace/projects/TaskMaster"
  },
  "platform": {
    "type": "web",
    "web_framework": "nextjs"
  },
  "tech_stack": {
    "language_primary": "typescript",
    "language_backend": "typescript",
    "framework_backend": "nextjs-api",
    "database": "postgresql",
    "cache": "redis"
  },
  "infrastructure": {
    "hosting_frontend": "vercel",
    "hosting_backend": "vercel",
    "ci_cd": "github-actions"
  },
  "git": {
    "repo_url": "https://github.com/yourorg/taskmaster.git",
    "default_branch": "main",
    "enable_branch_protection": true
  },
  "integrations": {
    "secrets_mgmt": "bitwarden-eu",
    "db_provider": "your-db-provider",
    "auth_provider": "custom-jwt",
    "project_mgmt": "linear",
    "ai_services": "openai,anthropic"
  },
  "team": {
    "size": "small",
    "governance_level": "full",
    "use_dev_diary": true,
    "use_dashboard": true
  }
}
```

3. **Run the adapter**:

```bash
cd ~/workspace/project-blueprint/tools
python3 adapter.py /tmp/project-config.json {{PROJECT_ROOT}}
```

4. **Post-initialization checklist**:

After successful initialization, provide this checklist:

```
✅ Project structure created at {{PROJECT_ROOT}}
✅ Governance docs adapted for {{PLATFORM_TYPE}}
✅ CI/CD workflows configured
✅ Claude commands installed
{{IF use_dashboard}}✅ Dashboard installed{{ENDIF}}
{{IF use_dev_diary}}✅ Dev diary structure created{{ENDIF}}

📋 **Next Steps (Manual):**

1. Review and customize CLAUDE.md with project-specific context
2. {{IF integrations.secrets_mgmt}}Set up {{secrets_mgmt}} project and configure secrets{{ENDIF}}
3. {{IF git.repo_url}}Initialize git and push to {{git.repo_url}}{{ENDIF}}
4. {{IF git.enable_branch_protection}}Configure GitHub branch protection rules (see BRANCH_PROTECTION_SETUP.md){{ENDIF}}
5. Review SDLC-ROLE-MAPPING.md and adapt for your team size ({{team.size}})
6. Update TECH_STACK.md with specific versions and dependencies
7. {{IF use_dashboard}}Install dashboard: cd dashboard && ./install.sh{{ENDIF}}
8. {{IF platform.type == 'mobile'}}Set up Expo project in ${project_name}-frontend/ or similar{{ENDIF}}
9. {{IF platform.type == 'web'}}Set up {{web_framework}} project{{ENDIF}}
10. Review .github/workflows/ and enable/disable workflows as needed

📚 **Documentation:**
- Governance: GOVERNANCE_OPERATIONS_GUIDE.md
- Quality gates: SDLC-ROLE-MAPPING.md
- Handoff protocols: HANDOVER_PROTOCOLS.md
- Best practices: ENGINEERING_BEST_PRACTICES.md

🤖 **Claude Commands:**
- /governance-check - Validate governance compliance
- /primer - Load project context
{{IF use_dev_diary}}- /daily-report - Generate daily dev diary
- /weekly-report - Generate weekly summary{{ENDIF}}

{{IF use_dashboard}}
📊 **Dashboard:**
Access at http://localhost:8888 after running install.sh
{{ENDIF}}
```

## Important Notes

- **Be conversational**: Don't just dump all 27 questions at once
- **Skip irrelevant questions**: If they say "no backend", skip backend questions
- **Provide examples**: Help them understand each choice
- **Confirm before execution**: Show summary and get approval
- **Handle errors gracefully**: If adapter.py fails, provide debugging steps

## Error Handling

If the adapter fails:
1. Check that ~/workspace/project-blueprint/ exists
2. Verify Python 3 is available
3. Check write permissions on target directory
4. Offer to show the error log
5. Suggest manual initialization as fallback
