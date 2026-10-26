---
name: roblox-audio
description: "Use when implementing Roblox audio playback, spatial sound, music, sound effects, SoundGroups, or dynamic audio effects."
last_reviewed: 2026-07-26
sources:
  - https://create.roblox.com/docs/reference/engine/classes/SoundService
  - https://create.roblox.com/docs/audio/objects
  - https://create.roblox.com/docs/audio/effects
  - https://create.roblox.com/docs/sound/groups
  - https://create.roblox.com/docs/sound/dynamic-effects
---

# Roblox Audio

## When to Load

Load when implementing audio playback, spatial/3D sound, background music, sound effects, audio mixing (SoundGroups), or dynamic effects. Covers both legacy Sound objects and the newer modular AudioPlayer/Wire system.

## Quick Reference

**Two Systems**: Legacy (`Sound`/`SoundGroup`/`SoundEffect`): simpler. New modular (`AudioPlayer`/`AudioEmitter`/`Wire`/`AudioDeviceOutput`): preferred for new projects, required for voice chat.

**Sound Placement**: BasePart child → volumetric. Attachment/MeshPart → point source. SoundService/Workspace → global (BGM/UI).

**Legacy Setup**:
```luau
local s = Instance.new("Sound")
s.SoundId = "rbxassetid://ID"; s.Looped = true; s.Volume = 0.25
s.RollOffMode = Enum.RollOffMode.InverseTapered
s.RollOffMinDistance = 10; s.RollOffMaxDistance = 100
s.Parent = SoundService; s:Play()
```

**SoundGroups** (mixer): Nest `SoundGroup` under Master for player-adjustable Music vs SFX volume. `bgMusic.SoundGroup = musicGroup`. Effects (`ReverbSoundEffect`, `EqualizerSoundEffect`, `CompressorSoundEffect`, etc.) parent to Sound/SoundGroup. Ducking: `CompressorSoundEffect` with `SideChain = sfxGroup` on music.

**New Modular**: 2D: `AudioPlayer → Wire → AudioDeviceOutput`. 3D: `AudioPlayer → Wire → AudioEmitter` (on Part). Studio/plugin-only `SoundService.DefaultListenerLocation` controls the default listener; wire an explicit `AudioListener` for runtime control.

**One-Shot SFX**:
```luau
local function playSFX(parent, id)
    local s = Instance.new("Sound"); s.SoundId = id
    s.RollOffMode = Enum.RollOffMode.InverseTapered
    s.RollOffMinDistance = 10; s.RollOffMaxDistance = 80
    s.Parent = parent; s:Play()
    s.Ended:Once(function() s:Destroy() end)
end
```

**Preload**: `ContentProvider:PreloadAsync({sound1, sound2})`. **Client SFX**: `FireClient` → `OnClientEvent` creates invisible Part + `playSFX`.

**Pitfalls**: Server sounds have latency → play feedback on client. Default `RollOffMaxDistance`=10000 studs → set explicitly. Volume > 1 clips. Rapid-fire → check `IsPlaying`. Always `Destroy()` one-shots after `Ended`.

### Loudness safety (DontMissTheElevator 2026-10-23: an unmuted test hurt J's ears)
- A mixer only protects what goes through it. Server-made Sounds have no SoundGroup and skip every group, setting and
  limiter: on the client, adopt them (`workspace`/`SoundService` `DescendantAdded` -> `s.SoundGroup = worldGroup` when nil).
- The new audio API (AudioPlayer, AudioTextToSpeech -> Wire -> AudioDeviceOutput) skips SoundGroups entirely: give
  that chain its own `AudioCompressor` + `AudioFader` tied to the volume setting.
- End every group in a limiter: `CompressorSoundEffect` Threshold -12, Ratio 20, Attack 0.005, Release 0.2,
  Priority low so it runs last. Cap source volumes at 1 (`math.min(volume, 1)` in the shared sound helper).
- Many creatures/props at once stack their loops: the limiter is what bounds the sum, not the per-sound values.
- Agents testing in Studio: a Studio-only mute attribute (checked with `RunService:IsStudio()`) zeroes every group;
  set it before every playtest. Never judge loudness by playing it; read volumes in code.

See `references/full.md` for detailed examples, effect table, and client-side patterns.

### Footsteps and custom one-shots (DontMissTheElevator 2026-10-24)
- Roblox's licensed libraries (Pro Sound Effects, APM) have no clean single human footsteps per surface (only
  compilations, animals, music). Searching works best through the toolbox API, filtered to the licensed creators:
  `https://apis.roblox.com/toolbox-service/v2/assets:search?searchCategoryType=Audio&query=...&maxPageSize=100`, keep
  `creator.name` in ProSoundEffects / APMOfficial / DailySoundsFX. Skip game rips (Half-Life, CS:GO, SCP uploads).
- Make your own with ffmpeg filters only (no install): heel body (short brown-noise burst + a quick low sine), toe slap
  10-30 ms later (band-passed noise), plus a surface layer (metal: inharmonic rings; snow: sparse random clicks
  band-passed 1.4-7.5 kHz; wet: a gliding sine formant + a bubble chirp). 4 seeded variations, peak -3 dBFS.
  Recipe + script: RobloxGames/DontMissTheElevator/audio/footsteps/build_steps.py. Check by `showspectrumpic`
  (use fscale=lin for low frequencies: the log scale's labels mislead). Show J a listening page before uploading.
- One file per surface with steps in 0.5 s slots: play one by `TimePosition` and cut it with a delayed Destroy (5 uploads,
  not 20). Time footsteps from the run AnimationTrack's TimePosition (the clip's plant times), not a guessed rhythm.
- Upload: Studio Asset Manager > Import (its dialog says "Open 3D File" but the filter list includes Audio Files),
  then Start Import in the Import Queue; read the new ids with Studio MCP `search_asset` scope=user, assetType=Audio.
