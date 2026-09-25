#!/usr/bin/env bash

#####################################################
# This is the entry point for configuring the system.
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
#####################################################

INSTALL_DIR="$HOME/multipool/install"
cd "$INSTALL_DIR" || exit 1

# Recall the last settings used if we're running this a second time.
FIRST_TIME_SETUP=""
if [ -f /etc/multipool.conf ]; then
	# Load the old .conf file to get existing configuration options loaded
	# into variables with a DEFAULT_ prefix.
	PREV_CONF=$(mktemp)
	sed 's/^/DEFAULT_/' /etc/multipool.conf > "$PREV_CONF"
	# shellcheck source=/dev/null
	source "$PREV_CONF"
	rm -f "$PREV_CONF"
else
	FIRST_TIME_SETUP=1
fi

# Always install the latest helper functions so that updates to this
# repository reach /etc/functions.sh and editconf.py.
source "$INSTALL_DIR/functions.sh"
sudo install -m 0644 "$INSTALL_DIR/functions.sh" /etc/functions.sh
sudo install -m 0755 "$INSTALL_DIR/editconf.py" /usr/local/bin/editconf.py
# Remove the copy older releases installed; /usr/local/bin is on the PATH.
sudo rm -f /usr/bin/editconf.py

# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files.
if ! locale -a 2>/dev/null | grep -qi '^en_US\.utf8$'; then
	# Generate locale if not exists
	hide_output sudo locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
export NCURSES_NO_UTF8_ACS=1

if [[ "$FIRST_TIME_SETUP" == "1" ]]; then
	clear

	# Check system setup: Are we running on a supported Ubuntu LTS release
	# on a machine with enough memory? If not, this shows an error and exits.
	source preflight.sh

	echo -e " Installing needed packages for setup to continue...$COL_RESET"
	hide_output sudo apt-get -q -q update
	apt_install dialog python3 acl nano git curl openssl ca-certificates openssh-client

	# Are we running as root?
	if [[ $EUID -ne 0 ]]; then
		# Welcome
		message_box "Ultimate Crypto-Server Setup Installer" \
			"Hello and thanks for using the Ultimate Crypto-Server Setup Installer!
			\n\nInstallation for the most part is fully automated. In most cases any user responses that are needed are asked prior to the installation.
			\n\nNOTE: You should only install this on a brand new Ubuntu ${MULTIPOOL_SUPPORTED_RELEASES// / or } LTS installation."
		source existing_user.sh
	else
		source create_user.sh
	fi
	exit
fi

clear

# Load our functions and variables.
source /etc/functions.sh
source /etc/multipool.conf

# Refresh DISTRO/UBUNTU_CODENAME/PHP_VERSION in case the OS was upgraded or
# this configuration was written by an older release of the installer.
source preflight.sh
write_conf_file -m 0644 -o root:root /etc/multipool.conf \
	STORAGE_USER STORAGE_ROOT PUBLIC_IP PUBLIC_IPV6 PRIVATE_IP DISTRO UBUNTU_CODENAME PHP_VERSION

# Start multipool
cd "$INSTALL_DIR" || exit 1
source menu.sh
echo
echo "-----------------------------------------------"
echo
echo "Thank you for using the Ultimate Crypto-Server Setup Installer!"
echo
echo "To run this installer anytime simply type, multipool!"
echo "Donations for continued support of this script are welcomed at:"
echo
echo "BTC 3DvcaPT3Kio8Hgyw4ZA9y1feNnKZjH7Y21"
echo "BCH qrf2fhk2pfka5k649826z4683tuqehaq2sc65nfz3e"
echo "ETH 0x6A047e5410f433FDBF32D7fb118B6246E3b7C136"
echo "LTC MLS5pfgb7QMqBm3pmBvuJ7eRCRgwLV25Nz"
cd ~ || exit
