#!/usr/bin/env bash
#####################################################
# Created by cryptopool.builders for crypto use...
#
# Steps shared by create_user.sh and existing_user.sh.
#####################################################

# Give USER passwordless sudo. The installer (and the YiiMP scripts it runs
# unattended, e.g. on remote servers) depends on this.
function multipool_grant_sudo {
	local user=$1 tmp
	sudo usermod -aG sudo "$user"
	tmp=$(mktemp)
	printf '# Added by the MultiPool installer, which needs passwordless sudo.\n%s ALL=(ALL) NOPASSWD:ALL\n' "$user" > "$tmp"
	if ! sudo visudo -cqf "$tmp"; then
		rm -f "$tmp"
		echo "Error: generated sudoers entry for ${user} is invalid." >&2
		exit 1
	fi
	sudo install -m 0440 -o root -g root "$tmp" "/etc/sudoers.d/multipool-${user}"
	# Older releases wrote /etc/sudoers.d/<user> with the wrong permissions.
	sudo rm -f "/etc/sudoers.d/${user}"
	rm -f "$tmp"
}

# Install the `multipool` command.
function multipool_install_command {
	local tmp
	tmp=$(mktemp)
	cat > "$tmp" <<'EOS'
#!/usr/bin/env bash
cd "$HOME/multipool/install" || { echo "MultiPool is not installed for $USER." >&2; exit 1; }
exec bash start.sh "$@"
EOS
	sudo install -m 0755 -o root -g root "$tmp" /usr/local/bin/multipool
	sudo rm -f /usr/bin/multipool
	rm -f "$tmp"
}

# Work out the IP addresses, create the storage user and save the global
# options in /etc/multipool.conf so that standalone tools know where to look
# for data.
function multipool_write_global_conf {
	cd "$HOME/multipool/install" || exit 1
	source pre_setup.sh

	# Create the STORAGE_USER and STORAGE_ROOT directory if they don't already exist.
	if ! id -u "$STORAGE_USER" >/dev/null 2>&1; then
		sudo useradd -m -d "$STORAGE_ROOT" "$STORAGE_USER"
	fi
	if [ ! -d "$STORAGE_ROOT" ]; then
		sudo mkdir -p "$STORAGE_ROOT"
	fi

	write_conf_file -m 0644 -o root:root /etc/multipool.conf \
		STORAGE_USER STORAGE_ROOT PUBLIC_IP PUBLIC_IPV6 PRIVATE_IP DISTRO UBUNTU_CODENAME PHP_VERSION
}
