# Controls Component

The **Controls** component handles player movement and rotation logic in
Mazestein 3D.

It provides a simple abstraction layer over player input, allowing external
code to move and rotate the player without directly modifying internal state.

---

## Responsibilities

- Forward/backward player movement
- Player rotation (yaw)
- Input-agnostic movement control
- Safe interaction with the player state

---

## Accessing the Component

```lua
local Controls = Engine:GetComponent("Controls")
```

---

№ Public API

`Controls:Move(direction)`
Moves the player forward or backward relative to the current facing direction.

```lua
Controls:Move(1)   -- move forward
Controls:Move(-1)  -- move backward
Controls:Move(0)   -- stop movement
```
parameters
| Name             | Description                                 |
| ---------------- | ------------------------------------------- |
| `forward`  | Movement direction (-1, 0, 1)                     |

Movement speed is handled internally by the engine.

---

`Controls:AddAngle(angleDelta)`
Rotates the player horizontally.

```lua
Controls:AddAngle(0.05)   -- rotate right
Controls:AddAngle(-0.05)  -- rotate left
```

parameters
| Name             | Description                                 |
| ---------------- | ------------------------------------------- |
| `angle`          | Rotation Delta in **radians**               |
Positive values rotate clockwise, negative values rotate counter-clockwise.

---

## Usage Example
```lua
function update()
    if inputForward then
        Controls:Move(1)
    else
        Controls:Move(0)
    end

    if inputRight then
        Controls:AddAngle(0.04)
    elseif inputLeft then
        Controls:AddAngle(-0.04)
    end
end
```

---

## Notes & Limitations
    * Controls operate on the player entity only
    * Collision handling is performed internally
    * Rotation affects raycasting and rendering immediately
    * Vertical movement is not supported (2.5D engine)
