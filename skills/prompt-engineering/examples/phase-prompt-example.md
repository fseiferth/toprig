# Example: Phase Execution Prompt (Hybrid Framework)

## Input Request

"Create a Phase 17 execution prompt for implementing a item rating system.
Users should be able to rate items 1-5 stars and optionally leave comments."

## Framework Selection

**Selected: Hybrid** (complex multi-step task, multi-agent coordination required)

**Rationale:** This is a full feature implementation requiring backend, frontend, and QA coordination with multiple deliverables and success criteria.

---

## Structured Output

# Phase 17: item Rating System Implementation

## Executive Context

**Background:** ${PROJECT_NAME} users have requested the ability to rate items they've tried. Currently, users can save items but cannot provide feedback on quality or leave reviews.

**Current State:**
- item display exists (`itemDetailScreen`)
- User authentication functional
- No rating data model or UI components exist

**Objective:** Implement end-to-end item rating system with 1-5 star ratings and optional text comments.

**Audience:**
- Backend Engineer: API and data model
- Frontend Engineer: UI components and state
- QA Engineer: Test coverage and validation

## Mission

Enable users to rate items 1-5 stars and optionally leave text comments, with ratings displayed on item cards and detail screens.

## Instructions

**Task Type:** Full-stack feature implementation (multi-agent, complex)

### Steps

1. **Backend: Data Model & API** (Backend Engineer)
   - Create Rating model (user_id, item_id, stars, comment, created_at)
   - Implement POST /items/{id}/ratings endpoint
   - Implement GET /items/{id}/ratings endpoint
   - Add average_rating to item response

2. **Frontend: UI Components** (Frontend Engineer)
   - Create StarRating component (interactive 1-5 stars)
   - Create RatingModal (submit rating + optional comment)
   - Add RatingSummary to itemCard (average + count)
   - Integrate into itemDetailScreen

3. **Integration & Testing** (QA Engineer)
   - E2E test: Submit rating flow
   - E2E test: View ratings on item
   - Edge cases: Duplicate ratings, empty comments

### Do
- Use existing design tokens for star colors (warning for filled, neutral for empty)
- Implement optimistic UI updates for rating submission
- Cache ratings to avoid redundant API calls
- Follow TDD: Write tests before implementation

### Don't
- Don't allow users to rate their own items
- Don't allow multiple ratings from same user on same item (update instead)
- Don't require comment (stars-only is valid)
- Don't block UI while rating submits (optimistic update)

## Success Criteria

- [ ] Users can tap 1-5 stars to rate a item
- [ ] Users can optionally add a text comment (max 500 chars)
- [ ] Average rating displays on item cards (e.g., "4.2 ★ (15)")
- [ ] Submitting rating shows immediate feedback (optimistic update)
- [ ] Users can update their existing rating
- [ ] API returns 400 if user tries to rate own item
- [ ] All tests pass (unit + E2E)

## Pre-Flight Checklist

- [ ] Backend environment running with database
- [ ] User authentication functional
- [ ] item detail screen accessible
- [ ] Design tokens available for star colors

## Quality Gates

- [ ] **Gate 1 (Backend):** API endpoints return correct responses, tests pass
- [ ] **Gate 2 (Frontend):** Components render correctly, interact properly
- [ ] **Gate 3 (Integration):** E2E flow works on real device
- [ ] **Gate 4 (QA):** All test scenarios pass, no regressions

## Landing the Plane

1. Backend closes bead when API tests pass
2. Frontend closes bead when UI tests pass
3. QA closes bead when E2E tests pass
4. Run `bd sync && git push`
5. Create PR with evidence of passing tests

---

## Validation Checklist

- [x] Context complete (background, current state, objective, audience)
- [x] Objective specific and measurable (rating system with stars + comments)
- [x] Success criteria testable (7 specific criteria)
- [x] Constraints clear (4 do's, 4 don'ts)
- [x] Steps have clear deliverables per role
- [x] Pre-flight checklist included (4 items)
- [x] Quality gates defined (4 gates)
- [x] Landing protocol defined
