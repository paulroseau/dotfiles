# Docker images

Series of docker images with the binaries installed along with their configuration.

## Debian based with nix

Start from a base debian image, install nix and install your binaries using nix and this repository. This image ends up being pretty heavy (several GB).

## Debian based without nix

From a debian image, install your main binaries "manually" (without nix) to optimize for the size.
