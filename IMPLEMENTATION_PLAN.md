# Implementation Plan - Missing & Incomplete Features

This document outlines the tasks needed to complete SmallICCer based on the comparison with the PLAN.

**Current Status**: ~75-80% Complete  
**Target**: 100% Feature Complete

## Note on Estimates

**Estimates are based on using LittleCMS and other open-source libraries** that handle ICC format details. The work primarily involves:
- Creating UI components for editing
- Converting between our Objective-C data models and LittleCMS structures
- Using LittleCMS APIs like `cmsWriteTag()`, `cmsBuildParametricToneCurve()`, etc.

This is much faster than implementing ICC format parsing/writing from scratch. Most complexity is in UI implementation, not ICC format handling.

---

## Priority 1: Critical UI Components (High Priority)

### Task 1.1: Complete TagEditorPanel Implementation
**Status**: ~30% Complete  
**Estimated Effort**: 1-2 days  
**Dependencies**: ICCTag classes (complete)  
**Note**: LittleCMS handles ICC format - we just need UI to edit values and convert to/from LittleCMS structures

#### Subtasks:
1. **Initialize UI Components** (`TagEditorPanel.m`)
   - Create and layout `NSPopUpButton` for tag selection
   - Create container view for tag-specific editors
   - Set up autoresizing masks
   - Add to view hierarchy

2. **Implement Tag Selection**
   - Populate popup with all tag signatures from profile
   - Handle tag selection change
   - Display appropriate editor for selected tag type
   - Show "No tag selected" state

3. **Implement TRC Editor** (`ICCTagTRC` editing)
   - Create curve view (custom NSView subclass) - can use LittleCMS `cmsEvalToneCurveFloat()` for display
   - Display curve points graphically
   - Allow point manipulation (drag points) - then use `cmsBuildParametricToneCurve()` or `cmsBuildTabulatedToneCurve()`
   - Support parametric vs table curve types
   - Input validation
   - Update `ICCTagTRC` object when edited

4. **Implement Matrix Editor** (`ICCTagMatrix` editing)
   - Create 3x3 matrix input grid (NSTextField array)
   - Create 3-element offset vector input
   - Input validation (numeric only)
   - Real-time preview of transformation
   - Update `ICCTagMatrix` object when edited

5. **Implement LUT Editor** (`ICCTagLUT` editing)
   - Display LUT dimensions (input/output channels, grid points)
   - Show LUT data size
   - Option to import/export LUT data
   - Basic visualization (if feasible)
   - Update `ICCTagLUT` object when edited
   - Note: Full LUT editing is complex - may be read-only initially

6. **Implement Metadata Editor** (`ICCTagMetadata` editing)
   - Text field for metadata content
   - Support for different metadata formats
   - Character encoding handling
   - Update `ICCTagMetadata` object when edited

7. **Integration**
   - Connect to AppController for profile updates
   - Mark profile as "modified" when tags change
   - Handle profile save notifications

**Files to Modify**:
- `ui/TagEditorPanel.m` - Main implementation
- `ui/TagEditorPanel.h` - Add any needed methods/properties
- Potentially create: `ui/TRCCurveView.h/m` - Custom curve editor view

---

### Task 1.2: Complete ProfileInspectorPanel UI
**Status**: ~60% Complete  
**Estimated Effort**: 0.5-1 day  
**Dependencies**: None

#### Subtasks:
1. **Initialize UI Components** (`ProfileInspectorPanel.m`)
   - Create `NSTextView` for metadata display (with scroll view)
   - Create `NSTableView` for tag list
   - Create `NSScrollView` containers for both
   - Set up split view or layout constraints
   - Configure table view columns (Tag Signature, Tag Type, Size)

2. **Implement Metadata Display**
   - Format metadata string with proper layout
   - Use attributed string for better formatting
   - Add labels/sections for different metadata categories
   - Make text view read-only but selectable

3. **Implement Tag Table View**
   - Create data source for table view
   - Display tag signatures, types, and sizes
   - Handle row selection (could link to TagEditorPanel)
   - Sortable columns
   - Context menu for tag operations (view, edit, delete?)

4. **Update on Profile Load**
   - Clear previous data
   - Populate metadata view
   - Populate tag table
   - Handle nil profile state

**Files to Modify**:
- `ui/ProfileInspectorPanel.m` - Complete UI initialization and data source
- `ui/ProfileInspectorPanel.h` - Add data source protocol if needed

---

### Task 1.3: Implement HistogramAndCurvesPanel
**Status**: ~10% Complete  
**Estimated Effort**: 1-2 days  
**Dependencies**: ICCTagTRC (complete)  
**Note**: Can use LittleCMS `cmsEvalToneCurveFloat()` to sample curve for display

