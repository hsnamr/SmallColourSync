# GNUmakefile for SmallICCer Tests
# Builds all test tools

include $(GNUSTEP_MAKEFILES)/common.make

# Detect LittleCMS
LCMS_INCLUDE := $(shell pkg-config --cflags lcms2 2>/dev/null)
LCMS_LIBS := $(shell pkg-config --libs lcms2 2>/dev/null)
ifeq ($(LCMS_INCLUDE),)
  ifneq ($(wildcard /usr/include/lcms2.h),)
    LCMS_INCLUDE := -I/usr/include
    LCMS_LIBS := -llcms2
  endif
endif

ifneq ($(LCMS_INCLUDE),)
  ifneq ($(LCMS_LIBS),)
    HAVE_LCMS := 1
  endif
endif

# Test 1: ColorConverter (includes ColorSpace and StandardColorSpaces for verification)
TOOL_NAME = test_ColorConverter
test_ColorConverter_OBJC_FILES = test_ColorConverter.m ../color/ColorConverter.m ../color/ColorSpace.m ../color/StandardColorSpaces.m
test_ColorConverter_INCLUDE_DIRS = -I.. -I../color
test_ColorConverter_TOOL_LIBS = -lgnustep-base
include $(GNUSTEP_MAKEFILES)/tool.make

# Test 2: ICCParser
TOOL_NAME = test_ICCParser
test_ICCParser_OBJC_FILES = test_ICCParser.m
test_ICCParser_INCLUDE_DIRS = -I.. -I../icc -I../icc/tags $(LCMS_INCLUDE)
test_ICCParser_TOOL_LIBS = -lgnustep-base $(LCMS_LIBS)
ifdef HAVE_LCMS
test_ICCParser_OBJCFLAGS = -DHAVE_LCMS=1
endif
include $(GNUSTEP_MAKEFILES)/tool.make

# Test 3: ICCWriter
TOOL_NAME = test_ICCWriter
test_ICCWriter_OBJC_FILES = test_ICCWriter.m
test_ICCWriter_INCLUDE_DIRS = -I.. -I../icc -I../icc/tags $(LCMS_INCLUDE)
test_ICCWriter_TOOL_LIBS = -lgnustep-base $(LCMS_LIBS)
ifdef HAVE_LCMS
test_ICCWriter_OBJCFLAGS = -DHAVE_LCMS=1
endif
include $(GNUSTEP_MAKEFILES)/tool.make

# Test 4: GamutCalculator
TOOL_NAME = test_GamutCalculator
test_GamutCalculator_OBJC_FILES = test_GamutCalculator.m
test_GamutCalculator_INCLUDE_DIRS = -I.. -I../color -I../icc $(LCMS_INCLUDE)
test_GamutCalculator_TOOL_LIBS = -lgnustep-base $(LCMS_LIBS)
ifdef HAVE_LCMS
test_GamutCalculator_OBJCFLAGS = -DHAVE_LCMS=1
endif
include $(GNUSTEP_MAKEFILES)/tool.make

# Test 5: RenderBackend (Task 3.2 backend verification)
TOOL_NAME = test_RenderBackend
test_RenderBackend_OBJC_FILES = test_RenderBackend.m ../visualization/RenderBackend.m ../visualization/OpenGLBackend.m ../visualization/Gamut3DModel.m ../visualization/CIELABSpaceModel.m ../visualization/Renderer3D.m ../app/SettingsManager.m
test_RenderBackend_INCLUDE_DIRS = -I.. -I../visualization -I../app -I../SmallStep/SmallStep/Core
test_RenderBackend_TOOL_LIBS = -lgnustep-base -lgnustep-gui -lSmallStep
include $(GNUSTEP_MAKEFILES)/tool.make

# Test 6: CIELABSpaceModel
TOOL_NAME = test_CIELABSpaceModel
test_CIELABSpaceModel_OBJC_FILES = test_CIELABSpaceModel.m
test_CIELABSpaceModel_INCLUDE_DIRS = -I.. -I../visualization
test_CIELABSpaceModel_TOOL_LIBS = -lgnustep-base
include $(GNUSTEP_MAKEFILES)/tool.make

# Test 7: ICCTagEditing
TOOL_NAME = test_ICCTagEditing
test_ICCTagEditing_OBJC_FILES = test_ICCTagEditing.m
test_ICCTagEditing_INCLUDE_DIRS = -I.. -I../icc -I../icc/tags
test_ICCTagEditing_TOOL_LIBS = -lgnustep-base
include $(GNUSTEP_MAKEFILES)/tool.make

# Test 8: SettingsManager
TOOL_NAME = test_SettingsManager
test_SettingsManager_OBJC_FILES = test_SettingsManager.m ../app/SettingsManager.m
test_SettingsManager_INCLUDE_DIRS = -I.. -I../app
test_SettingsManager_TOOL_LIBS = -lgnustep-base
include $(GNUSTEP_MAKEFILES)/tool.make

# Test 9: GamutComparator
TOOL_NAME = test_GamutComparator
test_GamutComparator_OBJC_FILES = test_GamutComparator.m ../visualization/GamutComparator.m ../visualization/Gamut3DModel.m
test_GamutComparator_INCLUDE_DIRS = -I.. -I../visualization
test_GamutComparator_TOOL_LIBS = -lgnustep-base
include $(GNUSTEP_MAKEFILES)/tool.make
