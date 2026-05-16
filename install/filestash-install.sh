#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Bart0110
# License: MIT | https://github.com/Bart0110/ProxmoxVED/raw/main/LICENSE
# Source: https://www.filestash.app/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  build-essential \
  git \
  libjpeg-dev \
  libtiff-dev \
  libpng-dev \
  libwebp-dev \
  libraw-dev \
  libheif-dev \
  libgif-dev \
  libvips-dev \
  ffmpeg
msg_ok "Installed Dependencies"

setup_go

msg_info "Cloning Filestash"
rm -rf /opt/filestash
$STD git clone --depth 1 --single-branch --branch master https://github.com/mickael-kerjean/filestash /opt/filestash
msg_ok "Cloned Filestash"

msg_info "Building Filestash"
cd /opt/filestash
$STD make init
$STD make build
chmod 751 /opt/filestash/dist/filestash
msg_ok "Built Filestash"

msg_info "Configuring Filestash"
mkdir -p /opt/filestash-run/data
cp /opt/filestash/dist/filestash /opt/filestash-run/
msg_ok "Configured Filestash"

msg_info "Setting up User"
useradd -r -s /usr/sbin/nologin -M filestash
chown -R filestash:filestash /opt/filestash-run/
find /opt/filestash-run/data/ -type d -exec chmod 770 {} \; 2>/dev/null || true
find /opt/filestash-run/data/ -type f -exec chmod 760 {} \; 2>/dev/null || true
msg_ok "Set up User"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/filestash.service
[Unit]
Description=Filestash File Manager
After=network.target

[Service]
Type=simple
User=filestash
WorkingDirectory=/opt/filestash-run
ExecStart=/opt/filestash-run/filestash
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now filestash
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
