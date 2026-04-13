# PAI Packs — Skills & Tools Reference

> Source: /Users/vetus/ai/Personal_AI_Infrastructure/Packs/
> Reviewed: 2026-04-14

PAI (Personal AI Infrastructure) by Daniel Miessler. 12 skill packs, each installable via `INSTALL.md`. All Claude Code native (`.claude/skills/`). Structured as SKILL.md + Workflows/ + Tools/.

---

## High-Value for DarkFact

### Research
- **Quick** (1 Perplexity agent, ~15s), **Standard** (3 agents: Perplexity + Claude + Gemini, ~30s), **Extensive** (12 agents, ~90s), **Deep Investigation** (iterative, hours)
- Fabric patterns integration (242+ prompts)
- Content retrieval with CAPTCHA bypass
- YouTube extraction via `fabric -y`
- URL verification protocol (prevents hallucinated links)
- Artifacts persist at `~/.claude/MEMORY/RESEARCH/{date}_{topic}/`

### Thinking
- **FirstPrinciples** — decompose → challenge assumptions → rebuild
- **IterativeDepth** — multi-angle, progressive deepening
- **BeCreative** — brainstorm, divergent, tree-of-thoughts
- **Council** — multi-agent debate from different perspectives
- **RedTeam** — adversarial critique, stress test, devil's advocate
- **WorldThreatModel** — future analysis, test ideas/investments
- **Science** — hypothesis → experiment → iterate

### Security
- **Recon** — port scan, subdomain, DNS, WHOIS, ASN, netblock
- **WebAssessment** — OWASP, pentest, ffuf, Playwright, threat model
- **PromptInjection** — jailbreak testing, guardrail bypass, LLM security
- **SECUpdates** — security news monitoring, tldrsec
- **AnnualReports** — threat landscape analysis, vendor reports

### ContextSearch
- `/context-search` and `/cs` slash commands
- Searches 8 sources: conversation history, git commits, project memory, session metadata, PRD content, session names, work directories
- Two modes: standalone (browse) and paired (search + execute task)
- Works on vanilla Claude Code, enhanced with PAI MEMORY
- **This solves our "cross-instance amnesia" problem differently than brain.py**

### Utilities (cherry-pick)
- **CreateCLI** — scaffold TypeScript CLI tools
- **CreateSkill** — scaffold new skills with proper structure
- **Delegation** — parallel agent teams, swarm patterns
- **PAIUpgrade** — self-improvement: check for new features, mine reflections
- **Evals** — test agent behavior, compare models/prompts, regression tests
- **Documents** — PDF, DOCX, XLSX processing
- **Parser** — URL, transcript, entity extraction
- **Browser** — screenshot, debug web, verify UI
- **Prompting** — meta-prompting, template generation, prompt optimization

---

## Medium-Value

### Investigation
- **OSINT** — due diligence, company intel, background checks
- **PrivateInvestigator** — people search, public records, reverse lookup

### ContentAnalysis
- **ExtractWisdom** — extract insights from videos, podcasts, articles, YouTube

### Media
- **Art** — illustrations, diagrams, mermaid, infographics, header images
- **Remotion** — programmatic video generation

### Scraping
- **BrightData** — progressive proxy escalation for blocked content
- **Apify** — social media scraping (Twitter, Instagram, LinkedIn, TikTok)

### Agents (custom composition)
- Dynamic agent composition from traits (expertise + personality + approach)
- Voice mappings with ElevenLabs prosody control
- Persistent custom agents via `--save` / `--load`
- Parallel agent orchestration patterns
- **Interesting pattern for our agent definitions**

---

## Low-Value for Us

### Telos (full PAI version)
- 18+ personal TELOS files (MISSION, BELIEFS, WISDOM, BOOKS, MOVIES, TRAUMAS, etc.)
- Project TELOS analysis with parallel engineer dashboard builds
- McKinsey-style report generation
- **Overkill** — our TELOS-lite (goals.md + learned.md) is sufficient

### USMetrics
- 68 US economic indicators from FRED, EIA, Treasury, BLS, Census
- Very domain-specific, not relevant to our template

---

## Key Patterns to Adopt

| Pattern | Source | How We'd Use It |
|---------|--------|-----------------|
| Workflow routing tables | All skills | Every SKILL.md has a trigger→workflow routing table. Clean pattern. |
| `USER/SKILLCUSTOMIZATIONS/` | Agents, Research | User overrides that survive upgrades. Our equivalent: per-project config. |
| Parallel agent spawning | Agents, Utilities/Delegation | Use Claude Agent Teams for dogfooding phase. |
| Self-improvement loop | Utilities/PAIUpgrade | Our maintainer agent is the same concept. |
| Eval framework | Utilities/Evals | Test agent behavior systematically. Could validate our agents. |
| Context search | ContextSearch | Alternative to brain.py — uses file-based search instead of vector DB. |

---

## Tools (standalone scripts)

| Tool | File | Purpose |
|------|------|---------|
| BackupRestore.ts | Tools/BackupRestore.ts | Backup/restore PAI configuration (Bun/TS) |
| validate-protected.ts | Tools/validate-protected.ts | Validate protected file integrity |
| ComposeAgent.ts | Packs/Agents/src/Tools/ComposeAgent.ts | Dynamic agent composition engine |

---

## Dependencies

Most PAI packs require:
- **Claude Code** (native platform)
- **Bun** (for TypeScript tools)
- **ElevenLabs** (for voice — optional)
- **Perplexity API** (for research — optional)
- **Fabric** (for pattern processing — optional)
- **Bright Data / Apify** (for scraping — optional)
