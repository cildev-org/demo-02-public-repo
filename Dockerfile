# syntax=docker/dockerfile:1
FROM debian:12-slim@sha256:7c7b2c966bc9ee8cedfeef67e0e279108992c77681fa595db4a9d65c06ccc587

ARG SNAP=20240115T000000Z
RUN rm -f /etc/apt/sources.list.d/* && \
    printf 'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/%s/ bookworm main\ndeb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/%s/ bookworm-security main\n' "$SNAP" "$SNAP" > /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y --no-install-recommends haproxy=2.6.12-1+deb12u1 && \
    rm -rf /var/lib/apt/lists/*

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
EXPOSE 80
CMD ["haproxy", "-db", "-f", "/etc/haproxy/haproxy.cfg"]
# blue-oryx live test
