# nsenter

[![CI](https://github.com/alexei-led/nsenter/actions/workflows/ci.yaml/badge.svg)](https://github.com/alexei-led/nsenter/actions/workflows/ci.yaml)
[![Build and Release](https://github.com/alexei-led/nsenter/actions/workflows/build-release.yaml/badge.svg)](https://github.com/alexei-led/nsenter/actions/workflows/build-release.yaml)

## Overview

Minimal `scratch`-based Docker image (~400KB) containing a single statically linked `nsenter` binary, built from [util-linux](https://github.com/util-linux/util-linux) sources.

## Docker Image

```bash
docker pull ghcr.io/alexei-led/nsenter
```

Multi-arch: `linux/amd64` and `linux/arm64` (built natively, no QEMU emulation).

> **Note:** Docker Hub images (`alexeiled/nsenter`) are deprecated and no longer updated.
> Docker Hub has introduced increasingly restrictive policies for open-source projects —
> including rate limits, image retention limits for free accounts, and removal of
> free Team organizations. We've moved exclusively to GitHub Container Registry (GHCR),
> which offers unlimited pulls for public packages with no retention restrictions.

## Usage

Read the official `nsenter` [man page](http://man7.org/linux/man-pages/man1/nsenter.1.html).

### Enter a Docker container's namespaces

```sh
# enter all namespaces of a running container
docker run -it --rm --privileged --pid=container:<container_name_or_ID> \
  ghcr.io/alexei-led/nsenter --all --target 1 -- su -
```

### Enter the Docker host

```sh
# enter all namespaces of Docker host
docker run -it --rm --privileged --pid=host \
  ghcr.io/alexei-led/nsenter --all --target 1 -- su -
```

### Enter a Kubernetes node

Use the helper script `nsenter-node.sh` to enter any Kubernetes node by creating a temporary privileged pod:

```sh
# list Kubernetes nodes
kubectl get nodes

NAME                                            STATUS   ROLES    AGE     VERSION
ip-192-168-151-104.us-west-2.compute.internal   Ready    <none>   6d17h   v1.30.0-eks
ip-192-168-171-140.us-west-2.compute.internal   Ready    <none>   5d10h   v1.30.0-eks

# enter selected node as root
./nsenter-node.sh ip-192-168-151-104.us-west-2.compute.internal

[root@ip-192-168-151-104 ~]#
```

The script creates a temporary pod with `hostPID`, `hostNetwork`, and tolerations for all taints — it is automatically cleaned up when you exit the shell.

## Building

```sh
docker build --build-arg UTIL_LINUX_VER=2.41.3 -t nsenter .
```

## CI/CD

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| **CI** | Push / PR | Hadolint + ShellCheck + build + integration tests |
| **Build and Release** | Tag push | Native multi-arch build → GHCR + GitHub Release |

Releases are triggered by pushing a version tag (e.g., `2.41.3`) matching the upstream [util-linux](https://github.com/util-linux/util-linux/releases) version.

## License

[GPL-2.0](LICENSE)
