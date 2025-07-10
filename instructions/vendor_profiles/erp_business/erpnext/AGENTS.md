# Guidelines for Developers

This repository provides ERPNext as a reference codebase. 

# Repository Navigation

This project is organized into multiple modules and supporting folders. Use the following navigation files to load context about each area.

## Modules

- [Accounts](nav-accounts.md) – financial accounting, ledgers and payment entries.
- [CRM](nav-crm.md) – lead and opportunity management with onboarding helpers.
- [Buying](nav-buying.md) – purchase orders, supplier quotes and RFQs.
- [Projects](nav-projects.md) – project planning, tasks and timesheets.
- [Selling](nav-selling.md) – quotations, sales orders and Point of Sale.
- [Setup](nav-setup.md) – installation wizard and default company settings.
- [Manufacturing](nav-manufacturing.md) – BOMs, work orders and production plans.
- [Stock](nav-stock.md) – inventory ledger, valuation and item utilities.
- [Support](nav-support.md) – issue tracking and SLA monitoring.
- [Utilities](nav-utilities.md) – generic tools like naming series and SMS logs.
- [Assets](nav-assets.md) – asset acquisition, depreciation and disposals.
- [Portal](nav-portal.md) – website portal home pages and user records.
- [Maintenance](nav-maintenance.md) – equipment and asset maintenance schedules.
- [Regional](nav-regional.md) – country-specific templates and VAT reports.
- [ERPNext Integrations](nav-erpnext_integrations.md) – connectors such as Plaid.
- [Quality Management](nav-quality_management.md) – non-conformance and reviews.
- [Communication](nav-communication.md) – communication mediums and time slots.
- [Telephony](nav-telephony.md) – call logs and incoming call popups.
- [Bulk Transaction](nav-bulk_transaction.md) – background bulk processing.
- [Subcontracting](nav-subcontracting.md) – outsourced manufacturing workflows.
- [EDI](nav-edi.md) – electronic data interchange code lists and importers.

## Other Topics

- [Core](nav-core.md) – repository settings, hooks and shared code.
- [Controllers](nav-controllers.md) – server and client controllers used across modules.
- [Domains](nav-domains.md) – domain activation to tailor features by industry.
- [Patches & Change Log](nav-patches.md) – database migrations and release notes.
- [Web & Templates](nav-web.md) – website assets, templates and portal pages.
- [Translations](nav-translations.md) – localization files and translation hooks.
- [Tests](nav-tests.md) – Python and JavaScript test suites.
- [GitHub / CI](nav-github.md) – contribution guidelines and CI workflows.

# Accounts Module

Source directory: `erpnext/accounts`

Main subfolders and files:

- `README.md` – module overview and Payment Ledger design
- `__init__.py`
- `deferred_revenue.py`
- `general_ledger.py`
- `party.py`
- `utils.py`
- `accounts_dashboard/` – dashboard card configuration
- `custom/` – custom scripts like Address hooks
- `dashboard_chart/` – prebuilt analytics charts
- `dashboard_chart_source/` – chart source Python and JS
- `doctype/` – DocType definitions for accounts, invoices, journal entries, payments, etc.
- `form_tour/` – interactive form tours (e.g. Accounts Settings)
- `module_onboarding/` and `onboarding_step/` – onboarding JSON
- `notification/` – email notification templates
- `number_card/` – KPI cards such as incoming/outgoing bills
- `page/` – module pages
- `print_format/` and `print_format_field_template/` – print templates for vouchers
- `report/` – financial reports like Balance Sheet, General Ledger, Profit and Loss
- `test/` – unit tests
- `test_party.py` – standalone party tests
- `workspace/` – Workspace configurations

# Assets Module

Source directory: `erpnext/assets`

Main subfolders:

- __init__.py
- assets_dashboard
- dashboard_chart
- dashboard_fixtures.py
- doctype
- form_tour
- module_onboarding
- number_card
- onboarding_step
- report
- workspace


# Bulk Transaction Module

Source directory: `erpnext/bulk_transaction`

Main subfolders:

- __init__.py
- doctype

### Doctypes

- `bulk_transaction_log` - summary log for a specific date
- `bulk_transaction_log_detail` - records each created document

### Related Files

