#!/bin/sh

IMAGE_NAME="${1:-wrk:local}"

buildah build -t "$IMAGE_NAME" .