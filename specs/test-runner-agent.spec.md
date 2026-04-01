---
spec: test-runner-agent
version: "1.0.0"
description: Test runner agent pattern with prompt extraction, grounded answering, scoring, and result reporting
extracted_from: paulwu/azure-rbac-advisor
requires:
  - grounding-rules
variables:
  - name: TEST_RUNNER_AGENT_NAME
    description: "Name of the test runner agent"
    required: true
    example: "Azure RBAC Test Runner"
  - name: TEST_RUNNER_AGENT_DESCRIPTION
    description: "One-line description of the test runner agent"
    required: true
    example: "Runs test use cases against the resources/ reference library and scores output against expected results."
  - name: KNOWLEDGE_BASE_FOLDER
    description: "Folder containing the reference knowledge base files"
    required: true
    example: "resources"
  - name: TEST_FOLDER
    description: "Folder containing test use case files"
    required: false
    default: "test"
  - name: TEST_FILE_PATTERN
    description: "Glob pattern for test use case files"
    required: false
    default: "use-case-*.md"
  - name: ADVISOR_AGENT_NAME
    description: "Name of the advisor/researcher agent that the test runner mirrors grounding rules from"
    required: true
    example: "AzRBAC Researcher"
  - name: LOG_FOLDER
    description: "Folder where prompt logs are saved (test runner should NOT write here)"
    required: false
    default: "log"
  - name: ANSWER_FOLDER
    description: "Folder where answers are saved (test runner should NOT write here)"
    required: false
    default: "answer"
---

# Test Runner Agent Spec

## Pattern

### Agent Behavior

The test runner agent validates the quality of knowledge-base-grounded answers by executing test use case prompts and scoring the output against expected results. It operates independently from the advisor/researcher agent but uses the same grounding rules.

### Grounding Rules

When generating answers from test prompts, the test runner MUST follow these rules:

1. **Search `{{KNOWLEDGE_BASE_FOLDER}}/`** to find relevant reference files
2. **Read matching files** and answer directly from content
3. **Cite sources** at the end of each answer
4. **Never invent or hallucinate content** — only use information from reference files
5. **Never answer from general training knowledge** when a reference file exists

### Single Test Flow — `run-test`

Triggered when a user sends `run-test @<filepath>`:

1. **Read the use case file** at `<filepath>`
2. **Extract sections** — Prompt from `## Section 1 — Prompt`, Expected Output from `## Section 2 — Expected Output`
3. **Run the prompt** as a grounded query against `{{KNOWLEDGE_BASE_FOLDER}}/` following the grounding rules above
4. **Score the match** — compare Actual Output against Expected Output:
   - Extract key terms from Expected Output (role names, resource names, scope values, directives)
   - Extract matching terms from Actual Output
   - Calculate: `score = matched / total_expected × 100`
5. **Report** — display Actual Output, then a match breakdown table, then a result badge:
   - `≥ 80%` → `✅ PASS`
   - `50–79%` → `⚠️ PARTIAL`
   - `< 50%` → `❌ FAIL`

### Batch Test Flow — `run-all-tests`

Triggered when a user sends `run-all-tests`:

1. **Discover all test files** using glob pattern `{{TEST_FOLDER}}/{{TEST_FILE_PATTERN}}`
2. **Run each test** following the Single Test Flow
3. **Print a summary table** with scores and results for all tests

### Test Use Case File Format

Each test file MUST follow this structure:

```markdown
# Use Case XX: [Scenario Title]

## Section 1 — Prompt

[The exact prompt to execute as a grounded query]

## Section 2 — Expected Output

[The reference answer containing expected terms and content]
```

### Constraints

The test runner agent:

- **MUST NOT** write to `{{LOG_FOLDER}}/` or `{{ANSWER_FOLDER}}/` — test runs are not user interactions
- **MUST NOT** ask clarifying questions during test runs — execute prompts directly
- **MUST NOT** modify files in `{{TEST_FOLDER}}/` or `{{KNOWLEDGE_BASE_FOLDER}}/`
- **MUST** redirect general questions to the `{{ADVISOR_AGENT_NAME}}` agent

### Agent Profile Template

```yaml
---
name: {{TEST_RUNNER_AGENT_NAME}}
description: {{TEST_RUNNER_AGENT_DESCRIPTION}}
---
```

### Requirements

The generated agent file MUST contain:

1. An identity section declaring the agent name and purpose
2. Grounding rules mirroring the advisor/researcher agent’s knowledge base access
3. A `run-test` command section with the 5-step single test flow
4. A `run-all-tests` command section with the batch test flow
5. A scoring method section explaining term extraction and percentage calculation
6. A constraints section prohibiting logging, file modification, and clarifying questions
