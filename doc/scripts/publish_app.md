# Release Process

Use `publish_app.sh` to create tags and optional release pull requests.

```bash
./scripts/publish_app.sh <dev-stable|test-stable|major>
```

The argument decides which part of the version is bumped:

- `dev-stable` – increase the patch level.
- `test-stable` – increase the minor version and reset patch.
- `major` – increase the major version and reset minor and patch.

The script checks for an existing clean git repository, creates a release commit if needed, tags the new version and pushes the tag. When the GitHub CLI is installed, it also opens a release PR on the `main` branch.
