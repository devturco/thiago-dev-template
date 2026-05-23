# thiago-dev-template

Template de produtividade para projetos Better-T-Stack com Claude Code e GitHub Copilot.

Instala em qualquer projeto novo: agents, hooks, skills, OpenSpec e CLAUDE.md configurados para a stack padrão.

---

## Stack padrão

| Camada | Tecnologia |
|---|---|
| Frontend | TanStack Router + React 19 |
| Backend | Hono |
| Runtime | Bun |
| API | tRPC |
| ORM | Drizzle |
| Banco | PostgreSQL (Docker local, Railway produção) |
| Auth | Better-Auth |
| Monorepo | Turborepo |
| Linting | Ultracite |
| Observabilidade | evlog + Axiom |

---

## O que este template instala

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
24 skills cobrindo toda a stack:

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
- `config.yaml` — configuração do OpenSpec

### `CLAUDE.md`
Instruções globais do projeto para o agente: stack, regras de desenvolvimento, o que sempre fazer, o que nunca fazer, fluxo de trabalho e comandos.

---

## Como usar

### Fluxo mais comum — repositório já criado no GitHub

Você já criou o repositório no GitHub, clonou na máquina e está dentro da pasta. Basta rodar dois comandos:

```powershell
# 1. Instalar a stack Better-T-Stack na pasta atual
bun create better-t-stack@latest . --frontend tanstack-router --backend hono --runtime bun --api trpc --auth better-auth --payments none --database postgres --orm drizzle --db-setup docker --package-manager bun --git --web-deploy none --server-deploy none --install --addons evlog skills turborepo ultracite --examples none

# 2. Instalar agents, hooks, skills, OpenSpec e CLAUDE.md
irm https://raw.githubusercontent.com/devturco/thiago-dev-template/main/setup.ps1 | iex
```

O `.` no comando do Better-T-Stack instala tudo na pasta atual sem criar subpasta.

### Projeto novo do zero (sem repositório prévio)

```powershell
# 1. Criar o projeto com Better-T-Stack (cria a pasta automaticamente)
bun create better-t-stack@latest meu-app --frontend tanstack-router --backend hono --runtime bun --api trpc --auth better-auth --payments none --database postgres --orm drizzle --db-setup docker --package-manager bun --git --web-deploy none --server-deploy none --install --addons evlog skills turborepo ultracite --examples none

# 2. Entrar na pasta
cd meu-app

# 3. Instalar agents, hooks, skills, OpenSpec e CLAUDE.md
irm https://raw.githubusercontent.com/devturco/thiago-dev-template/main/setup.ps1 | iex
```

### Projeto existente (adicionar setup sem reinstalar stack)

```powershell
# Dentro da pasta do projeto existente
irm https://raw.githubusercontent.com/devturco/thiago-dev-template/main/setup.ps1 | iex
```

O script nunca sobrescreve um `CLAUDE.md` que já existe no projeto.

---

## Fluxo de trabalho padrão

```
Nova feature
      ↓
/opsx:propose [descrição]     ← OpenSpec cria a spec
      ↓
Revisar arquivos em openspec/changes/
      ↓
/opsx:apply                   ← implementa seguindo a spec
      ↓
/security-reviewer            ← revisão adversarial de segurança
      ↓
bun run lint                  ← Ultracite/Biome
      ↓
/opsx:archive                 ← arquiva a feature concluída
      ↓
Deploy no Railway
```

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
.\setup.ps1
```

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
│   │   └── [24 skills]
│   └── settings.json
├── .github/
│   ├── prompts/
│   │   ├── opsx-apply.prompt.md
│   │   ├── opsx-archive.prompt.md
│   │   ├── opsx-explore.prompt.md
│   │   └── opsx-propose.prompt.md
│   └── skills/
│       ├── openspec-apply-change/
│       ├── openspec-archive-change/
│       ├── openspec-explore/
│       └── openspec-propose/
├── openspec/
│   ├── changes/
│   │   └── archive/
│   ├── specs/
│   └── config.yaml
├── CLAUDE.md
├── setup.ps1
└── README.md
```