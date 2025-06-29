# Using the Frappe Template as a Submodule

This guide explains how to start a new repository that keeps the `frappe_app_template` as a Git submodule. The approach allows you to pull in updates from the template at any time.

## 1. Repository Setup

```bash
mkdir myapp
cd myapp
git init
# add the template as submodule
git submodule add https://github.com/seclution/frappe_app_template template
```

Copy the configuration files from the template so you can adjust them:

```bash
cp template/apps.json .
cp template/vendors.txt .
cp -r template/vendor_profiles .
```

Edit these files to add your desired vendor slugs and integration profiles.

## 2. Initialising the Environment

Run the setup script inside the submodule to clone the vendor apps and generate `codex.json`. The script also copies the GitHub workflow files to the parent repository when they are missing so that CI runs automatically:

```bash
cd template
./setup.sh
cd ..
```

Commit all generated files and push the repository to GitHub. Trigger the *update-vendors* workflow if you want to rebuild `apps.json` automatically.

## 3. Updating the Template

Whenever a new version of the template is available, update the submodule:

```bash
git submodule update --remote template
git commit -am "chore: update template"
```

This pulls the latest changes from `frappe_app_template` while keeping your own configuration files intact.
