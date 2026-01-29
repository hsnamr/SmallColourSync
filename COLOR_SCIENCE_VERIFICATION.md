# Color Science Verification (Task 2.2)

This document records the verification and completion of color science components for SmallColourSync.

## Summary

- **StandardColorSpaces**: All 5 spaces verified (primaries and white points per standard specs).
- **ColorConverter**: XYZ↔Lab and RGB↔XYZ now use primaries and white point; matrix derived from xy chromaticities (Lindbloom formulation).
- **GamutCalculator**: Uses color space white point for Lab; profile gamut uses sRGB when no profile transform.
- **CIELABSpaceModel**: Axes and grid generation verified by existing tests.

## 1. StandardColorSpaces

| Space         | Primaries (xy) | White point | Reference |
|---------------|----------------|------------|-----------|
| sRGB          | R(0.64,0.33) G(0.30,0.60) B(0.15,0.06) | D65 (0.3127, 0.3290) | IEC 61966-2-1 |
| Adobe RGB     | R(0.64,0.33) G(0.21,0.71) B(0.15,0.06) | D65 (0.3127, 0.3290) | Adobe |
| Display P3    | R(0.68,0.32) G(0.265,0.69) B(0.15,0.06) | D65 (0.3127, 0.3290) | Apple |
| ProPhoto RGB  | R(0.7347,0.2653) G(0.1596,0.8404) B(0.0366,0.0001) | D50 (0.3457, 0.3585) | Kodak |
| Rec. 2020     | R(0.708,0.292) G(0.17,0.797) B(0.131,0.046) | D65 (0.3127, 0.3290) | BT.2020 |

All five are implemented in `StandardColorSpaces.m` and covered by `test_ColorConverter` (testStandardColorSpacesExist, testRoundTripEachStandardSpace).

## 2. ColorConverter

### XYZ ↔ Lab (CIE 1976 L*a*b*)

- Uses standard formulas with configurable white point (XYZ).
- D50 and D65 white point helpers added: `d50WhitePointXyz`, `d65WhitePointXyz`.
- `whitePointXyzFromColorSpace:` converts ColorSpace xy white point to XYZ (Y=1).

### RGB ↔ XYZ

- **Before**: Hardcoded sRGB D65 matrix; primaries/whitePoint ignored.
- **After**: Matrix built from xy primaries and white point (Bruce Lindbloom, RGB/XYZ Matrices). Fallback to sRGB D65 when primaries or whitePoint is nil.
- Linear RGB only (no TRC/gamma in converter).

### Tests

- `test_ColorConverter.m`: XYZ↔Lab, D50/D65 white points, sRGB white→Lab, all 5 standard spaces exist, round-trip (1,1,1) for each space, xy→XYZ (Y=1).

## 3. GamutCalculator

- `computeGamutForProfile:`: Now uses sRGB color space (no profile LUT); previously passed nil primaries to rgbToXyz.
- `computeGamutForColorSpace:`: Uses `whitePointXyzFromColorSpace:` for Lab white point instead of hardcoded D50.

## 4. CIELABSpaceModel

- Axes: L* 0–100, a* and b* ±128.
- Grid: L = 0,25,50,75,100; a,b in steps of 32.
- Verified by `test_CIELABSpaceModel` (initialization, axes, grid, bounds, showAxes/showGrid).

## Running verification

```bash
./tests/build_and_run_tests.sh
```

All 7 tests (including ColorConverter and GamutCalculator) pass after Task 2.2.
