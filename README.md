# nsenter

[![CI](https://github.com/alexei-led/nsenter/actions/workflows/ci.yaml/badge.svg)](https://github.com/alexei-led/nsenter/actions/workflows/ci.yaml)
[![Release](https://github.com/alexei-led/nsenter/actions/workflows/release.yaml/badge.svg)](https://github.com/alexei-led/nsenter/actions/workflows/release.yaml)
![Docker Pulls](https://img.shields.io/docker/pulls/alexeiled/nsenter.svg?style=popout)

## Overview

Minimal `scratch`-based Docker image (~400KB) containing a single statically linked `nsenter` binary, built from [util-linux](https://github.com/util-linux/util-linux) sources.

Automatically updated weekly when new util-linux versions are released.

## Docker Images

| Registry | Image | Pull Command |
|----------|-------|-------------|
| **GHCR** (default) | `ghcr.io/alexei-led/nsenter` | `docker pull ghcr.io/alexei-led/nsenter` |
| DockerHub | `alexeiled/nsenter` | `docker pull alexeiled/nsenter` |

Both registries provide multi-arch images for `linux/amd64` and `linux/arm64`.

## Usage

Read the official `nsenter` [documentation](http://man7.org/linux/man-pages/man1/nsenter.1.html).

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
# Build with a specific util-linux version
docker build --build-arg UTIL_LINUX_VER=2.41.3 -t nsenter .
```

## CI/CD

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| `ci.yaml` | Push / PR | Hadolint + ShellCheck + build + integration tests |
| `release.yaml` | Tag push | Multi-arch build → GHCR + DockerHub + GitHub Release |
| `cron.yaml` | Weekly (Monday) | Check for new util-linux → auto-tag → triggers release |

## License

[MIT](LICENSE)
