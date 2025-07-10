# Guidelines for Developers

This repository hosts the **Frappe Framework**. 

# Repository Navigation

Use these navigation files to explore specific areas of the framework:

- [Doctypes](nav_doctypes.md) – DocType definitions and base classes.
- [APIs](nav_apis.md) – REST routes and RPC handlers.
- [Emails](nav_emails.md) – email queue, accounts and helpers.
- [Websites](nav_websites.md) – website pages, templates and routing.
- [Permissions](nav_permissions.md) – role based access control.
- [Fixtures](nav_fixtures.md) – demo and fixture data utilities.
- [Hooks](nav_hooks.md) – framework hooks and configuration keys.
- [Integrations](nav_integrations.md) – third party integration modules.
- [Patches](nav_patches.md) – database migrations and patch handler.
- [Translations](nav_translations.md) – CSV language files and helpers.
- [Reports](nav_reports.md) – built-in reports.
- [Printing](nav_printing.md) – print formats and printing tools.
- [Themes](nav_themes.md) – website and desk theme files.
- [Webforms](nav_webforms.md) – web form definitions and assets.
- [Database](nav_database.md) – database layer and query builder.
- [Scheduled Tasks](nav_scheduled.md) – scheduler events and logs.
- [Search](nav_search.md) – full text and website search.
- [CLI Commands](nav_commands.md) – bench command implementations.
- [Workflows](nav_workflows.md) – document workflow configuration.

# Doctypes

DocType definitions reside in `doctype` subfolders across modules such as `frappe/core/doctype`, `frappe/desk/doctype`, `frappe/website/doctype`, `frappe/email/doctype`, and others. Base classes live in `frappe/model/document.py` and `frappe/model/base_document.py`.

A DocType folder typically contains `<DocType>.json`, `<DocType>.py`, optional `<DocType>.js`, and additional resources like docs or tests.

# APIs

REST and RPC endpoints are registered in `frappe/api/__init__.py` for `/api/method` and `/api/resource`. Key implementation files include `frappe/api/v1.py`, `frappe/api/v2.py`, `frappe/core/api/file.py`, `frappe/client.py`, and `frappe/handler.py`. Tests live in `frappe/tests/test_api.py` and `frappe/tests/test_api_v2.py`.

# Emails

Important parts of the email system are located in `frappe/email`:

- `__init__.py` with helper functions.
- `email_body.py` for MIME generation.
- `doctype/` containing `email_queue`, `email_account`, and related DocTypes.
- `assets/` for template images.
- `email.md` describing the module.
- additional helpers in `queue.py`, `receive.py` and `smtp.py`.

# Websites

Key directories for website features:

- `frappe/www` for HTML and Python pages.
- `frappe/website/doctype` including `web_page`, `blog_post`, and `website_theme`.
- `frappe/website/page_renderers` and `frappe/website/router.py`.
- `frappe/website/web_template` reusable templates.
- styling under `website_theme/` and `public/scss/website`.
- static assets in `frappe/public` and templates in `frappe/templates`.

# Permissions

Permissions logic is implemented in `frappe/permissions.py`. DocTypes may define hooks like `get_permission_query_conditions` or `has_permission`. Rights definitions reside under `frappe/core/doctype` in folders `docperm`, `custom_docperm`, `user_permission`, `role`, `has_role`, `role_profile`, and `role_permission_for_page_and_report`.

# Fixtures

Demo and fixture data reside in `frappe/custom/fixtures`, `frappe/core/doctype/data_import/fixtures`, and `cypress/fixtures`. Utilities are provided by `frappe/utils/fixtures.py`. Related tests are in `frappe/tests/test_fixture_import.py` and `frappe/tests/test_exporter_fixtures.py`. The setup wizard loads fixtures via `frappe/desk/page/setup_wizard/install_fixtures.py`.

# Hooks

