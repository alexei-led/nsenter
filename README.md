![Docker Pulls](https://img.shields.io/docker/pulls/alexeiled/nsenter.svg?style=popout) [![](https://images.microbadger.com/badges/image/alexeiled/aws-ssm-agent.svg)](https://microbadger.com/images/alexeiled/nsenter "Get your own image badge on microbadger.com")

# nsenter

## Info

`alexeiled/nsenter` Docker image is a `scratch` image that contains only one statically linked `nsenter` file.

## Usage

Read the official `nsenter` [documentation](http://man7.org/linux/man-pages/man1/nsenter.1.html).

## How do I *use* `alexeiled/nsenter`?

Enter the container:

```sh
# enter all namespaces of selected container
docker run -it --rm --privileged --pid=container:<container_name_or_ID> alexeiled/nsenter --all --target 1 -- su -
```

Enter the Docker host:

```sh
# enter all namespaces of Docker host
docker run -it --rm --privileged --pid=host alexeiled/nsenter --all --target 1 -- su -
```