- `erpnext/utilities/bulk_transaction.py` - server side processing and retry logic
- `erpnext/public/js/bulk_transaction_processing.js` - helper used by list views
- `erpnext/hooks.py` - schedules periodic `bulk_transaction.retry`

List view scripts across `buying`, `selling`, `accounts` and `stock` use the
`bulk_transaction_processing.create` helper to generate related documents in
bulk from selected rows.


# Buying Module

Source directory: `erpnext/buying`

Main subfolders:

- README.md
- __init__.py
- buying_dashboard
- dashboard_chart
- doctype
- form_tour
- module_onboarding
- number_card
- onboarding_step
- page
- print_format
- print_format_field_template
- report
- utils.py
- workspace

Key DocTypes:

- Purchase Order
- Supplier
- Supplier Quotation
- Request for Quotation
- Supplier Scorecard

Related code outside this module:

- `erpnext/controllers/buying_controller.py` – base class for buying transactions
- `erpnext/controllers/subcontracting_controller.py` – provides subcontracting features used in buying
- `erpnext/controllers/accounts_controller.py` – integrates buying logic into accounting
- `erpnext/stock/doctype/purchase_receipt/` – Purchase Receipt built on BuyingController
- `erpnext/stock/onboarding_step/buying_settings/` – onboarding JSON for buying setup
- `erpnext/patches/v12_0/add_default_buying_selling_terms_in_company.py`
- `erpnext/patches/v11_0/check_buying_selling_in_currency_exchange.py`


# Communication Module

Source directory: `erpnext/communication`

The module defines communication mediums and their time slots for assigning
employees to handle incoming requests.

Main contents:

- `__init__.py`
- `doctype/`
  - `communication_medium/`
  - `communication_medium_timeslot/`

Related files:

- `erpnext/public/js/communication.js` – custom form script for the Frappe
  **Communication** DocType (registered via `erpnext/hooks.py`).
- `erpnext/crm/doctype/utils.py` – helper `get_scheduled_employees_for_popup()`
  queries `Communication Medium Timeslot` to find available employees.
- `erpnext/templates/pages/task_info.py` – uses the **Communication** DocType to
  display comments for a task.


# Controllers

Cross-module controllers, tests and command utilities.

## Directories

- `erpnext/controllers` – server-side controller classes and shared utilities.
- `erpnext/controllers/tests` – unit tests for these controllers.
- `erpnext/public/js/controllers` – client-side form controller classes.
- `erpnext/commands` – bench command extensions.

## Key Modules

- `accounts_controller.py`
- `buying_controller.py`
- `selling_controller.py`
- `stock_controller.py`
- `subcontracting_controller.py`
- `taxes_and_totals.py`
- `status_updater.py`
- `queries.py`

# Core

General configuration and shared code.

Important files:

- `pyproject.toml`
- `package.json`
- `README.md`
- `erpnext/hooks.py`
- `erpnext/__init__.py`
- `.pre-commit-config.yaml`
- `erpnext/modules.txt`
- `erpnext/exceptions.py`

Key directories:

- `erpnext/controllers`
- `erpnext/commands`
- `erpnext/config`
- `erpnext/startup`
- `erpnext/change_log`
- `erpnext/patches`
- `erpnext/tests`
- `erpnext/public`
- `erpnext/templates`
- `erpnext/www`

# CRM Module

Source directory: `erpnext/crm`

Main subfolders and files:

- `__init__.py`
- `crm_dashboard/` – dashboard config JSON
- `dashboard_chart/` – charts like `incoming_leads` and `opportunity_trends`
- `doctype/` – CRM doctypes (Lead, Opportunity, Prospect, Campaign, Contract, etc.)
- `frappe_crm_api.py` – integration helpers for Frappe CRM
- `module_onboarding/` – module level onboarding
- `number_card/` – number card definitions
- `onboarding/` – onboarding configuration
- `onboarding_step/` – JSON steps used in onboarding
- `report/` – built‑in CRM reports
- `utils.py` – utilities (link communications, CRMNotes, open activities)
- `workspace/` – workspace layout

Related files elsewhere in the repository:

