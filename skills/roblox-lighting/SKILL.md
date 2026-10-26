---
name: roblox-lighting
description: "Use for Roblox lighting, atmosphere, day/night, or post-processing effects."
last_reviewed: 2026-07-26
sources:
  - https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/environment/lighting.md
  - https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/environment/atmosphere.md
  - https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/environment/post-processing-effects.md
---

# Roblox Lighting & Atmosphere

## When to Load

Load for Roblox lighting, atmosphere, day/night, or post-processing (Bloom, ColorCorrection, DepthOfField).

## Quick Reference

### Lighting Service
```luau
Lighting.ClockTime = 14            -- 0-24 numeric
Lighting.Brightness = 2            -- 0-10, default 2
Lighting.Ambient = Color3.fromRGB(70, 70, 70)        -- shadow fill
Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.2      -- 0=sharp, 1=soft
-- Configure tech/style/quality in Studio; these properties are not script-writable.
-- Verify enum values and device behavior against current Creator Hub docs before setting them.
```

### Atmosphere
```luau
local atmo = Instance.new("Atmosphere")
atmo.Density = 0.3    -- 0=clear, 1=opaque (keep <0.5)
atmo.Offset = 0.25    -- 0=ground, 1=sky
atmo.Color = Color3.fromRGB(199, 199, 199)   -- near fog
atmo.Decay = Color3.fromRGB(92, 92, 92)      -- far/horizon
atmo.Glare = 0        -- 0-10
atmo.Haze = 0         -- 0-10
atmo.Parent = Lighting
```

### Post-Processing (all parented to Lighting)
| Effect | Key Properties |
|--------|---------------|
| `BloomEffect` | Intensity (0-1), Size (px), Threshold (>0.7 recommended) |
| `ColorCorrectionEffect` | Brightness, Contrast, Saturation (-1 to 1), TintColor |
| `DepthOfFieldEffect` | FarIntensity, FocusDistance, InFocusRadius, NearIntensity |
| `SunRaysEffect` | Intensity (0-1), Spread (0-1) |

### Day/Night Cycle
```luau
local CYCLE_SPEED = 1  -- minutes per full day
task.spawn(function()
    while true do
        Lighting.ClockTime += (task.wait() / 60) * (24 / CYCLE_SPEED)
        if Lighting.ClockTime >= 24 then Lighting.ClockTime -= 24 end
    end
end)
```

### Local Lights
| Light | Use | Key Props |
|-------|-----|-----------|
| `PointLight` | Lamps, torches | Range, Brightness, Color |
| `SpotLight` | Flashlights | Range, Angle, Face |
| `SurfaceLight` | Screens, panels | Range, Angle, Face |

**Perf:** Limit shadow-casting lights to 4-6 visible. Use `Shadows=false` on most. Neon material = cheap glow.

**MCP:** Inspect, change minimally, capture, check performance.

### Common Pitfalls
- Brightness >3 washes out. Density >0.5 = soup. Max 2-3 post effects.
- Avoid black Ambient. Technology is deprecated; it and its replacements are Studio-only.

### References
- Mood presets (Day, Golden Hour, Night, Horror, Underwater, Sci-Fi), zone tweens, full examples: `references/full.md`

### Realistic interiors (measured, DontMissTheElevator 2026-10-23)
- Plaster at room scale reads as exterior stucco, and a ceiling of it under grazing light looks like a cave. Painted
  drywall = SmoothPlastic with slight per-panel tint; realism comes from the light, scale and trim.
- Flush ceiling lights: hang the PointLight ~0.5 studs below the fixture (an Attachment) so the ceiling gets a halo.
  Range ~13 with spacing 11 gives pools; range 17 lit the hall evenly (looked fake).
- Edit-mode camera via MCP: set `Camera.Focus` along with `CFrame`, or Studio re-aims it. Put test post effects in
  Lighting; save the original Lighting values somewhere a rebuild won't overwrite.
- A SpotLight with `Shadows = true` and `Angle` over 90 lights NOTHING (measured 10-23: a whole factory went black;
  shadows off or Angle 85 fixed it). Keep shadowed spots at 90 or less; use PointLights for wide fills.
- MCP `screen_capture` of a minimized Studio window returns a frozen flat-grey 3D view (GUI still updates): check
  `IsIconic` and restore with `ShowWindow(h, 4)` (no focus steal) before judging a scene as "too dark".
