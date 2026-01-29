#!/bin/bash
# Build and run all tests manually
# This script compiles tests directly with gcc when makefile has issues

cd "$(dirname "$0")"
cd ..

export GNUSTEP_MAKEFILES=$(gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null || echo "/usr/share/GNUstep/Makefiles")
if [ -f "$GNUSTEP_MAKEFILES/GNUstep.sh" ]; then
    . "$GNUSTEP_MAKEFILES/GNUstep.sh"
fi

# Get GNUStep paths
GNUSTEP_HEADERS=$(gnustep-config --variable=GNUSTEP_HEADERS 2>/dev/null || echo "$HOME/GNUstep/Library/Headers")
GNUSTEP_LIBRARIES=$(gnustep-config --variable=GNUSTEP_LIBRARIES 2>/dev/null || echo "$HOME/GNUstep/Library/Libraries")

FAILURES=0
TOTAL=0

echo "Building and running SmallICCer Test Suite"
echo "==========================================="
echo ""

# Function to build and run a test
run_test() {
    local test_name=$1
    local test_file="tests/test_${test_name}.m"
    local source_files="$2"
    local includes="$3"
    local libs="$4"
    local cflags="$5"
    
    echo "Building $test_name..."
    
    # Create obj directory
    mkdir -p tests/obj
    
    # Compile test file
    local obj_files=""
    for src in $test_file $source_files; do
        if [ -f "$src" ]; then
            local obj_name=$(basename "$src" .m).o
            local obj_path="tests/obj/${test_name}_${obj_name}"
            echo "  Compiling $src..."
            if ! gcc $cflags $includes -c "$src" -o "$obj_path" 2>&1 | grep -v "warning:" | grep -v "note:"; then
                # Check if compilation actually failed (not just warnings)
                if [ ! -f "$obj_path" ]; then
                    echo "  ERROR: Failed to compile $src"
                    return 1
                fi
            fi
            if [ -f "$obj_path" ]; then
                obj_files="$obj_files $obj_path"
            fi
        else
            echo "  WARNING: Source file not found: $src"
        fi
    done
    
    # Link
    echo "  Linking..."
    gcc -shared-libgcc -pthread -fexceptions -rdynamic -o "tests/obj/test_${test_name}" $obj_files $libs -lobjc 2>&1 | grep -v "warning:" || true
    if [ $? -ne 0 ]; then
        echo "  ERROR: Failed to link test_${test_name}"
        return 1
    fi
    
    # Run test
    echo "Running test_${test_name}..."
    if [ -f "tests/obj/test_${test_name}" ]; then
        TOTAL=$((TOTAL + 1))
        ./tests/obj/test_${test_name}
        local result=$?
        if [ $result -ne 0 ]; then
            FAILURES=$((FAILURES + 1))
            echo "FAILED: test_${test_name}"
        else
            echo "PASSED: test_${test_name}"
        fi
        echo ""
        return $result
    else
        echo "  ERROR: Test binary not found"
        return 1
    fi
}

# Common flags
COMMON_CFLAGS="-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -O2 -fconstant-string-class=NSConstantString -pthread"
COMMON_INCLUDES="-I. -Itests -Icolor -Iicc -Iicc/tags -Ivisualization -ISmallStep/SmallStep/Core -I$GNUSTEP_HEADERS -I/usr/local/include/GNUstep -I/usr/include/x86_64-linux-gnu/GNUstep -I/usr/include"
# Find GNUStep library paths - try multiple locations
GNUSTEP_LIB_PATHS=""
for path in "$HOME/GNUstep/Library/Libraries" "/usr/local/lib/GNUstep" "/usr/lib/x86_64-linux-gnu/GNUstep" "/usr/lib/GNUstep" "/usr/lib"; do
    if [ -d "$path" ] && [ -f "$path/libgnustep-base.so" ] 2>/dev/null || [ -f "$path/libgnustep-base.a" ] 2>/dev/null; then
        GNUSTEP_LIB_PATHS="$GNUSTEP_LIB_PATHS -L$path"
    fi
done

# Try pkg-config
if pkg-config --exists gnustep-base 2>/dev/null; then
    GNUSTEP_BASE_LIBS=$(pkg-config --libs gnustep-base)
else
    GNUSTEP_BASE_LIBS="-lgnustep-base"
fi

COMMON_LIBS="$GNUSTEP_LIB_PATHS $GNUSTEP_BASE_LIBS -pthread"

# Check for LittleCMS
if pkg-config --exists lcms2 2>/dev/null; then
    LCMS_CFLAGS=$(pkg-config --cflags lcms2)
    LCMS_LIBS=$(pkg-config --libs lcms2)
    COMMON_CFLAGS="$COMMON_CFLAGS -DHAVE_LCMS=1 $LCMS_CFLAGS"
    COMMON_LIBS="$COMMON_LIBS $LCMS_LIBS"
fi

# Run tests
run_test "ColorConverter" "color/ColorConverter.m" "$COMMON_INCLUDES" "$COMMON_LIBS" "$COMMON_CFLAGS"

run_test "ICCTagEditing" "icc/ICCProfile.m icc/ICCTag.m icc/tags/ICCTagTRC.m icc/tags/ICCTagMatrix.m icc/tags/ICCTagLUT.m icc/tags/ICCTagMetadata.m" "$COMMON_INCLUDES" "$COMMON_LIBS" "$COMMON_CFLAGS"

run_test "CIELABSpaceModel" "visualization/CIELABSpaceModel.m" "$COMMON_INCLUDES" "$COMMON_LIBS" "$COMMON_CFLAGS"

run_test "RenderBackend" "visualization/RenderBackend.m" "$COMMON_INCLUDES -ISmallStep/SmallStep/Core -I../SmallStep/SmallStep/Core" "$COMMON_LIBS -lgnustep-gui" "$COMMON_CFLAGS"

# Tests requiring LittleCMS
if pkg-config --exists lcms2 2>/dev/null; then
    run_test "ICCParser" "icc/ICCParser.m icc/ICCProfile.m icc/ICCTag.m icc/tags/ICCTagTRC.m icc/tags/ICCTagMatrix.m icc/tags/ICCTagLUT.m icc/tags/ICCTagMetadata.m" "$COMMON_INCLUDES" "$COMMON_LIBS" "$COMMON_CFLAGS"
    
    run_test "ICCWriter" "icc/ICCWriter.m icc/ICCParser.m icc/ICCProfile.m icc/ICCTag.m icc/tags/ICCTagTRC.m icc/tags/ICCTagMatrix.m icc/tags/ICCTagLUT.m icc/tags/ICCTagMetadata.m" "$COMMON_INCLUDES" "$COMMON_LIBS" "$COMMON_CFLAGS"
    
    run_test "GamutCalculator" "color/GamutCalculator.m color/ColorConverter.m color/ColorSpace.m color/StandardColorSpaces.m icc/ICCProfile.m icc/ICCParser.m icc/ICCTag.m icc/tags/ICCTagTRC.m icc/tags/ICCTagMatrix.m icc/tags/ICCTagLUT.m icc/tags/ICCTagMetadata.m" "$COMMON_INCLUDES" "$COMMON_LIBS" "$COMMON_CFLAGS"
else
    echo "SKIPPED: ICCParser (LittleCMS not available)"
    echo "SKIPPED: ICCWriter (LittleCMS not available)"
    echo "SKIPPED: GamutCalculator (LittleCMS not available)"
    echo ""
fi

echo "==========================================="
echo "Tests run: $TOTAL"
echo "Failures: $FAILURES"

if [ $FAILURES -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
