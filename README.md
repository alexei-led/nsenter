[![CI](https://github.com/alexei-led/nsenter/actions/workflows/ci.yaml/badge.svg)](https://github.com/alexei-led/nsenter/actions/workflows/ci.yaml)
[![Release](https://github.com/alexei-led/nsenter/actions/workflows/release.yaml/badge.svg)](https://github.com/alexei-led/nsenter/actions/workflows/release.yaml)
[![Docker Pulls](https://img.shields.io/docker/pulls/alexeiled/nsenter.svg?style=popout)](https://hub.docker.com/r/alexeiled/nsenter)
[![GHCR](https://img.shields.io/badge/GHCR-nsenter-blue?logo=github)](https://github.com/alexei-led/nsenter/pkgs/container/nsenter)

# nsenter

Minimal (`scratch`) Docker image containing a single statically linked `nsenter` binary. Multi-arch: `linux/amd64` and `linux/arm64`.

## Quick Start

```sh
# Pull from GitHub Container Registry (recommended)
docker pull ghcr.io/alexei-led/nsenter

# Or from DockerHub
docker pull alexeiled/nsenter
```

## Usage

Read the official `nsenter` [documentation](http://man7.org/linux/man-pages/man1/nsenter.1.html).

### Enter a Docker container

```sh
# enter all namespaces of selected container
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

Use the helper script `nsenter-node.sh` to enter into any Kubernetes node by creating a temporary privileged pod:

```sh
# list Kubernetes nodes
kubectl get nodes

NAME                                            STATUS   ROLES    AGE     VERSION
ip-192-168-151-104.us-west-2.compute.internal   Ready    <none>   6d17h   v1.13.7-eks-c57ff8
ip-192-168-171-140.us-west-2.compute.internal   Ready    <none>   5d10h   v1.13.7-eks-c57ff8

# enter into selected node with default shell as superuser
./nsenter-node.sh ip-192-168-151-104.us-west-2.compute.internal

[root@ip-192-168-171-140 ~]#
```

## Automatically Updated

The `nsenter` image is automatically rebuilt when a new version of [util-linux](https://github.com/util-linux/util-linux) is released. A weekly GitHub Actions cron job checks for new releases and triggers a build.

## CI/CD

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **CI** | PR / push to `master` | Lint (hadolint, shellcheck) → Build → Integration tests |
| **Release** | Tag push | Multi-arch build → Push to GHCR + DockerHub → GitHub Release |
| **Cron** | Weekly (Monday) | Check for new util-linux version → Create tag → Trigger release |

## License

[MIT](LICENSE)