#### Subtasks:
1. **Create Custom Curve View**
   - Create `TRCCurveView` custom NSView subclass
   - Implement drawing of TRC curve
   - Draw axes and grid
   - Handle coordinate transformation (data space to view space)
   - Support multiple curves (R, G, B) with different colors

2. **Implement Histogram Display**
   - Create histogram view (or use existing curve view)
   - Sample data from profile (if available)
   - Display histogram bars
   - Coordinate with curve view

3. **Interactive Editing** (Optional - can be Phase 2)
   - Allow dragging curve points
   - Add control points
   - Delete control points
   - Smooth curve interpolation
   - Update profile TRC when edited

4. **Integration**
   - Connect to current profile
   - Display TRCs from profile (rTRC, gTRC, bTRC tags)
   - Update when profile changes
   - Handle profiles without TRC tags

5. **UI Layout**
   - Split view: curves on top, histogram below (or side-by-side)
   - Controls for curve selection (R/G/B/All)
   - Zoom/pan controls
   - Legend/key

**Files to Create/Modify**:
- `ui/HistogramAndCurvesPanel.m` - Main implementation
- `ui/HistogramAndCurvesPanel.h` - Add methods for profile display
- Potentially: `ui/TRCCurveView.h/m` - Reusable curve view (can share with TagEditorPanel)

---

## Priority 2: Core Functionality Enhancements (Medium Priority)

### Task 2.1: Enhance ICCWriter for Full Tag Serialization
**Status**: ~70% Complete (simplified implementation)  
**Estimated Effort**: 2-3 days  
**Dependencies**: All ICCTag classes

#### Subtasks:
1. **Review Current Implementation**
   - Understand what's currently serialized
   - Identify missing tag types
   - Test with real profiles

2. **Implement Full Tag Serialization**
   - Convert ICCTag objects to LittleCMS structures:
     - **TRC tags**: 
       - From `ICCTagTRC`: Extract curve points or parameters
       - Use `cmsBuildParametricToneCurve()` for parametric curves
       - Use `cmsBuildTabulatedToneCurve()` for table-based curves
       - Write with `cmsWriteTag(hProfile, cmsSigRedTRCTag, toneCurve)`
     - **Matrix tags**: 
       - From `ICCTagMatrix`: Extract matrix[3][3] and offset[3]
       - Use `cmsStageAllocMatrix()` or create matrix structure
       - Write with `cmsWriteTag()`
     - **LUT tags**: 
       - From `ICCTagLUT`: Extract LUT data
       - Use `cmsPipeline` structures (already loaded in ICCTagLUT)
       - Write with `cmsWriteTag(hProfile, cmsSigAToB0Tag, pipeline)`
     - **Metadata tags**: 
       - From `ICCTagMetadata`: Extract text
       - Convert NSString to wide string (wchar_t*)
       - Write with `cmsWriteTag(hProfile, cmsSigProfileDescriptionTag, text)`
     - **Colorant tags**: 
       - From profile: Extract XYZ values
       - Create `cmsCIEXYZ` structures
       - Write with `cmsWriteTag(hProfile, cmsSigRedColorantTag, xyz)`
   - **Key LittleCMS functions**:
     - `cmsWriteTag()` - Write any tag type
     - `cmsBuildParametricToneCurve()` - Create parametric TRC
     - `cmsBuildTabulatedToneCurve()` - Create table-based TRC
     - `cmsCreateProfile()` or modify existing profile handle
   - LittleCMS handles all ICC format details automatically

3. **Header Serialization**
   - Ensure all header fields are written correctly
   - Update profile size
   - Update creation date if modified
   - Preserve original fields when possible

4. **Error Handling**
   - Validate profile before writing
   - Check for required tags
   - Provide meaningful error messages

5. **Testing**
   - Test write/read round-trip
   - Compare original vs saved profiles
   - Test with various profile types (RGB, CMYK, etc.)

**Files to Modify**:
- `icc/ICCWriter.m` - Enhance serialization logic
- `icc/ICCWriter.h` - Add validation methods if needed

---

### Task 2.2: Verify and Complete Color Science Components
**Status**: ~85% Complete (needs verification)  
**Estimated Effort**: 1-2 days  
**Dependencies**: None

#### Subtasks:
1. **Verify StandardColorSpaces**
   - Check all 5 required spaces are implemented:
     - ✅ sRGB (confirmed)
     - ✅ Adobe RGB (confirmed)
     - ⚠️ Display-P3 (verify)
     - ⚠️ ProPhoto RGB (verify)
     - ⚠️ Rec. 2020 (verify)
   - Verify primaries and white points are correct
   - Test color space definitions

