#!/usr/bin/env bash
#########################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
# This script is intended to be ran from the multipool installer
#########################################################

source "$HOME/multipool/install/bootstrap_legacy.sh"
multipool_legacy_component "YiiMP Stratum Upgrade" multipool_yiimp_upgrade \
	"$HOME/multipool/yiimp_upgrade" "${YIIMP_UPGRADE_REF:-v1.08}" start.sh
