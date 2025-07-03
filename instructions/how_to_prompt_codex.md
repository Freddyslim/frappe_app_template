# How to Prompt Codex

These notes explain how to craft useful prompts, document new scenarios and troubleshoot Codex behaviour. They complement the framework instructions under `instructions/_core/`.

## 1. Tips for efficient development prompts

When talking to Codex, keep the question short and include relevant paths or vendor slugs. Example questions:

- "Where are Frappe and Bench defined?"
- "How do I add ERPNext as a vendor?"
- "Which files control the submodule setup?"

Codex will scan `instructions/` and the repository structure to answer.

## 2. Steps for documenting new scenarios

1. Create a markdown file under `_scenarios/<scenario-name>.md`.
2. Add a `References:` section at the end that lists the important files or instructions.
3. Run `scripts/generate_index.py` to rebuild the dataset used by Codex.

## 3. How Codex learns from `_scenarios/` files

Each file in `_scenarios/` outlines when certain instructions or code apply. The generator script compiles them so Codex can link prompts to the relevant content in `instructions/_core/` and other folders.

## 4. Debugging advice

If Codex suggests wrong files or incomplete steps:

- Ensure the vendor index `instructions/_INDEX.md` includes all folders you need.
- Verify your scenario file lists correct references.
- Check the docs in `instructions/_core/` to see if they already cover your topic.
- Rerun `scripts/generate_index.py` after updating scenarios or instructions.


## 5. Inspecting the active context

Use your Agents tooling to inspect which files are loaded for a particular scenario. The
`agent.md` document in the repository root explains the available commands and
expected folder layout.
## 6. Automatic context and file management

Before executing any prompt, Codex should read the available documentation and the vendor overview in `_INDEX.md`. Adjust the referenced folders when repositories grow to avoid excessive context size.

Codex may create or extend configuration files such as `Price Settings` automatically. Similarly, when a new algorithm, scraping routine or API integration is required, Codex should scaffold sensible defaults or generate the necessary code once the feature is introduced.
