# TIDD-EC Framework Template

**Origin:** Precision-focused framework for technical tasks

**Best for:** Code implementation, analysis, debugging, technical reviews, specific deliverables

## Structure

- **T**ask Type: Category of work
- **I**nstructions: Step-by-step guidance
- **D**o: Required behaviors
- **D**on't: Prohibited behaviors
- **E**xamples: Concrete demonstrations
- **C**ontent: Input material to process

## Template

```markdown
# [Task Name]

## Task Type
**Category:** [implementation/analysis/research/review/debugging]
**Complexity:** [simple/moderate/complex]

## Instructions
1. [First step with specific action]
2. [Second step with specific action]
3. [Third step with specific action]

## Do
- [Required behavior 1]
- [Required behavior 2]
- [Required behavior 3]

## Don't
- [Prohibited behavior 1]
- [Prohibited behavior 2]
- [Prohibited behavior 3]

## Examples
**Good:**
```
[Example of correct approach]
```

**Bad:**
```
[Example of incorrect approach]
```

## Content
[Input material to process]
```

## Usage

Use this framework when the task is:
- Technical with clear constraints
- Implementation-focused
- Requires precise execution
- Has clear right/wrong approaches

## Example

**Task:** "Add input validation to the login form"

```markdown
# Login Form Input Validation

## Task Type
**Category:** Implementation
**Complexity:** Simple

## Instructions
1. Add email format validation using regex
2. Add password minimum length check (8 chars)
3. Display inline error messages below each field
4. Disable submit until both fields valid

## Do
- Use HTML5 email type attribute
- Show errors only after field blur
- Use form library's built-in validation
- Test with common edge cases

## Don't
- Don't validate on every keystroke (wait for blur)
- Don't block paste into password field
- Don't use alert() for errors
- Don't hardcode error messages (use i18n)

## Examples
**Good:**
```typescript
const validateEmail = (email: string): boolean => {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
};
```

**Bad:**
```typescript
// Too permissive
const validateEmail = (email: string): boolean => {
  return email.includes('@');
};
```

## Content
**Form Fields:**
- Email (required)
- Password (required, min 8 chars)
- Remember me checkbox (optional)
```
