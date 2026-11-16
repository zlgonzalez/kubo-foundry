---
name: speckit-epic-scorer
description: Score, audit, and evaluate GitHub Spec Kit artifacts (.specify/memory/constitution.md, spec.md, plan.md, tasks.md, research.md, data-model.md, quickstart.md, contracts/) dynamically based on whichever artifacts exist at execution time using the EPIC framework (4 categories, 10 quality dimensions, 40 practices). Use whenever asked to score, review, audit, critique, or check readiness of Spec Kit specifications, plans, tasks, or .specify directories, even if only a subset of files has been generated so far.
---

# Spec Kit EPIC Scorer

Evaluate GitHub Spec Kit artifacts using the empirically grounded **EPIC** framework (Expressive, Precise, Interpretable, Compartmentalized)[span_2](start_span)[span_2](end_span)[span_3](start_span)[span_3](end_span). Rather than requiring the entire Specify -> Plan -> Tasks pipeline to be complete before scoring, this skill adapts dynamically to the Spec Kit stage and files present at execution time[span_4](start_span)[span_4](end_span)[span_5](start_span)[span_5](end_span)[span_6](start_span)[span_6](end_span).

## When to Use

- The user asks to score, review, audit, or assess Spec Kit artifacts (`spec.md`, `plan.md`, `tasks.md`, `constitution.md`, or `.specify/` directories).
- The user wants a stage-gate check after `/speckit.specify`, `/speckit.plan`, or `/speckit.tasks` before running `/speckit.implement`[span_7](start_span)[span_7](end_span).
- The user requests machine-readable JSON or structured markdown feedback on Spec Kit specification quality[span_8](start_span)[span_8](end_span).

## Step 1: Discover Existing Spec Kit Artifacts

Inspect the target feature directory (e.g., `specs/<feature>/` or `.specify/`) and project memory to inventory what actually exists right now[span_9](start_span)[span_9](end_span)[span_10](start_span)[span_10](end_span):

1. **Constitution (Project-wide):** `.specify/memory/constitution.md` (or `constitution.md`)[span_11](start_span)[span_11](end_span)[span_12](start_span)[span_12](end_span)
2. **Specification Stage (`/speckit.specify`):** `spec.md`[span_13](start_span)[span_13](end_span)[span_14](start_span)[span_14](end_span)
3. **Planning Stage (`/speckit.plan`):** `plan.md`, plus optional supporting files (`research.md`, `data-model.md`, `quickstart.md`, `contracts/`)[span_15](start_span)[span_15](end_span)
4. **Task Stage (`/speckit.tasks`):** `tasks.md`[span_16](start_span)[span_16](end_span)[span_17](start_span)[span_17](end_span)

If multiple feature directories exist, evaluate one feature at a time unless asked for a repository-wide summary[span_18](start_span)[span_18](end_span). List every discovered file and explicitly note which pipeline stages have not been run yet[span_19](start_span)[span_19](end_span)[span_20](start_span)[span_20](end_span).

## Step 2: Determine Stage-Aware Applicability

Do not penalize a Spec Kit artifact set for downstream files that have not been created yet in the workflow[span_21](start_span)[span_21](end_span)[span_22](start_span)[span_22](end_span)[span_23](start_span)[span_23](end_span). Classify each of the 10 dimensions and 40 practices into **Active** vs. **Deferred (Not Yet Applicable)** based on the current stage[span_24](start_span)[span_24](end_span)[span_25](start_span)[span_25](end_span):

| Detected Spec Kit Stage | Files Present | Active Dimensions (Scored 0-3) | Deferred / Stage-Adjusted Dimensions |
|---|---|---|---|
| **Stage 1: Specify Only** | `spec.md` (and optional `constitution.md`) | **E1, E2, E3, I1, C1** (full weight); **P1, P2, I2, I3** (evaluated within `spec.md` and `constitution.md` only) | **C2** (`Not Yet Applicable` - plan and tasks not generated); **I2.3, C1.3, C2.3** (cross-file links deferred until `plan.md` exists) |
| **Stage 2: Specify + Plan** | `spec.md`, `plan.md` (plus optional `research.md`, `data-model.md`, `contracts/`) | **E1, E2, E3, P1, P2, I1, I2, I3, C1** (full weight); **C2** (evaluated on technical context `C2.1` and data/API contracts `C2.4`) | **C2.2** (task decomposition deferred until `tasks.md` exists); task-level traceability in **C2.3** and **P1.3** |
| **Stage 3: Full Pipeline (Pre-Implement)** | `spec.md`, `plan.md`, `tasks.md` (plus optional `constitution.md` and supporting docs) | **All 10 Dimensions (E1-E3, P1-P2, I1-I3, C1-C2)** at full weight (0-30 composite score) | None - evaluate full bidirectional traceability and implementation readiness |

