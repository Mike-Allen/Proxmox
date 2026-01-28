#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/Mike-Allen/Proxmox/Localize/misc/build.func)
# Copyright (c) 2021-2024 tteck
# Author: tteck (tteckster)
# License: MIT
# https://github.com/Mike-Allen/Proxmox/raw/Localize/LICENSE

function header_info {
clear
cat <<"EOF"
   __  __      __  _                   __ __                     
  / / / /___  / /_(_)___ ___  ___     / //_/_  ______ ___  ____ _
 / / / / __ \/ __/ / __  __ \/ _ \   / ,< / / / / __  __ \/ __  /
/ /_/ / /_/ / /_/ / / / / / /  __/  / /| / /_/ / / / / / / /_/ / 
\____/ .___/\__/_/_/ /_/ /_/\___/  /_/ |_\__,_/_/ /_/ /_/\__,_/  
    /_/                                                          
 
EOF
}
header_info
echo -e "Loading..."
APP="Uptime Kuma"
var_disk="4"
var_cpu="1"
var_ram="1024"
var_os="debian"
var_version="12"
variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="yes"
  VERB="no"
  echo_default
}

function update_script() {
header_info
if [[ ! -d /opt/uptime-kuma ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  if [[ "$(node -v | cut -d 'v' -f 2)" == "18."* ]]; then
    if ! command -v npm >/dev/null 2>&1; then
      echo "Installing NPM..."
      apt-get install -y npm >/dev/null 2>&1
      echo "Installed NPM..."
    fi
  fi
LATEST=$(curl -sL https://api.github.com/repos/louislam/uptime-kuma/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
msg_info "Stopping ${APP}"
sudo systemctl stop uptime-kuma &>/dev/null
msg_ok "Stopped ${APP}"

cd /opt/uptime-kuma

# WDGIS - Jan 28, 2026
msg_info "Wahoo time!"
msg_info "Pulling ${APP} ${LATEST}"
# WDGIS - Jan 28, 2026 - added --tags
# git fetch --all --tags &>/dev/null
git fetch --all &>/dev/null
git checkout $LATEST --force &>/dev/null
msg_ok "Pulled ${APP} ${LATEST}"

msg_info "Updating ${APP} to ${LATEST}"
# WDGIS - Jan 28, 2026
# npm install --omit dev --no-audit
npm install --production &>/dev/null
npm run download-dist &>/dev/null
msg_ok "Updated ${APP}"

msg_info "Starting ${APP}"
sudo systemctl start uptime-kuma &>/dev/null
msg_ok "Started ${APP}"
msg_ok "Updated Successfully"
exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${APP} should be reachable by going to the following URL.
         ${BL}http://${IP}:3001${CL} \n"
