<#
.SYNOPSIS
  Installs the Claude starter kit into a project.

.DESCRIPTION
  Copies template/ into the target project. Existing files are never overwritten,
  except kit-managed files (agents, skills, hooks) when -Update is given.
  An existing CLAUDE.md or .claude/settings.json is kept; the kit's version is written
  next to it (.claude/CLAUDE.kit-template.md, .claude/settings.kit.json) for /kit-setup to merge.

.EXAMPLE
  .\install.ps1 -Target C:\code\my-app
  .\install.ps1 -Target C:\code\my-app -Update
#>
param(
  [string]$Target = (Get-Location).Path,
  [switch]$Update
)

$ErrorActionPreference = 'Stop'
$KitRoot = $PSScriptRoot
$Template = Join-Path $KitRoot 'template'
$Target = (Resolve-Path -LiteralPath $Target).Path

if ($Target -eq $KitRoot) { throw 'Target is the kit itself. Pass -Target <project folder>.' }

# Files the user customises per project: never overwritten, even with -Update.
$UserOwned = @{
  'CLAUDE.md'              = '.claude/CLAUDE.kit-template.md'
  '.claude/settings.json'  = '.claude/settings.kit.json'
}

$counts = @{ new = 0; updated = 0; skipped = 0; sidecar = 0 }
$firstInstall = -not (Test-Path -LiteralPath (Join-Path $Target '.claude/kit-version'))

Get-ChildItem -LiteralPath $Template -Recurse -File -Force | ForEach-Object {
  $rel = $_.FullName.Substring($Template.Length + 1).Replace('\', '/')
  $dest = Join-Path $Target $rel

  if (Test-Path -LiteralPath $dest) {
    if ($UserOwned.ContainsKey($rel) -and -not $firstInstall) {
      Write-Host "  [keep]    $rel (yours; compare with template/$rel for new kit changes)" -ForegroundColor DarkGray
      $counts.skipped++
    } elseif ($UserOwned.ContainsKey($rel)) {
      $sidecar = Join-Path $Target $UserOwned[$rel]
      New-Item -ItemType Directory -Force -Path (Split-Path $sidecar) | Out-Null
      Copy-Item -LiteralPath $_.FullName -Destination $sidecar -Force
      Write-Host "  [merge]   $rel exists -> kit version saved as $($UserOwned[$rel])" -ForegroundColor Yellow
      $counts.sidecar++
    } elseif ($Update) {
      Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
      Write-Host "  [update]  $rel" -ForegroundColor Cyan
      $counts.updated++
    } else {
      Write-Host "  [skip]    $rel (exists; use -Update to refresh kit files)" -ForegroundColor DarkGray
      $counts.skipped++
    }
  } else {
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $dest
    Write-Host "  [new]     $rel" -ForegroundColor Green
    $counts.new++
  }
}

# Record which kit version is installed.
$utf8 = New-Object System.Text.UTF8Encoding($false)  # no BOM; PowerShell 5.1's -Encoding utf8 adds one
$version = (Get-Content -LiteralPath (Join-Path $KitRoot 'VERSION') -Raw).Trim()
[System.IO.File]::WriteAllText((Join-Path $Target '.claude/kit-version'), "$version`n", $utf8)

# Keep personal files out of git.
$gitignore = Join-Path $Target '.gitignore'
$existing = if (Test-Path -LiteralPath $gitignore) { Get-Content -LiteralPath $gitignore } else { @() }
$missing = @('CLAUDE.local.md', '.claude/settings.local.json') | Where-Object { $existing -notcontains $_ }
if ($missing) {
  $block = (@('', '# Claude Code (personal, not shared)') + $missing) -join "`n"
  [System.IO.File]::AppendAllText($gitignore, "$block`n", $utf8)
  Write-Host "  [gitignore] added: $($missing -join ', ')" -ForegroundColor Green
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Warning 'Node.js not found. The command guard hook needs Node 18+ on PATH; without it the hook is skipped.'
}

Write-Host ""
Write-Host "Kit $version installed into $Target"
Write-Host "  new: $($counts.new)  updated: $($counts.updated)  skipped: $($counts.skipped)  to merge: $($counts.sidecar)"
Write-Host ""
Write-Host "Next: open Claude Code in that folder and run /kit-setup"
