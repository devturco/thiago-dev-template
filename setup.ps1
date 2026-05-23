# ============================================================
# setup.ps1 — Thiago Dev Template
# Instala .claude/, .github/ (OpenSpec), CLAUDE.md e openspec/
# no projeto atual a partir do repositório template no GitHub.
#
# USO:
#   1. Crie o projeto com Better-T-Stack
#   2. Entre na pasta do projeto
#   3. Execute: irm https://raw.githubusercontent.com/devturco/thiago-dev-template/main/setup.ps1 | iex
#      OU copie este arquivo para a pasta e rode: .\setup.ps1
# ============================================================

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/devturco/thiago-dev-template"
$REPO_RAW  = "https://raw.githubusercontent.com/devturco/thiago-dev-template/main"
$TEMP_DIR  = "$env:TEMP\thiago-dev-template"
$TARGET    = Get-Location

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Thiago Dev Template — Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Projeto alvo: $TARGET" -ForegroundColor Gray
Write-Host ""

# ------------------------------------------------------------
# 1. Clonar o template para pasta temporaria
# ------------------------------------------------------------
Write-Host "[1/5] Clonando template..." -ForegroundColor Yellow

if (Test-Path $TEMP_DIR) {
    Remove-Item -Recurse -Force $TEMP_DIR
}

git clone --depth 1 $REPO_URL $TEMP_DIR | Out-Null

if (-not (Test-Path $TEMP_DIR)) {
    Write-Host "ERRO: Falha ao clonar o repositorio. Verifique a URL e sua conexao." -ForegroundColor Red
    exit 1
}

Write-Host "  OK" -ForegroundColor Green

# ------------------------------------------------------------
# 2. Copiar .claude/ (agents, hooks, skills)
# ------------------------------------------------------------
Write-Host "[2/5] Instalando .claude/ (agents, hooks, skills)..." -ForegroundColor Yellow

$claudeSrc = "$TEMP_DIR\.claude"
$claudeDst = "$TARGET\.claude"

if (Test-Path $claudeSrc) {
    if (-not (Test-Path $claudeDst)) {
        New-Item -ItemType Directory -Path $claudeDst | Out-Null
    }
    Copy-Item -Recurse -Force "$claudeSrc\*" "$claudeDst\"
    Write-Host "  OK — agents, hooks e skills instalados" -ForegroundColor Green
} else {
    Write-Host "  AVISO: .claude/ nao encontrado no template" -ForegroundColor DarkYellow
}

# ------------------------------------------------------------
# 3. Copiar .github/ (OpenSpec prompts e skills)
# ------------------------------------------------------------
Write-Host "[3/5] Instalando .github/ (OpenSpec)..." -ForegroundColor Yellow

$githubSrc = "$TEMP_DIR\.github"
$githubDst = "$TARGET\.github"

if (Test-Path $githubSrc) {
    if (-not (Test-Path $githubDst)) {
        New-Item -ItemType Directory -Path $githubDst | Out-Null
    }
    Copy-Item -Recurse -Force "$githubSrc\*" "$githubDst\"
    Write-Host "  OK — prompts e skills do OpenSpec instalados" -ForegroundColor Green
} else {
    Write-Host "  AVISO: .github/ nao encontrado no template" -ForegroundColor DarkYellow
}

# ------------------------------------------------------------
# 4. Copiar openspec/ (changes, specs, config.yaml)
# ------------------------------------------------------------
Write-Host "[4/5] Instalando openspec/..." -ForegroundColor Yellow

$openspecSrc = "$TEMP_DIR\openspec"
$openspecDst = "$TARGET\openspec"

if (Test-Path $openspecSrc) {
    if (-not (Test-Path $openspecDst)) {
        New-Item -ItemType Directory -Path $openspecDst | Out-Null
    }
    Copy-Item -Recurse -Force "$openspecSrc\*" "$openspecDst\"
    Write-Host "  OK — openspec instalado" -ForegroundColor Green
} else {
    Write-Host "  AVISO: openspec/ nao encontrado no template" -ForegroundColor DarkYellow
}

# ------------------------------------------------------------
# 5. Copiar CLAUDE.md (sem sobrescrever se ja existir)
# ------------------------------------------------------------
Write-Host "[5/5] Instalando CLAUDE.md..." -ForegroundColor Yellow

$claudeMdSrc = "$TEMP_DIR\CLAUDE.md"
$claudeMdDst = "$TARGET\CLAUDE.md"

if (Test-Path $claudeMdSrc) {
    if (Test-Path $claudeMdDst) {
        Write-Host "  AVISO: CLAUDE.md ja existe — pulando para nao sobrescrever" -ForegroundColor DarkYellow
        Write-Host "  Referencia disponivel em: $claudeMdSrc" -ForegroundColor Gray
    } else {
        Copy-Item -Force $claudeMdSrc $claudeMdDst
        Write-Host "  OK" -ForegroundColor Green
    }
} else {
    Write-Host "  AVISO: CLAUDE.md nao encontrado no template" -ForegroundColor DarkYellow
}

# ------------------------------------------------------------
# Limpeza
# ------------------------------------------------------------
Remove-Item -Recurse -Force $TEMP_DIR

# ------------------------------------------------------------
# Resumo final
# ------------------------------------------------------------
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Setup concluido!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "O que foi instalado:" -ForegroundColor White
Write-Host "  .claude/agents/   — code-reviewer, code-simplifier, fullstack-builder, test-writer" -ForegroundColor Gray
Write-Host "  .claude/hooks/    — auto-format, db-schema-reminder, post-implement-review, e mais" -ForegroundColor Gray
Write-Host "  .claude/skills/   — 24 skills (trpc, drizzle, hono, tanstack, react, scaffold...)" -ForegroundColor Gray
Write-Host "  .github/prompts/  — OpenSpec: propose, apply, explore, archive" -ForegroundColor Gray
Write-Host "  .github/skills/   — OpenSpec: skills de workflow" -ForegroundColor Gray
Write-Host "  openspec/         — changes/, specs/, config.yaml" -ForegroundColor Gray
Write-Host "  CLAUDE.md         — instrucoes da stack para o agente" -ForegroundColor Gray
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor White
Write-Host "  1. Abra o terminal integrado do VSCode" -ForegroundColor Gray
Write-Host "  2. Inicie o Claude Code: claude" -ForegroundColor Gray
Write-Host "  3. Para nova feature: /opsx:propose [descricao]" -ForegroundColor Gray
Write-Host "  4. Para scaffoldar feature completa: /scaffold" -ForegroundColor Gray
Write-Host ""