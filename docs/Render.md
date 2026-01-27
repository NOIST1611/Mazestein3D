# Render Component

The **Render** component is responsible for all visual output in Mazestein 3D.
It implements a classic 2.5D raycasting renderer with a configurable render
pipeline and user-extensible render steps.

This component exposes a small public API designed to be safe to use without
touching internal renderer state.

---

## Responsibilities

- Raycasting-based wall rendering
- Floor and background rendering
- Render step pipeline (similar to Roblox's RenderStepped concept)
- Frame-based render events
- Basic lighting via distance-based shading

---

## Public API

The Render component exposes its functionality through the `API` table.

You can obtain it via:

```lua
local Render = Engine:GetComponent("Render")
```

---

## Properties

`Render.FOV : number`
Field of view in **radians**
This value is applied every frame and can be modified at runtime.

```lua
Render.FOV = math.rad(75)
```
* Internally synchronized with the renderer each tick.

---

`Render.OnRender : BetterEvent`
Event **once per rendered frame**
Callback receives `deltaTime` as an argument.

```lua
Render.OnRender:Connect(function(dt)
    print("Frame time:", dt)
end)
```
Useful for:
* Debugging

---

`Render.RenderPriorities : table`
A predefined set of render layer priorities.

```lua
Render.RenderPriorities = {
    Clear = 0,
    Background = 1,
    Ground = 2,
    Entities = 3,
    Walls = 4,
    Sprites = 5,
    UI = 6,
}
```
Use these when registering custom render steps.

---

## Methods

`Render:AddRenderStep(name, priority, callback)`
Registers a new render step into the render pipeline.
```lua
Render:AddRenderStep(
    "DebugGrid",
    Render.RenderPriorities.UI,
    function()
        -- draw debug stuff
    end
)
```
parameters
| Name           | Description                                 |
| ---------------- | ------------------------------------------- |
| `name`           | unique step identifier                      |
| `priority`       | Render order priority                       |
| `callback`       | Function executed each frame                |

Steps are automatically sorted by priority.

---

`Render:RemoveRenderStep(name)`
Removes a previously registered render step.
```lua
Render:RemoveRenderStep("DebugGrid")
```
Safe to call even if the step does not exist.

---

## Render Pipeline Overview
The default pipeline consists of:

Clear screen

Background

Floor

Walls (raycasting)

---

## Notes & Limitations
    * Renderer currently uses step-based raycasting, not DDA.
    * Smaller ray step sizes improve visual quality but reduce performance.
    * Renderer assumes a grid-based tile map.
    * Texture support is planned but not available yet.