- `erpnext/public/js/utils/crm_activities.js` – front‑end widget for open tasks & events
- `erpnext/public/js/templates/crm_activities.html` and `crm_notes.html`
- `erpnext/public/js/communication.js` – actions to create leads or opportunities from communications
- `erpnext/telephony/doctype/call_log/call_log.py` – links call logs with leads
- `erpnext/hooks.py` – registers CRM event hooks and scheduler tasks
- `erpnext/patches/*` – migration scripts touching CRM doctypes
- other modules like `buying` and `selling` import CRM utilities when creating quotations or RFQs

# Domains

Configuration related to enabling or restricting industry domains.

## Source directory
- `erpnext/domains` – Python modules that define per-domain setup via a `data` dictionary.
  - `distribution.py`
  - `manufacturing.py`
  - `retail.py`
  - `services.py`

Each file lists desktop icons to show, default values to set and other options when the domain is active.

## Related code
- Workspace JSON files contain `"restrict_to_domain"` to hide pages when a domain is disabled. Examples:
  - `manufacturing/workspace/manufacturing/manufacturing.json`
  - `selling/page/point_of_sale/point_of_sale.json` (domain "Retail")
  - `buying/workspace/buying/buying.json`
- Tests can enable all domains using `enable_all_roles_and_domains` in `erpnext/setup/utils.py`.
- Patches such as `erpnext/patches/v11_1/setup_guardian_role.py` call `frappe.get_active_domains()` to add data only for certain domains.
- The Company doctype (`erpnext/setup/doctype/company/company.json`) includes a "Domain" field used during setup.

# EDI Module

Source directory: `erpnext/edi`

Main subfolders:

- `__init__.py`
- `doctype`
  - `code_list`
    - `code_list.json` – doctype schema
    - `code_list.py` – server logic
    - `code_list.js` – form script
    - `code_list_list.js` – list view settings
    - `code_list_import.py` – genericode import helpers
    - `code_list_import.js` – import dialog
    - `test_code_list.py`
  - `common_code`
    - `common_code.json`
    - `common_code.py`
    - `common_code.js`
    - `common_code_list.js`
    - `test_common_code.py`

Related entries:

- `hooks.py` registers `doctype_list_js` for the importer UI.


# ERPNext Integrations Module

Source directory: `erpnext/erpnext_integrations`

Main subfolders:

- __init__.py
- custom
  - contact.json
- doctype
  - plaid_settings/
    - plaid_settings.py
    - plaid_settings.js
    - plaid_settings.json
    - plaid_connector.py
    - test_plaid_settings.py
- utils.py
- workspace
  - erpnext_integrations/erpnext_integrations.json

Integration-related patches under `erpnext/patches`:

- v12_0/move_plaid_settings_to_doctype.py
- v13_0/shopify_deprecation_warning.py
- v15_0/remove_exotel_integration.py
- v15_0/delete_payment_gateway_doctypes.py
- v15_0/delete_taxjar_doctypes.py
- v15_0/delete_woocommerce_settings_doctype.py

Other references:

- `accounts/doctype/bank/bank.js` – calls Plaid APIs.
- `public/js/help_links.js` – links for PayPal, Razorpay, Dropbox, LDAP, Stripe.


# GitHub / CI

Resources for contributing, continuous integration, and repository management.

Main directories:

- `.github/ISSUE_TEMPLATE` – bug report and feature request templates.
- `.github/workflows` – GitHub Actions for linting, tests, and releases.
- `.github/helper` – helper scripts used in CI.
- `.github/PULL_REQUEST_TEMPLATE.md` – pull request guidelines.

Project policies:

- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `TRADEMARK_POLICY.md`
- `CODEOWNERS`

Continuous integration config:

- `.pre-commit-config.yaml` – pre-commit hooks.
- `commitlint.config.js` – commit message linting.
- `.mergify.yml` – PR automation rules.
- `.releaserc` – release configuration.
- `codecov.yml` – coverage reporting.
- `.semgrepignore` – static analysis exclusions.
- `.git-blame-ignore-revs` – ignored revisions for blame.
- `sider.yml` – Sider static analysis settings.

# Maintenance Module

Source directories:

- `erpnext/maintenance` – core maintenance module
- `erpnext/assets/doctype` – asset maintenance doctypes

Main subfolders under `erpnext/maintenance`:

