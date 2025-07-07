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

### Active Default Instructions
- Flags have highest priority!
- Always update `README.md` when `AGENTS.md` includes new instructions relevant to later usage
- Create missing essential files
- Build workflows, scripts, and configs logically and consistently – especially when structure changes (e.g., paths, imports, CI triggers)
- Always keep tests up to date when the project changes or when tests are insufficient. Tests must always follow the project, not the other way around
- Update existing files when they don't align with `README.md` or `AGENTS.md`
- Always review and adjust the `How to Code` section at the end of `README.md` to clearly explain:
  - Which flags are available
  - How Codex is influenced
  - Which instructions are active or deactivated
- If a prompt input is too long or might exceed the available context size, also process it with `--create-tasks`

### Vendor-Specific Agent Profiles

If submodules or vendor folders exist under `/vendor` in the repository, then:

- Look for a vendor-specific agent profile in `instructions/<vendorname>/AGENTS.md` – **but only if `<vendorname>` is actually included as a folder or submodule under `/vendor/`**

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

### `--focus-on-<file/folder>`

- high focus on specific file or folder recursive 

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
- check AGENTS.md if there are necessary new infos for README.md and developers to know like new flags

### `--update-scripts`

- Only checks and processes scripts located in `scripts/` + `setup.sh`
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
- No other parts of the repository are affected

### `--update-comments`

- understand code in each relevant file  
- only include files where comments add real value  
- IMPORTANT: only add comments – no other code changes allowed  
- begin with filename  
- use `#`, `//`, or `"""` depending on the language  
- explain **why**, not just what  
- focus on context clarity and Codex speed  
- keep comments short  
- be precise and helpful  
- avoid noise or redundancy  
- maintain high comment quality over quantity  
- if the task is too large, split into multiple subtasks --> --create-tasks
- Codex should instantly understand logic and purpose  
- files must be ready for prompt-based development  

### `--update-docs`

- Only the documentation in `docs/` should be worked on
- Assume that all other files in the repo are clean and up to date
- Docs should be thoroughly reviewed and adjusted to fit the project
- All scripts, workflows, etc. should be documented + comprehensive global documentation, possibly with interlinking
- Where reasonable, modular Mermaid diagrams should be used to visualize the workflow
- Mermaids should be generated automatically when useful and follow the `AGENTS.md` rules for Mermaid diagrams
- Directory trees from `README.md` are stored under `doc/trees/` and referenced from the README
- Each script in `scripts/` has a matching file in `doc/scripts/`
- Each workflow in `.github/workflows/` has a matching file in `doc/workflows/`

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

## Mermaid

All diagrams are stored as `.mmd` files under `doc/` and rendered to `.svg` using `scripts/generate_diagrams.sh`.
Use `flowchart TD` unless a different chart type better suits the information.
Represent files or resources with rectangular nodes and scripts or commands with rounded nodes.
Keep each diagram focused on a single workflow to stay concise.
