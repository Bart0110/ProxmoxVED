#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Bart0110/ProxmoxVED/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Bart0110
# License: MIT | https://github.com/Bart0110/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/fosrl/newt

APP="Pangolin-Newt"
var_tags="${var_tags:-bart0110-script;pangolin;vpn}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /etc/newt ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "newt" "fosrl/newt"; then
    msg_info "Stopping Service"
    systemctl stop newt
    msg_ok "Stopped Service"

    msg_info "Updating Newt Binary"
    rm -f /usr/local/bin/newt
    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "newt" "fosrl/newt" "singlefile" "latest" "/usr/local/bin" "newt_linux_*"
    msg_ok "Updated Newt Binary"

    msg_info "Starting Service"
    systemctl start newt
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Configure Newt using /etc/newt/newt.env${CL}"
