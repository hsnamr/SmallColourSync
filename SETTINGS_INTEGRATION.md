# Settings Integration (Task 2.3)

Settings from `SettingsManager` are now applied to the gamut view and 3D renderer.

## What Was Done

### 1. RenderBackend protocol (`visualization/RenderBackend.h`)

- Added **optional** methods so backends can accept settings:
  - `setBackgroundRed:green:blue:` – background clear color (0–1)
  - `setRenderingQuality:` – 0=low, 1=medium, 2=high

### 2. OpenGLBackend (`visualization/OpenGLBackend.m`, `.h`)

- **Background color**: Instance vars `backgroundRed/Green/Blue` (default 0.1). `render` uses them in `glClearColor`.
- **Rendering quality**: Stored and used to set `glPointSize` (low=1, medium=2, high=3) when drawing gamut points.
- Implements `setBackgroundRed:green:blue:` and `setRenderingQuality:`.

### 3. Renderer3D (`visualization/Renderer3D.m`, `.h`)

- **`applySettings`**: Calls `[SettingsManager sharedManager]`, `loadSettings`, then:
  - If the backend implements `setBackgroundRed:green:blue:`, passes `backgroundColorRed/Green/Blue`.
  - If the backend implements `setRenderingQuality:`, passes `renderingQuality`.

### 4. GamutViewPanel (`ui/GamutViewPanel.m`, `.h`)

- **On init**: After creating the renderer, calls `[renderer applySettings]`.
- **On backend change**: `setPreferredBackend:` calls `[renderer applySettings]` after creating the new renderer.
- **On displayProfile**: When building the Lab space model, sets `showAxes` and `showGrid` from `SettingsManager` before passing the model to the renderer.
- **`refreshFromSettings`**: Reapplies settings to the renderer, re-displays the current profile (so Lab grid/axes update), and marks the view for redraw. Intended for use when preferences change (e.g. from a future Preferences window).

### 5. AppController (`app/AppController.m`)

- Uses `[SettingsManager sharedManager]` instead of allocating a new instance, so the app has a single settings instance.
- Does not release the shared manager in `dealloc`.

## Settings Used

| Setting               | Where used                         |
|-----------------------|------------------------------------|
| `showGrid`            | CIELABSpaceModel in gamut view     |
| `showAxes`            | CIELABSpaceModel in gamut view     |
| `backgroundColorRed/Green/Blue` | OpenGL clear color          |
| `renderingQuality`    | OpenGL point size for gamut points |

## Optional: Preferences window

The plan listed a preferences window as optional. When added, it should:

1. Read/write via `[SettingsManager sharedManager]`.
2. On “OK” or “Apply”, call `[settings saveSettings]` and notify the main window to call `[gamutViewPanel refreshFromSettings]` so the 3D view updates immediately.

## ProfileInspectorPanel

No display settings in `SettingsManager` (e.g. font size) were wired to ProfileInspectorPanel; no changes were made there. If such settings are added later, they can be applied in the same way (read from shared manager, apply in the panel).