2. **Verify ColorConverter**
   - Test XYZ ↔ Lab conversions
   - Test RGB ↔ XYZ conversions
   - Verify with known test cases
   - Check edge cases (out of gamut, etc.)
   - Review implementation comments about "simplified" conversions

3. **Verify GamutCalculator**
   - Test RGB sampling
   - Test Lab conversion
   - Test convex hull computation
   - Verify gamut boundaries are correct
   - Test with known color spaces

4. **Verify CIELABSpaceModel**
   - Check axes generation
   - Check grid generation
   - Verify coordinate system
   - Test rendering integration

**Files to Review/Test**:
- `color/StandardColorSpaces.m` - Verify all spaces
- `color/ColorConverter.m` - Complete/verify conversions
- `color/GamutCalculator.m` - Verify implementation
- `visualization/CIELABSpaceModel.m` - Verify implementation
- `tests/test_ColorConverter.m` - Run and expand tests

---

### Task 2.3: Integrate Settings Throughout Application
**Status**: SettingsManager complete, integration unknown  
**Estimated Effort**: 0.5 day  
**Dependencies**: SettingsManager (complete)

#### Subtasks:
1. **GamutViewPanel Integration**
   - Use `showGrid` setting
   - Use `showAxes` setting
   - Use `backgroundColor` settings
   - Use `renderingQuality` setting

2. **Renderer3D Integration**
   - Apply rendering quality settings
   - Use background color
   - Apply grid/axes visibility

3. **ProfileInspectorPanel Integration**
   - Apply any relevant display settings

4. **Settings UI** (Optional)
   - Create preferences window
   - Allow user to change settings
   - Save settings on change

**Files to Modify**:
- `visualization/Renderer3D.m` - Use settings
- `ui/GamutViewPanel.m` - Use settings
- Potentially: `ui/PreferencesWindow.h/m` - New preferences UI

---

## Priority 3: Advanced Features (Low Priority)

### Task 3.1: Implement GamutComparator UI
**Status**: Core class exists, UI missing  
**Estimated Effort**: 1 day  
**Dependencies**: GamutComparator (verify implementation)

#### Subtasks:
1. **Verify GamutComparator Implementation**
   - Test volume computation
   - Test volume difference
   - Test overlap computation

2. **Add UI Controls**
   - Button to add standard color space for comparison
   - List of active comparisons
   - Toggle visibility of each gamut
   - Color picker for each gamut

3. **Display Comparison Results**
   - Show volume difference percentage
   - Highlight overlap regions
   - Display statistics panel

4. **Integration with GamutViewPanel**
   - Add multiple gamuts to renderer
   - Update when comparisons change
   - Handle gamut removal

**Files to Modify/Create**:
- `ui/GamutViewPanel.m` - Add comparison controls
- `ui/GamutViewPanel.h` - Add comparison methods
- Verify: `visualization/GamutComparator.m` - Implementation status

---

### Task 3.2: Verify Backend Implementations
**Status**: Files exist, functionality unknown  
**Estimated Effort**: 1-2 days  
**Dependencies**: None

#### Subtasks:
1. **Verify OpenGLBackend**
   - Test initialization
   - Test rendering
   - Test shader loading
   - Verify all features work

2. **Verify VulkanBackend** (Linux)
   - Check if implementation is complete or stub
   - Test initialization
   - Test rendering
   - Verify shader loading
   - Test fallback to OpenGL

3. **Verify MetalBackend** (macOS)
   - Check if implementation is complete or stub
   - Test initialization
   - Test rendering
   - Verify shader loading
   - Test fallback to OpenGL

4. **Verify Shader Integration**
   - Check `simple.vert` and `simple.frag` are used
   - Test shader compilation
   - Verify shader functionality

**Files to Review**:
- `visualization/OpenGLBackend.m`
- `visualization/VulkanBackend.m`
- `visualization/MetalBackend.m`
- `visualization/VulkanShaderLoader.m`
- `shaders/simple.vert`
- `shaders/simple.frag`

---

## Priority 4: Testing & Polish (Ongoing)

### Task 4.1: Comprehensive Testing
**Estimated Effort**: 1-2 days  
**Dependencies**: All Priority 1 & 2 tasks

#### Subtasks:
1. **Profile Loading Tests**
   - Test with various ICC profile types (RGB, CMYK, Grayscale, etc.)
   - Test with profiles from different sources
   - Test error handling (corrupted files, invalid formats)
   - Test large profiles

