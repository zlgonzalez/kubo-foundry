# CodeGraph Token-Saving Guide for Writing Code

Use CodeGraph first whenever a `.codegraph/` directory exists at the repo root (or target sub-project). One graph query replaces multi-step `Grep` + `Read` loops and prevents wasted edit/fix turns.

If no `.codegraph/` directory exists,run `codegraph init`. Run `codegraph sync` to index the codebase.

## 1. Query Before Reading or Searching

- **MCP (primary):** Call `codegraph_explore` before `Read`, `Grep`, `Glob`, or exploration subagents. Pass `projectPath` when querying a specific repo or monorepo sub-project.
- **CLI (when MCP is unavailable or for narrower slices):**
  - `codegraph explore "<symbols, file paths, or flow>" --max-files <n>` — verbatim line-numbered source + call paths + dependents in one call.
  - `codegraph node <symbol>` or `codegraph node -f <file> --symbols-only` — inspect one symbol or a file's symbol map/line slice (`--offset <n> --limit <n>`) without loading the whole file.
  - `codegraph context "<task>" --no-code -n <n>` or `codegraph files --max-depth <n>` — map structure before pulling code bodies.

## 2. Keep Queries Tight to Minimize Output Tokens

- **Name exact symbols, file paths, or flow endpoints** (e.g., `"AuthService loginUser"`, `"parseConfig validateSchema"`) instead of broad natural-language prompts.
- **Cap `maxFiles` / `--max-files`** (default is `12`) when you only need a few files.
- **Don't spawn subagents for code lookups:** a single direct CodeGraph query costs far fewer tokens than delegating file discovery to another context.

## 3. Edit Directly From Graph Output

- **Treat returned source as already Read:** `codegraph_explore` and `codegraph node` return verbatim line-numbered source (`<n>\t<line>`). Edit directly from it—do **not** re-open the same file with `Read` or re-verify matches with `Grep`.
- **Check blast radius before writing:** Inspect the dependents/callers returned by `codegraph_explore` (or run `codegraph impact <symbol>` / `codegraph callers <symbol>`) before changing signatures, types, or shared behavior so all affected call sites are updated in one pass.

## 4. Verify Selectively & Handle Staleness Cheaply

- **Target affected tests:** Run `codegraph affected <changed-files...>` to locate impacted tests instead of reading or running unrelated test suites.
- **Only `Read` flagged or unindexed files:** The file watcher lags writes by ~1s. If CodeGraph flags a file as changed on disk/pending sync, omits its body, or reports auto-sync recovering/disabled, `Read` only those specific files—keep trusting unflagged files. Use `Read`/`Grep` only for files CodeGraph does not index (e.g., configs, docs, scripts).
