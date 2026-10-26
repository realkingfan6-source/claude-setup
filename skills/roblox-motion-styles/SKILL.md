---
name: roblox-motion-styles
description: >-
  J's 20 reference animation styles (reel "20 crazy Claude animation styles", 2026-10-09) translated into Roblox
  motion recipes. Use when adding or polishing any UI animation, transition, celebration, scoreboard, callout,
  menu, tutorial or VFX moment in a Roblox game (or a web page), to pick the style that fits the interaction.
---

# roblox-motion-styles

Source: J's ZIP of 25 frames from millee.md's reel "20 crazy Claude animation styles (that you can steal)". The
frames are stills of small preview tiles, so the motion below is INFERRED from each style's known language, not
measured. Pair with roblox-animation-vfx (tracks, particles), roblox-gui (layout), roblox-camera (shakes, cuts).

## Rules
1. Pick per interaction, never one style everywhere. A game has ONE identity set of 3-5 styles (see bottom).
2. J's anti-AI list wins: holographic/rainbow, neon-on-everything, glassmorphism and harsh gradients are only for a
   deliberate reason (rarity tier, danger warning). Never as the default look.
3. Timing tokens: press 60-100 ms, small 150-250 ms, panel 280-400 ms, scene 600-900 ms, celebration 1-2 s.
   Enter = Out easing (Quart/Back), exit = In easing and ~30% faster than enter, loops = Sine InOut.
4. Overshoot only on things that "land" (Back Out, or a spring ~5 Hz, damping 0.55). Text that must be read
   holds still for at least 0.6 s.
5. Stagger lists 30-50 ms per item, max ~8 items, then the rest together.
6. Performance: TweenService for UI and anchored parts; one Heartbeat loop per system for springs/loops (never one
   connection per element); ParticleEmitter:Emit(n) bursts, not always-on emitters; pool short-lived UI.
7. Test: capture 3 frames per animation (start, overshoot peak, rest) with screen_capture; check console; check
   phone layout. It is done when it reads in 1 frame and never blocks input.

## The 20 styles: motion language and Roblox recipe

