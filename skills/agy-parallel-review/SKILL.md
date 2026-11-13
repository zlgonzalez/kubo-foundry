---
name: agy-parallel-review
description: Orchestrates parallel multi-persona code reviews across isolated agy CLI sessions and consolidates their findings into a unified report. Use when reviewing pull requests, branch diffs, or pre-push changes across spec conformance, CodeGraph blast radius, systems concurrency, and security.
license: MIT
compatibility: Requires bash, git, agy (Antigravity CLI), and an active codegraph MCP server.
allowed-tools: "Bash(bash:*), Bash(chmod:*), Bash(git:*), Bash(agy:*), Read, Write"
metadata:
  author: engineering
  version: "1.1.0"
---

# Parallel Multi-Persona Code Review (`agy-parallel-review`)

Execute a parallelized, four-persona code review using isolated `agy` CLI sessions, followed by a fifth consolidation pass that deduplicates findings and generates actionable remediation patches.

## The 4 Review Personas

1. **Spec & Intent Conformance Reviewer (`1-spec.md`)**
   - Audits `git diff` against `specs/` and `AGENTS.md` for requirement alignment, architectural boundary leaks, and scope creep.
2. **Blast-Radius Cartographer (`2-blast.md`)**
   - Queries the `codegraph` MCP server for all modified symbols to verify unedited callers and implicit interface implementations across the repository.
3. **Adversarial Systems Auditor (`3-systems.md`)**
   - Audits concurrency safety, goroutine/resource leaks, and context cancellation, executing `go test -race ./...` and linters.
4. **Security & DBA Reviewer (`4-security.md`)**
   - Audits input validation, auth middleware boundaries, BOLA/IDOR risks, transaction rollbacks, and query indexing.

---

## Step-by-Step Execution Instructions

### Step 1: Verify Target Branch and Workspace
Determine the target base branch for comparison (defaults to `main`) and verify `.review-reports/` is listed in `.gitignore`:

```bash
TARGET_BRANCH="${1:-main}"
grep -qxF '.review-reports/' .gitignore || echo '.review-reports/' >> .gitignore
```

### Step 2: Spawn Parallel Review Sessions
Launch four `agy run` commands in the background. Use session names that include a timestamp to avoid collisions.

```bash
TIMESTAMP="$(date +%s)"
mkdir -p .review-reports
rm -f .review-reports/1-spec.md .review-reports/2-blast.md .review-reports/3-systems.md .review-reports/4-security.md

# 1. Spec & Intent Review
agy run --session "review-spec-${TIMESTAMP}" \
  "You are the Spec & Intent Conformance Reviewer. Audit git diff ${TARGET_BRANCH}...HEAD against specs/ and AGENTS.md. Verify acceptance criteria alignment, flag scope creep, and check architectural boundary violations. Write your structured markdown report directly to .review-reports/1-spec.md."

# 2. Blast-Radius Review
agy run --session "review-blast-${TIMESTAMP}" \
  "You are the Blast-Radius Cartographer. Query the codegraph MCP server for all symbols modified in git diff ${TARGET_BRANCH}...HEAD. Map all inbound callers and interface implementations across unedited files in the repository. Write your structured markdown report directly to .review-reports/2-blast.md."

# 3. Systems & Concurrency Review
agy run --session "review-systems-${TIMESTAMP}" \
  "You are the Adversarial Systems Auditor. Inspect git diff ${TARGET_BRANCH}...HEAD for concurrency bugs, data races, goroutine/resource leaks, unclosed context cancellations, and missing transaction rollbacks. You may execute 'go test -race ./...' or active linters. Write your structured markdown report directly to .review-reports/3-systems.md."

# 4. Security Review
agy run --session "review-security-${TIMESTAMP}" \
  "You are the Security & DBA Reviewer. Inspect git diff ${TARGET_BRANCH}...HEAD for SQL/command injection vectors, authentication middleware bypasses, Broken Object-Level Authorization (BOLA), IDOR risks, and unindexed database queries. Audit secret hygiene: flag static shared secrets, plaintext .env storage, lack of secret rotation mechanisms, and recommend short-lived tokens or KMS/Vault integration for production readiness. Write your structured markdown report directly to .review-reports/4-security.md."

echo "==> All background review sessions have been spawned. Wait for the 5th consolidation step to complete for the final output."
```

### Step 3: Synthesize and Deduplicate
Concatenate the raw reports and execute a final `agy run` session that synthesizes findings, removes duplicate issues, and generates a single, actionable `FINAL_REVIEW.md` with suggested patches.

```bash
# Read reports in stable order
cat .review-reports/1-spec.md \
    .review-reports/2-blast.md \
    .review-reports/3-systems.md \
    .review-reports/4-security.md > .review-reports/combined-raw.md

# Generate synthesis with deduplication
agy run --session "review-summary-${TIMESTAMP}" \
  "Read .review-reports/combined-raw.md and compile an executive summary in .review-reports/FINAL_REVIEW.md using the following structure:

## Code Review Synthesis (${TARGET_BRANCH}...HEAD)

### 1. Critical Blockers (MUST FIX before merge)
- Cite exact file and line numbers.
- Explain the failure mode in 1-2 sentences.
- Provide the suggested code patch or command to fix it.

### 2. Blast Radius & Cross-File Contract Risks
- List all unedited callers and downstream symbols that depend on the modified interfaces.
- Mark any implicit interface breaches with severity and proposed fix.

### 3. Systems Concurrency, DB & Security Findings
- Combine findings from concurrency, security, and DBA review personas.
- Use bullet points for each distinct issue, including file references and suggested patches.

### 4. Overall Assessment
- Provide a GO/NO-GO verdict for the merge with rationale."

echo "==> Review complete. Final output generated at .review-reports/FINAL_REVIEW.md"
```