Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$HomeDir = [Environment]::GetFolderPath("UserProfile")
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HomeDir ".codex" }
$CodexSkills = Join-Path $CodexHome "skills"
$ConfigPath = Join-Path $CodexHome "config.toml"
$GStackRepo = Join-Path $HomeDir ".gstack\repos\gstack"

function Step($Message) {
  Write-Host ""
  Write-Host "==> $Message"
}

function Run($File, [string[]]$CommandArgs, [switch]$AllowFailure) {
  & $File @CommandArgs
  $code = $LASTEXITCODE
  if ($code -ne 0 -and -not $AllowFailure) {
    throw "$File $($CommandArgs -join ' ') failed with exit code $code"
  }
  return $code
}

function Ensure-Command($Name) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required command not found: $Name"
  }
}

function Ensure-Dir($Path) {
  New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Write-Utf8NoBom($Path, $Content) {
  [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Set-DirJunction($Target, $Link) {
  if (-not (Test-Path -LiteralPath $Target)) {
    Write-Warning "Missing target, skipping junction: $Target"
    return
  }

  if (Test-Path -LiteralPath $Link) {
    $item = Get-Item -LiteralPath $Link -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      try {
        Remove-Item -LiteralPath $Link -Recurse -Force
      } catch {
        [System.IO.Directory]::Delete($Link)
      }
    } else {
      Write-Warning "Existing non-link path, skipping: $Link"
      return
    }
  }

  Ensure-Dir (Split-Path -Parent $Link)
  New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
}

function Copy-File($Source, $Destination) {
  if (-not (Test-Path -LiteralPath $Source)) {
    Write-Warning "Missing source, skipping copy: $Source"
    return
  }

  Ensure-Dir (Split-Path -Parent $Destination)
  Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Ensure-TomlEnabledTable($TableName) {
  Ensure-Dir $CodexHome
  if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-Utf8NoBom $ConfigPath ""
  }

  $content = Get-Content -LiteralPath $ConfigPath -Raw
  $header = "[$TableName]"

  if ($content.Contains($header)) {
    $pattern = "(?ms)^" + [regex]::Escape($header) + "\r?\n(?<body>.*?)(?=^\[|\z)"
    $content = [regex]::Replace($content, $pattern, {
      param($match)
      $body = $match.Groups["body"].Value
      if ($body -match "(?m)^enabled\s*=") {
        $body = [regex]::Replace($body, "(?m)^enabled\s*=.*$", "enabled = true")
      } else {
        $body = "enabled = true`n" + $body
      }
      return "$header`n$body"
    }, 1)
  } else {
    if ($content.Length -gt 0 -and -not $content.EndsWith("`n")) {
      $content += "`n"
    }
    $content += "`n$header`nenabled = true`n"
  }

  Write-Utf8NoBom $ConfigPath $content
}

function Register-Marketplaces() {
  Step "Register Codex marketplaces"
  Run "codex" @("plugin", "marketplace", "add", "obra/superpowers") -AllowFailure | Out-Null
  Run "codex" @("plugin", "marketplace", "add", "EveryInc/compound-engineering-plugin") -AllowFailure | Out-Null

  Ensure-TomlEnabledTable 'plugins."superpowers@superpowers-marketplace"'
  Ensure-TomlEnabledTable 'plugins."compound-engineering@compound-engineering-plugin"'
}

function Install-CompoundEngineering() {
  Step "Install Compound Engineering agents"
  $existingSkill = Join-Path $CodexSkills "ce-compound\SKILL.md"
  $existingAgents = Join-Path $CodexHome "agents\compound-engineering"
  if ((Test-Path -LiteralPath $existingSkill) -and (Test-Path -LiteralPath $existingAgents)) {
    Write-Host "Compound Engineering already installed; skipping bunx install"
    return
  }

  Run "bunx" @("@every-env/compound-plugin", "install", "compound-engineering", "--to", "codex") | Out-Null

  $cePlugin = Join-Path $CodexHome ".tmp\marketplaces\compound-engineering-plugin\plugins\compound-engineering"
  $ceSkills = Join-Path $cePlugin "skills"
  if (-not (Test-Path -LiteralPath $ceSkills)) {
    throw "Compound Engineering marketplace skills not found: $ceSkills"
  }

  foreach ($dir in Get-ChildItem -LiteralPath $ceSkills -Directory) {
    if (Test-Path -LiteralPath (Join-Path $dir.FullName "SKILL.md")) {
      Set-DirJunction $dir.FullName (Join-Path $CodexSkills $dir.Name)
    }
  }

  $cacheRoot = Join-Path $CodexHome "plugins\cache\compound-engineering-plugin\compound-engineering"
  Ensure-Dir $cacheRoot
  Set-DirJunction $cePlugin (Join-Path $cacheRoot "3.8.2")
}

function Install-GStackRepo() {
  Step "Install or update gstack"
  Ensure-Dir (Split-Path -Parent $GStackRepo)

  if (Test-Path -LiteralPath (Join-Path $GStackRepo ".git")) {
    Run "git" @("-C", $GStackRepo, "pull", "--ff-only") | Out-Null
  } elseif (Test-Path -LiteralPath $GStackRepo) {
    $backup = "$GStackRepo.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Move-Item -LiteralPath $GStackRepo -Destination $backup
    Run "git" @("clone", "--single-branch", "--depth", "1", "https://github.com/garrytan/gstack.git", $GStackRepo) | Out-Null
  } else {
    Run "git" @("clone", "--single-branch", "--depth", "1", "https://github.com/garrytan/gstack.git", $GStackRepo) | Out-Null
  }

  Push-Location $GStackRepo
  try {
    Run "bun" @("install") | Out-Null
    Run "bun" @("run", "gen:skill-docs", "--host", "codex") | Out-Null

    $buildCode = Run "bun" @("run", "build") -AllowFailure
    if ($buildCode -ne 0) {
      Write-Warning "gstack full build failed; running Windows-compatible fallback build"
      Ensure-Dir (Join-Path $GStackRepo "browse\dist")
      Ensure-Dir (Join-Path $GStackRepo "design\dist")
      Ensure-Dir (Join-Path $GStackRepo "make-pdf\dist")

      Run "bun" @("build", "browse/src/cli.ts", "--compile", "--outfile", "browse/dist/browse") | Out-Null
      Run "bun" @("build", "browse/src/find-browse.ts", "--compile", "--outfile", "browse/dist/find-browse") | Out-Null
      Run "bun" @("build", "design/src/cli.ts", "--compile", "--outfile", "design/dist/design") | Out-Null
      Run "bun" @("build", "make-pdf/src/cli.ts", "--compile", "--outfile", "make-pdf/dist/pdf") | Out-Null
      Run "bun" @("build", "bin/gstack-global-discover.ts", "--compile", "--outfile", "bin/gstack-global-discover") | Out-Null
      Build-GStackNodeServer
      Copy-WindowsExeAliases
    }
  } finally {
    Pop-Location
  }
}

function Build-GStackNodeServer() {
  Run "bun" @(
    "build", "browse/src/server.ts",
    "--target=node",
    "--outfile", "browse/dist/server-node.mjs",
    "--external", "playwright",
    "--external", "playwright-core",
    "--external", "diff",
    "--external", "bun:sqlite",
    "--external", "@ngrok/ngrok"
  ) | Out-Null

  $dist = Join-Path $GStackRepo "browse\dist"
  $src = Join-Path $GStackRepo "browse\src"
  $server = Join-Path $dist "server-node.mjs"
  $content = Get-Content -LiteralPath $server -Raw
  $content = $content -replace 'import\.meta\.dir', '__browseNodeSrcDir'
  $content = $content -replace 'import \{ Database \} from "bun:sqlite";', 'const Database = null; // bun:sqlite stubbed on Node'
  $parts = $content -split "`r?`n", 2
  $header = @(
    $parts[0],
    '// Windows Node.js compatibility (auto-generated)',
    'import { fileURLToPath as _ftp } from "node:url";',
    'import { dirname as _dn } from "node:path";',
    'const __browseNodeSrcDir = _dn(_dn(_ftp(import.meta.url))) + "/src";',
    '{ const _r = createRequire(import.meta.url); _r("./bun-polyfill.cjs"); }',
    '// end compatibility'
  ) -join "`n"

  $newContent = if ($parts.Count -gt 1) { $header + "`n" + $parts[1] } else { $header }
  Set-Content -LiteralPath $server -Value $newContent -Encoding utf8
  Copy-Item -LiteralPath (Join-Path $src "bun-polyfill.cjs") -Destination (Join-Path $dist "bun-polyfill.cjs") -Force
}

function Copy-WindowsExeAliases() {
  $aliases = @(
    @("browse\dist\browse.exe", "browse\dist\browse"),
    @("browse\dist\find-browse.exe", "browse\dist\find-browse"),
    @("design\dist\design.exe", "design\dist\design"),
    @("make-pdf\dist\pdf.exe", "make-pdf\dist\pdf"),
    @("bin\gstack-global-discover.exe", "bin\gstack-global-discover")
  )

  foreach ($pair in $aliases) {
    $src = Join-Path $GStackRepo $pair[0]
    $dst = Join-Path $GStackRepo $pair[1]
    if (Test-Path -LiteralPath $src) {
      Copy-Item -LiteralPath $src -Destination $dst -Force
    }
  }
}

function Link-GStackSkills() {
  Step "Link gstack Codex skills"
  Ensure-Dir $CodexSkills

  $codexGStack = Join-Path $CodexSkills "gstack"
  if (Test-Path -LiteralPath $codexGStack) {
    $item = Get-Item -LiteralPath $codexGStack -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      Remove-Item -LiteralPath $codexGStack -Force
    } elseif ((Get-ChildItem -LiteralPath $codexGStack -Force -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
      Remove-Item -LiteralPath $codexGStack -Recurse -Force
    }
  }
  Ensure-Dir $codexGStack

  Copy-File (Join-Path $GStackRepo ".agents\skills\gstack\SKILL.md") (Join-Path $codexGStack "SKILL.md")
  Set-DirJunction (Join-Path $GStackRepo "bin") (Join-Path $codexGStack "bin")
  Set-DirJunction (Join-Path $GStackRepo "browse\dist") (Join-Path $codexGStack "browse\dist")
  Set-DirJunction (Join-Path $GStackRepo "browse\bin") (Join-Path $codexGStack "browse\bin")
  Copy-File (Join-Path $GStackRepo ".agents\skills\gstack-upgrade\SKILL.md") (Join-Path $codexGStack "gstack-upgrade\SKILL.md")

  foreach ($file in @("checklist.md", "design-checklist.md", "greptile-triage.md", "TODOS-format.md")) {
    Copy-File (Join-Path $GStackRepo "review\$file") (Join-Path $codexGStack "review\$file")
  }
  Copy-File (Join-Path $GStackRepo "ETHOS.md") (Join-Path $codexGStack "ETHOS.md")

  foreach ($dir in Get-ChildItem -LiteralPath (Join-Path $GStackRepo ".agents\skills") -Directory -Filter "gstack*") {
    if ($dir.Name -eq "gstack") { continue }
    if (Test-Path -LiteralPath (Join-Path $dir.FullName "SKILL.md")) {
      Set-DirJunction $dir.FullName (Join-Path $CodexSkills $dir.Name)
    }
  }
}

function Install-CustomSkills() {
  Step "Install custom skills"
  $sourceRoot = Join-Path $RepoRoot "skills"
  foreach ($dir in Get-ChildItem -LiteralPath $sourceRoot -Directory) {
    if (-not (Test-Path -LiteralPath (Join-Path $dir.FullName "SKILL.md"))) {
      continue
    }

    $dest = Join-Path $CodexSkills $dir.Name
    if (Test-Path -LiteralPath $dest) {
      Remove-Item -LiteralPath $dest -Recurse -Force
    }
    Ensure-Dir (Split-Path -Parent $dest)
    Copy-Item -LiteralPath $dir.FullName -Destination $dest -Recurse -Force
  }
}

function Install-GlobalAgentsHook() {
  Step "Install global AGENTS hook"
  $source = Join-Path $RepoRoot "templates\AGENTS.global.md"
  $dest = Join-Path $HomeDir "AGENTS.md"
  if (Test-Path -LiteralPath $dest) {
    $backup = "$dest.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -LiteralPath $dest -Destination $backup -Force
  }
  Copy-Item -LiteralPath $source -Destination $dest -Force
}

function Install-CodexAgentsGuidance() {
  Step "Install Codex AGENTS guidance"
  $source = Join-Path $RepoRoot "templates\AGENTS.codex.md"
  $dest = Join-Path $CodexHome "AGENTS.md"
  if (Test-Path -LiteralPath $dest) {
    $backup = "$dest.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -LiteralPath $dest -Destination $backup -Force
  }
  Copy-Item -LiteralPath $source -Destination $dest -Force
}

function Verify-Install() {
  Step "Verify install"
  python -c "import tomllib, pathlib; tomllib.loads(pathlib.Path(r'$ConfigPath').read_text(encoding='utf-8')); print('config.toml valid')"

  $required = @(
    (Join-Path $CodexSkills "ce-compound\SKILL.md"),
    (Join-Path $CodexSkills "gstack-review\SKILL.md"),
    (Join-Path $CodexSkills "global-orchestrator\SKILL.md"),
    (Join-Path $CodexSkills "superpowers-compound-review-loop\SKILL.md"),
    (Join-Path $CodexHome "agents\compound-engineering")
  )

  foreach ($path in $required) {
    if (-not (Test-Path -LiteralPath $path)) {
      throw "Verification failed, missing: $path"
    }
  }

  Write-Host "Install verified. Restart Codex to load the new skills."
}

Ensure-Command "git"
Ensure-Command "codex"
Ensure-Command "bun"
Ensure-Command "bunx"
Ensure-Command "python"

Ensure-Dir $CodexHome
Ensure-Dir $CodexSkills

Register-Marketplaces
Install-CompoundEngineering
Install-GStackRepo
Link-GStackSkills
Install-CustomSkills
Install-GlobalAgentsHook
Install-CodexAgentsGuidance
Verify-Install
