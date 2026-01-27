# Engine Component — Mazestein 3D

This document describes the **Engine** component: how it loads components, controls tick order, and exposes component APIs. It's the bootstrap and manager for the whole Mazestein runtime.

---

## Purpose

The Engine is responsible for:

* loading core components (Render, Controls, etc.)
* keeping a prioritized tick list
* initializing components with a single `GameConfig` snapshot
* exposing component APIs via `Engine:GetComponent(name)`
* driving the per-frame update (`Engine.Update()`)

It intentionally stays small and opinionated: components do the work, Engine composes them.

---

## Public API

### `Engine.Initialize(config, cpu, video)`

Initializes the engine and all loaded components. Typical usage:

```lua
Engine.Initialize(GameConfig, gdt.CPU0, gdt.VideoChip0)
```

* `config` — `GameConfig` table (see GameConfig section)
* `cpu`, `video` - runtime objects passed to components for integration

If `Engine.Initialize` was already called, subsequent calls return immediately.

### `Engine.Update()`

Call this every frame. Engine will iterate the internal tick list in priority order and call `component._Tick()` for each component that exposes it.

Example:

```lua
function update()
    Engine.Update()
end
```

### `Engine:GetComponent(name)` → component.API

Returns the `API` table of the named component (for example `Render` or `Controls`). Throws if the component is unknown or doesn't expose `API`.

Example:

```lua
local Controls = Engine:GetComponent("Controls")
Controls:Move(1)
```

---

## Component loading & priorities

**Component discovery**

* `ComponentList` defines which modules will be `require`d at load time (default: `{"Render","Controls"}`).
* `LoadComponents()` tries to `require(name)` for each name and registers the module only if `module.Initialize` exists.

**Priorities**

* `ComponentPriorities` maps component names to numeric priorities. Lower numbers tick earlier.
* The engine builds `_TickList` from registered components and sorts it by priority using `RebuildTickList()`.

If a component has no explicit priority in `ComponentPriorities`, it defaults to `1`.

**Example priorities**

* Controls = 1 (input and movement should happen early)
* Render   = 2 (render should run after movement)

This order avoids race conditions where render runs before movement or physics.

---

## Types (short)

* **Vector** - `BetterVector.Vector` (used for `PlayerPosition`)
* **GameConfig** - configuration passed to `Engine.Initialize` (see below)
* **RenderAPI** - expected API shape for the Render component (`AddRenderStep`, `RemoveRenderStep`, `OnRender`, `FOV`, etc.)
* **ControlsAPI** - expected API for Controls (`SetAngle`, `AddAngle`, `Move`, `PlayerSpeed`)

---

## GameConfig (reference)

`GameConfig` is a plain table with the following fields (Engine passes it to components):

* `TileMap` : `number[]` - row-major 1D array where `1 = wall`, `0 = empty`
* `TileMapWidth` : number
* `TileMapHeight` : number
* `PlayerPosition` : `BetterVector` (world coords)
* `PlayerAngle` : number (radians)
* `PlayerFOV` : number (degrees; Engine/Render converts to radians internally)
* `RaycasterRays` : number
* `RaycasterRayStepSize` : number
* `WallsColor`, `FloorColor`, `BackgroundColor` : `Color` objects

Notes:

* `TileMap` length must equal `TileMapWidth * TileMapHeight`.
* `PlayerPosition` must not be inside a wall tile.

---

## How to add a new component

1. Create a module file (e.g. `Physics.lua`) with at least an `Initialize(config, cpu, video)` function. Optionally implement `_Tick()` for per-frame logic and expose an `API` table for public methods.

2. Add the module name to `ComponentList`.

3. (Optional) Add a priority to `ComponentPriorities` so your component ticks in the right place relative to others.

4. Engine will `require` the module on startup and call `Initialize`. The engine builds the tick list and will call `_Tick()` if present.

**Minimal component skeleton**

```lua
local Physics = {}

local API = {}
function Physics.Initialize(config, cpu, video)
    -- init
end
function Physics._Tick()
    -- per-frame physics
end
Physics.API = API
return Physics
```

---

## Best practices & gotchas

* **One authoritative config**: Engine stores `Engine.Config` and passes the same table to all components. Do not expect components to share independent snapshots unless intentionally implemented.
* **Priority ordering matters**: set sensible priorities to avoid reading stale state. Input first, physics next, render last.
* **Expose a clean `API`**: components should expose only stable functions in `component.API` and avoid touching other modules directly.
* **Initialize once**: calling `Engine.Initialize` multiple times is a no-op after the first call. If you need hot-reload semantics, implement them inside components.
* **Error handling**: `LoadComponents()` uses `pcall` when requiring modules. If a module fails to load or doesn't provide `Initialize`, it is skipped and a message is printed.

---

## Example usage

```lua
local Engine = require("Engine")
local BetterVector = require("BetterVector")

local config = { TileMap = {...}, TileMapWidth = 15, TileMapHeight = 15, PlayerPosition = BetterVector.new(2, 100, 100), PlayerAngle = 0, PlayerFOV = 60, RaycasterRays = 100, RaycasterRayStepSize = 1 }

Engine.Initialize(config, gdt.CPU0, gdt.VideoChip0)
local Controls = Engine:GetComponent("Controls")

fu
```
