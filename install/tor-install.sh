#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Bart0110
# License: MIT | https://github.com/Bart0110/ProxmoxVED/raw/main/LICENSE
# Source: https://www.torproject.org/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Tor"
$STD apk add --no-cache tor tor-openrc
msg_ok "Installed Tor"

msg_info "Configuring Tor"
cat <<EOF >/etc/tor/torrc
# Tor configuration for ProxmoxVED LXC

# Drop root privileges to the native tor user
User tor

# Data directory
DataDirectory /var/lib/tor

# SOCKS proxy - Listen on all interfaces so the Proxmox host/other LXCs can use it
SocksPort 0.0.0.0:9050

# Control port (local only, no password)
ControlPort 127.0.0.1:9051

# Logging
Log notice syslog
EOF
msg_ok "Configured Tor"

msg_info "Enabling Service"
$STD rc-update add tor default
$STD rc-service tor start
msg_ok "Enabled Service"

motd_ssh
customize
cleanup_lxc
