# GNUmakefile for SmallICCer (Linux/GNUStep and macOS)
#
# ICC Color Profile Editor and Visualizer
# Targets GNUStep and macOS

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = SmallICCer

# Try to find LittleCMS (lcms2) headers and library
LCMS_INCLUDE := $(shell pkg-config --cflags lcms2 2>/dev/null)
LCMS_LIBS := $(shell pkg-config --libs lcms2 2>/dev/null)
ifeq ($(LCMS_INCLUDE),)
  # Try common locations
  ifneq ($(wildcard /usr/include/lcms2.h),)
    LCMS_INCLUDE := -I/usr/include
    ifneq ($(wildcard /usr/lib/x86_64-linux-gnu/liblcms2.so),)
      LCMS_LIBS := -llcms2
    else ifneq ($(wildcard /usr/lib/liblcms2.so),)
      LCMS_LIBS := -llcms2
    endif
  else ifneq ($(wildcard /usr/local/include/lcms2.h),)
    LCMS_INCLUDE := -I/usr/local/include
    ifneq ($(wildcard /usr/local/lib/liblcms2.so),)
      LCMS_LIBS := -llcms2
    endif
  endif
endif

# Try to find OpenGL headers and library
OPENGL_LIBS := $(shell pkg-config --libs gl 2>/dev/null)
ifeq ($(OPENGL_LIBS),)
  # Try common locations
  ifneq ($(wildcard /usr/lib/x86_64-linux-gnu/libGL.so),)
    OPENGL_LIBS := -lGL
  else ifneq ($(wildcard /usr/lib/libGL.so),)
    OPENGL_LIBS := -lGL
  endif
endif

# Try to find GLU (OpenGL Utility Library)
GLU_LIBS := $(shell pkg-config --libs glu 2>/dev/null)
ifeq ($(GLU_LIBS),)
  ifneq ($(wildcard /usr/lib/x86_64-linux-gnu/libGLU.so),)
    GLU_LIBS := -lGLU
  else ifneq ($(wildcard /usr/lib/libGLU.so),)
    GLU_LIBS := -lGLU
  endif
endif

# Try to find Vulkan (for Linux)
VULKAN_INCLUDE := $(shell pkg-config --cflags vulkan 2>/dev/null)
VULKAN_LIBS := $(shell pkg-config --libs vulkan 2>/dev/null)
ifeq ($(VULKAN_INCLUDE),)
  ifneq ($(wildcard /usr/include/vulkan/vulkan.h),)
    VULKAN_INCLUDE := -I/usr/include
    ifneq ($(wildcard /usr/lib/x86_64-linux-gnu/libvulkan.so),)
      VULKAN_LIBS := -lvulkan
    else ifneq ($(wildcard /usr/lib/libvulkan.so),)
      VULKAN_LIBS := -lvulkan
    endif
  endif
endif

# Objective-C source files
SmallICCer_OBJC_FILES = \
	main.m \
	app/AppController.m \
	app/SettingsManager.m \
	icc/ICCProfile.m \
	icc/ICCParser.m \
	icc/ICCWriter.m \
	icc/tags/ICCTag.m \
	icc/tags/ICCTagTRC.m \
	icc/tags/ICCTagMatrix.m \
	icc/tags/ICCTagLUT.m \
	icc/tags/ICCTagMetadata.m \
	color/ColorSpace.m \
	color/StandardColorSpaces.m \
	color/ColorConverter.m \
	color/GamutCalculator.m \
	visualization/Gamut3DModel.m \
	visualization/CIELABSpaceModel.m \
	visualization/Renderer3D.m \
	visualization/GamutComparator.m \
	visualization/RenderBackend.m \
	visualization/OpenGLBackend.m \
	visualization/VulkanBackend.m \
	visualization/VulkanShaderLoader.m \
	visualization/MetalBackend.m \
	ui/MainWindow.m \
	ui/ProfileInspectorPanel.m \
	ui/TagEditorPanel.m \
	ui/GamutViewPanel.m \
	ui/HistogramAndCurvesPanel.m \
	ui/FileBrowserPanel.m

