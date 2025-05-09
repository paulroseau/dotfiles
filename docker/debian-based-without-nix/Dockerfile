FROM debian:stable-slim AS base

ARG USER=user

RUN useradd $USER --create-home

RUN apt update && \
  apt install -y \
    curl \
    xz-utils \
    xclip \
    jq \
    bat \
    ripgrep \
    stow \
    git \
    tig \
    tmux \
    tree \
    yq \
    zsh

RUN curl -sS https://starship.rs/install.sh | FORCE="true" sh

# Install nvim
ARG NVIM_VERSION="v0.11.1"
RUN <<EOF
curl -sL https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz -o /tmp/nvim-linux-x86_64.tar.gz
tar -C /tmp -zxvf /tmp/nvim-linux-x86_64.tar.gz
mv /tmp/nvim-linux-x86_64/bin/* /usr/local/bin/
mv /tmp/nvim-linux-x86_64/lib/* /usr/local/lib/
mv /tmp/nvim-linux-x86_64/share/* /usr/local/share/
rm -r /tmp/nvim-linux*
EOF

# Install fzf
ARG FZF_VERSION="0.62.0"
RUN <<EOF
curl -sL https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz -o /tmp/fzf-linux-x86_64.tar.gz
tar -C /tmp -zxvf /tmp/fzf-linux-x86_64.tar.gz
mv /tmp/fzf /usr/local/bin/
rm -r /tmp/fzf-linux*
EOF

USER ${USER}
WORKDIR "/home/${USER}"

