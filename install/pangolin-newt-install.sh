#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Bart0110
# License: MIT | https://github.com/Bart0110/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/fosrl/newt

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Downloading Newt Binary"
fetch_and_deploy_gh_release "newt" "fosrl/newt" "singlefile" "latest" "/usr/local/bin" "newt_linux_*"
msg_ok "Downloaded Newt Binary"

msg_info "Configuring Newt"
install -d -m 0755 /etc/newt

# Prompt for credentials (all required)
read -r -p "${TAB3}Enter your Pangolin Newt ID (from your Pangolin site): " NEWT_ID
while [[ -z "$NEWT_ID" ]]; do
  msg_error "NEWT_ID is required. Please enter a valid ID."
  read -r -p "${TAB3}Enter your Pangolin Newt ID (from your Pangolin site): " NEWT_ID
done

read -r -p "${TAB3}Enter your Pangolin Newt Secret (from your Pangolin site): " NEWT_SECRET
while [[ -z "$NEWT_SECRET" ]]; do
  msg_error "NEWT_SECRET is required. Please enter a valid secret."
  read -r -p "${TAB3}Enter your Pangolin Newt Secret (from your Pangolin site): " NEWT_SECRET
done

PANGOLIN_ENDPOINT_DEFAULT="https://app.pangolin.net"
read -r -p "${TAB3}Enter your Pangolin endpoint (default: ${PANGOLIN_ENDPOINT_DEFAULT}): " PANGOLIN_ENDPOINT
PANGOLIN_ENDPOINT="${PANGOLIN_ENDPOINT:-$PANGOLIN_ENDPOINT_DEFAULT}"

cat <<EOF >/etc/newt/newt.env
NEWT_ID=${NEWT_ID}
NEWT_SECRET=${NEWT_SECRET}
PANGOLIN_ENDPOINT=${PANGOLIN_ENDPOINT}
EOF
chmod 600 /etc/newt/newt.env
msg_ok "Configured Newt"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/newt.service
[Unit]
Description=Newt
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
Group=root
EnvironmentFile=/etc/newt/newt.env
ExecStart=/usr/local/bin/newt
Restart=always
RestartSec=2
UMask=0077

NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now newt
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
