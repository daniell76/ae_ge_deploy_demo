# Deploy ADK agent on Agent Engine and Gemini Enterprise

This repository contains the source code for the Sequential Trip Planner Agent, a demo AI application designed to solve multi-faceted user requests by delegating tasks to specialized, fine-tuned sub-agents.

The entire demonstration is built around an Agent Development Kit (ADK) architecture and is hosted on the Agent Engine (AE) before being surfaced for end-users via Gemini Enterprise.

## Demo steps

- 0. [before demo] Prepare GCP environment:  
Gemini Enterprise License, Service Account, IAM permission, Source code.

- 1. [optional] Local Run & Validation

```shell
uv run adk run my_agent
```

- 2. Deploy to Agent Engine (AE)

```shell
./agent_deployment.sh --deploy-agent
```

- 3. Register to Gemini Enterprise

```shell
./agent_deployment.sh --link-as-agent
```

- 4. Demo on Gemini Enterprise UI  
Demo the trip planning agent from Gemini Enterpires UI

## Agent Architecture

The Trip Planner is orchestrated by a central Root Agent that manages a sequential workflow, synthesizing the final result from the outputs of three specialized sub-agents.

- a. Agent Logic (ADK Sequential Flow)

```text
+------------------------------------+
|                                    |
|         ROOT AGENT (Orchestrator)  <---+
|                                    |   |
+-----------------+------------------+   |
                  |                      |
                  |  Delegates Task      |
                  V                      |
+------------------------------------+   |
|                                    |   |
|   +--------------------------+     |   |
|   | Destination Analyzing    | <---+---+
|   | Agent                    |     |
|   +--------------------------+     |
|               |                    |
|               |  Sequential Flow   |
|               V                    |
|   +--------------------------+     |
|   | Itinerary Planning       |     |
|   | Agent                    |     |
|   +--------------------------+     |
|               |                    |
|               |  Sequential Flow   |
|               V                    |
|   +--------------------------+     |
|   | Logistics Planning       |     |
|   | Agent                    |     |
|   +--------------------------+     |
|                                    |
+------------------------------------+
```

- b. System Architecture Diagram

```text
+-------------------------+
|      Agent Engine (AE)  |
|                         |
|   +-------------------+ |
|   | Trip Planning     | |
|   | Agent (Deployment)| |
|   +-------------------+ |
|            |            |
+-------------------------+
             |
             | [Register]
             V
+--------------------------------+
|      Gemini Enterprise         |
|                                |
|   +------------------------+   |
|   | Enterprise App (UI)    |   |
|   | - User Interaction     |   |
|   +------------------------+   |
+--------------------------------+
```
