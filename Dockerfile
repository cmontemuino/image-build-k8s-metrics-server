ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=briandowns/rancher-build-base:v0.1.1

FROM ${UBI_IMAGE} as ubi

FROM ${GO_IMAGE} as builder
ARG TAG="" 
RUN apt update     && \ 
    apt upgrade -y && \ 
    apt install -y ca-certificates git
RUN git clone --depth=1 https://github.com/kubernetes-sigs/metrics-server.git
RUN cd /go/metrics-server              && \
    git fetch --all --tags --prune     && \
    git checkout tags/${TAG} -b ${TAG} && \
    make all

FROM ubi
RUN microdnf update -y && \ 
    rm -rf /var/cache/yum

COPY --from=builder /go/metrics-server/_output/amd64/metrics-server /usr/local/bin
