---
name: video-frame-audit
description: Audit a rendered video (long 16:9 or 9:16 Short) and its thumbnail frame by frame before anyone uploads it, using contact sheets of evenly spaced frames, then zooming every suspicious timestamp. Use this whenever a video, Short, reel or animation render has just finished or "landed", before staging files for upload, when J asks "is it ready / check it / audit the frames", when a builder says a fix pass or patch is done, or when comparing a patched render against the old one. Also use it for thumbnails and end cards. Not for writing scripts, titles or retention analysis of already-published videos.
---

# Video frame audit

Goal: J should never be the one who spots a visual defect. A render is not "done" because the file exists; it is done
when a harsh outside critic has looked at evenly spaced frames, chased every oddity to a timestamp, and found nothing
amateur. This skill makes that check fast (seconds, not minutes) and repeatable.

## 1. Is the render really final?
Builders often keep working after the first `final/video.mp4` appears (fix passes, re-rendered Shorts). Auditing a file
that is about to be replaced wastes the audit and can get a stale file uploaded. Before you start:
- J's YouTube pipeline: look for `videos/<n>/final/READY.txt` ("FINAL READY"). No READY yet? Check
  `YouTubeChannel/v4/render.lock` / `render.next` and the newest files in `v4/<n>/` (a `runfix*.ps1` / `patch.mjs`
  run means more changes are coming). Audit anyway if asked, but say the file may still change and re-audit after READY.
- Wait for the file size to stop changing before reading it.

## 2. Contact sheets (scripts/sheet.ps1)
`powershell -File scripts/sheet.ps1 <video> <n> <cols> <cellW> <cellH> <out.jpg>` takes n evenly spaced frames
(at (i+0.5)/n of the duration, timestamp printed on each cell) and tiles them. It extracts frames in parallel (~1.5 s).
- Long 16:9: `24 6 480 270`. Short 9:16: `12 6 270 480`. Look at the thumbnail .jpg at full size too.
- ffmpeg/ffprobe: the script uses Remotion's bundled copies (`YouTubeChannel/v4/node_modules/@remotion/compositor-win32-x64-msvc`);
  that build has no `tile`/`fps=1/x` filter support, which is why tiling is done with System.Drawing.

## 3. Read the sheets as a harsh critic
For every cell ask: would a viewer think this looks broken, cheap or AI-made? The defects that actually occur:
- **Empty or near-empty frames** (just background). Could be a gap in the timeline. Could also be a drawing caught
  mid-animation: decide by zooming, never by guessing.
- **Lines crossing things they should go behind**: arms over a phone screen, cobwebs over title text, strokes over faces.
- **Subjects cut by the frame edge** (9:16 needs about a 6% margin) and objects floating with nothing under them.
- **Text problems**: overlapping, clipped, misspelled, a card that contradicts the narration or the facts file.
- **Covered faces / key objects hidden** by a prop, a card or a caption bar. Title cards dropped at a fixed spot
  often sit on the one thing the narration is talking about (a balloon, a frozen cloud): check what is under each card.
- **Text clipped by its own container**: slanted paper strips and boxes that cut the first or last letters
  ("YOU LATER" wider than its box, "STRESS" losing its S to the paper edge). Zoom text-heavy frames at full size.
- **Font misreads at phone size**: the v4 kit's Ink Free capital M reads as W ("WOOD FROZEN" for MOOD, "WICHAEL").
  Check every card word that starts with or leans on M at Short size (270 px wide cells), not only at full size.
- **End cards and pointer tails**: a Short's last seconds should show the long video's (fixed) thumbnail, readable.
- Thumbnail: big readable words, nothing drawn across them, still reads at 168x94.

## 4. Zoom every suspicious timestamp (scripts/frames.ps1)
`powershell -File scripts/frames.ps1 <video> "t1,t2,t3,..." <out.jpg> [cellW]` grids exact timestamps (4 per row).
Bracket a suspect: e.g. a blank cell at 270.7 s -> `"268.5,269.5,270.7,271.8,273.0"` to find where the gap starts and
ends. Report the range in seconds and m:ss.

## 4b. One audio pass (30 s, catches what frames cannot)
Use the FULL ffmpeg build (`%USERPROFILE%\AgentHQ\tools\bin\ffmpeg\bin\ffmpeg.exe`; Remotion's copy lacks the
encoders): `ffmpeg -hide_banner -nostats -i <video> -vn -af ebur128=peak=true -f null NUL` and read the
`I:` and `Peak:` lines of the Summary: integrated about -14 LUFS,
true peak below -1 dBFS. Compare audio vs video stream durations (ffprobe) so a splice did not drift the voice. Listen
yourself only at the timestamps a builder flags (voice chunk joins).

## 5. Verifying a patch / fix pass
A splice can drop or duplicate frames and drift the audio. Check:
- Frame counts equal before and after: `ffprobe -v error -select_streams v:0 -count_packets -show_entries
  stream=nb_read_packets -of csv=p=0 <file>` (the output ends in a comma; strip it before comparing numbers, or a
  script will print NaN / "MISMATCH" for an identical file).
- `frames.ps1` the patched seconds in the old and new file side by side, and confirm the defect is gone and nothing
  near the splice changed.

## 6. Report and route
- PASS: say what you checked ("24 + 12 + 12 frames, thumbnail, end cards") and stage.
- FIX: list each defect as `time range | what is wrong | suggested fix`, most visible first. Send it to the agent that
  owns the render instead of editing its files while it may still be rendering (render.lock); small isolated fixes you
  make yourself (e.g. a thumbnail-only scene) must be re-rendered and re-checked before you claim them.
- Never stage or upload a file you have not audited in its final form.