*Note on missing upstream files:* If `plan.md` or `tasks.md` exists without `spec.md`, flag `spec.md` as **Missing (Penalized)** rather than deferred, because downstream artifacts cannot trace back to behavioral requirements[span_26](start_span)[span_26](end_span).

## Step 3: Score Active Dimensions (0-3 Rubric)

Read all discovered files completely before assigning scores so evidence in `plan.md` or `tasks.md` can support dimensions first checked in `spec.md`[span_27](start_span)[span_27](end_span). Collect verbatim quotes with filenames as evidence[span_28](start_span)[span_28](end_span).

| Dimension | 0 (Absent) | 1 (Partial) | 2 (Mostly Consistent) | 3 (Consistent Throughout) |
|---|---|---|---|---|
| **E1 Unambiguous** | Pervasive vague terms ("fast", "user-friendly") without bounds or definitions[span_29](start_span)[span_29](end_span). | Some requirements precise; many use unbounded or ambiguous terms[span_30](start_span)[span_30](end_span). | Most requirements bounded/measurable; key terms defined[span_31](start_span)[span_31](end_span). | Every requirement has one interpretation; open items use explicit `[NEEDS CLARIFICATION]` markers or clarifications log[span_32](start_span)[span_32](end_span). |
| **E2 Singular** | Requirements bundle multiple capabilities ("support X and Y and Z")[span_33](start_span)[span_33](end_span). | Some singular; many compound statements[span_34](start_span)[span_34](end_span). | Most state one capability/constraint, with occasional bundling[span_35](start_span)[span_35](end_span). | Every requirement, risk, edge case, and scenario states exactly one concern[span_36](start_span)[span_36](end_span). |
| **E3 Verifiable** | Unverifiable claims; no acceptance scenarios or measurable success criteria[span_37](start_span)[span_37](end_span). | Informal validation notes; many requirements hard to test[span_38](start_span)[span_38](end_span). | Most requirements have Given/When/Then scenarios or measurable checks; uneven edge cases[span_39](start_span)[span_39](end_span). | Every requirement is testable with explicit failure/edge scenarios and completion gates[span_40](start_span)[span_40](end_span). |
| **P1 Dependency Control** | No assumptions, dependencies, or constraints documented[span_41](start_span)[span_41](end_span). | Mentioned in passing without structure[span_42](start_span)[span_42](end_span). | Documented in dedicated sections at the artifact level[span_43](start_span)[span_43](end_span). | Non-trivial requirements/tasks paired with prerequisites, ordering rationale, and failure behavior[span_44](start_span)[span_44](end_span). |
| **P2 Complete** | Major sections empty; unaddressed error handling, NFRs, or many raw TBDs[span_45](start_span)[span_45](end_span). | Happy path covered; edge cases and NFRs largely missing[span_46](start_span)[span_46](end_span). | Functional, interface, and constraint content present; minor open items[span_47](start_span)[span_47](end_span). | All applicable stories, edge cases, constraints, and open-item resolution plans covered[span_48](start_span)[span_48](end_span). |
| **I1 Conforming** | Ignores Spec Kit templates; no requirement or task IDs[span_49](start_span)[span_49](end_span). | Inconsistent structure; partial ID usage[span_50](start_span)[span_50](end_span). | Follows Spec Kit template sections; stable IDs with minor gaps[span_51](start_span)[span_51](end_span). | Strictly conforms to Spec Kit templates with unique, immutable IDs (`FR-001`, `T001`, etc.)[span_52](start_span)[span_52](end_span). |
| **I2 Consistent** | Contradictions in behavior, units, or terminology across files[span_53](start_span)[span_53](end_span). | Same concept named differently; inconsistent units or modal verbs[span_54](start_span)[span_54](end_span). | Terminology and units largely uniform; no contradictions detected[span_55](start_span)[span_55](end_span). | Identical terms, field names, modal verbs (`MUST`/`MUST NOT`), and IDs across all present files[span_56](start_span)[span_56](end_span). |
| **I3 Comprehensible** | Disorganized; no clear entry point or cross-references[span_57](start_span)[span_57](end_span). | Findable with effort; relationships between files implicit[span_58](start_span)[span_58](end_span). | Clear structure and cross-references across present artifacts[span_59](start_span)[span_59](end_span). | Cohesive artifact set with explicit cross-links, file roles, non-goals, and rationale[span_60](start_span)[span_60](end_span). |
| **C1 Scope Discipline** | `spec.md` dominated by tech stack, code, or implementation tasks[span_61](start_span)[span_61](end_span). | Behavioral requirements mixed with implementation prescriptions or project-management content[span_62](start_span)[span_62](end_span). | Mostly behavioral in `spec.md`, with minor technical leakage[span_63](start_span)[span_63](end_span). | `spec.md` is strictly behavioral; tech choices live in `plan.md` and work items in `tasks.md`[span_64](start_span)[span_64](end_span). |
| **C2 Implementation-Planning Info** | Present planning files lack tech context, contracts, or task breakdown[span_65](start_span)[span_65](end_span). | Minimal technical context or task list without rationale or links[span_66](start_span)[span_66](end_span). | Substantive technical context and contracts/tasks linked to `spec.md`[span_67](start_span)[span_67](end_span). | Full tech context, contracts/data models, phased tasks, and bidirectional ID traceability (or Stage-3 complete)[span_68](start_span)[span_68](end_span). |

