---
description: "Generate integration tests from the feature spec before any implementation begins"
---

# Pre-Implement: Generate Integration Tests From Spec

Generate comprehensive, executable integration tests directly from the feature specification **before any implementation code is written**.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider any user input or constraints provided above before proceeding (if not empty).

## Strict Pre-Implementation Boundary

- **Tests only — NO implementation code:** Do **not** write, modify, or scaffold production/application code (models, services, controllers, endpoints, UI components, migrations, etc.) during this hook.
- **TDD Red phase is expected:** Generated integration tests are expected to fail until `/speckit.implement` builds the feature. Never weaken assertions, add unconditional skips (`skip` / `xit` / `xfail`), or mock out the system under test just to make tests pass early.
- **Preserve existing tests:** Never overwrite or break unrelated existing tests. If integration tests for this feature already exist, add missing spec coverage or update only changed scenarios idempotently.

## Execution Steps

### 1. Resolve Feature Paths and Read Artifacts

From the repository root, resolve feature paths using Spec Kit's prerequisite script:

- **Bash**: `.specify/scripts/bash/check-prerequisites.sh --paths-only --json`
- **PowerShell**: `.specify/scripts/powershell/check-prerequisites.ps1 -PathsOnly -Json`

Parse `REPO_ROOT`, `FEATURE_DIR`, `FEATURE_SPEC` (`spec.md`), `IMPL_PLAN` (`plan.md`), and `TASKS` (`tasks.md`).

Read the feature specification and available design context:
1. **REQUIRED — `FEATURE_SPEC` (`spec.md`)**: If `spec.md` does not exist, stop and instruct the user to run `/speckit.specify` first.
2. **IF EXISTS — `plan.md`**: Extract the testing framework, language/runtime, project structure, and integration test directory conventions.
3. **IF EXISTS — `contracts/`, `data-model.md`, `quickstart.md`**: Extract exact API routes, CLI contracts, schemas, status codes, and end-to-end integration flows.
4. **IF EXISTS — `tasks.md` and `.specify/memory/constitution.md`**: Check planned integration test file paths and project testing rules (do **not** execute implementation tasks).

### 2. Inspect Repository Test Conventions

Before creating files, inspect the repository's existing test setup (use `codegraph_explore` / `codegraph` first if `.codegraph/` exists, otherwise inspect project manifests and `tests/` directories):
- Identify the test runner and assertion library (e.g., `pytest`, `vitest`, `jest`, `playwright`, `go test`, `cargo test`, `xctest`, etc.).
- Locate existing integration test directories, shared fixtures, test factories, database/server test harnesses, and naming conventions.
- Follow the exact file layout and naming pattern documented in `plan.md` or already established in the repo (for example `tests/integration/...`).

### 3. Map `spec.md` Requirements to Integration Tests

Ensure every testable requirement in `spec.md` is covered by concrete integration test cases exercising real component/API/CLI/persistence boundaries:

1. **User Stories & Acceptance Scenarios (`P1`, `P2`, ...):**
   - Translate every **Given / When / Then** scenario and **Independent Test** into an integration test.
2. **Functional Requirements (`FR-xxx`):**
   - Cover every `FR-*` behavior, state transition, persistence guarantee, and output contract.
3. **Edge Cases & Error Handling:**
   - Cover boundary inputs, validation failures, missing/invalid resources, authorization failures, and error recovery listed in `spec.md`.
4. **Measurable Success Criteria (`SC-xxx`):**
   - Assert deterministically testable outcomes from `spec.md`.
5. **Traceability:**
   - Tag test descriptions or comments with the corresponding spec identifiers (e.g., `US1`, `FR-001`, `SC-002`) so implementation and review can trace coverage back to `spec.md`.

### 4. Write the Integration Tests & Verify TDD Red State

1. Create the feature integration test file(s) (and test-only fixtures or external-dependency mocks if required by the repo's test harness) without touching production source files.
2. Confirm the test suite discovers the new integration tests and that failures reflect unimplemented feature behavior rather than broken test configuration or syntax errors (in compiled languages, isolate the new integration test file cleanly so existing unrelated tests remain intact).

### 5. Output Summary

Report concisely before returning control to `/speckit.implement`:
- Spec path read (`FEATURE_SPEC`)
- Integration test file(s) created or updated
- Coverage summary mapping `spec.md` User Stories, `FR-*` requirements, and Edge Cases to test cases
- Confirmation that no production implementation code was modified and the initial test-discovery/Red check status
