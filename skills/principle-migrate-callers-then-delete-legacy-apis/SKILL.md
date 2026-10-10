---
name: "principle-migrate-callers-then-delete-legacy-apis"
description: "Explicit request or pstack routing only. Plan caller migration and legacy removal when replacing an internal API."
license: MIT
metadata:
  pstack-distilled-origin: "cursor/plugins/pstack/skills/principle-migrate-callers-then-delete-legacy-apis"
  pstack-distilled-activation: "explicit"
---
# Migrate Callers Then Delete Legacy APIs

When we decide a new API is the right design, migrate callers and remove the old API in the same refactor wave instead of preserving compatibility layers.

**Rule:**
- Do not keep legacy API paths only because internal callers still exist
- Inventory callers, migrate them, and delete the old API immediately
- Treat temporary adapters as exceptional and time-boxed, not default architecture
- Update tests to assert the new contract, and delete tests that only protect pre-refactor implementation details

**When the blast radius fans too wide for one wave** (a rename or retype that breaks thousands of call sites at once), sequence it expand-contract instead. Expand: add the new form beside the old so nothing breaks. Migrate: move call sites in batches sized by blast radius (per package, per directory), each batch its own verifiable step, CI green batch to batch because the old form still exists. Contract: delete the old form once no caller remains. When even the batches cannot stay green alone, keep the sequence but let them share an integration branch, with green promised only at the final integrate-and-verify step.

**When this applies:**
- No external users depend on backward compatibility
- The project can absorb coordinated breaking changes
- The new API is part of a simplification or refactor initiative

Keeping both old and new APIs creates dual-path complexity, slows cleanup, and makes the codebase feel append-only.