- `__init__.py`
- `doctype/`
  - `maintenance_schedule/`
  - `maintenance_schedule_detail/`
  - `maintenance_schedule_item/`
  - `maintenance_visit/`
  - `maintenance_visit_purpose/`
- `report/`
  - `maintenance_schedules/`

Related asset maintenance folders:

- `erpnext/assets/doctype/asset_maintenance/`
- `erpnext/assets/doctype/asset_maintenance_log/`
- `erpnext/assets/doctype/asset_maintenance_task/`
- `erpnext/assets/doctype/asset_maintenance_team/`
- `erpnext/assets/doctype/maintenance_team_member/`
- `erpnext/assets/report/asset_maintenance/`

Maintenance patches:

- `erpnext/patches/v13_0/set_status_in_maintenance_schedule_table.py`
- `erpnext/patches/v13_0/update_maintenance_schedule_field_in_visit.py`
- `erpnext/patches/v15_0/update_task_assignee_email_field_in_asset_maintenance_log.py`

# Manufacturing Module

Source directory: `erpnext/manufacturing`

Main subfolders:

- README.md
- __init__.py
- dashboard_chart
- dashboard_fixtures.py
- doctype
- manufacturing_dashboard
- module_onboarding
- notification
- number_card
- onboarding
- onboarding_step
- page
- report
- workspace

Key doctypes include `BOM`, `Work Order`, `Job Card`, `Operation`, `Routing`, `Production Plan`, `Workstation`, and `Manufacturing Settings`.

Common pages under `page/`:

- `bom_comparison_tool`
- `visual_plant_floor`

Dashboards and number cards are generated via `dashboard_fixtures.py` and loaded in `manufacturing_dashboard/` and `workspace/`.

Manufacturing workflows rely on the **Stock** module for inventory movements and integrate with **Quality Management** for inspections.

# Patches & Change Log

Database patches and release notes for upgrades.

- `erpnext/patches/` – patch modules organized by version folders (`v10_0`, `v11_0`, `v12_0`, `v13_0`, `v14_0`, `v15_0`, etc.). Each file exposes an `execute()` function run during migrations.
- `erpnext/patches.txt` – ordered list of patches that have been applied.
- `erpnext/change_log/` – versioned release notes. `current/` holds upcoming notes.
- `.github/workflows/patch.yml` – CI workflow testing patch migrations.
- `erpnext/tests/test_init.py` – includes a patch file validation test.
- `CODEOWNERS` – patch directory owners listed for review responsibility.

# Portal Module

Source directory: `erpnext/portal`

Main subfolders:

- __init__.py
- doctype
- utils.py

Portal doctypes:

- homepage
- homepage_section
- homepage_section_card
- website_attribute
- website_filter_field

Portal-related features elsewhere in the codebase:

- `erpnext/utilities/doctype/portal_user` – links system users with Customers/Suppliers
- `erpnext/controllers/website_list_for_contact.py` – manages portal user roles
- `erpnext/selling/doctype/customer` – handles Customer portal user records
- `erpnext/buying/doctype/supplier` – handles Supplier portal user records and migration patches
- `erpnext/support/doctype/issue` – fields and logic for issues created via the portal


# Projects Module

Source directory: `erpnext/projects`

Main subfolders:

- `__init__.py`
- `dashboard_chart` – chart definitions
- `doctype` – Project DocTypes
- `projects_dashboard` – module dashboard
- `report` – standard reports
- `utils.py`
- `web_form` – web forms
- `workspace` – workspace config

## DocTypes
- Activity Cost
- Activity Type
- Dependent Task
- Project
- Project Template
- Project Template Task
- Project Type
- Project Update
- Project User
- Projects Settings
- Task
- Task Depends On
- Task Type
- Timesheet
- Timesheet Detail

## Reports
- Billing Summary
- Daily Timesheet Summary
- Delayed Tasks Summary
- Employee Billing Summary
- Project Billing Summary
- Project Summary
- Project Wise Stock Tracking

## Web Templates
- `templates/pages/projects.{html,js,py}` – project portal page
- `templates/pages/task_info.{html,py}` – task details
- `templates/pages/timelog_info.{html,py}` – time log view
- `templates/includes/projects/*.html` – project includes

## Other
- `web_form/tasks` – public Tasks form
- `workspace/projects/projects.json` – workspace layout
- `dashboard_chart/project_summary/project_summary.json`
- `projects_dashboard/project/project.json`

