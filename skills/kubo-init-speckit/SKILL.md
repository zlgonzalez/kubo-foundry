---
name: kubo-init-speckit
description: Initialize GitHub Spec Kit in a repository (if needed), install all Spec Kit extensions from kubo-foundry's speckit/ directory, copy context/AGENTS.md to the repository root, install mcp/ servers as Antigravity workspace plugins, and copy the agy-parallel-review and speckit-converge skills to the repository. Use when setting up Spec Kit, AGENTS.md, and Kubo MCP/Spec Kit tooling in a project.
---

# Kubo Init Spec Kit

Initialize Spec Kit in the target repository (if `.specify/` does not already exist), install every Spec Kit extension from `kubo-foundry`'s `speckit/` directory, copy `context/AGENTS.md` to the repository root (`./AGENTS.md`), install every MCP server in `mcp/` as an Antigravity workspace plugin under `.agents/plugins/<server>/`, and copy `skills/agy-parallel-review/` and `skills/speckit-converge/` into both `.agent/skills/` and `.agents/skills/` (creating those directories if they do not exist, plus any other active assistant skills directory).

## Prerequisites

Verify that the `specify` CLI is installed:

```bash
command -v specify
```

If `specify` is missing, instruct the user to install it:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

and stop until it is available.

## Execution Steps

### Step 1: Ensure Spec Kit Is Initialized

Check if `.specify/` exists in the target repository root:

- If `.specify/` already exists, continue to **Step 2**.
- If `.specify/` does not exist, initialize Spec Kit non-interactively first:
  1. Determine `--ai` from existing project directories (`.agent` → `agy`, `.claude` → `claude`, `.gemini` → `gemini`, `.codex` → `codex`, `.cursor` → `cursor-agent`, `.github` → `copilot`) or ask the user which assistant to target if unclear.
  2. Determine `--script` (`sh` on macOS/Linux, `ps` on Windows).
  3. Run:
     ```bash
     specify init --here --force --ai <agent> --script sh --ignore-agent-tools
     ```
     *(Add `--no-git` only if the user explicitly wants to skip Git setup and the built-in `git` extension.)*

### Step 2: Locate `kubo-foundry` Assets and Install Extensions, `AGENTS.md`, MCP Plugins, and Skills

Run the script below from the target repository root (setting `SKILL_FILE` to this `SKILL.md` path if known). It:

1. Resolves `FOUNDRY_DIR` (containing `speckit/*/extension.yml`, `context/AGENTS.md`, `mcp/*/mcp.json`, `skills/agy-parallel-review/SKILL.md`, and `skills/speckit-converge/SKILL.md`) from:
   - `.` (current repository),
   - `<resolved_skill_dir>/../..` (when `kubo-init-speckit` is symlinked from a `kubo-foundry` clone),
   - `"$KUBO_FOUNDRY_DIR"` (when `KUBO_FOUNDRY_DIR` is set),
   - a temporary shallow sparse clone of `speckit/`, `context/`, `mcp/`, `skills/agy-parallel-review/`, and `skills/speckit-converge/` from `zlgonzalez/kubo-foundry`,
   - or common local `kubo-foundry` checkout paths under `$HOME`.
2. Installs every extension in `speckit/` via `specify extension add --dev` (preserving any `*-config.yml` / `*-config.local.yml` files on reinstall).
3. Copies `context/AGENTS.md` to `./AGENTS.md` at the target repository root (overwriting `./AGENTS.md` if present).
4. Installs every `mcp/<server>/mcp.json` into `.agents/plugins/<server>/` (`plugin.json` + `mcp_config.json`) so Antigravity App, IDE, and CLI can discover and use each MCP server in the repository.
5. Creates `.agent/skills/` and `.agents/skills/` (plus any other active assistant skills directory, e.g., `.claude/skills/`) if they do not already exist and copies `skills/agy-parallel-review/` and `skills/speckit-converge/` into `<skills_dir>/<skill>/`, replacing any prior copy cleanly.

