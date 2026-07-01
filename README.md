# thiago-dev-template

Template de produtividade para projetos Better-T-Stack com Claude Code, GitHub Copilot e Hermes Agent.

Instala em qualquer projeto novo: agents, hooks, skills, OpenSpec, `CLAUDE.md` (Claude Code), `AGENTS.md` (multi-tool) e `.github/copilot-instructions.md` (Copilot Agent) configurados para a stack padrão.

---

## Stack padrão

| Camada | Tecnologia |
|---|---|
| Frontend | TanStack Router + React 19 |
| Backend | Hono |
| Runtime | Bun |
| API | tRPC v11 |
| ORM | Drizzle |
| Banco | PostgreSQL (Docker local, Railway produção) |
| Auth | Better-Auth |
| Monorepo | Turborepo |
| Linting | Ultracite |
| Validação | Zod 4 (`zod/v4`) |
| Testes | vitest via `bun test` |
| Observabilidade | evlog |

> **Stack confirmada via better-t-stack wizard em 01/jul/2026.** Não trocar componentes sem aprovação explícita. **NUNCA** usar Neon ou Supabase — PostgreSQL é self-managed.

---

## O que este template instala

### Arquivos de instrução por ferramenta

| Arquivo | Quem lê automaticamente | Conteúdo |
|---|---|---|
| `CLAUDE.md` | Claude Code | Instruções detalhadas (stack, convenções, anti-patterns, OpenSpec workflow, paralelismo) |
| `AGENTS.md` | Aider, Continue, Cursor (via @-mention), Codex | Versão multi-tool do workflow |
| `.github/copilot-instructions.md` | VSCode Copilot Agent | Versão otimizada pro Copilot |
| `openspec/config.yaml` | OpenSpec CLI (contexto em toda criação de artifact) | Stack + convenções injetadas em cada spec |

### `.claude/agents/`
Subagentes especializados que o Claude Code pode invocar:
- `code-reviewer` — revisão de código em 9 pontos
- `code-simplifier` — reduz complexidade e aninhamento
- `fullstack-builder` — gera features fullstack completas
- `test-writer` — escreve testes automatizados
- `security-reviewer` — revisão adversarial de segurança (OWASP + stack específico)

### `.claude/hooks/`
Automações que rodam em momentos específicos do ciclo de desenvolvimento:
- `auto-format` — formata com Ultracite/Biome após edições
- `db-schema-reminder` — lembra de rodar migrations após mudanças no schema
- `git-context` — injeta contexto do branch atual no agente
- `post-implement-review` — aciona revisão automática quando 3+ arquivos TypeScript são modificados
- `protect-sensitive` — bloqueia commits com secrets ou .env
- `session-context` — injeta contexto do projeto no início de cada sessão
- `stop-notify` — notificação no Windows quando o agente termina uma tarefa

### `.claude/skills/`
23 skills cobrindo toda a stack:

**Da fadhlirahim/claude-starter-kit** (feito para esta stack exata):
`add-feature`, `add-trpc-router`, `clean-branches`, `commit`, `compound`, `debug`, `docs`, `migrate`, `push`, `refactor`, `review`, `scaffold`, `setup`, `simplify`, `test`

**Da Mindrally/skills:**
`trpc`, `drizzle-orm`, `postgresql-best-practices`, `react`

**Da jezweb/claude-skills:**
`d1-drizzle-schema`, `hono-api-scaffolder`, `tanstack-start`, `react-patterns`

**Da hmohamed01:**
`project-scaffolding`

### `.github/prompts/` e `.github/skills/`
OpenSpec configurado para GitHub Copilot:
- `opsx-propose` — cria spec de nova feature
- `opsx-apply` — implementa a spec
- `opsx-explore` — investiga problema antes de propor solução
- `opsx-archive` — arquiva feature concluída

### `openspec/`
Estrutura pronta para Spec-Driven Development:
- `changes/` — features pendentes de implementação
- `specs/` — especificações como fonte da verdade
- `config.yaml` — stack + convenções + regras por artifact

---

## Como usar

### Fluxo mais comum — repositório já criado no GitHub

Você já criou o repositório no GitHub, clonou na máquina e está dentro da pasta. Basta rodar dois comandos:

```powershell
# 1. Instalar a stack Better-T-Stack na pasta atual
bun create better-t-stack@latest . --frontend tanstack-router --backend hono --runtime bun --api trpc --auth better-auth --payments none --database postgres --orm drizzle --db-setup docker --package-manager bun --git --web-deploy none --server-deploy none --install --addons evlog skills turborepo ultracite --examples none

# 2. Instalar agents, hooks, skills, OpenSpec, CLAUDE.md, AGENTS.md e copilot-instructions
irm https://raw.githubusercontent.com/devturco/thiago-dev-template/main/setup.ps1 | iex
```

O `.` no comando do Better-T-Stack instala tudo na pasta atual sem criar subpasta.

### Projeto novo do zero (sem repositório prévio)

```powershell
# 1. Criar o projeto com Better-T-Stack (cria a pasta automaticamente)
bun create better-t-stack@latest meu-app --frontend tanstack-router --backend hono --runtime bun --api trpc --auth better-auth --payments none --database postgres --orm drizzle --db-setup docker --package-manager bun --git --web-deploy none --server-deploy none --install --addons evlog skills turborepo ultracite --examples none

# 2. Entrar na pasta
cd meu-app

# 3. Instalar agents, hooks, skills, OpenSpec, CLAUDE.md, AGENTS.md e copilot-instructions
irm https://raw.githubusercontent.com/devturco/thiago-dev-template/main/setup.ps1 | iex
```