# Header files
SmallICCer_HEADER_FILES = \
	app/AppController.h \
	app/SettingsManager.h \
	icc/ICCProfile.h \
	icc/ICCParser.h \
	icc/ICCWriter.h \
	icc/tags/ICCTag.h \
	icc/tags/ICCTagTRC.h \
	icc/tags/ICCTagMatrix.h \
	icc/tags/ICCTagLUT.h \
	icc/tags/ICCTagMetadata.h \
	color/ColorSpace.h \
	color/StandardColorSpaces.h \
	color/ColorConverter.h \
	color/GamutCalculator.h \
	visualization/Gamut3DModel.h \
	visualization/CIELABSpaceModel.h \
	visualization/Renderer3D.h \
	visualization/GamutComparator.h \
	visualization/RenderBackend.h \
	visualization/OpenGLBackend.h \
	visualization/VulkanBackend.h \
	visualization/VulkanShaderLoader.h \
	visualization/MetalBackend.h \
	ui/MainWindow.h \
	ui/ProfileInspectorPanel.h \
	ui/TagEditorPanel.h \
	ui/GamutViewPanel.h \
	ui/HistogramAndCurvesPanel.h \
	ui/FileBrowserPanel.h

SmallICCer_INCLUDE_DIRS = \
	-I. \
	-Iapp \
	-Iicc \
	-Iicc/tags \
	-Icolor \
	-Ivisualization \
	-Iui \
	-I../SmallStep/SmallStep/Core \
	-I../SmallStep/SmallStep/Platform/Linux \
	$(LCMS_INCLUDE) \
	$(VULKAN_INCLUDE)

# Define HAVE_LCMS if headers and library are available
ifneq ($(LCMS_INCLUDE),)
  ifneq ($(LCMS_LIBS),)
    SmallICCer_OBJCFLAGS += -DHAVE_LCMS=1
  endif
endif

# Define HAVE_VULKAN if headers and library are available (Linux only)
ifneq ($(VULKAN_INCLUDE),)
  ifneq ($(VULKAN_LIBS),)
    SmallICCer_OBJCFLAGS += -DHAVE_VULKAN=1
  endif
endif

# Find SmallStep framework/library
SMALLSTEP_FRAMEWORK := $(shell find ../SmallStep -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 && pwd)
  SMALLSTEP_LIB_NAME := -lSmallStep
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_NAME := -lSmallStep
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

# Base libraries
LIBRARIES := -lobjc -lgnustep-gui -lgnustep-base

# Add optional libraries if available
ifneq ($(LCMS_LIBS),)
  LIBRARIES += $(LCMS_LIBS)
endif

ifneq ($(OPENGL_LIBS),)
  LIBRARIES += $(OPENGL_LIBS)
endif

ifneq ($(GLU_LIBS),)
  LIBRARIES += $(GLU_LIBS)
endif

# Add Vulkan if available (Linux only)
ifneq ($(VULKAN_LIBS),)
  LIBRARIES += $(VULKAN_LIBS)
endif

SmallICCer_LIBRARIES_DEPEND_UPON = $(LIBRARIES)

# Linker flags
SmallICCer_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS)
SmallICCer_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep

# Tool libraries
TOOL_LIBS_LIST = -lSmallStep
ifneq ($(LCMS_LIBS),)
  TOOL_LIBS_LIST += $(LCMS_LIBS)
endif
ifneq ($(OPENGL_LIBS),)
  TOOL_LIBS_LIST += $(OPENGL_LIBS)
endif
ifneq ($(GLU_LIBS),)
  TOOL_LIBS_LIST += $(GLU_LIBS)
endif
ifneq ($(VULKAN_LIBS),)
  TOOL_LIBS_LIST += $(VULKAN_LIBS)
endif
SmallICCer_TOOL_LIBS = $(TOOL_LIBS_LIST)

include $(GNUSTEP_MAKEFILES)/application.make
