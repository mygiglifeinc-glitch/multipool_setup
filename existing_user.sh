#!/usr/bin/env bash
#####################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
cd "$HOME/multipool/install" || exit 1
source user_setup.sh
clear

# Get logged in user name
whoami=$(id -un)
echo -e " Modifying existing user $whoami for multipool support."
multipool_grant_sudo "$whoami"
multipool_install_command
multipool_write_global_conf

sudo setfacl -m "u:${whoami}:rwx" "$HOME/multipool"
clear
echo -e " Your User has been modified for multipool support..."
echo -e "$RED You must reboot the system for the new permissions to update and type$COL_RESET $GREEN multipool$COL_RESET $RED to continue setup...$COL_RESET"
exit 0
