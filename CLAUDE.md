# nsenter Development Guide

## Project Overview

Minimal Docker image (~600KB) providing a static `nsenter` binary for entering Linux namespaces from containers. Used for debugging containers and Kubernetes nodes.

## Build & Test

```bash
# Build Docker image (replace VERSION with util-linux version, e.g. 2.41.3)
docker build --build-arg UTIL_LINUX_VER=2.41.3 -t nsenter:local .

# Test locally
docker run -it --rm --privileged --pid=host nsenter:local

# Multi-arch build
docker buildx build --platform linux/amd64,linux/arm64 --build-arg UTIL_LINUX_VER=2.41.3 -t nsenter:local .

# Run integration tests
TEST_IMAGE=nsenter:local ./tests/test-docker.sh
```

## Structure

This is a minimal project:
- `Dockerfile` — Multi-stage: builds static nsenter from util-linux sources (Debian builder) → copies to scratch base
- `nsenter-node.sh` — Helper script for entering Kubernetes node namespaces via a privileged pod
- `tests/test-docker.sh` — Integration tests (image size, binary version, scratch-based)
- `.github/workflows/ci.yaml` — CI: lint (Hadolint + ShellCheck) + build + test on every push/PR
- `.github/workflows/build-release.yaml` — Release: triggered on tag push, builds multi-arch (amd64 + arm64 native runners), pushes to GHCR, creates GitHub Release

## Key Details

- **Base image:** scratch (zero attack surface)
- **Build source:** util-linux from GitHub releases (version pinned via `UTIL_LINUX_VER` build arg)
- **Binary:** static nsenter (no shared libs), stripped
- **Required privileges:** `--privileged` and `--pid=host` (or specific namespace flags)
- **Use cases:** Enter host PID/network/mount namespaces from container, debug Kubernetes nodes
- **Published to:** GHCR as `ghcr.io/alexei-led/nsenter` (Docker Hub deprecated)
- **Default branch:** `master`
- **Versioning:** Follows util-linux release tags (e.g., tag `2.42` → builds util-linux v2.42)

## CI/CD Flow

```
Push/PR → ci.yaml (lint + build + test)
Git tag  → build-release.yaml (multi-arch build → GHCR push → GitHub Release)
```

## Important Notes

- NEVER add AI co-author to git commits
- Do not push directly to master — use PRs for non-trivial changes
- Image must stay under 1MB (currently ~600KB)
- Always test with `tests/test-docker.sh` before releasing