Central configuration lives in `frappe/hooks.py` with keys such as `doc_events`, `scheduler_events`, `permission_query_conditions`, `has_permission`, `jinja`, and `override_whitelisted_methods`. Each app can define its own `hooks.py`. See `hooks.md` for a complete list of available keys.

# Integrations

Integration code resides in `frappe/integrations`:

- `doctype/` for various integration DocTypes.
- `frappe_providers/` helpers for FrappeCloud.
- `google_oauth.py` for Google OAuth.
- `oauth2.py` providing the OAuth2 server.

# Patches

Patches are stored under version folders in `frappe/patches` and listed in `frappe/patches.txt`. Execution is handled by `frappe/modules/patch_handler.py`, which logs completed patches in the `Patch Log` DocType under `frappe/core/doctype/patch_log`. Migrations use `frappe/migrate.py`, and individual patches can be run via `run-patch` in `frappe/commands/site.py`. Tests are located in `frappe/tests/test_patches.py`.

# Translations

CSV translation files live in `frappe/translations`. Loader functions such as `get_all_translations` and `get_app_translations` reside in `frappe/translate.py`.

# Reports

Core reports are found in `frappe/core/report` with folders like `database_storage_usage_by_tables`, `document_share_report`, `permitted_documents_for_user`, `prepared_report_analytics`, and `transaction_log_report`. Each contains `<name>.py`, `<name>.js`, and `<name>.json`.

# Printing

Printing-related code lives in `frappe/printing`:

- `doctype/` for `print_format`, `print_settings`, and `letter_head`.
- `form_tour/` for guided tours.
- `page/` with pages like `print` and `print_format_builder`.
- `print_style/` providing CSS themes.

# Themes

Theme resources include the `website_theme` DocType and templates under `frappe/website/website_theme`, SCSS files in `frappe/public/scss/website` and `frappe/public/scss/desk`, the theme switcher in `frappe/public/js/frappe/ui/theme_switcher.js`, and the helper script `generate_bootstrap_theme.js`. Example themes live in `frappe/templates/includes/website_theme`.

# Webforms

Webform definitions are spread across several folders:

- `frappe/website/doctype/web_form` with templates and related DocTypes.
- `frappe/website/web_form` and `frappe/core/web_form` for prebuilt forms.
- client scripts in `frappe/public/js/frappe/web_form` and styles in `frappe/public/scss`.
- tests in `frappe/tests/test_webform.py` and `frappe/www/_test/_test_webform.py`.

# Database / Query Builder

Modules under `frappe/database` implement the database layer. Important files include `database.py`, `query.py`, `schema.py`, `db_manager.py`, dialect implementations under `mariadb/` and `postgres/`, `operator_map.py`, and `__init__.py` with `get_db()`.

# Scheduled Tasks

Scheduler logic lives in `frappe/utils/scheduler.py`. Events are defined under `scheduler_events` in `frappe/hooks.py`. Job types are stored via `frappe/core/doctype/scheduled_job_type`, with logs in `frappe/core/doctype/scheduled_job_log`. Server script jobs are configured in `frappe/core/doctype/server_script`. Command-line helpers exist in `frappe/commands/scheduler.py`, and system health information is provided by `frappe/desk/doctype/system_health_report`.

# Search

Search functionality resides in `frappe/search` with `web_search` in `__init__.py`, the base class `full_text_search.py`, and website search implementation in `website_search.py`. Tests are located in `frappe/search/test_full_text_search.py`.

# CLI Commands

All bench commands live under `frappe/commands` including `gettext.py`, `redis_utils.py`, `scheduler.py`, `site.py`, `translate.py`, and `utils.py`.

# Workflows

Workflow configuration is located in `frappe/workflow/doctype` with DocTypes such as `workflow`, `workflow_action`, `workflow_action_permitted_role`, `workflow_action_master`, `workflow_document_state`, `workflow_state`, and `workflow_transition`. The workflow builder interface resides at `frappe/workflow/page/workflow_builder`.
