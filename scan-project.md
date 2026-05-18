# Deep Scan Project — Auto-populate Agent Configuration

> **Khi nào chạy**: Sau khi `bash setup.sh` tạo xong skeleton files.
> **Ai chạy**: Bất kỳ AI agent nào (Claude, Gemini, Codex). Copy prompt bên dưới vào agent.
> **Kết quả**: Agent tự động scan codebase và populate tất cả markdown files.

---

## Prompt (copy từ đây đến hết file và paste vào AI agent)

Scan this project codebase and auto-populate the agent configuration files.

### Step 1: Deep Scan

Analyze the following to understand the project:

1. **package.json** (or equivalent: Cargo.toml, go.mod, requirements.txt, pubspec.yaml) — name, dependencies, devDependencies, scripts
2. **tsconfig.json / jsconfig.json / build config** — language settings, strict mode
3. **Project structure** — list top-level dirs in `src/` (or equivalent: `lib/`, `app/`, `pkg/`)
4. **Framework detection** — React Native? Next.js? Express? Flutter? Go? Python? Rust?
5. **State management** — Redux? Zustand? MobX? Context API? Pinia? Riverpod?
6. **Testing** — Jest? Vitest? Pytest? go test? What test runner and config?
7. **Linting** — ESLint? Prettier? Biome? golangci-lint? clippy?
8. **CI/CD** — GitHub Actions? GitLab CI? Fastlane? Dockerfile?
9. **Key patterns** — Scan 3-5 representative files to understand coding conventions:
   - Component style (functional vs class? StyleSheet vs Tailwind?)
   - API layer (Axios? Fetch? GraphQL client? gRPC?)
   - File naming (kebab-case? PascalCase? camelCase? snake_case?)
   - Export style (default export? named export? barrel files?)
10. **Existing documentation** — README.md, CONTRIBUTING.md, or existing instruction files?

### Step 2: Generate & Populate Files

Using scan results, update these files:

#### memory/COMPACT.md

Fill in all placeholder sections:
- **Project**: one-line tech stack summary (e.g. "React Native 0.75.4 · TypeScript strict · Redux+Saga · Zustand · React Query")
- **Active Task**: leave as (none)
- **Critical Rules**: extract top 3-5 coding patterns from codebase scan
- **Blockers**: any setup issues detected (missing scripts, broken configs)
- **Last Session**: leave as (no sessions yet)

#### memory/context.md

Fill in:
- **Tech Stack Summary**: exact versions from package.json / lock file
- **Known Issues**: any issues detected during scan (missing test config, lint errors, etc.)

#### CLAUDE.md (create or update)

If file contains `{{PLACEHOLDER}}` variables, replace them with scan results:
- `{{PROJECT_NAME}}` → actual project name from package.json
- `{{PROJECT_DESCRIPTION}}` → one paragraph describing the project
- `{{TECH_STACK}}` → tech stack string
- `{{PROJECT_STRUCTURE}}` → tree view of src/ top-level dirs
- `{{CODE_STYLE_LANGUAGE}}` → language rules extracted from codebase
- `{{CODE_STYLE_COMPONENTS}}` → component/module patterns
- `{{NAMING_CONVENTIONS}}` → file/variable naming patterns
- `{{COMMANDS}}` → commands from package.json scripts

If file already has real content (no placeholders), MERGE new findings — don't overwrite existing rules.

#### AGENTS.md (create or update)

Same replacement as CLAUDE.md but customized for Codex agent.

#### GEMINI.md (create or update)

Same replacement as CLAUDE.md but customized for Gemini agent.

### Step 3: Verify

After generating, show this summary:

| File | Status | Key Change |
|------|--------|------------|
| memory/COMPACT.md | Updated | Tech stack + critical rules filled |
| memory/context.md | Updated | Versions + scripts detected |
| CLAUDE.md | Created/Updated | Project-specific rules generated |
| AGENTS.md | Created/Updated | Project-specific rules generated |
| GEMINI.md | Created/Updated | Project-specific rules generated |

Ask user to review before committing.

### Important Rules

- Do NOT hardcode project-specific info in memory/README.md — it's generic
- Do NOT modify memory/lessons-learned.md or memory/decisions.md — append-only, start empty
- Do NOT modify memory/INDEX.md — starts empty, grows organically
- Keep instruction files under 500 lines — focus on what differs from defaults
- If instruction files already have real content, MERGE — don't overwrite existing rules
- Detect primary language of the codebase and write code examples accordingly

---

## Cách dùng

### Trên máy mới (project mới hoàn toàn):

```bash
# 1. Clone agent-skills repo
git clone https://github.com/<your-username>/agent-skills.git

# 2. Chạy setup (tạo skeleton)
cd /path/to/your-new-project
bash /path/to/agent-skills/setup.sh

# 3. Mở AI agent (Claude/Gemini/Codex) và paste prompt ở trên
#    Agent sẽ tự scan và populate tất cả files
```

### Trên project đã có instruction files:

```bash
# 1. Chạy setup (chỉ tạo memory/ nếu chưa có)
bash /path/to/agent-skills/setup.sh

# 2. Paste prompt vào agent — nó sẽ MERGE vào files hiện có
```
