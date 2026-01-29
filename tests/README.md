# SmallBarcoder Test Suite

This directory contains unit tests for core SmallICCer functionality.

## Test Files

- **test_ColorConverter.m** - Tests color space conversions (XYZ ↔ Lab, RGB ↔ XYZ)
- **test_ICCParser.m** - Tests ICC profile parsing and tag extraction
- **test_ICCWriter.m** - Tests ICC profile writing and round-trip functionality
- **test_GamutCalculator.m** - Tests gamut computation and visualization
- **test_RenderBackend.m** - Tests renderer backend initialization (OpenGL/Vulkan/Metal)
- **test_CIELABSpaceModel.m** - Tests CIELAB space model generation
- **test_ICCTagEditing.m** - Tests ICC tag editing functionality

## Building Tests

From the `tests/` directory:

### Build all tests:
```bash
for test in ColorConverter ICCParser ICCWriter GamutCalculator RenderBackend CIELABSpaceModel ICCTagEditing; do
    make -f GNUmakefile.single TOOL=$test
done
```

Or use the original GNUmakefile (may need adjustment for your GNUStep version):
```bash
make
```

This will build all test executables in `obj/`.

## Running Tests

### Run all tests:
```bash
./run_tests.sh
```

### Run individual tests:
```bash
./obj/test_ColorConverter
./obj/test_ICCParser
./obj/test_ICCWriter
./obj/test_GamutCalculator
./obj/test_RenderBackend
./obj/test_CIELABSpaceModel
./obj/test_ICCTagEditing
```

## Test Coverage

### Core Functionality
- ✅ ICC profile reading (with LittleCMS)
- ✅ ICC profile writing (with LittleCMS)
- ✅ ICC profile round-trip (load → save → load)
- ✅ ICC tag editing (TRC, Matrix, LUT, Metadata)
- ✅ Color space conversions
- ✅ Gamut calculation
- ✅ Renderer backend initialization
- ✅ CIELAB space model generation

### Platform Support
- Tests work on both GNUStep (Linux) and macOS
- LittleCMS-dependent tests are skipped if library not available
- Renderer backend tests verify platform-specific backend selection

## Notes

- Some tests require LittleCMS to be installed and available
- Renderer backend initialization tests may skip if OpenGL context is not available (normal in test environment)
- Tests create temporary files in `/tmp` which are cleaned up automatically
