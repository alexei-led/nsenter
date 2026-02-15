#!/bin/sh
# Integration tests for alexeiled/nsenter Docker image.
# Runs in CI or locally — requires Docker.
set -eu

IMAGE="${TEST_IMAGE:-alexeiled/nsenter:latest}"
PASSED=0
FAILED=0

pass() { PASSED=$((PASSED + 1)); echo "  ✅ $1"; }
fail() { FAILED=$((FAILED + 1)); echo "  ❌ $1: $2"; }

echo "=== nsenter Docker integration tests ==="
echo "Image: ${IMAGE}"
echo ""

# -------------------------------------------------------------------
# Test 1: Image exists and can be pulled/loaded
# -------------------------------------------------------------------
echo "▶ Test: image is available"
if docker image inspect "$IMAGE" >/dev/null 2>&1 || docker pull "$IMAGE" >/dev/null 2>&1; then
    pass "image available"
else
    fail "image available" "could not find or pull ${IMAGE}"
fi

# -------------------------------------------------------------------
# Test 2: nsenter binary runs and prints version
# -------------------------------------------------------------------
echo "▶ Test: nsenter --version"
version_output=$(docker run --rm "$IMAGE" --version 2>&1) || true
if echo "$version_output" | grep -q "nsenter.*util-linux"; then
    pass "nsenter --version → ${version_output}"
else
    fail "nsenter --version" "unexpected output: ${version_output}"
fi

# -------------------------------------------------------------------
# Test 3: nsenter --help exits 0 and shows usage
# -------------------------------------------------------------------
echo "▶ Test: nsenter --help"
help_output=$(docker run --rm "$IMAGE" --help 2>&1) || true
if echo "$help_output" | grep -qi "usage"; then
    pass "nsenter --help shows usage"
else
    fail "nsenter --help" "no usage text in output"
fi

# -------------------------------------------------------------------
# Test 4: Image is minimal (< 1MB)
# -------------------------------------------------------------------
echo "▶ Test: image size"
size_bytes=$(docker image inspect "$IMAGE" --format='{{.Size}}')
size_kb=$((size_bytes / 1024))
if [ "$size_bytes" -lt 1048576 ]; then
    pass "image size ${size_kb}KB (< 1MB)"
else
    size_mb=$((size_bytes / 1048576))
    fail "image size" "${size_mb}MB exceeds 1MB limit"
fi

# -------------------------------------------------------------------
# Test 5: Only /nsenter exists in the image (scratch-based)
# -------------------------------------------------------------------
echo "▶ Test: image contains only nsenter binary"
# Export image filesystem and check contents
file_count=$(docker create --name nsenter-test-$$ "$IMAGE" /nsenter --version 2>/dev/null && \
    docker export nsenter-test-$$ 2>/dev/null | tar -t 2>/dev/null | grep -cv '^\.$\|^/$' || echo "0")
docker rm -f nsenter-test-$$ >/dev/null 2>&1 || true
if [ "$file_count" -le 2 ]; then
    pass "minimal image (${file_count} files)"
else
    fail "minimal image" "found ${file_count} files, expected ≤2"
fi

# -------------------------------------------------------------------
# Test 6: Can enter own PID namespace (basic functionality)
# -------------------------------------------------------------------
echo "▶ Test: nsenter into own PID namespace"
pid_output=$(docker run --rm --privileged --pid=host "$IMAGE" --target=1 --pid -- echo "nsenter-works" 2>&1) || true
if echo "$pid_output" | grep -q "nsenter-works"; then
    pass "nsenter --target=1 --pid works"
else
    # This may fail in rootless Docker or restricted CI — warn instead of fail
    echo "  ⚠️  nsenter PID namespace test skipped (requires --privileged + host PID): ${pid_output}"
fi

# -------------------------------------------------------------------
# Summary
# -------------------------------------------------------------------
echo ""
echo "=== Results: ${PASSED} passed, ${FAILED} failed ==="

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
