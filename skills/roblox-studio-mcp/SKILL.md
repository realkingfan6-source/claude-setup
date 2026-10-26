---
name: roblox-studio-mcp
description: "Use when working with Roblox Studio through built-in MCP for scripts, scenes, generated assets, input, or playtesting."
last_reviewed: 2026-09-13
sources:
  - https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/studio/mcp.md
  - https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/parts/procedural-models.md
  - https://create.roblox.com/docs/reference/engine/classes/ProceduralModel
---

# Roblox Studio MCP

## When to Load

Load for Studio MCP work: scripts, scenes, assets, debugging, or playtesting. Skip for standalone code generation.

## Quick Reference

**Route by capability first.** Two Studio MCP bridges exist: the **official** (built into Studio, closed-source) and **[chrrxs's](https://github.com/Chrrxs/robloxstudio-mcp)** (MIT). Route on `tools/list` (`get_connected_instances`/`eval_*`/`multiplayer_*` → chrrxs; `list_roblox_studios` + per-call `studio_id` → official) BEFORE bridge-specific bootstrap.

### Bootstrap before mutation
1. Identify the target via `list_roblox_studios` (official) or `get_connected_instances` (chrrxs).
2. Pass the target's `studio_id` (official) or `instance_id` (chrrxs) on every tool call.
3. `get_studio_state` and confirm Edit/Client/Server availability.
4. Inspect the target tree and scripts before changing them.

### Execution contract
```text
discover → select Studio/context → inspect → mutate in bounded batches
→ read back → start play → evaluate live → evidence → clean up
```

Edit-time injection (`multi_edit`, Edit-context `execute_luau`) writes scripts; it never targets a running playtest. Live evaluation targets a running VM: start play, wait for the intended `Client`/`Server` VM, then evaluate there. A stopped VM is never a live-evaluation target. Pass `datamodel_type` only where the tool requires it; do not guess from a previous session.

### Capabilities
Inspect (`search_game_tree`, `inspect_instance`, `script_read`, `script_grep`), edit/execute (`multi_edit`, `execute_luau`), assets (`search_asset`/`insert_asset`, `generate_*` with `wait_job_finished`, `store_image`/`upload_image`), play/evidence (`start_stop_play`, `get_console_output`, `screen_capture`, input simulation, `subagent`).

### Reliability rules
- `execute_luau` is stateless: re-acquire references every call.
- Read before write; read back after every script, asset, or geometry mutation.
- Choose reuse vs generation vs native fallback before asset work.
- Call `wait_job_finished` before edits that depend on a generation job.
- Command-size limits are bridge-specific. Split large scripts into separate bounded `multi_edit`/`execute_luau` writes (or supported multi-edit operations), then read back the full payload to verify.
- If MCP is absent, provide offline Luau and state what was not verified.

- `user_keyboard_input` actions are `{action: "keyDown"|"keyUp"|"keyPress"|"wait", key_code: "W", wait_time_ms}`.
  A wrong shape (e.g. `{type, key}`) still returns Success and sends nothing: log `UserInputService.InputBegan` on the
  client the first time to prove keys arrive. Input reaches a background Studio: no window focus needed.
- Mute the place before any playtest an agent starts (J may be wearing headphones in another window).
- ProximityPrompts can't be fired from execute_luau (InputHoldBegin does nothing, user_keyboard_input E doesn't trigger
  them): give the game a Studio-only attribute hook that calls the same server handler (DontMissTheElevator DebugGrab).
- execute_luau runs in its own VM: `require(Config)` there is a different table from the game's, so changing it does
  nothing; `_G` set by one execute_luau call is visible to later calls in the same datamodel, not to game scripts.
- screen_capture does not draw BillboardGuis; a gfxcapture recording of the window does.
- Welding a model that has its own Humanoid into a player's character can knock the player into FallingDown:
  strip the Humanoid (paint the parts, pose with an AnimationController) before welding.

- Thumbnail stills (10-24): a frozen tableau beats filming a live scene. Clone the creature, anchor it, Play its clip,
  set TimePosition, AdjustSpeed(0); same for the player (anchored root). A client RenderStep bound after every game
  camera sets a fixed Scriptable camera; set Humanoid.AutoRotate = false or the client turns the posed body to face
  the camera's way. Hide PlayerGui, BillboardGuis and UserInputService.MouseIconEnabled. Grab one frame with ffmpeg
  gfxcapture (works under other windows). Studio can't make the window taller than the screen (SetWindowPos height
  caps at ~1061), so close the bottom panels for a bigger viewport. PivotTo(CFrame.new(pos)) drops a model's
  rotation: park models with GetPivot() + offset.
- Local diffusion image-to-image on game shots (Z-Image Turbo, 10-24): even strength 0.2 rewrites signs, faces and
  removes dark thin creatures. Don't run it over the whole frame; grade with ffmpeg instead.
- ffmpeg gfxcapture `window_title` is a pattern match on every window: a browser tab whose title contains the game's
  name matches too. Always pin it to Studio: `window_title=<Place name>.* - Roblox Studio`.
- (10-24 night) `user_mouse_input` clicks arrive with gameProcessed = true and don't reach a ContextActionService
  MouseButton1 binding (keyboard keys do): test click actions through a Studio-only server hook instead.
  In Server & Clients, only the front client window took a ProximityPrompt key press; the background one ignored E
  (and InputHoldBegin). Drive prompt tests from one client, or bring its window forward first.
- A long untouched session's Bash heredoc turned a `\n` inside a Luau string into a real newline (the client script
  failed to load: "Malformed string"). Write Luau with escapes through Write/Edit and parse-check with
  `luau-lsp analyze <file> | grep -i syntax` (aftman's luau-lsp.exe) before syncing.
> Full tool mappings, live schemas, asset workflows, and recovery rules: [references/full.md](references/full.md)
