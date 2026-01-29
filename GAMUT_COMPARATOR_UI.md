# GamutComparator UI (Task 3.1)

Gamut comparison controls are integrated into `GamutViewPanel`: add standard color spaces, toggle visibility, and view volume stats.

## What Was Done

### 1. Renderer3D (`visualization/Renderer3D.h`, `.m`)

- **`clearGamutModels`**: Forwards to the backend so the panel can clear all gamuts and re-add profile + comparisons.

### 2. GamutViewPanel – Comparison UI (OpenGL backend only)

When the backend is OpenGL, a **comparison panel** is shown on the right (220 pt wide):

- **Add comparison**  
  Pop-up with: “Add comparison…”, separator, then **sRGB**, **Adobe RGB**, **Display P3**, **ProPhoto RGB**, **Rec. 2020**.  
  Choosing a space computes its gamut via `GamutCalculator computeGamutForColorSpace:` and adds a `Gamut3DModel` to the comparison list with a default color (green, blue, cyan, yellow, magenta).

- **Comparison table**  
  Two columns: **Gamut** (name) and **Show** (checkbox).  
  Toggling **Show** updates visibility and redraws (only visible gamuts are added to the renderer).

- **Remove selected**  
  Button below the table. Removes the selected comparison and refreshes the view.

- **Statistics**  
  Text field at the bottom uses `GamutComparator` to show:
  - Approximate volume for each visible gamut (profile + comparisons).
  - Volume difference and percentage between the first two visible gamuts (profile vs first comparison when applicable).

### 3. Data and Refresh

- **Comparison entries**: `comparisonEntries` is an array of dicts: `@"model"` → `Gamut3DModel`, `@"visible"` → `NSNumber` (BOOL).
- **`refreshGamuts`**: Clears backend gamuts, adds profile gamut (if any), adds each visible comparison model, sets Lab space model from settings, updates stats, and marks the view for redraw.
- **`displayProfile:`**: Sets `currentProfile` and calls `refreshGamuts` so the profile gamut and all visible comparisons are shown together.

### 4. Layout (OpenGL)

- **`glContentView`**: The NSOpenGLView used for 3D; created first and passed to `Renderer3D` so the backend gets the real OpenGL view. Resized to leave room for the comparison panel on the right.
- **`layoutComparisonPanel`**: Called from `init` and `setFrame:` so the 3D view and comparison panel split the width (3D on the left, panel width 220 pt).

### 5. Non-OpenGL backends

For Vulkan/Metal, no comparison panel is created; `comparisonEntries` is still used so that when/if the backend is switched or the same logic is reused, comparisons are preserved. Profile gamut and `refreshGamuts` behave the same; only the UI for adding/removing and toggling comparisons is omitted.

## GamutComparator Usage

- **`computeVolume:`**: Bounding-box–based approximate volume (existing implementation).
- **`computeVolumeDifference:and:`**: Absolute difference of two volumes.
- **`findOverlap:and:`**: Not used in the UI; overlap could be wired later (e.g. highlight or stats).

## Files Touched

- `visualization/Renderer3D.h`, `.m` – `clearGamutModels`.
- `ui/GamutViewPanel.h` – Protocol, ivars for comparison panel and table.
- `ui/GamutViewPanel.m` – Comparison panel, pop-up, table, stats, `refreshGamuts`, `displayProfile` update, NSTableView data source/delegate.

## Optional Follow-ups

- Color picker per gamut (e.g. column or double-click to change color).
- Use `findOverlap` in the stats area or to highlight overlap in the 3D view.
- Show comparison panel for Vulkan/Metal when those backends support multiple gamuts.
