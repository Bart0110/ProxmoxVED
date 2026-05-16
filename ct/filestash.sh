#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Bart0110/ProxmoxVED/main/misc/build.func)

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Bart0110
# License: MIT | https://github.com/Bart0110/ProxmoxVED/raw/main/LICENSE
# Source: https://www.filestash.app/

APP="Filestash"
var_tags="${var_tags:-bart0110-script;files;webdav}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
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

  if [[ ! -d /opt/filestash ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  CURRENT_COMMIT=$(git -C /opt/filestash rev-parse HEAD 2>/dev/null || echo "")
  LATEST_COMMIT=$(git ls-remote https://github.com/mickael-kerjean/filestash HEAD 2>/dev/null | awk '{print $1}')

  if [[ "$CURRENT_COMMIT" != "$LATEST_COMMIT" ]] && [[ -n "$LATEST_COMMIT" ]]; then
    msg_info "Stopping Service"
    systemctl stop filestash
    msg_ok "Stopped Service"

    msg_info "Updating Filestash"
    cd /opt/filestash
    git fetch origin master
    $STD git reset --hard origin/master

    $STD make init
    $STD make build
    chmod 751 /opt/filestash/dist/filestash

    cp /opt/filestash/dist/filestash /opt/filestash-run/

    msg_info "Starting Service"
    systemctl start filestash
    msg_ok "Started Service"
    msg_ok "Updated Successfully!"
  else
    msg_ok "No update required. Filestash is up-to-date."
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8334${CL}"
