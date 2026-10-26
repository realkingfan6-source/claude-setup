---
name: roblox-npc-ai
description: "Use when creating Roblox NPCs or enemies with pathfinding, state machines, line-of-sight or FOV detection, spawns, or AI update loops."
last_reviewed: 2026-08-31
sources:
  - https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/characters/pathfinding.md
  - https://create.roblox.com/docs/projects/server-authority
---

# Roblox NPC & AI

## When to Load

Load for NPCs/enemies: pathfinding, state machines, LOS/FOV detection, spawns, AI loops, or physics ownership.

## Quick Reference

### PathfindingService

```luau
local path = PathfindingService:CreatePath({
    AgentRadius = 2, AgentHeight = 5, AgentCanJump = true,
    Costs = { Water = 20, DangerZone = math.huge },
})
path:ComputeAsync(npcPos, targetPos)
if path.Status ~= Enum.PathStatus.Success then return end
for _, wp in path:GetWaypoints() do
    if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
    humanoid:MoveTo(wp.Position)
    if not humanoid.MoveToFinished:Wait() then return end
end
```

- Recompute on blocked with a bounded retry or cancellation policy.
- In Studio, test `Workspace.PathfindingUseImprovedSearch` on representative maps before rollout; it is not scriptable.
- Avoid long requests and repeated recomputation. Moving collidable geometry can trigger navigation-mesh work.
- Region modifiers: anchored part + `PathfindingModifier` Label → Costs
- `PassThrough = true` for doors; `PathfindingLink` for disconnected navmesh
- `math.huge` cost = non-traversable

### State Machine

`idle → patrol → chase → attack → flee → dead`
- idle/patrol → chase (player detected) → attack (in range) → idle (lost)
- any → flee (health low) → idle (safe); any → dead (health ≤ 0)
- Transitions own movement changes, target cleanup, and cancellation

### Detection (distance → FOV → LOS)

1. **Distance** `(a-b).Magnitude`: cheapest, always first
2. **FOV** `forward:Dot(toTarget)` cosine; use a configured cone for your game, not a universal angle
3. **LOS** `workspace:Raycast`: expensive, last
- If the design includes hearing or proximity detection, make it a separate configured signal rather than a universal FOV bypass.

### Network Ownership
- Classic projects may use `SetNetworkOwner(nil)` for physics-sensitive NPCs, but it is not complete security. In Server Authority projects, configure the authority model instead of treating network ownership as the security boundary.

### Update Loop

- Throttle and stagger AI based on NPC count, path cost, and profiler evidence, not a universal tick rate. Keep NPC decisions and movement server-side; client code may handle presentation.

### Fast chasers in tight mazes (measured, DontMissTheElevator 2026-10-22)

- `Humanoid:MoveTo` stops the humanoid dead on arrival. At chase speed it reaches a ~3-stud waypoint before the next
  AI tick: stop-start stutter. String-pull instead: aim at the farthest of the next few waypoints that a body-wide
  `Spherecast` at waist height can reach.
- Shape casts ignore parts they start inside: pressed against a wall, a spherecast "sees" straight through it. Add a
  centre-line `Raycast` to the same check.
- Plan with `AgentRadius` wider than the body (3 for a ~2-wide humanoid in 16-wide halls): default-hugging routes made
  it clip corners and wedge. `ComputeAsync` from hip height beside a wall fails where the same spot at foot height
  works: start paths from the feet.
- On NoPath, retry from a step out each way, but only a step a raycast says it can take (3 studs from a 0.6 wall is
  the far side). Never fall back to "walk straight at it" unless it can see the spot.
- Don't strip collisions down to the thin HumanoidRootPart: it rammed into a wall at 32 studs/s and stuck inside. To
  pass under low fixtures, put just the head in a non-colliding CollisionGroup (the Humanoid resets CanCollide).
- An AI tick that yields (pathfinding) overlaps the next Heartbeat tick unless you guard it (busy flag + pcall).
- Rubber banding: reel in proportionally to distance down to a hold gap; never let a "far" threshold leave a dead zone
  where it drops to base speed (it hovered 15-35 studs behind a sprinter).
- Catches that feel owed but don't happen (measured 10-25): (1) a "warned first" clock must count the notice beat,
  not restart when the chase begins (it stood on the player 1.2 s, swiping); (2) a wind-up/creep slower than the
  player's walk must not reset on distance, or walking away loops it forever; (3) a route that ends at the target's
  position from the last re-plan only matches their speed: with a clear line, re-aim at the live position every
  frame; (4) a door safe radius sized for an open floor swallows whole maze cells: size it to the doorway. Give every
  catch a line-of-sight ray. Test on straight lanes with held keys; an autopilot steering into walls fakes "stopped".
- Test with real input: steer the camera along a client pathfinding route while MCP holds W+Shift, log server-side
  commanded vs actual speed (stuck = high WalkSpeed, ~0 velocity) and what it's touching.

### Rigs and replication gotchas (measured, DontMissTheElevator 2026-10-23)

- R15 bodies from `Players:CreateHumanoidModelFromDescription` now use **AnimationConstraint** joints (Avatar Joint
  Upgrade): `Waist.C0` / `Neck.C0` are read-only and writing them errors every tick. To pose a joint from the server
  (lean, head twitch), rotate the joint's parent-side attachment (`joint.Attachment0`); attachment CFrames replicate.
  Keep the spawn rotation and re-read the position each time (Model:ScaleTo rescales attachments).
- Don't gate a client data stream on "the first child with this name is kind X" (`FindFirstChild("Stalker")`): with two
  creatures the first may be the other kind and the stream never starts. Publish an explicit flag (an attribute).
- A "can't move while watched" creature must freeze on the event that reports a look, not at the next brain tick:
  at 10 Hz + a 0.1 s tick it crept ~2.5 studs toward someone already looking at it.
- Close calls in a maze: rubber band (reel in from behind, hold the gap behind a clean sprinter, close on a mistake),
  a contact clock (no catch until the target has had it in sight or earshot ~1 s) and a swipe-and-miss when it's in
  reach but not allowed to catch. Without them, a chaser at sprint speed reads as unfair.

For spawners, lifecycle cleanup, timeout handling, and performance budgets, load `references/full.md`.
- Anchored NPCs moved by CFrame/PivotTo on the server reach other clients only ~23 times a second (measured: 0.4-stud
  jumps at a walk). For smooth chasers, steer a server-owned Humanoid with `Humanoid:Move(dir)` every Heartbeat along
  your own route (lookahead aim point); clients then get Roblox's physics interpolation (240/241 frames moved).
- Catch/reach checks on a humanoid: use horizontal distance, or it "reaches" by climbing onto the player.
- Players:CreateHumanoidModelFromDescription now gives a dynamic head: skin + default face live in the head mesh's TextureID (plus FaceControls), so HeadColor never shows (a black creature got a white smiling head). Clear MeshPart.TextureID and destroy FaceControls for a plain-coloured body (measured 10-23).
