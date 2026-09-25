#!/usr/bin/env bash
#########################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
# This script is intended to be ran from the multipool installer
#########################################################

# Branch or tag of multipool_yiimp_single to install.
YIIMP_SINGLE_REF="${YIIMP_SINGLE_REF:-master}"

multipool_fetch_repo multipool_yiimp_single "$HOME/multipool/yiimp_single" "$YIIMP_SINGLE_REF" || exit 1

# Start setup script.
cd "$HOME/multipool/yiimp_single" || exit 1
source start.sh