2. **Profile Editing Tests**
   - Test TRC editing and saving
   - Test matrix editing and saving
   - Test metadata editing and saving
   - Verify round-trip (load → edit → save → load)

3. **Visualization Tests**
   - Test gamut visualization with known profiles
   - Compare with reference visualizations
   - Test 3D interaction (rotation, zoom)
   - Test with multiple gamuts

4. **Cross-Platform Tests**
   - Test on Linux (GNUStep)
   - Test on macOS
   - Verify library detection works
   - Test fallback mechanisms

**Files to Create/Modify**:
- Expand `tests/test_ColorConverter.m`
- Create: `tests/test_ICCParser.m`
- Create: `tests/test_ICCWriter.m`
- Create: `tests/test_GamutCalculator.m`

---

### Task 4.2: Error Handling & User Feedback
**Estimated Effort**: 1 day  
**Dependencies**: All core features

#### Subtasks:
1. **Improve Error Messages**
   - Make error messages user-friendly
   - Add error codes and descriptions
   - Provide recovery suggestions

2. **Add User Feedback**
   - Loading indicators
   - Progress bars for long operations
   - Status messages
   - Success/error notifications

3. **Input Validation**
   - Validate user inputs in editors
   - Prevent invalid operations
   - Show validation errors

**Files to Modify**:
- All UI panels
- `app/AppController.m`
- `icc/ICCParser.m`
- `icc/ICCWriter.m`

---

### Task 4.3: UI Polish & Refinements
**Estimated Effort**: 0.5-1 day  
**Dependencies**: All UI components complete

#### Subtasks:
1. **Visual Refinements**
   - Consistent spacing and padding
   - Proper font sizes
   - Color scheme consistency
   - Icon usage (if applicable)

2. **Layout Improvements**
   - Better use of space
   - Responsive layouts
   - Proper split view behavior
   - Window resizing handling

3. **Accessibility**
   - Keyboard navigation
   - Accessibility labels
   - High contrast support (if needed)

**Files to Modify**:
- All UI panel files
- `ui/MainWindow.m`

---

## Implementation Order Recommendation

### Phase 1: Core UI Completion (Week 1-2)
1. Task 1.2: Complete ProfileInspectorPanel UI (1-2 days)
2. Task 1.1: Complete TagEditorPanel Implementation (3-4 days)
3. Task 1.3: Implement HistogramAndCurvesPanel (2-3 days)

**Goal**: All UI panels functional and usable

### Phase 2: Core Functionality (Week 3)
4. Task 2.1: Enhance ICCWriter (2-3 days)
5. Task 2.2: Verify Color Science Components (1-2 days)
6. Task 2.3: Integrate Settings (1 day)

**Goal**: Full save/load functionality, verified color science

### Phase 3: Advanced Features & Testing (Week 4)
7. Task 3.1: Implement GamutComparator UI (2 days)
8. Task 3.2: Verify Backend Implementations (1-2 days)
9. Task 4.1: Comprehensive Testing (2-3 days)
10. Task 4.2: Error Handling & User Feedback (1 day)
11. Task 4.3: UI Polish (1-2 days)

**Goal**: Feature complete, tested, polished

---

## Estimated Total Effort

- **Phase 1**: 6-9 days
- **Phase 2**: 4-6 days
- **Phase 3**: 7-10 days
- **Total**: 17-25 days (~3.5-5 weeks)

---

## Notes

1. **Dependencies**: Most tasks can be worked on in parallel after Phase 1
2. **Testing**: Should be ongoing, not just at the end
3. **Incremental**: Each task should be testable independently
4. **Documentation**: Consider adding code comments and user documentation as you go
5. **Git Workflow**: Consider feature branches for each major task

---

## Risk Areas

1. **LUT Editing**: Full LUT editing is complex - may need to be read-only initially. LittleCMS provides `cmsPipeline` manipulation but UI for editing large LUTs is still complex.
2. **Backend Implementations**: Vulkan/Metal may be stubs - need to verify
3. **Color Science**: Some conversions marked as "simplified" - may need enhancement, but LittleCMS can help if needed
4. **Cross-Platform**: Need to test on both Linux and macOS
5. **LittleCMS API**: Need to ensure we're using the right LittleCMS functions for tag writing (`cmsWriteTag()`, `cmsBuildParametricToneCurve()`, etc.)

---

## Success Criteria

- ✅ All UI panels fully functional
- ✅ Can load, view, edit, and save ICC profiles
- ✅ Gamut visualization works correctly
- ✅ All standard color spaces defined and working
- ✅ Settings persist and are used throughout app
- ✅ Error handling is robust
- ✅ Application works on both Linux and macOS
- ✅ Code is tested and polished