| # | Style | Motion language (inferred) | Roblox recipe | Use for | Avoid |
|---|---|---|---|---|---|
| 1 | Particles | radial burst from a point, fast start then drag (exp out), shrink + fade 0.6-1.2 s, slight gravity; ambient = slow drift loop | `ParticleEmitter:Emit(20-40)`, Speed NumberRange, Drag 4-8, Acceleration (0,-20,0), Size/Transparency NumberSequence to 0/1; UI: pooled Frames tweened Quart Out | serve success, confetti, coin pickup, combo | constant emitters on UI |
| 2 | Liquid morph | blobs stretch, merge, split; squash/stretch; slow sine loops 2-4 s | 3D: parts/meshes with sine scale on 2 axes out of phase; UI: UICorner circles on springs that overlap | soup/boil, slime, loading blobs | text, menus |
| 3 | Holographic | iridescent hue sweep, slow rotation, shimmer pass every 2-3 s | UIGradient rainbow ColorSequence, animate Rotation + Offset X -1 to 1 (Sine), Transparency band | legendary cosmetic tier only | anything common (J's avoid list) |
| 4 | Neon glow | flicker-on (on-off-on 60 ms), then breathing pulse 1.2-1.6 s | UIStroke Thickness/Transparency pulse, Neon material + PointLight Brightness sine, Bloom small | danger: fire, last 10 s, timer low | general UI (avoid list) |
| 5 | Wireframe 3D | line model rotating at constant speed, perspective grid floor | ViewportFrame + rotating model; Highlight FillTransparency 1 OutlineTransparency 0; SelectionBox | ghost placement previews, how-to-play diagrams, unlock previews | gameplay readability |
| 6 | Glassmorphism | frosted panels drifting with parallax | BlurEffect in Lighting behind a modal, panel BackgroundTransparency 0.2 + UIStroke | rarely: pause menu over gameplay | default panels (avoid list) |
| 7 | Kinetic type | words slam in big then settle (scale 1.6 to 1, Back Out 250 ms), per-letter stagger 35 ms, small rotation jitter, hold, cut out fast | per-character TextLabels in a UIListLayout, UIScale tweens; MaxVisibleGraphemes for typewriter; tiny camera punch on the last letter | "Service!", "LEAD CHANGE!", "RED WINS", countdown, combo callouts | paragraphs |
| 8 | Isometric | 2.5D tiles pop up from the floor in a wave, bounce, then idle bob | camera FieldOfView 10-20 from far away; parts tween Y from -1 with Back Out, delay = grid distance x 30 ms | kitchen/map reveal at round start, level select | first-person views |
| 9 | Clay 3D | soft matte shapes, squash on land (Y 0.8, XZ 1.15), elastic recover, rolling, gentle bob | SmoothPlastic, pastel colors, Size or Mesh.Scale tween with Elastic Out 350 ms; spring on landing | food landing, chef hops, pickups, 3D buttons | hard sci-fi |
| 10 | ASCII art | random characters scramble then resolve left to right; matrix rain | TextLabel with monospace font, swap chars every 25 ms, lock one more char each step | hacker/code themes, score "decrypt" reveal (rare) | cartoon games |
| 11 | Gradient mesh | slow flowing color fields, 6-10 s loops | 2-3 stacked UIGradients, low saturation, animate Offset/Rotation with Sine | subtle menu backgrounds | harsh, saturated gradients (avoid list) |
| 12 | Comic book | onomatopoeia burst ("WHOOSH!") with rotating starburst rays, halftone, speech bubbles pop with overshoot, 2-frame holds, hard cuts, small screen shake | ImageLabel burst: UIScale 0 to 1.2 to 1 (Back Out 180 ms) + Rotation snap -8 to 0; rays ImageLabel rotating 30 deg/s; Camera CFrame shake 0.15 s | big events: ORDER UP!, BURNED!, NICE CATCH!, KO-style moments | calm screens |
| 13 | Split-flap | characters flip through the alphabet with a top-half fold, mechanical 40-60 ms per flip, columns staggered, click per flip | TextLabel char cycling + UIScale Y squash 1 to 0.1 to 1 per flip; quiet click sound (pitch random) | scoreboards, results numbers, timers, ticket rail, leaderboards | long text |
| 14 | Retro VHS | scanlines, chromatic offset jitter, tracking noise, PLAY/REC HUD | tiled scanline ImageLabel at 0.85 transparency; duplicate red/blue text offset 1-2 px jittering; ColorCorrection tint | replays, intros, "rewind" moments | always-on overlays |
| 15 | Halftone | dot shading, dots grow with tone, print texture | tiled dot ImageLabel (ScaleType Tile), animate TileSize; pairs with Comic book | comic panels, backgrounds of callouts | small text |
| 16 | Bauhaus | primary-color circles, quarter circles, squares rotate 90 deg and slide into a grid, snappy Quint InOut, staggered | Frames with UICorner, rotation in 90 deg steps 250 ms, grid stagger | loading screens, scene-change wipes | gameplay HUD |
| 17 | Pixel art | stepped motion at 8-12 fps, no tweening, bob 1 px, coin counters | sprite sheets via ImageRectOffset stepped with task.wait(1/10); ResampleMode Pixelated | retro games only | smooth-style games |
| 18 | Blueprint | lines draw on, gears rotate at true ratios, labels type in | Frames growing along one axis (Linear 300 ms), gear ImageLabels rotating at ratio speeds, typewriter labels | how-to-play, upgrade trees, tutorials | celebrations |
| 19 | Art deco | symmetric gold lines draw outward from center, sunburst fans, slow elegant 0.8-1.2 s | gold UIStroke frames tween from center, symmetric pairs, Sine InOut | VIP/premium screens, gold star results | fast arcade moments |
| 20 | Neo-brutalism | flat blocks, thick black borders, hard offset shadows; stickers slam in with tiny overshoot and slight rotation; press = element drops into its shadow | Frame + offset shadow Frame, UIStroke 3 px black; press: Position +4 px and shadow offset 0 in 60 ms Linear, release Back Out 120 ms | buttons, cards, stickers, labels in loud arcade UI | elegant/premium screens |

## Choose by interaction
| Interaction | Style |
|---|---|
| Button press | 20 neo-brutal drop, or 9 clay squash |
| Panel/modal open | scale 0.92 to 1 + fade, Back Out 300 ms; close Quad In 200 ms |
| Number change (score, coins, time) | 13 split-flap, or count-up with a 1.15 punch at the end |
| Big moment (win, lead change, combo) | 7 kinetic type + 12 comic burst + 1 particles + 0.15 s camera punch |
| Danger | 4 neon pulse on the threat only |
| Tutorial / how to play | 18 blueprint draw-on, 5 wireframe preview |
| Rare reward | 3 holographic shimmer on that item only |
| Scene transition | 16 Bauhaus wipe or an iris; 0.6-0.9 s total |
| Ambient menu background | 11 gradient mesh (subtle) or 1 particle drift |

## Identity sets per game
- DINNER DISASTER (cartoon kitchen chaos): 9 Clay 3D (food, chefs), 12 Comic book (event callouts), 20 Neo-brutalism
  (buttons, cards, tickets), 13 Split-flap (scores, timer, results), 7 Kinetic type (Service!, LEAD CHANGE!,
  RED WINS), 1 Particles (confetti, steam). Neon only for fire/last 10 s.
- SURF RIVALS (fast, minimal): 7 Kinetic type (times, places), 13 Split-flap (leaderboards, splits), 1 Particles
  (speed streaks, boosts). Keep the Minimal label look.
