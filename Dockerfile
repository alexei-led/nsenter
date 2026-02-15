# Stage 1: Build static nsenter from util-linux sources
FROM debian:bookworm-slim AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
        make gcc gettext autopoint bison libtool automake pkg-config ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /code

# Download util-linux sources
ARG UTIL_LINUX_VER
ADD https://github.com/util-linux/util-linux/archive/v${UTIL_LINUX_VER}.tar.gz .
RUN tar -xf v${UTIL_LINUX_VER}.tar.gz && mv util-linux-${UTIL_LINUX_VER} util-linux

# Build static nsenter binary — only enable nsenter, skip everything else
WORKDIR /code/util-linux
RUN ./autogen.sh && \
    ./configure --disable-all-programs --enable-nsenter --without-python --without-ncurses && \
    make LDFLAGS="--static" nsenter && \
    strip nsenter

# Verify the binary works and print version
RUN ./nsenter --version

# Final image: scratch with only the static binary
FROM scratch

COPY --from=builder /code/util-linux/nsenter /nsenter

ENTRYPOINT ["/nsenter"]
