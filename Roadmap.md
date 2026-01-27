# Mazestein 3D – Roadmap

This document outlines the planned development path of **Mazestein 3D**
from the initial usable release to version **1.0**.

The roadmap focuses on stability, extensibility, and core engine features.
Dates are intentionally omitted — progress-driven development.

---

## v0.1 – Usable Prototype (Current)

Core goals:
- Prove that the engine is usable in real projects
- Establish public APIs
- Validate architecture decisions

Features:
- Raycasting renderer (step-based)
- Basic wall shading
- Configurable Raycaster
- Render step system with priorities
- Player movement and rotation (Controls component)
- Modular component-based engine structure

Limitations:
- No textures
- No sprites/entities

---

## v0.2 – Stability & API Cleanup

Goals:
- Finalize public APIs before expanding features

Planned changes:
- Safer component initialization order
- Better error messages and validation
- Expanded documentation per component
- GameConfig documentation

Optional:
- Minor render optimizations
- Small internal refactors (no breaking changes if possible)

---

## v0.3 – Map & World Improvements

Goals:
- Improve level creation and Error handling.

Planned features:
- Fully functional debugger and overall improved error handling
- Optional debug render mode (grid / rays)
---

## v0.4 – Visual Expansion

Goals:
- Make the engine visually more expressive without going full 3D

Planned features:
- Wall textures (basic texture mapping)
- Sprite rendering system
- Billboarding sprites
- Sprite render priorities
- Distance-based sprite scaling

---

## v0.5 – Entity System

Goals:
- Allow interactive objects in the world

Planned features:
- Entity component
- Basic entity update loop
- Renderable entities
- Simple collision with player
- Hooks for custom entity logic

Examples:
- Doors
- Pickups
- Enemies (logic-only, no AI yet)

---

## v0.6 – Performance & Rendering Improvements

Goals:
- Improve performance on larger maps
- Reduce CPU load

Planned features:
- Raycasting optimizations
- Render batching where possible
- Reduced overdraw
- Profiling utilities

Optional:
- Experimental renderer fork ideas (raymarching, SDFs)

---

## v0.7 – Tooling & Debugging

Goals:
- Make development easier for users

Planned features:
- Improve debugging (FPS, ray count, step size)
- Render step visualizer
- Engine state inspector

---

## v0.8 – Polish & UX

Goals:
- Improve developer experience

Planned features:
- Cleaner examples
- Better default configs
- Expanded documentation
- README overhaul
- Architecture diagrams
- Clear contribution guidelines

---

## v0.9 – Pre-Release Hardening

Goals:
- Prepare for a stable 1.0 release

Planned changes:
- Bug fixing
- Performance testing
- API freeze
- Documentation completeness

No new major features.

---

## v1.0 – Stable Release

Goals:
- Declare the engine stable and reliable

Guaranteed features:
- Stable public APIs
- Fully documented components
- Configurable raycasting renderer
- Modular component system
- Entity & sprite support
- Usable for small retro-style 3D games

---

## Post 1.0 Ideas (Not Guaranteed)

- Renderer forks (DDA / raymarching)

---

Mazestein 3D is designed to stay small, understandable, and hackable.