### Scoring Rules and Guardrails

- **Unfilled Spec Kit template placeholders are not evidence:** Boilerplate like `FR-001: System MUST [specific capability]` or unreviewed template sample stories count against **E1** and **P2.5**, not in favor of **I1**[span_69](start_span)[span_69](end_span).
- **Length is not quality:** A concise feature spec can earn a 3/3 if every requirement is atomic, bounded, and verifiable[span_70](start_span)[span_70](end_span).
- **Feature-level non-applicability:** Practices like security/privacy properties (**E2.5**) or data models (**C2.4**) only apply when the feature handles sensitive data, exposes an attack surface, or persists structured state[span_71](start_span)[span_71](end_span). Mark them `N/A (Feature)` rather than deducting points[span_72](start_span)[span_72](end_span)[span_73](start_span)[span_73](end_span).
- **Quote strictly verbatim:** Never paraphrase text into evidence[span_74](start_span)[span_74](end_span). If evidence is absent, mark the practice missing[span_75](start_span)[span_75](end_span).

## Step 4: Reference the 40 EPIC Practices

Map evidence and gaps to the specific practice IDs below:

- **E1 Unambiguous:** `E1.1` Explicit Clarification-Seeking (`[NEEDS CLARIFICATION]`), `E1.2` Quantified/Measurable Requirements, `E1.3` Bounded Vocabulary & Enums, `E1.4` Normative & Structural Consistency (`MUST`/`MUST NOT`), `E1.5` Explicit Scope & Verification Boundaries[span_76](start_span)[span_76](end_span).
- **E2 Singular:** `E2.1` Atomic Functional Statements, `E2.2` Singular Architecture/Design Facts, `E2.3` Isolated Risk/Assumption/Edge-Case Entries, `E2.4` Singular Definitional/Scenario Statements, `E2.5` Singular Security & Privacy Properties[span_77](start_span)[span_77](end_span).
- **E3 Verifiable:** `E3.1` Verification Criteria & Measurable Outcomes, `E3.2` Verification Scenarios (Given/When/Then) & Validation Methods, `E3.3` Comprehensive Verification Coverage (edge/error cases), `E3.4` Verification Completion & Readiness Gates[span_78](start_span)[span_78](end_span).
- **P1 Dependency Control:** `P1.1` Declared Assumptions & Dependencies, `P1.2` Explicit Constraint & Scope Boundaries, `P1.3` Requirement/Task-Level Dependency & Risk Traceability, `P1.4` Dependency Verification & Failure-Mode Handling[span_79](start_span)[span_79](end_span).
- **P2 Complete:** `P2.1` Functional & User Requirement Coverage, `P2.2` Exceptional Behavior & Scope Definition, `P2.3` Technical, Operational & Quality Constraints, `P2.4` Dependency & Delivery Planning, `P2.5` Specification Completeness Management[span_80](start_span)[span_80](end_span).
- **I1 Conforming:** `I1.1` Standardized Document Structure, `I1.2` Stable, Unique Requirement Identifiers, `I1.3` Explicit Template Declaration & Enforcement[span_81](start_span)[span_81](end_span).
- **I2 Consistent:** `I2.1` Standardized Terminology & Definitions, `I2.2` Uniform Identifiers & Notation, `I2.3` Cross-Artifact Alignment & Traceability, `I2.4` Consistent Organizational Structure[span_82](start_span)[span_82](end_span).
- **I3 Comprehensible:** `I3.1` Structured Document Organization, `I3.2` Cross-Document Context & Navigation, `I3.3` Comprehension Support (non-goals, legends, examples)[span_83](start_span)[span_83](end_span).
- **C1 Scope Discipline:** `C1.1` Behavioral Product Specification (`spec.md`), `C1.2` Separation of Product & Project Concerns (`plan.md`/`tasks.md`), `C1.3` Traceable Transition to Implementation[span_84](start_span)[span_84](end_span).
- **C2 Implementation-Planning Information:** `C2.1` Technical Context & Foundations (`plan.md`, `constitution.md`), `C2.2` Implementation Planning & Task Organization (`tasks.md`), `C2.3` Requirements-to-Implementation Traceability, `C2.4` Implementation Data Models & Evolution Planning (`data-model.md`, `contracts/`)[span_85](start_span)[span_85](end_span).

