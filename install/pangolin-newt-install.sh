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

# Prompt for credentials (all required) using whiptail
if NEWT_ID=$(whiptail --backtitle "Pangolin Installation" --title "Newt ID" --inputbox "\nEnter your Pangolin Newt ID (from your Pangolin site):" 10 60 "" 3>&1 1>&2 2>&3); then
  while [[ -z "$NEWT_ID" ]]; do
    whiptail --backtitle "Pangolin Installation" --title "Newt ID Required" --msgbox "NEWT_ID is required. Please enter a valid ID." 8 58
    if NEWT_ID=$(whiptail --backtitle "Pangolin Installation" --title "Newt ID" --inputbox "\nEnter your Pangolin Newt ID (from your Pangolin site):" 10 60 "" 3>&1 1>&2 2>&3); then
      :
    else
      exit
    fi
  done
else
  exit
fi

if NEWT_SECRET=$(whiptail --backtitle "Pangolin Installation" --title "Newt Secret" --passwordbox "\nEnter your Pangolin Newt Secret (from your Pangolin site):" 10 60 "" 3>&1 1>&2 2>&3); then
  while [[ -z "$NEWT_SECRET" ]]; do
    whiptail --backtitle "Pangolin Installation" --title "Newt Secret Required" --msgbox "NEWT_SECRET is required. Please enter a valid secret." 8 58
    if NEWT_SECRET=$(whiptail --backtitle "Pangolin Installation" --title "Newt Secret" --passwordbox "\nEnter your Pangolin Newt Secret (from your Pangolin site):" 10 60 "" 3>&1 1>&2 2>&3); then
      :
    else
      exit
    fi
  done
else
  exit
fi

PANGOLIN_ENDPOINT_DEFAULT="https://app.pangolin.net"
if PANGOLIN_ENDPOINT=$(whiptail --backtitle "Pangolin Installation" --title "Pangolin Endpoint" --inputbox "\nEnter your Pangolin endpoint (default: ${PANGOLIN_ENDPOINT_DEFAULT}):" 10 60 "${PANGOLIN_ENDPOINT_DEFAULT}" 3>&1 1>&2 2>&3); then
  PANGOLIN_ENDPOINT="${PANGOLIN_ENDPOINT:-$PANGOLIN_ENDPOINT_DEFAULT}"
else
  PANGOLIN_ENDPOINT="$PANGOLIN_ENDPOINT_DEFAULT"
fi

msg_info "Configuring Newt"
install -d -m 0755 /etc/newt

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
