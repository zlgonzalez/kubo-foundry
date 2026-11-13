
---

### `agy-parallel-review/scripts/run_review.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH="${1:-main}"
TIMESTAMP="$(date +%s)"
REPORT_DIR=".review-reports"

mkdir -p "$REPORT_DIR"
rm -f "$REPORT_DIR"/*.md

echo "==> Starting parallel multi-persona code review against branch: ${TARGET_BRANCH}"

# 1. Spec & Intent Conformance Reviewer
agy run --session "review-spec-${TIMESTAMP}" \
  "You are the Spec & Intent Conformance Reviewer. Analyze git diff ${TARGET_BRANCH}...HEAD against specs/ and AGENTS.md. Verify acceptance criteria alignment, flag scope creep, and check layer boundary violations. Write your structured markdown report directly to ${REPORT_DIR}/1-spec.md." &
PID_SPEC=$!

# 2. Blast-Radius Cartographer
agy run --session "review-blast-${TIMESTAMP}" \
  "You are the Blast-Radius Cartographer. Query the codegraph MCP server to inspect all symbols modified in git diff ${TARGET_BRANCH}...HEAD. Map all inbound callers and interface implementations across unedited files in the repository. Write your structured markdown report directly to ${REPORT_DIR}/2-blast.md." &
PID_BLAST=$!

# 3. Adversarial Systems Auditor
agy run --session "review-systems-${TIMESTAMP}" \
  "You are the Adversarial Systems Auditor. Inspect git diff ${TARGET_BRANCH}...HEAD for concurrency bugs, data races, goroutine leaks, unclosed resources, and missing context cancellation handling. Execute 'go test -race ./...' or active linters to verify. Write your structured markdown report directly to ${REPORT_DIR}/3-systems.md." &
PID_SYS=$!

# 4. Security & DBA Reviewer
agy run --session "review-security-${TIMESTAMP}" \
  "You are the Security & DBA Reviewer. Inspect git diff ${TARGET_BRANCH}...HEAD for SQL/command injection, authentication bypasses, broken object-level authorization, and unindexed database queries. Write your structured markdown report directly to ${REPORT_DIR}/4-security.md." &
PID_SEC=$!

echo "==> Background review sessions active (PIDs: $PID_SPEC, $PID_BLAST, $PID_SYS, $PID_SEC). Awaiting completion..."
wait "$PID_SPEC" "$PID_BLAST" "$PID_SYS" "$PID_SEC"
echo "==> All review passes completed."

# Synthesis Phase
cat "${REPORT_DIR}/1-spec.md" \
    "${REPORT_DIR}/2-blast.md" \
    "${REPORT_DIR}/3-systems.md" \
    "${REPORT_DIR}/4-security.md" > "${REPORT_DIR}/combined-raw.md"

echo "==> Synthesizing reports into ${REPORT_DIR}/FINAL_REVIEW.md..."

agy run --session "review-summary-${TIMESTAMP}" \
  "Read ${REPORT_DIR}/combined-raw.md and compile an executive summary in ${REPORT_DIR}/FINAL_REVIEW.md using the following structure:
   # Code Review Synthesis (${TARGET_BRANCH}...HEAD)
   ## 1. Critical Blockers (Must fix before merge, cite exact file and line numbers)
   ## 2. Blast Radius & Cross-File Contract Risks
   ## 3. Systems Concurrency, DB & Security Findings
   ## 4. Suggested Code Patches"

echo "==> Review complete. Final output generated at ${REPORT_DIR}/FINAL_REVIEW.md"