## Step 5: Format the Output

Present the review in markdown using the structure below (or return JSON with `artifacts`, `stage`, `scores`, `active_total`, and `max_possible` if machine-readable output is requested)[span_86](start_span)[span_86](end_span):

```markdown
# Spec Kit EPIC Review: <feature-name>

**Detected Stage:** <Stage + 1: 2: 3: Full Only Pipeline Plan Specify Stage |>
**Artifacts Found:** <list of existing files>
**Deferred Artifacts:** <list of not-yet-generated files, or "None">
**Active Score:** <n>/<max_applicable> (Composite: <n>/30) | E <n>/9 | P <n>/6 | I <n>/9 | C <n>/<3 or 6>

## Summary
<2-4 sentences highlighting the strongest dimensions, weakest dimensions, and the primary risk for an agent executing the next Spec Kit command.>

## Dimension Scores
| Dimension | Status | Score | Practices Present | Missing or Weak |
|---|---|---|---|---|
| E1 Unambiguous | Active | 2/3 | E1.2, E1.4 | E1.1 |
| ... | | | | |
| C2 Implementation-Planning | Deferred (Stage 1) | N/A | - | Awaits /speckit.plan and /speckit.tasks |

## Evidence and Gaps
### E1 Unambiguous (2/3)
- **Present (`E1.2`):** "<verbatim quote>" (`spec.md`)
- **Missing (`E1.1`):** <specific gap and why it matters>

## Recommended Revisions (Before Next Spec Kit Step)
1. **<Highest-impact fix>** (`<Practice ID>`, `<file>`): <concrete change to make before running the next `/speckit.*` command>
2. ...
```

## Gotchas

- **Do not penalize missing downstream files prematurely:** If a user runs this skill right after `/speckit.specify` to validate `spec.md` before planning, `plan.md` and `tasks.md` do not exist yet[span_87](start_span)[span_87](end_span). Score `C2` as `N/A (Deferred)` and adjust the denominator (e.g., `/27` instead of `/30`) while also showing the raw `/30` composite[span_88](start_span)[span_88](end_span)[span_89](start_span)[span_89](end_span).
- **Watch for Spec Kit template leakage:** Spec Kit templates include instructional HTML comments and placeholder brackets[span_90](start_span)[span_90](end_span). Flag leftover placeholders as ambiguity (`E1.1`) and incomplete specification items (`P2.5`)[span_91](start_span)[span_91](end_span).
- **Keep feedback objective and artifact-focused:** Frame scores as properties of the current specification artifacts rather than judgments of the author, and note that higher EPIC scores reduce agent guesswork without guaranteeing defect-free code[span_92](start_span)[span_92](end_span)[span_93](start_span)[span_93](end_span).
