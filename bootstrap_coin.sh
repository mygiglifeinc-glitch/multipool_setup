#!/usr/bin/env bash
#########################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
# This script is intended to be ran from the multipool installer
#########################################################

source "$HOME/multipool/install/bootstrap_legacy.sh"
multipool_legacy_component "Daemon Builder" multipool_coin_builder \
	"$HOME/multipool/daemon_builder" "${DAEMON_BUILDER_REF:-v1.36}" install.sh
