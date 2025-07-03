# Codex Agent Instructions

## Goal

This repository is a master template for Frappe apps with Codex integration.

The `README.md` describes:

- how to create an app  
- where each file should be located  
- how GitHub configurations should look  
- which automations are enabled via GitHub Actions  

Codex should develop the structure, files, and logic of this repo to match these specifications **exactly**.

---

## Instructions

These instructions are permanent and must be processed on every run, **unless they have been deactivated**.

Individual instructions can be deactivated by placing them **within an HTML comment `<!-- ... -->`**.  
Codex will completely ignore such instructions.  
The `How to Code` section in `README.md` will be automatically updated and list deactivated instructions visibly as “not active”.

### Active Default Instructions
- Flags have highest priority!
- Always update `README.md` when `AGENTS.md` includes new instructions relevant to later usage
- Create missing essential files
- Remove one-time initialization or helper files after use
- Build workflows, scripts, and configs logically and consistently – especially when structure changes (e.g., paths, imports, CI triggers)
- Always keep tests up to date when the project changes or when tests are insufficient. Tests must always follow the project, not the other way around
- Update existing files when they don't align with `README.md` or `AGENTS.md`
- Keep `README.md` ↔ `AGENTS.md` in sync: changes in one must be reflected in the other
- Always review and adjust the `How to Code` section at the end of `README.md` to clearly explain:
  - Which flags are available
  - How Codex is influenced
  - Which instructions are active or deactivated
- Always check all `/scripts` to ensure they match the `README.md`
- If a prompt input is too long or might exceed the available context size, also process it with `--create-tasks`

### Vendor-Specific Agent Profiles

If submodules or vendor folders exist under `/vendors` in the repository, then:

- Look for a vendor-specific agent profile in `instructions/vendor_profiles/<vendorname>/AGENTS.md` – **but only if `<vendorname>` is actually included as a folder or submodule under `/vendors/`**
- **If such an `AGENTS.md` exists**, it takes precedence over conflicting instructions in the main `AGENTS.md`

---

## Command & Execution Restrictions

Codex must **not execute any real shell commands or processes**. These instructions apply solely to structural implementation and preparation.

Allowed:

- Analyzing and modifying all files in the repository
- Creating new files and content
- Generating scripts, configs, CI workflows, and supporting files

Not allowed:

- Running `bench`, `git`, `curl`, `wget`, `npm`, `ssh`, etc.
- Accessing networks or remote repositories
- Initializing external systems or services

**Exception:**  
Codex may generate local commands in CI files or `setup.sh` **as code**, **but must not execute them**.  
These must remain fully within the repository context (e.g., `chmod`, `yarn install`, `git status`, `rm`, `mkdir`, etc.).

The goal is to keep everything **locally preparable and testable** – without side effects on external systems.

---

## Flags

The following flags can be set via prompt.  
**If not set, they are ignored.**

### Flag Combinations and Task Splitting

Multiple flags can be used in combination within a single prompt.  
In such cases, Codex will process all requested operations in sequence and ensure consistency across affected areas.

If the combined logic, number of files, or expected output **exceeds the context window or processing capacity**,  
Codex must **automatically switch to `--create-tasks` mode**.

---

### `--go`

- use prompts from `PROJECT.md`

### `--start`

- Initializes implementation of the template based on the current `README.md` and `AGENTS.md`
- Executes all active instructions
- Adds missing files, adjusts existing ones
- Updates the `How to Code` section in `README.md`

### `--update-agent`

- Prompt is interpreted as the primary source
- `AGENTS.md` is modified based on the prompt as a direct code change
- Then the entire project is updated according to the new `AGENTS.md`
- `How to Code` must also be updated; if context size is exceeded, use `--create-tasks`

### `--create-tasks`

- No direct code changes are made
- Instead, clear, low-conflict tasks are generated
- These tasks are logically separated, understandable, and can be executed in parallel
- If multiple tasks modify the same file, they should be handled in a single task to minimize merge conflicts
- Each task is clearly scoped and individually executable
- The division is optimized to avoid parallel merge conflicts (e.g., if multiple flags affect the same file)

This ensures large or multi-scope prompts remain traceable, manageable, and safe to execute.

### `--update-readme`

- Prompt is interpreted as the primary source
- `README.md` is adjusted accordingly
- The entire project is reviewed and updated based on the new README  
  If the context becomes too large, use `--create-tasks`
- Only new files explicitly required by the prompt will be created
- check AGENTS.md if there are necessary new infos for README.md and developers to know

### `--update-scripts`

- Only checks and processes scripts located in `scripts/`
- All files in this directory are **individually reviewed line by line**
- Each script is adapted to match the logic and structure defined in `README.md` and `AGENTS.md`
- Any outdated, unused, or redundant content must be **cleaned up or deleted**
- Scripts should be made consistent, minimal, and purposeful
- If a script cannot be adjusted without violating or contradicting the logic in `README.md` or `AGENTS.md`,  
  **no changes are made** – Codex must first prompt the user for clarification
- No other parts of the repository are affected

### `--update-workflows`

- Only checks and processes workflows located in `.github/workflows/`
- Every workflow file is **fully parsed and reviewed line by line**
- Each is updated to reflect the automation strategy and CI/CD logic defined in `README.md` and `AGENTS.md`
- Unused triggers, deprecated steps, or ineffective logic must be **removed**
- Redundant or conflicting workflows should be **merged, refactored, or removed**
- If a workflow cannot be updated without contradicting the intended logic in `README.md` or `AGENTS.md`,  
  **no changes are made** – Codex must first prompt the user for clarification
- No modifications are made outside the `.github/workflows/` directory  
  **except in the following special case**:  
  If a workflow is invoked or referenced in another file (e.g. `setup.sh`, `Makefile`, `README.md`, etc.), and the invocation is no longer valid or logical according to `README.md`,  
  then Codex may **modify that reference** – but only that specific line or section – to restore consistency

### `--update-docs`

- Only the documentation in `docs/` should be worked on
- Assume that all other files in the repo are clean and up to date
- Docs should be thoroughly reviewed and adjusted to fit the project
- All scripts, workflows, etc. should be documented + comprehensive global documentation, possibly with interlinking
- Where reasonable, modular Mermaid diagrams should be used to visualize the workflow
- Mermaids should be generated automatically when useful and follow the `AGENTS.md` rules for Mermaid diagrams

---

## Note

This file is for Codex – not for users.  
It defines central behavioral rules for automated project structuring.  
**Instructions** can be deactivated via comments.  
Flags are dynamic and must be actively set.  
The `How to Code` section in `README.md` always documents the current state.

## PROJECT.md 

`PROJECT.md` 

- **New prompts** are added and executed via `codex --go`.
- Codex reads **only the section above a separator** (`---`) to ignore old logs.

This makes `PROJECT.md` a central place for:
- pre-prepared tasks,
- automated execution,
- gapless logging.

## Mermaid

Mermaid diagrams should be created consistently. The following guidelines support standardization.  
If Codex deems a diagram useful and generates one, this section will be updated with new rules.

- if this happens for the first time, replace this section with new instructions to standardize the following mermaids
- structure mermaids logically and use different shapes for distinct purposes
- e.g., functions as rounded shapes, instructions as rectangles – depending on what the diagram illustrates and what groupings make sense
