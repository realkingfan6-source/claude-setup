# Claude Code setup

My Claude Code global config: rules (`CLAUDE.md`), skills, one slash command and a usage-guard hook.

## Install

1. Install Claude Code.
2. Copy into your `.claude` folder (`%USERPROFILE%\.claude` on Windows, `~/.claude` on Mac/Linux):
   - `skills\` -> `.claude\skills\`
   - `commands\` -> `.claude\commands\`
   - `hooks\` -> `.claude\hooks\` (optional, see below)
   - `CLAUDE.md` -> `.claude\CLAUDE.md`
3. Edit `CLAUDE.md`. It is written for me ("J"), and it points at my own folders (`%USERPROFILE%\AgentHQ`, `RobloxGames`).
   Keep the rules you like and remove the rest.
4. Plugins I use (install from inside Claude Code with `/plugin`): **superpowers**, **ponytail**, **playwright**.

## Optional: usage guard hook

`hooks/budget.ps1` with `/budget <percent>` warns at 85% weekly usage and blocks tool calls at 92%. It is Windows PowerShell only.
To turn it on, merge the `hooks` block from `settings.example.json` into `.claude\settings.json` and replace `<you>` with your Windows username.

## Notes

- Some skills expect tools I installed locally (ffmpeg, Scrapling, Blender, Roblox Studio MCP). They tell you where the tools should go. Change the paths if yours live somewhere else.
- Third-party skills (gsap-*, threejs-*, ui-ux-pro-max, impeccable, scrapling-official, humanizer, design-dna and others) keep their original authors' licenses.
- Not included: my memory, chat history, project files and login tokens.
