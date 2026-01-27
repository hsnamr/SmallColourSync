# Next Steps - Building on Existing Implementation

This document maps the **ARCHITECTURE_PLAN.md** to the current implementation and provides concrete next steps.

## 📊 Current Implementation Status

### ✅ Fully Implemented (Matches Architecture Plan)

**Application Layer**
- ✅ `AppController` - Complete, coordinates UI, file I/O, rendering
- ✅ `SettingsManager` - Complete with NSUserDefaults persistence

**ICC Profile Handling**
- ✅ `ICCProfile` - Complete data model with header fields and tag dictionary
- ✅ `ICCParser` - Complete, uses LittleCMS to parse ICC files
- ✅ `ICCWriter` - Implemented with LittleCMS (needs enhancement for full tag serialization)
- ✅ `ICCTag` base class and all specialized classes:
  - ✅ `ICCTagTRC` - TRC handling with LittleCMS integration
  - ✅ `ICCTagMatrix` - Matrix handling
  - ✅ `ICCTagLUT` - LUT handling with LittleCMS pipeline integration
  - ✅ `ICCTagMetadata` - Metadata handling

**Color Science & Conversion**
- ✅ `ColorSpace` - Abstract representation
- ✅ `StandardColorSpaces` - All 5 required spaces (sRGB, Adobe RGB, Display-P3, ProPhoto RGB, Rec.2020)
- ✅ `ColorConverter` - XYZ ↔ Lab, RGB ↔ XYZ conversions
- ✅ `GamutCalculator` - Interface complete, computes gamut boundaries

**Visualization**
- ✅ `Gamut3DModel` - Complete data model for gamut mesh/point cloud
- ✅ `CIELABSpaceModel` - Generates Lab space axes and grid
- ✅ `Renderer3D` - Complete with multi-backend support (OpenGL/Vulkan/Metal)
- ✅ `RenderBackend` - Abstract interface
- ✅ `OpenGLBackend` - Implemented
- ✅ `VulkanBackend` - Present (conditional compilation)
- ✅ `MetalBackend` - Present (conditional compilation)
- ✅ `GamutComparator` - Present

**UI Layer - Structure**
- ✅ `MainWindow` - Complete layout with split views
- ✅ `FileBrowserPanel` - Fully implemented with open/save dialogs

---

### ⚠️ Partially Implemented (Needs Completion)

**UI Layer - Content**
- ⚠️ `ProfileInspectorPanel` - ~60% complete
  - ✅ Metadata display logic
  - ⚠️ UI components not initialized (NSTextView, NSTableView)
  - ⚠️ Tag table data source not implemented

- ⚠️ `TagEditorPanel` - ~30% complete
  - ✅ Basic structure
  - ⚠️ UI components not initialized
  - ⚠️ Tag editing logic not implemented
  - ⚠️ No TRC/Matrix/LUT/Metadata editors

- ⚠️ `HistogramAndCurvesPanel` - ~10% complete
  - ✅ Basic structure
  - ❌ No curve view implementation
  - ❌ No histogram display
  - ❌ No interactive editing

- ✅ `GamutViewPanel` - ~95% complete (mostly done!)

**ICC Writing**
- ⚠️ `ICCWriter` - ~70% complete
  - ✅ Basic profile creation with LittleCMS
  - ⚠️ Simplified tag serialization (needs full implementation)
  - ⚠️ Need to use `cmsWriteTag()` for all tag types

---

## 🎯 Immediate Next Steps (Priority Order)

### Step 1: Complete ProfileInspectorPanel UI (0.5-1 day)

**Goal**: Display profile metadata and tag list properly

**Tasks**:
1. Initialize UI components in `ProfileInspectorPanel.m`:
   ```objc
   - Create NSTextView with NSScrollView for metadata
   - Create NSTableView with NSScrollView for tag list
   - Set up layout (split view or constraints)
   - Configure table columns: Tag Signature, Tag Type, Size
   ```

2. Implement NSTableView data source:
   ```objc
   - Implement numberOfRowsInTableView:
   - Implement tableView:objectValueForTableColumn:row:
   - Populate from profile.allTagSignatures
   ```

3. Enhance metadata display:
   ```objc
   - Use attributed strings for better formatting
   - Add section headers
   - Make text view read-only but selectable
   ```

**Files**: `ui/ProfileInspectorPanel.m`, `ui/ProfileInspectorPanel.h`

---

### Step 2: Complete TagEditorPanel UI (1-2 days)

**Goal**: Allow editing of ICC tags (TRCs, matrices, LUTs, metadata)

**Tasks**:
1. Initialize UI components:
   ```objc
   - Create NSPopUpButton for tag selection
   - Create container NSView for tag-specific editors
   - Set up autoresizing masks
   ```

2. Implement tag selection:
   ```objc
   - Populate popup with profile.allTagSignatures
   - Handle selection change
   - Show appropriate editor based on tag type
   ```

3. Implement TRC Editor:
   ```objc
   - Create custom NSView for curve display
   - Use LittleCMS cmsEvalToneCurveFloat() to sample curve
   - Draw curve with NSBezierPath
   - Allow point editing (optional initially)
   - Convert edited points back to cmsToneCurve using cmsBuildParametricToneCurve() or cmsBuildTabulatedToneCurve()
   ```

4. Implement Matrix Editor:
   ```objc
   - Create 3x3 grid of NSTextField for matrix
   - Create 3 NSTextField for offset vector
   - Validate numeric input
   - Update ICCTagMatrix when edited
   ```

