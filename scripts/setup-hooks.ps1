# scripts/setup-hooks.ps1
# Run this once after cloning to enable repository hooks
# Usage: pwsh -NoProfile -File scripts/setup-hooks.ps1

# Ensure we are in a git repo
$repo = git rev-parse --show-toplevel 2>$null
if (-not $repo) {
  Write-Error "Not inside a git repository."
  exit 1
}
Set-Location $repo

# Point git to the repository hooks folder
git config core.hooksPath .githooks

# Ensure pre-commit wrapper is executable in the index (so Git preserves the +x bit)
if (Test-Path .githooks/pre-commit) {
  git update-index --add --chmod=+x .githooks/pre-commit 2>$null
  Write-Host "Enabled executable bit for .githooks/pre-commit"
} else {
  Write-Host ".githooks/pre-commit not found. Make sure .githooks exists in the repo."
}

Write-Host "core.hooksPath set to .githooks. To undo: git config --unset core.hooksPath"
