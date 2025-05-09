FROM debian:stable-slim AS base

ARG NIX_VERSION=2.28.3
ARG USER=nixuser

RUN <<EOF
addgroup --gid 30000 --system nixbld
for i in $(seq 1 30)
do 
  adduser \
    --system \
    --disabled-password \
    --home /var/empty \
    --gecos "Nix build user $i" \
    --uid $((30000 + i)) \
    --ingroup nixbld \
    nixbld$i
done
adduser --disabled-password nixuser

mkdir -m 0755 /nix
chown nixuser /nix

apt update
apt install -y wget xz-utils
apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

mkdir -p /etc/nix && touch /etc/nix/nix.conf
EOF

USER ${USER}
WORKDIR "/home/${USER}"

RUN <<EOF
wget https://nixos.org/releases/nix/nix-${NIX_VERSION}/nix-${NIX_VERSION}-x86_64-linux.tar.xz
tar xJf nix-*-x86_64-linux.tar.xz
./nix-*-x86_64-linux/install
rm -rf ./nix-*-*
EOF

FROM base AS workstation

ARG PKGS="myPkgs.work"

# Necessary for sourcing ./.nix-profile/etc/profile.d/nix.sh
ENV USER=${USER}

RUN <<EOF
. ./.nix-profile/etc/profile.d/nix.sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
nix-channel --update
EOF

COPY --chown=$USER:$USER . ./.dotfiles

RUN ./.dotfiles/install-docker.sh ${PKGS}

ENTRYPOINT ["bash", "--login", "-c", "zsh", "--login"]