5. Implement LUT Editor (basic):
   ```objc
   - Display LUT dimensions and size
   - Show read-only info (full editing is complex)
   - Option to import/export LUT data
   ```

6. Implement Metadata Editor:
   ```objc
   - NSTextField or NSTextView for text content
   - Handle character encoding
   - Update ICCTagMetadata when edited
   ```

**Files**: `ui/TagEditorPanel.m`, `ui/TagEditorPanel.h`
**Optional**: Create `ui/TRCCurveView.h/m` for reusable curve view

---

### Step 3: Implement HistogramAndCurvesPanel (1-2 days)

**Goal**: Visualize TRC curves and histograms

**Tasks**:
1. Create TRC curve view:
   ```objc
   - Custom NSView subclass
   - Use LittleCMS cmsEvalToneCurveFloat() to sample curve
   - Draw axes, grid, and curve
   - Support multiple curves (R, G, B) with different colors
   - Handle coordinate transformation
   ```

2. Implement histogram display:
   ```objc
   - Sample data from profile (if available)
   - Draw histogram bars
   - Coordinate with curve view
   ```

3. Integration:
   ```objc
   - Connect to current profile
   - Display rTRC, gTRC, bTRC tags
   - Update when profile changes
   ```

**Files**: `ui/HistogramAndCurvesPanel.m`, `ui/HistogramAndCurvesPanel.h`
**Note**: Can reuse TRCCurveView from TagEditorPanel if created

---

### Step 4: Enhance ICCWriter (1 day)

**Goal**: Full tag serialization using LittleCMS

**Tasks**:
1. Review current implementation and identify missing tag types

2. Implement full tag writing using LittleCMS APIs:
   ```objc
   // TRC tags
   cmsToneCurve *curve = cmsBuildParametricToneCurve(NULL, type, params);
   cmsWriteTag(hProfile, cmsSigRedTRCTag, curve);
   
   // Matrix tags
   cmsWriteTag(hProfile, cmsSigRedMatrixColumnTag, matrix);
   
   // LUT tags
   cmsWriteTag(hProfile, cmsSigAToB0Tag, pipeline);
   
   // Metadata tags
   wchar_t *text = ...; // Convert from NSString
   cmsWriteTag(hProfile, cmsSigProfileDescriptionTag, text);
   
   // Colorant tags
   cmsCIEXYZ xyz = {...};
   cmsWriteTag(hProfile, cmsSigRedColorantTag, &xyz);
   ```

3. Convert ICCTag objects to LittleCMS structures:
   - `ICCTagTRC` → `cmsToneCurve*`
   - `ICCTagMatrix` → matrix structure
   - `ICCTagLUT` → `cmsPipeline*` (already loaded)
   - `ICCTagMetadata` → wide string

4. Test write/read round-trip

**Files**: `icc/ICCWriter.m`

---

### Step 5: Verify and Polish (1-2 days)

**Tasks**:
1. Verify StandardColorSpaces - check all 5 spaces are correct
2. Test ColorConverter with known test cases
3. Verify GamutCalculator produces correct results
4. Integrate SettingsManager throughout UI
5. Test with real ICC profiles
6. Error handling improvements
7. UI polish

---

## 🔧 Implementation Notes

### Using LittleCMS Effectively

Since we're using LittleCMS, the work is primarily:
1. **UI Implementation** - Create views and controls
2. **Data Conversion** - Convert between Objective-C objects and LittleCMS structures
3. **LittleCMS API Calls** - Use existing functions for ICC operations

**Key LittleCMS Functions**:
- `cmsOpenProfileFromMem()` - Already used in ICCParser
- `cmsReadTag()` - Already used in ICCParser
- `cmsWriteTag()` - Need to use in ICCWriter
- `cmsBuildParametricToneCurve()` - For TRC creation
- `cmsBuildTabulatedToneCurve()` - For table-based TRCs
- `cmsEvalToneCurveFloat()` - For curve sampling/display
- `cmsCreateProfile()` - For profile creation
- `cmsSaveProfileToMem()` - Already used in ICCWriter

### Architecture Alignment

The current implementation **already matches** the architecture plan:
- ✅ All classes exist and are structured correctly
- ✅ LittleCMS is integrated for ICC operations
- ✅ Multi-backend rendering is implemented
- ✅ Color science components are in place

**What's missing**: Primarily UI completion and full tag serialization.

---

## 📋 Quick Reference: What to Build Next

1. **ProfileInspectorPanel** - Initialize UI, implement table data source
2. **TagEditorPanel** - Build tag editors (TRC, Matrix, LUT, Metadata)
3. **HistogramAndCurvesPanel** - Create curve/histogram views
4. **ICCWriter** - Use `cmsWriteTag()` for all tag types
5. **Testing & Polish** - Verify everything works

---

## 🎯 Success Criteria

- ✅ All UI panels display and function correctly
- ✅ Can load, view, edit, and save ICC profiles
- ✅ Gamut visualization works
- ✅ Tag editing works for all tag types
- ✅ Application is usable end-to-end

---

## 📚 Resources

- **LittleCMS Documentation**: http://www.littlecms.com/
- **LittleCMS API Reference**: Check `lcms2.h` for function signatures
- **ICC Specification**: For understanding tag structures
- **Current Codebase**: All components exist, just need completion

---

**Remember**: Don't start over! Build on what exists. The architecture is solid, the foundation is there. Focus on completing the UI and enhancing ICCWriter.
