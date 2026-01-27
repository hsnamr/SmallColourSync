# SmallICCer Implementation Plan

Based on README.md requirements

## Project Overview
Cross-platform ICC Color Profile Editor and Visualizer targeting GNUStep (Linux) and macOS.

## Core Features (from README)

### 1. Load and Parse ICC Profiles
- **Requirement**: Read ICC profile files and extract metadata, tags, and color space information
- **Components**:
  - `ICCParser`: Parse ICC files using LittleCMS
  - `ICCProfile`: Represent loaded ICC profile with all header fields and tags
  - Support for reading from file path
  - Error handling for invalid/corrupted profiles

### 2. Edit ICC Tags
- **Requirement**: Modify TRCs (Tone Reproduction Curves), matrices, LUTs (Look-Up Tables), and metadata
- **Components**:
  - `ICCTag`: Base class for ICC tags
  - `ICCTagTRC`: Edit Tone Reproduction Curves
  - `ICCTagMatrix`: Edit matrix transformations
  - `ICCTagLUT`: Edit Look-Up Tables
  - `ICCTagMetadata`: Edit metadata tags
  - `ICCWriter`: Write modified profiles back to disk
  - `TagEditorPanel`: UI for editing tags

### 3. Gamut Visualization
- **Requirement**: Visualize color gamuts relative to standard color spaces (sRGB, Adobe RGB, Display-P3, ProPhoto RGB, Rec. 2020)
- **Components**:
  - `StandardColorSpaces`: Definitions for standard color spaces
  - `GamutCalculator`: Compute gamut boundaries
  - `Gamut3DModel`: Store gamut mesh/point cloud
  - `GamutViewPanel`: 3D gamut visualization UI
  - `GamutComparator`: Compare multiple gamuts

### 4. 3D CIELAB Visualization
- **Requirement**: Interactive 3D view of the CIELAB color space with gamut boundaries plotted
- **Components**:
  - `CIELABSpaceModel`: Generate Lab space axes and grid
  - `Renderer3D`: Handle 3D rendering with OpenGL
  - `RenderBackend`: Abstract rendering backend
  - `OpenGLBackend`: OpenGL implementation
  - `VulkanBackend`: Vulkan implementation (optional)
  - `MetalBackend`: Metal implementation (optional, macOS)
  - Mouse interaction for rotation/zoom
  - Viewport management

## Architecture Components

### Application Layer
- **AppController**: ✅ Coordinates UI, file I/O, and rendering
  - Initialize application
  - Load/save profiles
  - Coordinate between UI and data models
- **SettingsManager**: ✅ Manages user preferences
  - Store/load user settings
  - Preference persistence

### ICC Profile Handling
- **ICCProfile**: ✅ Represents a loaded ICC profile
  - Header fields (size, version, device class, color spaces, dates, etc.)
  - Tag dictionary
  - Tag access methods
- **ICCParser**: ✅ Parses ICC files using LittleCMS
  - Parse from file path
  - Parse from data
  - Extract header information
  - Extract and parse tags
  - Error handling
- **ICCWriter**: ✅ Writes modified profiles back to disk
  - Write profile to file
  - Serialize header
  - Serialize tags
  - Error handling
- **ICCTag and subclasses**: ✅ Specialized tag classes for editing
  - `ICCTag`: Base class
  - `ICCTagTRC`: TRC editing
  - `ICCTagMatrix`: Matrix editing
  - `ICCTagLUT`: LUT editing
  - `ICCTagMetadata`: Metadata editing

### Color Science
- **ColorSpace**: ✅ Abstract color space representation
  - Color space definition
  - Conversion support
- **StandardColorSpaces**: ✅ Definitions for standard color spaces
  - sRGB
  - Adobe RGB
  - Display-P3
  - ProPhoto RGB
  - Rec. 2020
- **ColorConverter**: ✅ Converts between XYZ, Lab, and RGB
  - XYZ to Lab conversion
  - Lab to XYZ conversion
  - RGB to XYZ conversion
  - XYZ to RGB conversion
- **GamutCalculator**: ✅ Computes gamut boundaries
  - Sample RGB space
  - Convert samples to Lab
  - Compute convex hull
  - Generate gamut mesh

### Visualization
- **Gamut3DModel**: ✅ Stores gamut mesh/point cloud
  - Vertex storage
  - Face indices
  - Color for rendering
  - Name/label
- **CIELABSpaceModel**: ✅ Generates Lab space axes and grid
  - Generate axes
  - Generate grid lines
  - Coordinate system visualization
- **Renderer3D**: ✅ Handles 3D rendering with OpenGL
  - Initialize renderer
  - Add gamut models
  - Set Lab space model
  - Render frame
  - Mouse interaction (rotation, zoom)
  - Viewport management
- **RenderBackend**: ✅ Abstract rendering interface
  - Backend type enum
  - Protocol definition
- **OpenGLBackend**: ✅ OpenGL implementation
  - OpenGL context setup
  - Rendering implementation
  - Shader support
- **VulkanBackend**: ✅ Vulkan implementation (optional)
  - Vulkan initialization
  - Rendering implementation
- **MetalBackend**: ✅ Metal implementation (optional, macOS)
  - Metal initialization
  - Rendering implementation
- **GamutComparator**: ✅ Compares multiple gamuts
  - Multiple gamut storage
  - Comparison visualization
  - Overlay rendering

### UI Layer
- **MainWindow**: ✅ Main application window
  - Window setup
  - Panel layout (split views)
  - Coordinate panels
  - Profile load notification
- **ProfileInspectorPanel**: ✅ Displays profile metadata
  - Display header fields
  - Display tag list
  - Metadata visualization
- **TagEditorPanel**: ✅ Edits ICC tags
  - Tag selection
  - Tag editing UI
  - TRC editing
  - Matrix editing
  - LUT editing
  - Metadata editing
- **GamutViewPanel**: ✅ 3D gamut visualization
  - 3D view setup
  - Renderer integration
  - Mouse interaction
  - Profile gamut display
  - Standard space comparison
- **HistogramAndCurvesPanel**: ✅ TRC visualization
  - TRC curve display
  - Histogram display
  - Interactive editing
- **FileBrowserPanel**: ✅ File loading/saving
  - Open file dialog
  - Save file dialog
  - File path display
  - Integration with AppController

## Dependencies
- **SmallStep**: ✅ Cross-platform framework (../SmallStep)
- **LittleCMS (lcms2)**: ✅ ICC profile parsing and manipulation
- **OpenGL**: ✅ 3D rendering (GL and GLU)
- **Vulkan**: ✅ Optional 3D rendering (Linux)
- **Metal**: ✅ Optional 3D rendering (macOS)

## Build System
- **GNUmakefile**: ✅ Cross-platform build configuration
  - GNUStep integration
  - Library detection (LittleCMS, OpenGL, Vulkan)
  - Conditional compilation
  - SmallStep framework linking

## Usage Workflow
1. ✅ Launch the application
2. ✅ Use "Open Profile" to load an ICC profile file
3. ✅ View profile metadata in the inspector panel
4. ✅ Edit tags using the tag editor
5. ✅ Visualize the gamut in the 3D view
6. ✅ Save modified profiles using "Save Profile"

## Additional Components (from file structure)
- **VulkanShaderLoader**: ✅ Shader loading for Vulkan backend
- **Shader files**: ✅ simple.vert, simple.frag in shaders/
- **Tests**: ✅ test_ColorConverter.m for color conversion testing
