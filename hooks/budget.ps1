# Usage guard (J 2026-10-11: "I need to not run out ever again"). Runs on the PC through the project hooks in
# .claude/settings.json; the cloud container has no powershell.exe, so it never runs there.
#   budget.ps1 prompt   UserPromptSubmit: prints the last recorded % so every turn carries it, nags for a fresh one
#   budget.ps1 tool     PreToolUse: exit 2 (blocks EVERY tool call) at 92 %+; the 85-92 band is for the handoff
# The number comes from J: the /budget slash command writes ".claude/usage.txt" as "<percent> <ISO time>".
param([string]$Mode = "prompt")
# One number for the whole PC: the user-level file wins when it exists (tools\install_guard.ps1 puts the guard there).
$global = Join-Path ([Environment]::GetFolderPath('UserProfile')) ".claude\usage.txt"
$file = if (Test-Path $global) { $global } else { Join-Path $PSScriptRoot "..\usage.txt" }
$hard = 92
$soft = 85
if (-not (Test-Path $file)) {
    if ($Mode -eq "prompt") { Write-Output "USAGE GUARD: no percentage recorded. Ask J for the weekly usage % and run /budget <n> before any real work." }
    exit 0
}
$parts = (Get-Content $file -Raw).Trim() -split "\s+"
$pct = 0
[void][double]::TryParse($parts[0], [ref]$pct)
$when = if ($parts.Count -gt 1) { $parts[1] } else { "unknown time" }
$age = 999
try { $age = ((Get-Date) - [DateTime]::Parse($when)).TotalHours } catch {}
if ($Mode -eq "tool") {
    if ($pct -ge $hard) {
        [Console]::Error.WriteLine("USAGE GUARD: $pct % recorded at $when. Hard stop at $hard %. Write the handoff (BUILD_STATE, SESSION_HANDOFF), commit, push, then stop. Only /budget with a lower number (after the reset) lifts this.")
        exit 2
    }
    exit 0
}
$line = "USAGE GUARD: $pct % of the weekly bar, recorded $when."
if ($age -gt 3) { $line += " That is over 3 h old: ask J for the current % and run /budget <n>." }
if ($pct -ge $soft) { $line += " Over $soft %: finish the handoff now, start nothing new." }
# Pace (J 2026-10-12: "92 % only with minutes till the reset"): the bar resets Tue 00:00 PT and refills over 7 days,
# so the even-spend line is 100 % * hours-since-reset / 168. Ahead of that line by 10+ points = cloud-only for today.
try {
    $pt = [TimeZoneInfo]::ConvertTime((Get-Date), [TimeZoneInfo]::FindSystemTimeZoneById("Pacific Standard Time"))
    $sinceMon = ([int]$pt.DayOfWeek + 6) % 7          # Monday = 0 ... Sunday = 6
    $hours = ($sinceMon - 1 + 7) % 7 * 24 + $pt.Hour + $pt.Minute / 60.0   # hours since Tuesday 00:00 PT
    $pace = [Math]::Round(100 * $hours / 168)
    $pctR = [Math]::Round($pct)
    if ($pctR -ge $pace + 10) { $line += " PACE: $pctR % used vs $pace % expected this far into the week. AHEAD by $($pctR - $pace): no new local work today, cloud only; tell J." }
    elseif ($pctR -le $pace - 10) { $line += " PACE: $pctR % used vs $pace % expected: room for a longer local task today." }
    else { $line += " PACE: $pctR % used vs $pace % expected: on track." }
} catch {}
$line += " Local = Studio work only, /model sonnet unless J said otherwise, one test at a time."
Write-Output $line
exit 0
