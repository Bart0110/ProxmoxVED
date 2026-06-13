#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Bart0110/ProxmoxVED/main/misc/build.func)

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Bart0110
# License: MIT | https://github.com/Bart0110/ProxmoxVED/raw/main/LICENSE
# Source: https://www.torproject.org/

APP="Tor"
var_tags="${var_tags:-privacy;proxy;tor}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-alpine}"
var_version="${var_version:-3.23}"
var_arm64="${var_arm64:-no}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt ]] || [[ ! -f /etc/tor/torrc ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Checking for Tor updates"
  $STD apk update

  # Check if updates are available explicitly for tor or tor-openrc
  if apk version -l '<' | grep -qE '^(tor|tor-openrc)-'; then
    msg_info "Upgrading Tor dependencies"
    apk upgrade tor tor-openrc
    msg_ok "Upgraded Tor dependencies"
  else
    msg_ok "Tor and tor-openrc are already up to date!"
    exit
  fi

  msg_ok "Updated successfully!"
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} SOCKS proxy available at:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}socks5://${IP}:9050${CL}"
