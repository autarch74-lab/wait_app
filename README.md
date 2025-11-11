# wait_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Setup repository hooks

After cloning, run the following to enable the repository hooks:

PowerShell (recommended):
  pwsh -NoProfile -File scripts/setup-hooks.ps1

Or set hooks path manually:
  git config core.hooksPath .githooks

This ensures the pre-commit BOM-removal hook runs for all contributors.
