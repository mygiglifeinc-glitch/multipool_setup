#!/usr/bin/env bash
#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh

RESULT=$(dialog --stdout --nocancel --default-item 1 --title "Ultimate Crypto-Server Setup Installer v3.0.0" --menu "Choose one" -1 60 16 \
	' ' "- YiiMP Server Install -" \
	1 "YiiMP Single Server" \
	2 "YiiMP Multi Server" \
	' ' "- YiiMP Upgrade -" \
	3 "YiiMP Stratum Upgrade (legacy)" \
	' ' "- NOMP Server Install -" \
	4 "NOMP Server (legacy)" \
	' ' "- MPOS Server Install -" \
	5 "MPOS Server - Coming Soon" \
	' ' "- CryptoNote Server Install -" \
	6 "CryptoNote-Nodejs Server - Coming Soon" \
	' ' "- Faucet Server Install -" \
	7 "Faucet Script - Coming Soon" \
	' ' "- Daemon Wallet Builder -" \
	8 "Daemonbuilder (legacy)" \
	9 Exit)

cd "$HOME/multipool/install" || exit 1
case "$RESULT" in
	1) clear; source bootstrap_single.sh ;;
	2) clear; source bootstrap_multi.sh ;;
	3) clear; source bootstrap_upgrade.sh ;;
	4) clear; source bootstrap_nomp.sh ;;
	8) clear; source bootstrap_coin.sh ;;
	5 | 6 | 7 | 9) clear; exit 0 ;;
	*) source menu.sh ;;
esac
