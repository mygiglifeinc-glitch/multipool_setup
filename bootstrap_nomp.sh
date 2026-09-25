#!/usr/bin/env bash
#########################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
# This script is intended to be ran from the multipool installer
#########################################################

source "$HOME/multipool/install/bootstrap_legacy.sh"
multipool_legacy_component "NOMP Server" multipool_nomp \
	"$HOME/multipool/nomp" "${NOMP_REF:-v1.14}" start.sh