### Projeto existente (adicionar setup sem reinstalar stack)

```powershell
# Dentro da pasta do projeto existente
irm https://raw.githubusercontent.com/devturco/thiago-dev-template/main/setup.ps1 | iex
```

O script nunca sobrescreve um `CLAUDE.md` que já existe no projeto.

---

## Fluxo de trabalho padrão (1 feature)

```
Nova feature
      ↓
/opsx:propose [descrição]     ← OpenSpec cria a spec (proposal.md + design.md + tasks.md)
      ↓
GATE: revisar proposal.md + design.md  ← VOCÊ precisa aprovar antes do apply
      ↓
/opsx:apply                   ← implementa seguindo tasks.md
      ↓
Code review (entre tasks ou antes do PR)
      ↓
bun typecheck && bun check && bun test
      ↓
git push -u origin HEAD && gh pr create --fill
      ↓
/opsx:archive                 ← arquiva a feature concluída (após merge)
      ↓
Deploy no Railway
```

---

## Fluxo paralelo (2+ features independentes)

Quando você tem **2 ou mais features independentes** pra entregar (não compartilham arquivos/schema), use worktrees paralelos:

```bash
# 1. Cria um worktree por feature
git worktree add .worktrees/<repo>-<feat-a> -b feat/a
git worktree add .worktrees/<repo>-<feat-b> -b feat/b
git worktree add .worktrees/<repo>-<feat-c> -b feat/c

# 2. Em cada worktree, abre o agente (Claude Code, Copilot Agent, Hermes, etc.)
cd .worktrees/<repo>-feat-a && claude    # sessão A
cd .worktrees/<repo>-feat-b && claude    # sessão B
cd .worktrees/<repo>-feat-c && claude    # sessão C

# 3. Cada sessão implementa sua feature de forma isolada
#    Cada agente recebe brief com escopo + arquivos proibidos + DoD

# 4. Quando cada uma termina, push + PR separado
cd .worktrees/<repo>-feat-a
bun typecheck && bun check && bun test
git push -u origin feat/a
gh pr create --fill
# Repete pra B e C
```

**Hard-gate:** rode o **independence audit** antes de paralelizar. Se as features compartilham schema/arquivo/port, **serialize** em vez de paralelizar. Detalhes em `CLAUDE.md` seção "Parallel Features Workflow".

**Quando usar:** "tenho 2+ features pra entregar", "paraleliza X, Y, Z", "em paralelo".

**Quando NÃO usar:** 1 feature só, features com dependência, fix pequeno, refactor em arquivo compartilhado.

---

## Comandos principais no Claude Code

| Comando | O que faz |
|---|---|
| `/opsx:propose` | Cria spec de nova feature |
| `/opsx:apply` | Implementa a spec atual |
| `/opsx:archive` | Arquiva feature concluída |
| `/scaffold` | Gera Zod + Drizzle schema + tRPC router + página + componentes |
| `/review` | Revisão de código em 9 pontos |
| `/security-reviewer` | Revisão adversarial de segurança |
| `/push` | Commit + push + PR com descrição automática |

---

## Skills globais recomendadas

Instale estas uma vez para ficarem disponíveis em todos os projetos:

```powershell
# Via ccpi (se disponível)
ccpi install typescript
ccpi install docker
ccpi install owasp-security

# Ou copiar manualmente para:
# C:\Users\SEU-USUARIO\.claude\skills\
```

---

## Atualizar o template em projetos existentes

```powershell
# Rodar setup novamente — sobrescreve tudo exceto CLAUDE.md
irm https://raw.githubusercontent.com/devturco/thiago-dev-template/main/setup.ps1 | iex
```

> **Mudou `AGENTS.md` ou `copilot-instructions.md` no template?** Esses arquivos **não são protegidos** pelo setup, então serão sobrescritos na próxima execução. Use isso pra puxar atualizações. `CLAUDE.md` continua protegido (não sobrescreve) pra preservar customizações locais.

---

## Estrutura do repositório

```
thiago-dev-template/
├── .claude/
│   ├── agents/
│   │   ├── code-reviewer.md
│   │   ├── code-simplifier.md
│   │   ├── fullstack-builder.md
│   │   ├── security-reviewer.md
│   │   └── test-writer.md
│   ├── hooks/
│   │   ├── auto-format.sh
│   │   ├── db-schema-reminder.sh
│   │   ├── git-context.sh
│   │   ├── notify-windows.ps1
│   │   ├── post-implement-review.sh
│   │   ├── protect-sensitive.sh
│   │   ├── session-context.sh
│   │   └── stop-notify.sh
│   ├── skills/
│   │   └── [23 skills]
│   └── settings.json
├── .github/
│   ├── prompts/
│   │   ├── opsx-apply.prompt.md
│   │   ├── opsx-archive.prompt.md
│   │   ├── opsx-explore.prompt.md
│   │   └── opsx-propose.prompt.md
│   ├── skills/
│   │   ├── openspec-apply-change/
│   │   ├── openspec-archive-change/
│   │   ├── openspec-explore/
│   │   └── openspec-propose/
│   └── copilot-instructions.md     ← VSCode Copilot Agent
├── openspec/
│   ├── changes/
│   │   └── archive/
│   ├── specs/
│   └── config.yaml                 ← stack + convenções injetadas em specs
├── AGENTS.md                       ← multi-tool (Aider, Continue, Cursor, Codex)
├── CLAUDE.md                       ← Claude Code (protegido contra sobrescrita)
├── setup.ps1
└── README.md
```