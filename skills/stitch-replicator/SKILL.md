---
name: stitch-replicator
description: Use when you need to perfectly replicate a user interface, mockup, or wireframe from a Google Stitch project into functional, semantic frontend components.
allowed-tools: stitch.list_projects stitch.get_screen_code stitch.get_screen_image View Edit Bash
---

# Stitch Design Replication Workflow

## Prerequisites
- You must verify that the Stitch MCP server is live by running `stitch.list_projects`.
- If an API error occurs, prompt the user to check their `STITCH_API_KEY` in Antigravity's MCP settings.
- Ensure that you only replicate one project and if it's not clear which project, list all the projects, both main and shared and ask the user to select.

## Execution Steps

### Step 1: Ingest the Design DNA
Do not guess or hallucinate styles. You must systematically extract the structure from the platform:
1. Run `stitch.list_projects` to find the target project ID.
2. Call `stitch.get_screen_code` for the specified screen to extract layout rules, grid structures, and spacing data.
3. Call `stitch.get_screen_image` to fetch the visual screenshot string for multi-modal layout verification.

### Step 2: Document the Design Tokens
Before writing application components, create an intermediate blueprint file in the root directory:
1. Create a `DESIGN.md` file.
2. Document the extracted Color Palette (Hex codes), Typography (font sizes, weights), Spacing scale, and Core Component structural hierarchy.
3. Present this `DESIGN.md` summary to the user for a quick conformation checkpoint.

### Step 3: Scaffold and Implement
1. Map the Stitch structural data to your target framework primitives (e.g., matching Stitch container layouts to custom Flutter widgets or Tailwind classes).
2. Generate the code cleanly, ensuring all styling attributes are tied explicitly back to the parameters defined in `DESIGN.md`.

### Step 4: Visual Vibe Check (Crucial)
1. Read the base64 image data pulled via `get_screen_image`.
2. Compare your generated component layout against the visual screenshot.
3. Check and correct padding, text alignments, and absolute positioning shifts.
