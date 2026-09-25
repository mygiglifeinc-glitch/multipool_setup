#!/usr/bin/env bash
#########################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
# This script is intended to be ran from the multipool installer
#########################################################

# Branch or tag of multipool_yiimp_multi to install.
YIIMP_MULTI_REF="${YIIMP_MULTI_REF:-master}"

multipool_fetch_repo multipool_yiimp_multi "$HOME/multipool/yiimp_multi" "$YIIMP_MULTI_REF" || exit 1

# Start setup script.
cd "$HOME/multipool/yiimp_multi" || exit 1
source start.sh
