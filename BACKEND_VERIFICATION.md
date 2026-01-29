# Backend Verification (Task 3.2)

Verification status of the 3D rendering backends (OpenGL, Vulkan, Metal) and shader integration.

## Summary

| Backend   | Factory behavior        | Implementation status | Unit tests                          |
|-----------|--------------------------|------------------------|-------------------------------------|
| OpenGL    | Used for OpenGL type     | Complete               | Init, optional API, add/clear gamuts |
| Vulkan    | Fallback to OpenGL       | Present (Linux, HAVE_VULKAN) | Factory returns non-nil             |
| Metal     | Fallback to OpenGL       | Present (macOS, HAVE_METAL)   | Factory returns non-nil             |

## 1. OpenGLBackend

### Verified (unit tests)

- **Creation**: `[RenderBackendFactory createBackend:RenderBackendTypeOpenGL]` returns non-nil.
- **Initialization**: `initializeWithView:` succeeds when view is an `NSOpenGLView`; otherwise returns NO (test uses plain NSView, so init is skipped in headless run).
- **Optional API** (Task 2.3):
  - `setBackgroundRed:green:blue:` – stored and used in `render` for `glClearColor`.
  - `setRenderingQuality:` – stored and used in `render` for `glPointSize`.
- **Gamut models**: `addGamutModel:`, `clearGamutModels` – tested with a minimal `Gamut3DModel`.

### Implementation details

- Uses fixed-function pipeline (glBegin/glEnd, gluPerspective, gluLookAt).
- Does **not** use `shaders/simple.vert` or `shaders/simple.frag` (those are GLSL 450 for Vulkan).
- Lab axes/grid and gamut points are drawn with immediate-mode GL.

## 2. VulkanBackend

### Status

- **Factory**: `RenderBackend.m` currently returns an **OpenGL** backend for `RenderBackendTypeVulkan` (fallback). VulkanBackend is not instantiated by the factory in the default build.
- **Implementation**: `VulkanBackend.m` exists and is substantial (instance, device, surface, swapchain, pipeline). It is compiled when `HAVE_VULKAN` is defined (Linux, Vulkan headers available).
- **Shaders**: Looks for **SPIR-V** files `simple.vert.spv` and `simple.frag.spv` (compiled from `simple.vert` / `simple.frag`). The repo provides **source** GLSL in `shaders/simple.vert` and `shaders/simple.frag` (GLSL 450); they must be compiled to SPIR-V (e.g. with `glslc`) for Vulkan to use them.
- **Initialization**: Requires a real window/surface (X11 on Linux). Headless tests do not drive Vulkan init.

### Verification

- Unit test only checks that `createBackend:RenderBackendTypeVulkan` returns non-nil (currently an OpenGL instance).

## 3. MetalBackend

### Status

- **Factory**: `RenderBackend.m` currently returns an **OpenGL** backend for `RenderBackendTypeMetal` (fallback). MetalBackend is not instantiated by the factory in the default build.
- **Implementation**: `MetalBackend.m` exists; uses `MTLCreateSystemDefaultDevice()`, pipeline descriptor, and looks for default library functions `vertex_main` / `fragment_main`. No `.metal` shader file is in the repo; shaders would need to be added and compiled.
- **Platform**: Only active when `HAVE_METAL` is defined (macOS, non-GNUStep).

### Verification

- Unit test only checks that `createBackend:RenderBackendTypeMetal` returns non-nil (currently an OpenGL instance).

## 4. Renderer3D

### Verified (unit tests)

- **Creation**: `initWithView:backendType:` with a plain NSView and OpenGL type returns non-nil (backend may not have a real GL context).
- **clearGamutModels**: No crash; backend’s gamut list is cleared.
- **addGamutModel**: Accepts a `Gamut3DModel` and forwards to backend.
- **applySettings**: Calls `SettingsManager` and optional backend methods (background color, rendering quality); no crash.

## 5. Shaders

| File           | Purpose              | Used by        | Format   |
|----------------|----------------------|----------------|----------|
| simple.vert    | Vertex shader        | Vulkan (if SPIR-V built) | GLSL 450 |
| simple.frag    | Fragment shader     | Vulkan (if SPIR-V built) | GLSL 450 |

- **OpenGL**: Does not use these files; uses fixed pipeline.
- **Vulkan**: Expects `simple.vert.spv` and `simple.frag.spv`; source is in `shaders/`. To enable: compile with `glslc -o simple.vert.spv simple.vert` (and similarly for .frag) and place .spv files where the app loads them.
- **Metal**: Would require `.metal` sources and `vertex_main` / `fragment_main`; not present in repo yet.

## 6. Running verification tests

```bash
./tests/build_and_run_tests.sh
```

Relevant tests:

- **test_RenderBackend**: Factory, OpenGL creation, Vulkan/Metal creation (fallback), init (optional), OpenGL optional API, Renderer3D clearGamutModels/addGamutModel, Renderer3D applySettings, factory fallback.
- **test_SettingsManager**: Shared manager, load/save, properties (used indirectly by applySettings).
- **test_GamutComparator**: Volume, volume difference, overlap (gamut math used by UI).
- **test_ColorConverter**, **test_GamutCalculator**, **test_CIELABSpaceModel**: Color and visualization support.

## 7. Recommendations

1. **Vulkan/Metal in factory**: To use real Vulkan or Metal backends, change `RenderBackend.m` to instantiate `VulkanBackend` / `MetalBackend` when the corresponding type is requested and the platform supports it; keep OpenGL fallback when init fails.
2. **Vulkan shaders**: Add a build step to compile `shaders/simple.vert` and `shaders/simple.frag` to SPIR-V and ship or load the .spv files.
3. **Metal shaders**: Add a `.metal` file with `vertex_main` and `fragment_main` and wire it into the Metal pipeline.
4. **OpenGL**: Optional API and add/clear gamuts are covered by tests; full render path still requires a real NSOpenGLView and context (e.g. in the app or a dedicated integration test).
