# Mazestein 3D — Overview

A lightweight 2.5D raycasting engine written in Lua. Designed for clarity, modularity and easy extension. Perfect for small retro-style projects, prototypes, and educational uses.

---

## Quick facts

* **Language:** Lua (Works only in Retro Gadgets)
* **Style:** Component-based architecture (Engine + separate components like Render, Controls)
* **Primary use:** Maze games, simple shooters, demos and experiments with raycasting

---

## Features

* Component-based engine with predictable tick order
* Simple configurable raycaster with adjustable `RayStepSize` and ray count
* Basic shading (distance-based) and configurable colors
* Small, dependency-light design - relies on `BetterVector` and `BetterEvents` utilities

---

## Architecture & components

The engine uses a minimal set of components. Each component exposes an `Initialize` and `_Tick` (optional) method and an API table when needed.

* **Engine** - bootstrapper and manager. Loads components, builds a prioritized tick list and exposes `Engine.Initialize(config, cpu, video)` and `Engine.Update()`.
* **Render** - raycaster and renderer. Handles rendering steps (Clear, Background, Floor, Walls, etc.) and exposes `API:AddRenderStep(name, priority, callback)` and `OnRender` event.
* **Controls** - player movement and rotation helpers (Move, AddAngle, etc.).

Each component should ship its own documentation file (see links below).

---

## Quick start
first import all scripts from [Export](https://github.com/NOIST1611/Mazestein3D/tree/main/export) folder
and after that you could start work with Mazestein 3D

```lua
local BetterVector = require("BetterVector")
local Engine = require("Engine")

local GameConfig = {
  TileMap = generatedMap,          -- 1D array (row-major): 1 = wall, 0 = empty
  TileMapWidth = 15,
  TileMapHeight = 15,
  PlayerPosition = BetterVector.new(2, 150, 150),
  PlayerAngle = 0,
  PlayerFOV = 60,                  -- degrees (engine converts to radians)
  RaycasterRays = 125,
  RaycasterRayStepSize = 1,
  WallsColor = Color(180,180,100),
  FloorColor = Color(80,60,40),
  BackgroundColor = Color(100,120,140),
}

Engine.Initialize(GameConfig, gdt.CPU0, gdt.VideoChip0)

function update()
  Engine.Update()
end
```

---

## Configuration reference (short)

* `TileMap` - `number[]` (row-major). Length must equal `TileMapWidth * TileMapHeight`.
* `TileMapWidth`, `TileMapHeight` - integers.
* `PlayerPosition` - `BetterVector` in world units; must not be inside a wall tile.
* `PlayerAngle` - radians (0 = right).
* `PlayerFOV` - degrees (converted internally to radians).
* `RaycasterRays` - integer, number of vertical slices (quality vs perf).
* `RaycasterRayStepSize` - integer, stepping resolution for rays (1 = best quality, higher = faster).
* `WallsColor`, `FloorColor`, `BackgroundColor` — colors in `Color(r,g,b)` format.

---

## Documentation links (component-level)

* [Engine docs](https://github.com/NOIST1611/Mazestein3D/blob/main/docs/Engine.md)
* [Render docs](https://github.com/NOIST1611/Mazestein3D/blob/main/docs/Render.md)
* [Controls docs](https://github.com/NOIST1611/Mazestein3D/blob/main/docs/Controls.md)

## External dependencies / related projects

* [BetterVector (vector utility)](https://github.com/NOIST1611/BetterVector)
* [BetterEvents (event utility)](https://github.com/NOIST1611/BetterEvents)

## Example gadget / demo

* [Maze demo example (uses the DFS generator)](https://github.com/NOIST1611/Mazestein3D/tree/main/examples/V0.1)

---

*This overview is a short entry point - see the individual component docs for full API details and examples.*
