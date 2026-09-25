#!/usr/bin/env bash
#####################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
#
# Checks that this machine can run the installer and sets DISTRO,
# UBUNTU_CODENAME and PHP_VERSION. Sourced by start.sh.
#####################################################

# Check the operating system. Set MULTIPOOL_SKIP_OS_CHECK=1 to install on an
# untested release at your own risk.
if [ -r /etc/os-release ]; then
	# shellcheck source=/dev/null
	OS_ID=$(. /etc/os-release && echo "${ID:-}")
	OS_VERSION_ID=$(. /etc/os-release && echo "${VERSION_ID:-}")
	UBUNTU_CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}")
	OS_PRETTY_NAME=$(. /etc/os-release && echo "${PRETTY_NAME:-unknown}")
fi

if [[ "${OS_ID:-}" != "ubuntu" || " ${MULTIPOOL_SUPPORTED_RELEASES} " != *" ${OS_VERSION_ID:-} "* ]]; then
	if [ -z "${MULTIPOOL_SKIP_OS_CHECK:-}" ]; then
		echo "The Ultimate Crypto-Server Setup Installer requires one of these Ubuntu LTS releases:"
		echo "  ${MULTIPOOL_SUPPORTED_RELEASES}"
		echo "This machine is running: ${OS_PRETTY_NAME:-unknown}"
		echo "Set MULTIPOOL_SKIP_OS_CHECK=1 to continue anyway (unsupported)."
		exit 1
	fi
	echo -e "${YELLOW}WARNING: ${OS_PRETTY_NAME:-unknown} is not a supported release. Continuing anyway.${COL_RESET}"
fi
DISTRO=${OS_VERSION_ID%%.*}

# PHP version to install (from ppa:ondrej/php). Keep the value from a
# previous run so re-running the installer never switches PHP underneath an
# existing install.
PHP_VERSION=${PHP_VERSION:-${DEFAULT_PHP_VERSION:-$MULTIPOOL_DEFAULT_PHP_VERSION}}
if ! [[ "$PHP_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
	echo "Invalid PHP_VERSION '${PHP_VERSION}', expected something like 8.3."
	exit 1
fi

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
	echo "Ultimate Crypto-Server Setup Installer only supports x86_64 and will not work on any other architecture, like ARM or 32 bit OS."
	echo "Your architecture is $ARCHITECTURE"
	exit 1
fi

# Check memory. Values from /proc/meminfo are in kB.
TOTAL_PHYSICAL_MEM=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
if [ "$TOTAL_PHYSICAL_MEM" -lt 1436000 ]; then
	echo "Your Crypto-Pool Server needs more memory (RAM) to function properly."
	echo "Please provision a machine with at least 1.5 GB, 4 GB or more recommended."
	echo "This machine has $((TOTAL_PHYSICAL_MEM / 1024)) MB memory."
	exit 1
fi

# Check swap
echo "Checking if swap space is needed and if so creating..."

SWAP_MOUNTED=$(tail -n+2 /proc/swaps)
SWAP_IN_FSTAB=$(grep -E '^[^#].*[[:space:]]swap[[:space:]]' /etc/fstab || true)
ROOT_IS_BTRFS=$(grep -E '^[^ ]+ / btrfs ' /proc/mounts || true)
AVAILABLE_DISK_SPACE=$(df / --output=avail | tail -n 1)
if
	[ -z "$SWAP_MOUNTED" ] &&
	[ -z "$SWAP_IN_FSTAB" ] &&
	[ ! -e /swapfile ] &&
	[ -z "$ROOT_IS_BTRFS" ] &&
	[ "$TOTAL_PHYSICAL_MEM" -lt 4096000 ] &&
	[ "$AVAILABLE_DISK_SPACE" -gt 10485760 ]
then
	echo "Adding a swap file to the system..."
	if sudo fallocate -l 3G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=3072 status=none; then
		sudo chmod 600 /swapfile
		hide_output sudo mkswap /swapfile
		sudo swapon /swapfile
	fi
	# Check if swap is mounted then activate on boot
	if swapon --show=NAME --noheadings | grep -qx "/swapfile"; then
		echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
		echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/90-multipool-swap.conf > /dev/null
		sudo sysctl -q -p /etc/sysctl.d/90-multipool-swap.conf
	else
		echo "ERROR: Swap allocation failed"
	fi
fi

# Set STORAGE_USER and STORAGE_ROOT to default values (crypto-data and /home/crypto-data), unless
# we've already got those values from a previous run.
if [ -z "${STORAGE_USER:-}" ]; then
	STORAGE_USER=${DEFAULT_STORAGE_USER:-crypto-data}
fi
if [ -z "${STORAGE_ROOT:-}" ]; then
	STORAGE_ROOT=${DEFAULT_STORAGE_ROOT:-/home/$STORAGE_USER}
fi
