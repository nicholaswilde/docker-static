FROM golang:1.14.15-alpine3.13 as build
ARG VERSION
ARG COMMIT=ee8a20c8325015b5277b0f53078e67f9fb3603b5
ENV GO111MODULE on
WORKDIR /go/src/static
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    git=2.30.1-r0 \
    make=4.3-r0 \
    build-base=0.5-r2 && \
  echo "**** download static ****" && \
  mkdir /app && \
  git clone "https://github.com/prologic/static.git" /go/src/static && \
  git reset --hard "${COMMIT}" && \
  go get -v -d && \
  go install -v

FROM ghcr.io/linuxserver/baseimage-alpine:3.13
ARG BUILD_DATE
ARG VERSION
ENV GOPATH /go
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nicholaswilde"
COPY --from=build --chown=abc:abc /go /go
COPY root/ /
RUN \
  mkdir /data && \
  chown -R abc:abc \
    /data \
    /go
WORKDIR /data
EXPOSE 8000/tcp
VOLUME \
  /data
