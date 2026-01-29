# SmallColourSync

ICC Color Profile Editor and Visualizer

A cross-platform application for loading, editing, and visualizing ICC color profiles, targeting GNUStep (Linux) and macOS.

## Features

- **Load and Parse ICC Profiles**: Read ICC profile files and extract metadata, tags, and color space information
- **Edit ICC Tags**: Modify TRCs (Tone Reproduction Curves), matrices, LUTs (Look-Up Tables), and metadata
- **Gamut Visualization**: Visualize color gamuts relative to standard color spaces (sRGB, Adobe RGB, Display-P3, ProPhoto RGB, Rec. 2020)
- **3D CIELAB Visualization**: Interactive 3D view of the CIELAB color space with gamut boundaries plotted

## Architecture

### Application Layer
- `AppController`: Coordinates UI, file I/O, and rendering
- `SettingsManager`: Manages user preferences

### ICC Profile Handling
- `ICCProfile`: Represents a loaded ICC profile
- `ICCParser`: Parses ICC files using LittleCMS
- `ICCWriter`: Writes modified profiles back to disk
- `ICCTag` and subclasses: Specialized tag classes for editing

### Color Science
- `ColorSpace`: Abstract color space representation
- `StandardColorSpaces`: Definitions for standard color spaces
- `ColorConverter`: Converts between XYZ, Lab, and RGB
- `GamutCalculator`: Computes gamut boundaries

### Visualization
- `Gamut3DModel`: Stores gamut mesh/point cloud
- `CIELABSpaceModel`: Generates Lab space axes and grid
- `Renderer3D`: Handles 3D rendering with OpenGL
- `GamutComparator`: Compares multiple gamuts

### UI Layer
- `MainWindow`: Main application window
- `ProfileInspectorPanel`: Displays profile metadata
- `TagEditorPanel`: Edits ICC tags
- `GamutViewPanel`: 3D gamut visualization
- `HistogramAndCurvesPanel`: TRC visualization
- `FileBrowserPanel`: File loading/saving

## Dependencies

- **SmallStep**: Cross-platform framework (../SmallStep)
- **LittleCMS (lcms2)**: ICC profile parsing and manipulation
- **OpenGL**: 3D rendering (GL and GLU)

## Building

### Linux (GNUStep)

```bash
make
```

The Makefile will automatically detect available libraries (LittleCMS, OpenGL) and build accordingly.

### macOS

Build using Xcode or GNUstep Make on macOS.

## Usage

1. Launch the application
2. Use "Open Profile" to load an ICC profile file
3. View profile metadata in the inspector panel
4. Edit tags using the tag editor
5. Visualize the gamut in the 3D view
6. Save modified profiles using "Save Profile"

## License

GNU Affero General Public License v3.0

See LICENSE file for details.
