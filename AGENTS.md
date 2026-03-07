# AGENTS.md: Guidelines for Agentic Coding

This document provides guidelines for AI agents and tooling operating on this Odin language codebase.

## Project Overview

This is a **2D physics sandbox** built in **Odin**, integrating:
- **Box2D** physics engine (`vendor:box2d`)
- **Raylib** graphics library (`vendor:raylib`)

The codebase is minimal (~360 lines across 4 source files) with no external package managers, build configs, or test runners.

---

## Build, Run & Test Commands

### Build
```bash
odin build src/
```
Output binary: `src.bin`

### Run
```bash
odin run src/
```
Launches the physics sandbox window.

### Run All Tests
```bash
odin test src/
```

### Run Single Test
```bash
odin test src/ -define:ODIN_TEST_THREADS=1 | grep -A 20 "testing_hex_2_rgb"
```
Or rebuild and run just the test file:
```bash
odin test src/extra/debug_rendering.odin
```

### Clean
```bash
rm -f src.bin
```

---

## Project Structure

```
src/
  main.odin                    # Entry point (14 lines) - wires world creation and render loop
  extra/
    constants.odin            # Compile-time constants (9 lines)
    world.odin                # Physics domain model & lifecycle (105 lines)
    rendering.odin            # Render loop, camera, coordinate mapping (121 lines)
    debug_rendering.odin      # Box2D debug callbacks, color utilities (113 lines)
```

**Package naming:** All files in `extra/` declare `package core` (the logical package name).

---

## Code Style Guidelines

### Imports

**Vendor packages** use short aliases:
```odin
import b2 "vendor:box2d"
import xray "vendor:raylib"
```

**Standard library** imports use full paths without aliases:
```odin
import "core:fmt"
import "core:log"
import "core:math"
import "core:testing"
```

**Local imports** are unaliased:
```odin
import "extra"
```

**Ordering:** Group imports (vendor, core, local) with blank lines between; alphabetize within groups.

### Formatting

- **Indentation:** Tabs (not spaces)
- **No semicolons:** Odin does not use them
- **Trailing commas:** Use in multi-line struct literals and function calls
- **Braces:** Opening brace on same line; closing brace on new line
- **Line length:** Keep readable; break long calls across multiple lines with indentation

### Naming Conventions

- **Files:** `snake_case` (e.g., `debug_rendering.odin`)
- **Procedures (functions):** `camelCase` (e.g., `createWorld`, `makeDebugDrawer`)
- **Struct types:** `PascalCase` (e.g., `World`, `DebugRenderData`)
- **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `PIXELS_PER_METER`, `FPS`)
- **Variables/parameters:** `camelCase` for loop/param variables; `snake_case` for struct fields and definitions
- **Packages:** `core` for logical package name (convention in `extra/`)

### Type Usage

- **Explicit types:** Always declare types on struct fields and procedure return values
- **Named returns:** Use named return values; they can be returned with bare `return` statement:
  ```odin
  getWorldAABB :: proc(camera: xray.Camera2D) -> (aabbMin, aabbMax: b2.Vec2) {
      // ... computation ...
      return  // implicitly returns both aabbMin and aabbMax
  }
  ```
- **Struct definitions:** Use `::` constant declaration syntax:
  ```odin
  World :: struct { ... }
  ```
- **Avoid `any` and `rawptr`:** Only use `rawptr` for C interop (immediately cast to typed pointer)

### Error Handling

**No explicit error handling** is currently used in this codebase. Fallible operations (e.g., `b2.CreateWorld()`) are called without error checks.

**Resource cleanup:** Use `defer` consistently:
```odin
defer {extra.releaseWorld(world)}
defer xray.CloseWindow()
```

### Comments & Documentation

- Keep comments **sparse** and **inline**
- Use comments only for clarifying non-obvious logic or architectural decisions
- **No doc comments** (`///` or `/** */`) are used
- Commented-out code should have implicit context (e.g., "trying a different approach")

### Export Patterns

Odin uses **capitalization-based visibility**: uppercase = exported. This codebase uses **all lowercase-initial names**, making all procedures **package-private** by default. Cross-package calls use fully qualified names:
```odin
extra.createWorld()
```

### Framework-Specific Patterns

#### Box2D Lifecycle: Create/Release Symmetry
Every `create*` has a matching `release*`:
```odin
createWorld / releaseWorld
createBody / releaseBody
```

#### Raylib: Begin/End with Defer
Every `Begin*` is immediately followed by `defer End*`:
```odin
xray.BeginDrawing()
defer xray.EndDrawing()
```

#### C Interop for Box2D Callbacks
C-calling-convention callbacks restore the Odin runtime context:
```odin
DrawPolygonFcn = proc "c" (vertices: [^]b2.Vec2, ..., ctx: rawptr) {
    data := cast(^DebugRenderData)(ctx)
    context = data.ctx  // restore Odin context
    // ... Box2D callback implementation ...
}
```

#### SOA Dynamic Arrays
This codebase uses Structure-of-Arrays layout for performance:
```odin
boxes: #soa[dynamic]Box
append_soa(&world.boxes, createBody(...))
```

### Logging

Use `core:log` for all output (no `fmt.println`):
```odin
context.logger = log.create_console_logger(log.Level.Debug)
log.debug("message")
log.debugf("formatted %v", value)
```

### Testing

Tests use Odin's built-in `@(test)` attribute and `core:testing` package:
```odin
@(test)
testing_<function_name> :: proc(t: ^testing.T) {
    testing.expect_value(t, actual, expected)
}
```

- **Naming:** `testing_<function_name>` prefix
- **Location:** Same file as the code being tested
- **Scope:** Currently only utility functions (e.g., `hex_2_rgb`) are tested

---

## Git Commit Message Convention

Format: `[TYPE] (scope): description`

**Types:**
- `[FEATURE]` – New feature
- `[FIX]` – Bug fix
- `[REFACTOR]` – Code refactoring (no behavior change)

**Scope:** File or concern name (e.g., `rendering`, `debug_rendering`, `world`, `log`)

**Example:**
```
[FEATURE] (rendering): cull debug drawing to visible screen area using world AABB
[FIX] (world): center capsule shape around body origin
[REFACTOR] (debug_rendering): simplify hex_2_rgb by delegating to raylib's GetColor
```

---

## Development Workflow

1. **Read source files** to understand the current state and any existing patterns
2. **Run tests** before making changes: `odin test src/`
3. **Build and test** after changes: `odin build src/ && odin test src/`
4. **Follow naming & formatting conventions** (see above)
5. **Add tests** for new utility functions using `@(test)` attribute
6. **Use `defer`** for all resource cleanup
7. **Commit with structured messages** following the convention above

---

## Dependencies & Vendor System

- Odin's **vendor system** automatically manages Box2D and Raylib bindings
- No `package.json` or external package manager—dependencies are built into Odin's stdlib
- To use a vendor library: `import "vendor:box2d"` (with alias recommended for clarity)
