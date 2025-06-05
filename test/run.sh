#!/bin/bash

TEST_DIR=$(realpath $(dirname $0))
DOCKER_IMAGE_NAME=manual-install-dotfiles-test

docker buildx build --tag $DOCKER_IMAGE_NAME -f $TEST_DIR/Dockerfile .

docker run -it \
  --rm \
  --volume $(dirname $(dirname $0)):/opt/dotfiles \
  --workdir /opt/dotfiles \
  --entrypoint /bin/bash \
  $DOCKER_IMAGE_NAME \
  -c "./scripts/install-manual.sh && bash --login"
