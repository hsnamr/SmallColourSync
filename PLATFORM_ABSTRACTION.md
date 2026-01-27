# Platform Abstraction - Using SmallStep

This document describes how platform-specific code has been abstracted to use SmallStep framework.

## Changes Made

### 1. FileBrowserPanel - Now Uses SSFileDialog

**Before**: Used `NSOpenPanel` and `NSSavePanel` directly with platform-specific response codes (`NSModalResponseOK` vs `NSFileHandlingPanelOKButton`)

**After**: Uses `SSFileDialog` from SmallStep which handles platform differences automatically

**Files Modified**:
- `ui/FileBrowserPanel.m` - Now imports and uses `SSFileDialog`

### 2. RenderBackend - Now Uses SSPlatform

**Before**: Used platform detection macros (`__APPLE__`, `__GNUSTEP__`, `__linux__`)

**After**: Uses `SSPlatform` from SmallStep for platform detection

**Files Modified**:
- `visualization/RenderBackend.m` - Now imports and uses `SSPlatform.isMacOS()` and `SSPlatform.isLinux()`

## Code That Stays in This Project

### 3D Renderer Implementation

The following platform-specific code **intentionally remains** in this project as it's part of the 3D renderer implementation:

1. **OpenGLBackend.m** - Platform-specific OpenGL includes:
   - macOS: `<OpenGL/gl.h>`, `<OpenGL/glu.h>`
   - Linux: `<GL/gl.h>`, `<GL/glu.h>`
   - This is renderer-specific and should stay here

2. **MetalBackend.m** - macOS-only Metal rendering
   - Uses `#if defined(__APPLE__) && !defined(__GNUSTEP__)`
   - This is renderer-specific and should stay here

3. **VulkanBackend.m** - Linux-only Vulkan rendering
   - Uses `#if (defined(__GNUSTEP__) || defined(__linux__)) && defined(HAVE_VULKAN)`
   - This is renderer-specific and should stay here

4. **GamutViewPanel.m** - Uses `NSOpenGLView` and `NSOpenGLPixelFormat`
   - These are AppKit classes available on both platforms
   - Part of the 3D renderer implementation

## SmallStep Components Used

- **SSPlatform** - Platform detection (`isMacOS()`, `isLinux()`, etc.)
- **SSFileDialog** - Cross-platform file dialogs (`openDialog()`, `saveDialog()`, `showModal()`)

## Verification

All platform-specific UI code now uses SmallStep abstractions. The 3D renderer code remains in this project as it's renderer-specific and not general platform abstraction.

## Future Considerations

If additional platform abstractions are needed, they should be added to SmallStep rather than this project. Examples might include:
- Window creation abstractions (if needed)
- Alert/dialog abstractions (if NSAlert differences become an issue)
- Other platform-specific UI patterns
