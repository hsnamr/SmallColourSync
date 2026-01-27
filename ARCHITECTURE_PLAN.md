# 🧩 High-Level Application Plan

## 🎯 Core Goals

• Load, parse, and display ICC color profiles.
• Edit key ICC tags (metadata, TRCs, matrices, LUTs, etc.).
• Visualize the profile's gamut relative to standard color spaces (sRGB, Adobe RGB, Display‑P3, ProPhoto, etc.).
• Render a 3D interactive CIELAB space with the profile's gamut boundary plotted inside it.

---

## 🏗️ Proposed Class Structure

### 1. Application Layer

**AppController**
• Coordinates UI, file I/O, and rendering.
• Manages active ICC profile and comparison color spaces.

**SettingsManager**
• Stores user preferences (rendering quality, color space presets, UI layout).

---

### 2. ICC Profile Handling

**ICCProfile**
• Represents a loaded ICC profile.
• Fields for header, tag table, and parsed tag data.

**ICCParser**
• Reads ICC files.
• Extracts tags (A2B/B2A LUTs, TRCs, matrices, metadata).
• Converts raw tag data into usable structures.

**ICCWriter**
• Writes modified ICC profiles back to disk.

**ICCTag**
• Base class for all tag types.

**ICCTagTRC, ICCTagMatrix, ICCTagLUT, ICCTagMetadata**
• Specialized tag classes for editing and visualization.

---

### 3. Color Science & Conversion

**ColorSpace**
• Abstract representation of a color space (primaries, white point, TRC).

**StandardColorSpaces**
• Static definitions for sRGB, Adobe RGB, Display‑P3, ProPhoto, Rec.2020, etc.

**ColorConverter**
• Converts between:
  • XYZ ↔ Lab
  • RGB ↔ XYZ
  • Profile‑based transforms (using LUTs or matrices)

**GamutCalculator**
• Computes gamut hull (convex hull or mesh) for:
  • ICC profile
  • Standard color spaces

---

### 4. Visualization

**Gamut3DModel**
• Stores mesh/point cloud representing a gamut in Lab space.

**CIELABSpaceModel**
• Generates the 3D axes and bounding surfaces for the Lab space.

**Renderer3D**
• Handles 3D rendering (OpenGL/Vulkan/WebGPU depending on platform).
• Renders:
  • Lab axes
  • Gamut hulls
  • Interactive camera controls

**GamutComparator**
• Computes relative volume differences.
• Overlays multiple gamuts for comparison.

---

### 5. UI Layer

**MainWindow**
• Hosts all panels and views.

**ProfileInspectorPanel**
• Displays ICC metadata and tag structure.

**TagEditorPanel**
• Allows editing TRCs, matrices, LUTs, metadata.

**GamutViewPanel**
• 3D interactive view of the Lab space and gamut.

**HistogramAndCurvesPanel**
• For TRC visualization and editing.

**FileBrowserPanel**
• For loading/saving ICC profiles.

---

## 📚 Free & Open‑Source Libraries You Can Use

### 🟦 ICC Profile Parsing & Color Science

| Library | Language | Notes |
|---------|----------|-------|
| **LittleCMS (lcms2)** | C | Industry‑standard ICC engine; parsing, transforms, gamut checks. |
| OpenColorIO | C++ | Color management framework; supports ICC workflows. |
| ICCMax / SampleICC | C++ | Reference ICC parsing and manipulation. |

### 🎨 Color Math & Gamut Tools

| Library | Language | Notes |
|---------|----------|-------|
| Eigen | C++ | Matrix math for color transforms. |
| glm | C++ | OpenGL‑friendly math library. |

### 🧊 3D Rendering

| Library | Language | Notes |
|---------|----------|-------|
| OpenGL | C/C++ | Cross‑platform 3D rendering. |
| Vulkan | C/C++ | Modern low‑level rendering. |
| bgfx | C++ | Cross‑platform rendering abstraction. |

### 🧮 Geometry & Mesh Processing

| Library | Language | Notes |
|---------|----------|-------|
| CGAL | C++ | Convex hulls, mesh generation, computational geometry. |
| Qhull | C | Convex hulls for gamut boundary. |

---

## 🧱 Suggested Architecture Patterns

• MVC or MVVM for UI separation.
• Modular color engine so ICC parsing and color math are independent of UI.
• Plugin‑friendly design for adding new color spaces or visualization modes.

---

## 🔧 Implementation Flow (High‑Level)

1. Load ICC profile → parse tags → build internal ICCProfile object.
2. Convert profile gamut to Lab space using ColorConverter.
3. Compute gamut hull using GamutCalculator + Qhull/CGAL.
4. Generate Lab axes using CIELABSpaceModel.
5. Render 3D scene with Renderer3D.
6. Allow editing of TRCs, matrices, metadata.
7. Write updated profile using ICCWriter.
