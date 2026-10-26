---
description: Record J's current weekly usage % so the usage guard (hooks) can warn at 85 and block at 90
---
J's current weekly usage is: $ARGUMENTS percent.

Do exactly this, nothing else:
1. Run one PowerShell command that writes the file `%USERPROFILE%\.claude\usage.txt` (one number for every project on
   this PC; if that folder does not exist, write `.claude/usage.txt` in this repository instead) with the content
   `<number> <current ISO time>` (example: `72 2026-10-14T19:02:00`), overwriting it.
2. Reply in one line: the number recorded, the estimated % this session's remaining work will cost, and whether
   that fits under 85. If it does not fit, say what you will leave for a cloud session instead.