```bash
set -euo pipefail

has_extensions() {
  local dir="$1"
  [ -d "$dir" ] || return 1
  local f
  for f in "$dir"/*/extension.yml; do
    [ -f "$f" ] && return 0
  done
  return 1
}

has_mcp_configs() {
  local dir="$1"
  [ -d "$dir" ] || return 1
  local f
  for f in "$dir"/*/mcp.json; do
    [ -f "$f" ] && return 0
  done
  return 1
}

BUNDLED_SKILLS=(agy-parallel-review speckit-converge)

has_bundled_skills() {
  local dir="$1"
  [ -d "$dir" ] || return 1
  local skill_name
  for skill_name in "${BUNDLED_SKILLS[@]}"; do
    [ -f "$dir/$skill_name/SKILL.md" ] || return 1
  done
  return 0
}

has_foundry_assets() {
  local dir="$1"
  [ -d "$dir" ] || return 1
  has_extensions "$dir/speckit" \
    && [ -f "$dir/context/AGENTS.md" ] \
    && has_mcp_configs "$dir/mcp" \
    && has_bundled_skills "$dir/skills"
}

resolve_skills_dirs() {
  local ai=""
  if [ -f ".specify/init-options.json" ]; then
    ai="$(python3 -c '
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as f:
        print(json.load(f).get("ai") or "")
except Exception:
    pass
' ".specify/init-options.json")"
  fi

  echo ".agent/skills"
  echo ".agents/skills"

  case "$ai" in
    agy|codex|amp) ;;
    claude) echo ".claude/skills" ;;
    cursor-agent) echo ".cursor/skills" ;;
    kimi) echo ".kimi/skills" ;;
    trae) echo ".trae/skills" ;;
    gemini)
      if [ -d ".gemini/skills" ]; then
        echo ".gemini/skills"
      fi
      ;;
    *)
      local dir
      for dir in ".claude/skills" ".cursor/skills" ".gemini/skills"; do
        if [ -d "$dir" ]; then
          echo "$dir"
        fi
      done
      ;;
  esac
}

SKILL_FILE="${SKILL_FILE:-}"
if [ -z "$SKILL_FILE" ] || [ ! -f "$SKILL_FILE" ]; then
  for p in \
    "./skills/kubo-init-speckit/SKILL.md" \
    "./.agent/skills/kubo-init-speckit/SKILL.md" \
    "./.agents/skills/kubo-init-speckit/SKILL.md" \
    "./.claude/skills/kubo-init-speckit/SKILL.md" \
    "./.gemini/skills/kubo-init-speckit/SKILL.md" \
    "$HOME/.agents/skills/kubo-init-speckit/SKILL.md" \
    "$HOME/.claude/skills/kubo-init-speckit/SKILL.md" \
    "$HOME/.gemini/antigravity/skills/kubo-init-speckit/SKILL.md"; do
    if [ -f "$p" ]; then
      SKILL_FILE="$p"
      break
    fi
  done
fi

SKILL_FOUNDRY_DIR=""
if [ -n "$SKILL_FILE" ] && [ -f "$SKILL_FILE" ]; then
  RESOLVED_SKILL_FILE="$(readlink -f "$SKILL_FILE" 2>/dev/null || python3 -c 'import pathlib, sys; print(pathlib.Path(sys.argv[1]).resolve())' "$SKILL_FILE")"
  SKILL_FOUNDRY_DIR="$(cd "$(dirname "$RESOLVED_SKILL_FILE")/../.." 2>/dev/null && pwd)"
fi

FOUNDRY_DIR=""
TMP_FOUNDRY=""
cleanup() {
  if [ -n "$TMP_FOUNDRY" ]; then
    rm -rf "$TMP_FOUNDRY"
  fi
}
trap cleanup EXIT

for candidate in \
  "." \
  "$SKILL_FOUNDRY_DIR" \
  "${KUBO_FOUNDRY_DIR:-}"; do
  if [ -n "$candidate" ] && has_foundry_assets "$candidate"; then
    FOUNDRY_DIR="$candidate"
    break
  fi
done

if [ -z "$FOUNDRY_DIR" ]; then
  TMP_FOUNDRY="$(mktemp -d)"
  if GIT_TERMINAL_PROMPT=0 git clone --depth 1 --filter=blob:none --sparse https://github.com/zlgonzalez/kubo-foundry.git "$TMP_FOUNDRY" 2>/dev/null \
    || GIT_TERMINAL_PROMPT=0 git clone --depth 1 --filter=blob:none --sparse git@github.com:zlgonzalez/kubo-foundry.git "$TMP_FOUNDRY" 2>/dev/null; then
    git -C "$TMP_FOUNDRY" sparse-checkout set speckit context mcp skills/agy-parallel-review skills/speckit-converge 2>/dev/null || true
    if has_foundry_assets "$TMP_FOUNDRY"; then
      FOUNDRY_DIR="$TMP_FOUNDRY"
    fi
  fi
fi

if [ -z "$FOUNDRY_DIR" ]; then
  for candidate in \
    "$HOME/kubo-foundry" \
    "$HOME/code/kubo-foundry" \
    "$HOME"/code/*/kubo-foundry \
    "$HOME/Documents/code/kubo-foundry" \
    "$HOME"/Documents/code/*/kubo-foundry \
    "$HOME/Projects/kubo-foundry" \
    "$HOME"/Projects/*/kubo-foundry \
    "$HOME/src/kubo-foundry"; do
    if has_foundry_assets "$candidate"; then
      FOUNDRY_DIR="$candidate"
      break
    fi
  done
fi

if [ -z "$FOUNDRY_DIR" ]; then
  echo "Error: Could not locate kubo-foundry assets (speckit/, context/AGENTS.md, mcp/, skills/agy-parallel-review/, skills/speckit-converge/)." >&2
  echo "Set KUBO_FOUNDRY_DIR to your local kubo-foundry checkout or push the assets to GitHub." >&2
  exit 1
fi

# 1. Install Spec Kit extensions
for manifest in "$FOUNDRY_DIR"/speckit/*/extension.yml; do
  [ -f "$manifest" ] || continue
  ext_dir="$(dirname "$manifest")"
  ext_id="$(python3 -c '
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"(?m)^extension:\s*\n(?:(?:[ \t]+.*|[ \t]*)\n)*?[ \t]+id:\s*[\"\x27]?([a-z0-9-]+)[\"\x27]?", text)
print(m.group(1) if m else "")
' "$manifest")"
  [ -n "$ext_id" ] || ext_id="$(basename "$ext_dir")"

  installed_dir=".specify/extensions/$ext_id"
  cfg_backup=""
  if [ -d "$installed_dir" ] || grep -q "\"$ext_id\"" .specify/extensions/.registry 2>/dev/null; then
    cfg_backup="$(mktemp -d)"
    if [ -d "$installed_dir" ]; then
      find "$installed_dir" -maxdepth 1 -type f \( -name '*-config.yml' -o -name '*-config.local.yml' \) -exec cp {} "$cfg_backup"/ \;
    fi
    specify extension remove "$ext_id" --force
  fi

  specify extension add --dev "$ext_dir"

  if [ -n "$cfg_backup" ]; then
    if [ -n "$(ls -A "$cfg_backup")" ]; then
      cp "$cfg_backup"/* "$installed_dir"/
    fi
    rm -rf "$cfg_backup"
  fi
done

# 2. Copy AGENTS.md to target repository root (overwriting any existing AGENTS.md)
cp -f "$FOUNDRY_DIR/context/AGENTS.md" "./AGENTS.md"

# 3. Install MCP servers from mcp/ as Antigravity workspace plugins
for mcp_file in "$FOUNDRY_DIR"/mcp/*/mcp.json; do
  [ -f "$mcp_file" ] || continue
  server_name="$(basename "$(dirname "$mcp_file")")"
  plugin_dir=".agents/plugins/$server_name"
  mkdir -p "$plugin_dir"

  python3 -c '
import json, re, sys

server_name, src_path, plugin_json_path, mcp_config_path = sys.argv[1:5]
plugin_name = re.sub(r"[^a-z0-9-]+", "-", server_name.lower()).strip("-") or server_name

with open(src_path, encoding="utf-8") as f:
    src = json.load(f)

servers = src.get("mcpServers", {})
cleaned_servers = {}
for name, cfg in servers.items():
    if isinstance(cfg, dict):
        cleaned_servers[name] = {k: v for k, v in cfg.items() if k != "type"}
    else:
        cleaned_servers[name] = cfg

with open(mcp_config_path, "w", encoding="utf-8") as f:
    json.dump({"mcpServers": cleaned_servers}, f, indent=2)
    f.write("\n")

plugin_manifest = {
    "name": plugin_name,
    "description": f"Workspace MCP server plugin for {server_name}."
}
with open(plugin_json_path, "w", encoding="utf-8") as f:
    json.dump(plugin_manifest, f, indent=2)
    f.write("\n")
' "$server_name" "$mcp_file" "$plugin_dir/plugin.json" "$plugin_dir/mcp_config.json"
done

# 4. Copy bundled skills (agy-parallel-review, speckit-converge) to .agent/skills and .agents/skills (plus any other active skills directory)
copied_parents=""
skills_dirs="$(resolve_skills_dirs)"
while IFS= read -r skills_dir; do
  [ -n "$skills_dir" ] || continue
  mkdir -p "$skills_dir"
  dest_parent_real="$(cd "$skills_dir" && pwd -P)"
  already_seen=0
  while IFS= read -r prev_parent; do
    if [ "$prev_parent" = "$dest_parent_real" ]; then
      already_seen=1
      break
    fi
  done <<EOF
$copied_parents
EOF
  if [ "$already_seen" -eq 1 ]; then
    continue
  fi
  if [ -z "$copied_parents" ]; then
    copied_parents="$dest_parent_real"
  else
    copied_parents="$copied_parents
$dest_parent_real"
  fi
  for skill_name in "${BUNDLED_SKILLS[@]}"; do
    src_skill_dir="$FOUNDRY_DIR/skills/$skill_name"
    src_real="$(cd "$src_skill_dir" && pwd -P)"
    dest_real="$dest_parent_real/$skill_name"
    if [ "$src_real" = "$dest_real" ]; then
      continue
    fi
    dest_skill_dir="$skills_dir/$skill_name"
    rm -rf "$dest_skill_dir"
    cp -R "$src_skill_dir" "$dest_skill_dir"
  done
done <<EOF
$skills_dirs
EOF
```

