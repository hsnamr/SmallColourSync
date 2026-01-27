# TODO - Quick Reference

Quick checklist of missing/incomplete work. See `IMPLEMENTATION_PLAN.md` for detailed tasks.

## 🔴 Critical (Must Complete)

### UI Components
- [ ] **TagEditorPanel** (~30% complete)
  - [ ] Initialize UI components (popup, editor view)
  - [ ] Implement tag selection
  - [ ] Implement TRC editor (curve view, point editing)
  - [ ] Implement Matrix editor (3x3 grid, offset vector)
  - [ ] Implement LUT editor (basic display/import)
  - [ ] Implement Metadata editor
  - [ ] Connect to AppController for updates

- [ ] **ProfileInspectorPanel** (~60% complete)
  - [ ] Initialize UI components (text view, table view)
  - [ ] Complete metadata display formatting
  - [ ] Implement tag table data source
  - [ ] Add table columns and sorting

- [ ] **HistogramAndCurvesPanel** (~10% complete)
  - [ ] Create custom TRC curve view
  - [ ] Implement histogram display
  - [ ] Connect to profile TRC tags
  - [ ] Add interactive editing (optional)

## 🟡 Important (Should Complete)

### Core Functionality
- [ ] **ICCWriter Enhancement** (~70% complete)
  - [ ] Implement full tag serialization (all tag types)
  - [ ] Proper header serialization
  - [ ] Error handling and validation
  - [ ] Test write/read round-trip

- [ ] **Color Science Verification**
  - [ ] Verify all 5 standard color spaces (Display-P3, ProPhoto RGB, Rec. 2020)
  - [ ] Complete/verify ColorConverter (some marked "simplified")
  - [ ] Verify GamutCalculator implementation
  - [ ] Verify CIELABSpaceModel

- [ ] **Settings Integration**
  - [ ] Use settings in GamutViewPanel (grid, axes, background color)
  - [ ] Use settings in Renderer3D (quality, colors)
  - [ ] Optional: Create preferences window

## 🟢 Nice to Have

### Advanced Features
- [ ] **GamutComparator UI**
  - [ ] Verify GamutComparator implementation
  - [ ] Add comparison controls to GamutViewPanel
  - [ ] Display comparison results

- [ ] **Backend Verification**
  - [ ] Verify OpenGLBackend (likely complete)
  - [ ] Verify VulkanBackend (may be stub)
  - [ ] Verify MetalBackend (may be stub)
  - [ ] Verify shader integration

## 📋 Testing & Polish

- [ ] **Comprehensive Testing**
  - [ ] Profile loading tests (various types)
  - [ ] Profile editing tests (round-trip)
  - [ ] Visualization tests
  - [ ] Cross-platform tests

- [ ] **Error Handling**
  - [ ] User-friendly error messages
  - [ ] Loading indicators
  - [ ] Input validation

- [ ] **UI Polish**
  - [ ] Visual refinements
  - [ ] Layout improvements
  - [ ] Accessibility

---

## Estimated Timeline

- **Phase 1 (Core UI)**: 2.5-5 days
- **Phase 2 (Core Functionality)**: 2-2.5 days  
- **Phase 3 (Advanced & Polish)**: 3.5-5.5 days
- **Total**: 8-13 days (~1.5-2.5 weeks)

**Note**: Estimates reduced because LittleCMS handles ICC format details - we mainly need UI and conversion to/from LittleCMS structures.

---

## Current Status: ~75-80% Complete
