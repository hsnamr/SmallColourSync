#!/bin/bash
# Test runner script for SmallICCer

cd "$(dirname "$0")"

echo "Running SmallICCer Test Suite"
echo "=============================="
echo ""

FAILURES=0
TOTAL=0

# Run each test
for test in test_ColorConverter test_ICCParser test_ICCWriter test_GamutCalculator test_RenderBackend test_CIELABSpaceModel test_ICCTagEditing; do
    if [ -f "./obj/$test" ]; then
        echo "Running $test..."
        TOTAL=$((TOTAL + 1))
        ./obj/$test
        if [ $? -ne 0 ]; then
            FAILURES=$((FAILURES + 1))
            echo "FAILED: $test"
        else
            echo "PASSED: $test"
        fi
        echo ""
    else
        echo "SKIPPED: $test (not built)"
        echo ""
    fi
done

echo "=============================="
echo "Tests run: $TOTAL"
echo "Failures: $FAILURES"

if [ $FAILURES -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "$FAILURES test(s) failed"
    exit 1
fi
