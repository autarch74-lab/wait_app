# scripts/remove-bom.ps1
param(
  [string]$Root = ".",
  [string[]]$Ext = @("*.toml","*.cfg","*.py","*.md","*.txt")
)

Get-ChildItem -Path $Root -Include $Ext -Recurse -File | ForEach-Object {
  $p = $_.FullName
  $bytes = [System.IO.File]::ReadAllBytes($p)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $new = $bytes[3..($bytes.Length-1)]
    [System.IO.File]::WriteAllBytes($p, $new)
    Write-Host "Removed BOM:" $p
  }
}