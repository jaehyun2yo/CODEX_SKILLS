# CODEX_SKILLS

Personal Codex setup for the current Superpowers + gstack + Compound Engineering workflow.

This repository intentionally does not vendor upstream plugin repositories or generated binaries. It stores only the durable customization layer and a reproducible installer:

- registers Superpowers and Compound Engineering marketplaces
- installs Compound Engineering agents for Codex
- installs gstack into `~/.gstack/repos/gstack`
- links gstack and Compound Engineering skills into `~/.codex/skills`
- installs the custom `superpowers-compound-review-loop` skill
- writes the global AGENTS hook that runs the custom compound step after Superpowers review cycles

## Install

From PowerShell:

```powershell
git clone https://github.com/jaehyun2yo/CODEX_SKILLS.git
cd CODEX_SKILLS
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Restart Codex after installation.

## What Is Custom

The custom integration is in:

```text
skills/superpowers-compound-review-loop/
templates/AGENTS.global.md
```

Do not edit vendored Superpowers, gstack, or Compound Engineering skill files for this behavior. Upstream packages can be updated independently; this custom skill remains the stable local hook.

## Verification

The installer checks:

- `~/.codex/config.toml` parses as TOML
- `ce-compound` exists
- `gstack-review` exists
- `superpowers-compound-review-loop` exists
- Compound Engineering agents exist