# Quality Management Module

Source directory: `erpnext/quality_management`

Main subfolders:

- __init__.py – module init (empty)
- doctype – individual DocType folders for the module
  - `non_conformance`
  - `quality_action` and `quality_action_resolution`
  - `quality_feedback` with related templates and parameters
  - `quality_goal` and `quality_goal_objective`
  - `quality_meeting` along with agenda and minutes
  - `quality_procedure` and `quality_procedure_process`
  - `quality_review` and `quality_review_objective`
- report – contains the *Review* query report
- workspace – workspace definition in `quality/quality.json`

Other related references appear in the manufacturing module (e.g. Quality Inspection)
and patches setting up quality records.

### DocTypes

- non_conformance
- quality_action
- quality_action_resolution
- quality_feedback
- quality_feedback_parameter
- quality_feedback_template
- quality_feedback_template_parameter
- quality_goal
- quality_goal_objective
- quality_meeting
- quality_meeting_agenda
- quality_meeting_minutes
- quality_procedure
- quality_procedure_process
- quality_review
- quality_review_objective

### Other folders

- `report/review`
- `workspace/quality`

### Related Modules

- Stock module contains quality inspection DocTypes under `erpnext/stock/doctype`.
- Manufacturing module includes reports like `quality_inspection_summary`.

### Tests

- `erpnext/quality_management/doctype/**/test_*.py`


# Regional Module

Source directory: `erpnext/regional`

Main subfolders:

- `__init__.py`
- `address_template/` – region-specific address formats
  - `README.md`
  - `setup.py`
  - `templates/` (e.g. `germany.html`, `luxembourg.html`)
  - `test_regional_address_template.py`
- `doctype/`
  - `import_supplier_invoice/`
  - `lower_deduction_certificate/`
  - `south_africa_vat_settings/`
  - `uae_vat_account/`
  - `uae_vat_settings/`
- `italy/` – `setup.py`, `utils.py`, `e-invoice.xml`
- `print_format/`
  - `detailed_tax_invoice/`
  - `irs_1099_form/`
  - `purchase_einvoice/`
  - `simplified_tax_invoice/`
  - `tax_invoice/`
- `report/`
  - `electronic_invoice_register/`
  - `irs_1099/`
  - `uae_vat_201/`
  - `vat_audit_report/`
- `south_africa/` – `setup.py`
- `turkey/` – `setup.py`
- `united_arab_emirates/` – `setup.py`, `utils.py`
- `united_states/` – `setup.py`, `test_united_states.py`

Related patches invoking these modules are located in `erpnext/patches`.


# Selling Module

Source directory: `erpnext/selling`

Main subfolders:

- README.md
- __init__.py
- dashboard_chart
- doctype
- form_tour
- module_onboarding
- number_card
- onboarding_step
- page
- print_format
- print_format_field_template
- report
- selling_dashboard
- workspace

Key doctypes (in `erpnext/selling/doctype`):

- `customer` – customer master and dashboard
- `quotation` – quote document and related items
- `sales_order` – sales order and items
- `product_bundle` – bundled products
- `selling_settings` – module configuration
- other supporting doctypes like `customer_credit_limit`, `party_specific_item`, `sms_center`

Important pages (`erpnext/selling/page`):

- `point_of_sale` – Point of Sale interface with JS and Python controllers
- `sales_funnel` – sales funnel dashboard page

Reports (`erpnext/selling/report`): numerous built‑in sales analytics reports such as `sales_order_analysis`, `sales_analytics`, `quotation_trends`, and more.

Dashboards and workspace:

- `dashboard_chart` and `number_card` provide chart and card JSON definitions
- `selling_dashboard/selling` and `workspace/selling` define the selling workspace
- `module_onboarding/selling` and `onboarding_step/*` configure onboarding flow

Related utilities:

- `erpnext/public/js/utils/sales_common.js` – shared client‑side logic
- `erpnext/controllers/selling_controller.py` – base controller used by doctypes

# Setup Module

Source directory: `erpnext/setup`

Main contents:

