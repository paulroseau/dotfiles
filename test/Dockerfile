FROM ubuntu

RUN <<EOF
apt update
apt install -y \
  gcc \
  git \
  curl \
  xz-utils \
  unzip
rm -rf /var/lib/apt/lists/*
EOF

ENTRYPOINT ["/bin/bash", "--login"]
