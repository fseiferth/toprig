# CO-STAR Framework Template

**Origin:** Winner of Singapore's GPT-4 Prompt Engineering Competition

**Best for:** PRDs, documentation, communications, content generation, user-facing outputs

## Structure

- **C**ontext: Background information and situation
- **O**bjective: What you want to achieve
- **S**tyle: Writing style or approach
- **T**one: Emotional quality of response
- **A**udience: Who will consume the output
- **R**esponse: Format of the output

## Template

```markdown
# [Task Name]

## Context
**Background:** [Situation and relevant history]
**Current State:** [What exists now]

## Objective
**Goal:** [What to achieve]
**Success Criteria:** [How to measure success]

## Style
**Approach:** [formal/informal/technical/conversational]

## Tone
**Voice:** [professional/friendly/authoritative/empathetic]

## Audience
**Reader:** [Who will consume this]
**Their Needs:** [What they care about]

## Response
**Format:** [markdown/json/code/prose]
**Length:** [short/medium/long]
**Structure:** [sections/bullets/paragraphs]
```

## Usage

Use this framework when the task is:
- Creative or content-focused
- User-facing output (emails, docs, PRDs)
- Requires specific tone/style
- Audience-aware communication

## Example

**Task:** "Write a product announcement for our new resource sharing feature"

```markdown
# item Sharing Feature Announcement

## Context
**Background:** ${PROJECT_NAME} users have been requesting social features
**Current State:** Users can generate and save items, but not share them

## Objective
**Goal:** Announce resource sharing with excitement and clear call-to-action
**Success Criteria:** Users understand and try the new feature within 24 hours

## Style
**Approach:** Conversational, friendly

## Tone
**Voice:** Excited but not salesy, helpful

## Audience
**Reader:** Existing ${PROJECT_NAME} users
**Their Needs:** Understand what's new, how to use it, why they should care

## Response
**Format:** Email/notification
**Length:** Short (150-200 words)
**Structure:** Hook → Feature → How-to → CTA
```