- `__init__.py`
- `default_energy_point_rules.py` – built‑in energy point configuration.
- `default_success_action.py` – helper for generic success messages.
- `demo.py` – scripts to create or clear sample data.
- `demo_data/` – JSON fixtures used by `demo.py`.
- `doctype/` – configuration DocTypes (Company, Department, Item Group, etc.).
- `form_tour/` – interactive tours for onboarding forms.
- `install.py` – post‑install hooks and default setup.
- `module_onboarding/` – workspace data for module onboarding.
- `onboarding_step/` – step definitions for guided setup.
- `page/` – location for setup‑related pages.
- `setup_wizard/` – initial setup wizard with data and operations.
- `utils.py` – helper utilities for tests and defaults.
- `workspace/` – workspace JSON files like Home and ERPNext Settings.

Additional references:

- `erpnext/public/js/utils/demo.js` – toolbar action to clear demo data.


# Stock Module

Source directory: `erpnext/stock`

Main subfolders:

- README.md
- __init__.py
- dashboard
- dashboard_chart
- dashboard_chart_source
- deprecated_serial_batch.py
- doctype
- form_tour
- get_item_details.py
- module_onboarding
- number_card
- onboarding_step
- page
- print_format
- reorder_item.py
- report
- serial_batch_bundle.py
- spec
- stock_balance.py
- stock_dashboard
- stock_ledger.py
- tests
- utils.py
- valuation.py
- workspace

Key doctypes and related directories:

- `doctype/item` – item master data
- `doctype/warehouse` – warehouse records
- `doctype/stock_entry` – stock transactions
- `doctype/batch` and `doctype/serial_no` – batch and serial number tracking
- `doctype/stock_ledger_entry` – ledger of all stock movements
- `doctype/stock_reconciliation` – adjustments of stock quantities
- documents like `delivery_note`, `purchase_receipt`, and `material_request`
  include stock-related child tables

Utility modules and controllers:

- `controllers/stock_controller.py` – shared logic for stock documents
- `stock/get_item_details.py` – helper to pull item data
- `stock/stock_ledger.py` – create and update ledger entries
- `stock/stock_balance.py` – queries for current stock quantities
- `stock/reorder_item.py` – automation for reorder levels
- `stock/valuation.py` – FIFO/LIFO valuation methods
- `stock/utils.py` – general stock helpers

Reports and dashboards:

- various reports under `stock/report` such as `stock_ledger` and
  `stock_balance`
- dashboard charts under `stock/dashboard_chart`
- workspace setup in `stock/workspace`

Reference specifications:

- `stock/spec/README.md` and `stock/spec/reposting.md`


# Subcontracting Module

Source directory: `erpnext/subcontracting`

Main subfolders:

- __init__.py
- doctype

### Doctypes

- subcontracting_bom
- subcontracting_order
- subcontracting_order_item
- subcontracting_order_service_item
- subcontracting_order_supplied_item
- subcontracting_receipt
- subcontracting_receipt_item
- subcontracting_receipt_supplied_item

### Related Code

- `erpnext/controllers/subcontracting_controller.py` – shared business logic for orders and receipts
- `erpnext/controllers/tests/test_subcontracting_controller.py` – controller tests
- `erpnext/patches/v15_0/rename_subcontracting_fields.py`
- `erpnext/patches/v14_0/copy_is_subcontracted_value_to_is_old_subcontracting_flow.py`
- `erpnext/patches/v14_0/change_is_subcontracted_fieldtype.py`

This module integrates with stock and manufacturing workflows to handle outsourced production.

# Support Module

Source directory: `erpnext/support`

Main subfolders:

- README.md – brief description of the module
- __init__.py – installs roles like *Support Team* and *Maintenance Manager*
- doctype – DocType folders for:
  - issue
  - issue_priority
  - issue_type
  - pause_sla_on_status
  - service_day
  - service_level_agreement
  - service_level_priority
  - sla_fulfilled_on_status
  - support_search_source
  - support_settings
  - warranty_claim
- page (placeholder)
- report – script reports:
  - first_response_time_for_issues
  - issue_analytics
  - issue_summary
  - support_hour_distribution
- web_form – includes `issues` form
- workspace – contains `support/support.json`
- website route: `erpnext/www/support`

Related modules:
- `erpnext/maintenance` – Warranty Claims can create Maintenance Visits

# Telephony Module

