---
name: ai-service-annotator
description: Universally analyzes frontend UI, data providers, and state repositories to inject standardized, agent-readable semantic metadata comments detailing backend microservice requirements.
allowed-tools: View Edit Bash MML
---

# Universal AI Microservice Annotator Workflow

## Objective
Scan the frontend code directory to discover data-binding layers, authentication hooks, and external API requests, then automatically prepend a standardized, agent-predictable metadata block. This ensures any downstream backend-generation agent can instantly synthesize the required backend microservice APIs.

## Execution Steps

### Step 1: Detect Data Dependencies
1. Iteratively scan the application's core codebase (e.g., `/lib`, `/src`).
2. Identify files or classes responsible for handling:
   - Outbound HTTP, REST, GraphQL, or WebSocket communication blocks.
   - Local authentication caching, session tracking, and user login workflows.
   - Component state management layers that require remote data populating.

### Step 2: Extract and Format the Metadata Schema
For each unique data channel or remote action found that lacks an authorization or data contract, calculate:
- **Service Name:** A generic, domain-specific name (e.g., `UserAuthService`, `AnalyticsLogService`).
- **Endpoint Structure:** Pure RESTful or RPC paths (e.g., `POST /api/v1/auth`, `GET /api/v1/data`).
- **Data Shape:** Construct structured JSON payload schemas mirroring the frontend models or fields used in that file.
- **Security Context:** Explicitly set security levels to ensure the downstream agent builds matching middleware (e.g., `Public` or `Protected`).

### Step 3: Inject the Agent-Readable Metadata Block
1. Write the computed metadata directly into the file, placing it cleanly above the target class or controller definition.
2. Use the universal schema block template below so that any coding agent can easily parse it via regular expressions or semantic search:

```text
// @ai-service: <ServiceName>
// @route: <HTTP_METHOD> <PATH>
// @request-payload: <JSON_INPUT_SCHEMA>
// @response-payload: <JSON_OUTPUT_SCHEMA>
// @security: <Public|Protected_JWT_Bearer>
