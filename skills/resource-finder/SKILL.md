---
name: resource-finder
description: >-
  Before building or paying for anything (hosting, database, auth, email, API, data source, scraper, AI model, or a
  new Claude tool/connection), check J's five free resource libraries: awesome-mcp-servers, public-apis,
  free-for-dev, Scrapling, Ollama. Use whenever a project needs infrastructure, outside data, web extraction,
  local AI, or a capability Claude doesn't have yet.
---

# resource-finder (J 2026-10-10: "proactively use these resources when they can save us money or time")

Local copies (plain text, grep them): %USERPROFILE%\AgentHQ\resources\<name>\README.md
Refresh monthly: `powershell -File %USERPROFILE%\AgentHQ\resources\refresh.ps1`

## Decision flow (stop at the first that works)
0. **Already possible?** Existing tools, connectors, skills, project scripts. Do it.
1. **New capability for Claude → MCP.** First the vetted paths: `mcp-registry` search and SearchPlugins (claude.ai
   connectors/plugins, reviewed). Then grep `awesome-mcp-servers` (🎖️ = official, 🏠 local, ☁️ cloud).
   Before any install: read the repo source, maintainer, stars, and exactly what access it gets. Never install
   because it's listed. J approves every install (config change). No duplicates of what J has (Roblox Studio MCP,
   claude-in-chrome, computer-use, api-anything, Higgsfield, HyperFrames, Claude Docs).
2. **Outside data or functionality → public-apis.** Rows: `| [Name](url) | Description | Auth | HTTPS | CORS |`.
   Grep by category or keyword. Then verify before depending on it: one live test call, auth type, rate limits,
   license/ToS, still maintained. Prefer official/reputable. Never assume a listed API still works.
3. **Infrastructure → free-for-dev** (hosting, DB, auth, storage, email, CI/CD, monitoring, analytics, DNS).
   Confirm the current free tier on the provider's own site (lists go stale). Never sign J up: name the option
   and J creates accounts.
4. **Public web data with no good API → Scrapling** (see "Installed" below). Respect robots.txt and ToS. Never
   bypass logins, paywalls, CAPTCHAs or bot protection (do not use StealthyFetcher's anti-bot mode). Same data
   needed twice = reusable script in %USERPROFILE%\AgentHQ\tools\scrape\.
5. **AI work that can run locally → Ollama** (bulk classify/summarize/extract, embeddings, private drafts,
   experiments). Claude stays the default for anything J sees (scripts, code, design). Ollama is for bulk, private
   or repeat passes. Compare quality on 3 samples before switching a job to a local model.
6. Choose the best option for quality, cost, speed, privacy. Implement, test, and save the setup (this skill,
   AgentHQ/docs/SKILLS.md). Say in one line which resource was used.

## Installed (keep current)
- free-for-dev, public-apis, awesome-mcp-servers: local READMEs (2026-10-10).
- Scrapling, Ollama, Context7, ElevenLabs API: see AgentHQ/docs/SKILLS.md for status, paths and models.

## Never
Paid tiers, sign-ups, API keys handled by Claude (J sets keys as env vars), installs without J's OK.