### Step 3: Verify Installation

1. **Spec Kit extensions:** Run `specify extension list` and confirm all extensions from `speckit/` (including `speckit-specify`, `speckit-plan`, and `speckit-implement`) are **Enabled**, their hooks (`before_specify`, `after_specify`, `before_plan`, `after_plan`, `before_implement`, `after_implement`) appear in `.specify/extensions.yml`, and commands/skills exist in the active agent directory (e.g., `.agent/skills/`, `.claude/skills/`, `.gemini/commands/`).
2. **`AGENTS.md`:** Confirm `./AGENTS.md` exists at the repository root and matches `context/AGENTS.md`.
3. **Antigravity MCP workspace plugins:** Confirm `.agents/plugins/<server>/plugin.json` and `.agents/plugins/<server>/mcp_config.json` exist for each server in `mcp/` (for example `.agents/plugins/codegraph/`). If the `agy` CLI is installed, validate each plugin:
   ```bash
   for p in .agents/plugins/*/; do
     [ -d "$p" ] && agy plugin validate "$p"
   done
   ```
   *(Note: if a server already exists globally in `~/.gemini/config/mcp_config.json` with the same key, Antigravity may report a name collision or require disabling one copy; also ensure referenced CLI binaries such as `codegraph` are on `PATH` for GUI-launched Antigravity sessions.)*
4. **`agy-parallel-review` and `speckit-converge` skills:** Confirm `agy-parallel-review/SKILL.md`, `agy-parallel-review/scripts/run_review.sh`, and `speckit-converge/SKILL.md` exist in both `.agent/skills/` and `.agents/skills/` (as well as any other active assistant skills directory, such as `.claude/skills/`, if applicable) and match `skills/agy-parallel-review/` and `skills/speckit-converge/`.
