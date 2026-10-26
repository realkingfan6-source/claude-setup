---
name: reel-to-skill
description: >-
  Turn a short video J shares (Instagram reel, TikTok, Short) into something Claude actually uses: a new skill, an
  Agent HQ change, a memory note, or a clear "skip, because". Use when J sends a reel link, pastes reel
  transcripts (often several separated by ", "), or says "add this to my claude", "use these tips", "study this".
---

# reel-to-skill

J sends reels with tips they want working in their setup, not just saved. Idea from @jens.heitmann's "3 systems"
reel (download, transcribe, turn into a skill), adapted to J's rules.

## 1. Get the words
- Fastest: `powershell -File %USERPROFILE%\AgentHQ\tools\reel_transcribe.ps1 -Url <link> [-Url <link2>]` ->
  `AgentHQ\inbox\reels\<id>.md` (account, date, likes, caption, full transcript). yt-dlp (public, logged out) +
  Windows transcoder + local Whisper base; ~6 s per minute of video; the clip is deleted after. Whisper base mishears
  names and brands: check them against the caption and on-screen text.
- J pasted transcripts: use them. Several reels arrive in one message separated by ", " - split them and handle each.
- Only a link: WebFetch the reel for caption, account, date, likes. J's reels have burned-in captions: if the
  spoken words matter, ask J to run it through their transcription website and paste it (fastest), or read the
  captions in the Claude Browser: play the video muted, grab frames with requestVideoFrameCallback every ~1 s, draw
  the bottom ~30% of each frame into canvas contact sheets (3 columns), screenshot each sheet. Instagram's page
  blocks sending frames anywhere else (CSP), so screenshots are the way.
- If yt-dlp + a local Whisper model are installed (see AgentHQ/docs/STATE.md "Tools"), use them. Never pull
  cookies or passwords from J's browsers to download anything.

## 2. Sort every tip into one bucket
| Bucket | Do |
|---|---|
| Already in place | Say where (CLAUDE.md line, existing skill, HQ doc). |
| A workflow J repeats | Write a skill (step 3). |
| A setting or habit | Apply it if it's J's own setting and J asked; otherwise give the one-line how-to. |
| Needs an account, money, an API key or a login | List it for J with cost and what it would replace. Never sign up. |
| Against J's rules or unsafe | Skip it and say why in one line. |

## 3. Write the skill
- Folder `%USERPROFILE%\.claude\skills\<kebab-name>\SKILL.md`. Frontmatter: `name`, `description` with the words
  J would actually type. Body: when to use, the exact steps and tools/paths, what it never does, and the gate
  ("ship it, or change it?") if it produces something publishable.
- Short. Reuse existing tools (YouTubeChannel/tools, AgentHQ/tools) instead of new ones.
- Summarize the creator's idea in your own words; never paste the whole transcript into the skill. Credit the reel
  in one line.

## 4. Log it
- Memory: one `reference` note per reel (account, link, date, what was taken from it), pointer in MEMORY.md.
- Agent HQ: one loop_log line and one dashboard event (see the `hq-dashboard` skill).

## 5. Report to J
What was added (skill names), what was applied, what needs J (with cost), what was skipped and why.
