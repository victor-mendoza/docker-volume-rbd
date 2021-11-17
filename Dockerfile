FROM quay.io/ceph/ceph:v16 as base

FROM base as build
RUN dnf -y update && \
    dnf -y install gcc git golang librados-devel librbd-devel
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/lib/golang/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin"
COPY Gopkg.* main.go $GOPATH/src/docker-volume-rbd/
COPY lib $GOPATH/src/docker-volume-rbd/lib/
WORKDIR $GOPATH/src/docker-volume-rbd
RUN set -ex && \
    go mod init && \
    go mod tidy && \
    go install

FROM base
RUN mkdir -p /run/docker/plugins /mnt/state /mnt/volumes /etc/ceph
COPY --from=build /go/bin/docker-volume-rbd /
CMD ["/docker-volume-rbd"]