Source directory: `erpnext/telephony`

Main subfolders:

- `__init__.py`
- `doctype`

Key doctypes:

- `call_log`
- `incoming_call_settings`
- `incoming_call_handling_schedule`
- `telephony_call_type`
- `voice_call_settings`

Related assets and hooks:

- `erpnext/public/js/telephony.js` – extends phone fields with a call button
- `erpnext/public/js/call_popup/call_popup.js` – UI for incoming call popups
- `erpnext/public/js/templates/call_link.html` – timeline card for call logs
- `erpnext/public/scss/call_popup.scss` – styles for the call popup
- `erpnext/hooks.py` – connects call logs with contacts and timeline events


# Tests

Automated test suites for ERPNext. Python tests typically
inherit from `frappe.tests.utils.FrappeTestCase` or `unittest.TestCase`.

- `erpnext/tests` – high level tests and shared utilities.
- `erpnext/tests/utils.py` – helpers for creating common test data.
- `erpnext/controllers/tests` – tests for controller logic.
- `erpnext/stock/tests` – tests for the Stock module.
- `erpnext/accounts/test` – accounts test helpers and report cases.
- Many doctypes and reports include `test_<name>.py` files directly in their
  folders under `erpnext/**/doctype/**` and `erpnext/**/report/**`.
- A few JavaScript tests use QUnit (e.g.
  `erpnext/manufacturing/doctype/workstation/_test_workstation.js`).

# Translations

ERPNext uses Frappe's i18n system. Translation strings are stored in CSV files and loaded via hooks.

- `erpnext/translations` – CSV files for each locale.
- `erpnext/hooks.py` – defines `get_translated_dict` for country info.
- `erpnext/tests/test_init.py` – `test_translation_files` validates CSV data.
- `erpnext/setup/utils.py` – setup wizard supplies a default `language`.
- DocType JSONs such as `selling/doctype/customer/customer.json` and
  `stock/doctype/purchase_receipt/purchase_receipt.json` include `language` or
  `Print Language` fields.
- Many print formats set `default_print_language`.
- Templates like `templates/print_formats/includes/item_table_description.html`
  call `doc.get_formatted(..., translated=True)`.

# Utilities Module

Source directory: `erpnext/utilities`

Main subfolders and key files:

- `README.md`
- `__init__.py`
- `activation.py`
- `bulk_transaction.py`
- `doctype`
- `doctype/portal_user`
- `doctype/rename_tool`
- `doctype/sms_log`
- `doctype/video`
- `doctype/video_settings`
- `naming.py`
- `product.py`
- `regional.py`
- `report`
- `report/youtube_interactions`
- `transaction_base.py`
- `web_form`
- `web_form/addresses`


# Web & Templates

Website assets, templates, and portal code.

## Assets

- `erpnext/public/images` – icons and illustrations used on the website and desk.
- `erpnext/public/js` – client-side JavaScript modules.
- `erpnext/public/js/templates` – HTML snippets rendered by JS.
- `erpnext/public/scss` – SCSS stylesheets for website and POS.
- `erpnext/public/sounds` – notification sounds.

## Templates

- `erpnext/templates` – Jinja templates and utility functions.
- `erpnext/templates/emails` – email templates.
- `erpnext/templates/includes` – partial HTML snippets.
- `erpnext/templates/pages` – standard website pages.
- `erpnext/templates/generators` – templates for DocTypes that generate pages.
- `erpnext/templates/form_grid` – grid component templates.
- `erpnext/templates/print_formats` – default print formats.
- `erpnext/templates/utils.py` – helper utilities for templates.

## Website Routes

- `erpnext/www` – Python modules and HTML files mapped to website URLs.
- Specific routes like `www/support` and `www/all-products` live here.
- Additional route rules are configured in `erpnext/hooks.py`.

## Web Forms

- `erpnext/support/web_form` – public Issue form.
- `erpnext/projects/web_form` – Tasks form for project portal.
- `erpnext/utilities/web_form` – Addresses form and others.

## Portal & Shopping Cart

- `erpnext/portal` – portal homepages and related DocTypes.
- `erpnext/controllers/website_list_for_contact.py` – manages portal lists and permissions.
- `erpnext/shopping_cart` – shopping cart portal templates and `web_template` folder.
